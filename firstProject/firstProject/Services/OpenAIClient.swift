import Foundation

/// OpenAI 요청 처리 중 발생할 수 있는 오류입니다.
enum OpenAIError: Error, Equatable {
    /// API 키가 설정되지 않았습니다.
    case missingAPIKey
    /// 네트워크 요청이 실패했습니다. (취소된 경우는 제외)
    case network
    /// 응답의 HTTP 상태 코드가 2xx 범위가 아닙니다.
    ///
    /// - Parameter statusCode: 응답의 HTTP 상태 코드입니다.
    case http(statusCode: Int)
    /// 응답 메시지에 거절(refusal) 값이 들어 있습니다.
    case refused
    /// 응답이 HTTP 응답이 아니거나, 요청 생성 또는 응답 해석에 실패했습니다.
    case invalidResponse
}

/// OpenAI Chat Completions API를 호출하는 클라이언트입니다.
struct OpenAIClient {
    /// 요청을 보내는 Chat Completions 엔드포인트 주소입니다.
    private static let endpoint = "https://api.openai.com/v1/chat/completions"

    /// 네트워크 요청에 사용하는 `URLSession`입니다.
    private let session: URLSession
    /// 요청의 Authorization 헤더에 사용하는 API 키입니다. 없으면 요청 생성 시 `OpenAIError.missingAPIKey`를 던집니다.
    private let apiKey: String?

    /// 클라이언트를 생성합니다.
    ///
    /// - Parameters:
    ///   - session: 요청에 사용할 세션입니다. 기본값은 `.shared`입니다.
    ///   - apiKey: 사용할 API 키입니다. 기본값은 `AppConfig.openAIAPIKey`입니다.
    init(session: URLSession = .shared, apiKey: String? = AppConfig.openAIAPIKey) {
        self.session = session
        self.apiKey = apiKey
    }

    /// 시스템·사용자 메시지와 JSON 스키마를 보내고, 응답을 `Output` 타입으로 디코딩해 반환합니다.
    ///
    /// `AppConfig.openAIModel` 모델에 `reasoning_effort`를 `none`으로, 응답 형식을 `json_schema`(strict)로 지정해서 요청합니다.
    /// 요청이 취소되면 `CancellationError`를 던지고, 그 외 전송 오류는 `OpenAIError.network`로 바꿔 던집니다.
    ///
    /// - Parameters:
    ///   - system: 시스템 메시지로 보낼 지시문입니다.
    ///   - user: 사용자 메시지로 보낼 내용입니다.
    ///   - schemaName: JSON 스키마의 이름입니다.
    ///   - schema: 응답이 따라야 하는 JSON 스키마입니다.
    ///   - timeout: 요청 제한 시간(초)입니다.
    /// - Returns: 응답 내용을 디코딩한 `Output` 값입니다.
    /// - Throws: API 키가 없으면 `OpenAIError.missingAPIKey`, 전송 실패 시 `OpenAIError.network`,
    ///   HTTP 상태 코드가 2xx가 아니면 `OpenAIError.http(statusCode:)`, 응답을 해석할 수 없으면 `OpenAIError.invalidResponse`,
    ///   거절 응답이면 `OpenAIError.refused`, 요청이 취소되면 `CancellationError`를 던집니다.
    func send<Output: Decodable>(
        system: String,
        user: String,
        schemaName: String,
        schema: [String: Any],
        timeout: TimeInterval
    ) async throws -> Output {
        let body: [String: Any] = [
            "model": AppConfig.openAIModel,
            "reasoning_effort": "none",
            "messages": [
                ["role": "system", "content": system],
                ["role": "user", "content": user]
            ],
            "response_format": [
                "type": "json_schema",
                "json_schema": ["name": schemaName, "strict": true, "schema": schema]
            ]
        ]
        let request = try makeRequest(body: body, timeout: timeout)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError where error.code == .cancelled {
            throw CancellationError()
        } catch {
            throw OpenAIError.network
        }

        guard let http = response as? HTTPURLResponse else { throw OpenAIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else { throw OpenAIError.http(statusCode: http.statusCode) }
        return try Self.parse(data)
    }

    /// POST 요청(`URLRequest`)을 만듭니다.
    ///
    /// Authorization(Bearer)과 Content-Type(application/json) 헤더를 설정하고, `body`를 JSON으로 직렬화해서 본문에 담습니다.
    ///
    /// - Parameters:
    ///   - body: JSON으로 직렬화할 요청 본문입니다.
    ///   - timeout: 요청 제한 시간(초)입니다.
    /// - Returns: 전송 준비가 끝난 요청입니다.
    /// - Throws: API 키가 없으면 `OpenAIError.missingAPIKey`, URL 생성이나 본문 직렬화에 실패하면 `OpenAIError.invalidResponse`를 던집니다.
    private func makeRequest(body: [String: Any], timeout: TimeInterval) throws -> URLRequest {
        guard let apiKey else { throw OpenAIError.missingAPIKey }
        guard let url = URL(string: Self.endpoint),
              let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            throw OpenAIError.invalidResponse
        }

        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = bodyData
        return request
    }

    /// 응답 데이터에서 첫 번째 choice의 메시지 content를 꺼내 `Output`으로 디코딩합니다.
    ///
    /// snake_case 키를 camelCase로 변환하는 디코더를 사용합니다.
    ///
    /// - Parameter data: API가 반환한 응답 본문입니다.
    /// - Returns: 메시지 content를 디코딩한 `Output` 값입니다.
    /// - Throws: 응답 구조나 content를 디코딩할 수 없으면 `OpenAIError.invalidResponse`, 메시지에 refusal이 있으면 `OpenAIError.refused`를 던집니다.
    private static func parse<Output: Decodable>(_ data: Data) throws -> Output {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let message = try? decoder.decode(ChatResponse.self, from: data).choices.first?.message else {
            throw OpenAIError.invalidResponse
        }
        if message.refusal != nil { throw OpenAIError.refused }
        guard let payload = message.content?.data(using: .utf8),
              let output = try? decoder.decode(Output.self, from: payload) else {
            throw OpenAIError.invalidResponse
        }
        return output
    }
}

/// Chat Completions 응답 중 사용하는 부분만 담은 디코딩용 모델입니다.
private struct ChatResponse: Decodable {
    /// 응답의 선택지 하나입니다.
    struct Choice: Decodable {
        /// 선택지의 메시지입니다.
        let message: Message
    }

    /// 선택지 메시지의 내용입니다.
    struct Message: Decodable {
        /// 메시지 본문입니다. 없을 수 있습니다.
        let content: String?
        /// 거절 사유입니다. 값이 있으면 요청이 거절된 것입니다.
        let refusal: String?
    }

    /// 응답에 포함된 선택지 목록입니다.
    let choices: [Choice]
}

/// `OpenAIError`를 사용자에게 보여줄 메시지로 바꾸는 확장입니다.
extension OpenAIError {
    /// 오류에 해당하는 사용자용 한국어 안내 문구를 반환합니다.
    ///
    /// 상태 코드 401과 429는 각각 전용 문구를 사용하고, 그 밖의 HTTP 오류는 오류 코드를 포함한 문구를 사용합니다.
    ///
    /// - Parameter feature: 문구에 넣을 기능 이름입니다. 예: "추천", "분석".
    /// - Returns: 사용자에게 보여줄 안내 문구입니다.
    func userMessage(for feature: String) -> String {
        switch self {
        case .missingAPIKey: "API 키가 설정되지 않아 \(feature)을 받을 수 없어요."
        case .network: "네트워크 연결을 확인하고 다시 시도해 주세요."
        case .http(statusCode: 401): "API 키가 올바르지 않아요."
        case .http(statusCode: 429): "요청이 많아요. 잠시 후 다시 시도해 주세요."
        case .http(let statusCode): "\(feature) 서버에 문제가 있어요. (오류 코드 \(statusCode))"
        case .refused: "이 내용은 \(feature)할 수 없어요."
        case .invalidResponse: "\(feature) 결과를 읽지 못했어요. 다시 시도해 주세요."
        }
    }
}
