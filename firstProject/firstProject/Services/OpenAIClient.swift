import Foundation

/// OpenAI 요청 처리 중 발생할 수 있는 오류입니다.
enum OpenAIError: Error, Equatable {
    /// API 키가 설정되지 않았습니다.
    case missingAPIKey
    /// 네트워크 요청에 실패했습니다.
    case network
    /// HTTP 상태 코드가 200~299 범위를 벗어났습니다.
    ///
    /// - Parameter statusCode: 응답의 HTTP 상태 코드입니다.
    case http(statusCode: Int)
    /// 모델이 응답을 거부했습니다.
    case refused
    /// 응답을 해석할 수 없습니다.
    case invalidResponse
}

/// OpenAI Chat Completions API로 요청을 보내고 응답을 디코딩하는 클라이언트입니다.
struct OpenAIClient {
    /// 요청을 보낼 API 주소입니다.
    private static let endpoint = "https://api.openai.com/v1/chat/completions"

    /// 요청에 사용하는 `URLSession`입니다.
    private let session: URLSession
    /// 인증에 사용하는 API 키이며, 없으면 요청 시 `missingAPIKey` 오류가 발생합니다.
    private let apiKey: String?

    /// 클라이언트를 생성합니다.
    ///
    /// - Parameters:
    ///   - session: 요청에 사용할 세션입니다. 기본값은 `.shared`입니다.
    ///   - apiKey: 인증에 사용할 API 키입니다. 기본값은 `AppConfig.openAIAPIKey`입니다.
    init(session: URLSession = .shared, apiKey: String? = AppConfig.openAIAPIKey) {
        self.session = session
        self.apiKey = apiKey
    }

    /// 시스템·사용자 메시지를 보내고, 구조화된 JSON 응답을 `Output` 타입으로 디코딩해 반환합니다.
    ///
    /// `json_schema` 형식(`strict: true`)으로 응답 구조를 지정하며, 네트워크 취소(`URLError.cancelled`)는 `CancellationError`로 전달합니다.
    ///
    /// - Parameters:
    ///   - system: 시스템 메시지입니다.
    ///   - user: 사용자 메시지입니다.
    ///   - schemaName: 응답 스키마 이름입니다.
    ///   - schema: 응답 형식을 지정하는 JSON 스키마입니다.
    ///   - timeout: 요청 타임아웃(초)입니다.
    /// - Returns: 응답 본문을 디코딩한 `Output` 값입니다.
    /// - Throws: API 키가 없으면 `missingAPIKey`, 네트워크 실패 시 `network`, 상태 코드가 200~299가 아니면 `http`, 거부 응답이면 `refused`, 해석 실패 시 `invalidResponse`를 던집니다. 요청이 취소되면 `CancellationError`를 던집니다.
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

    /// 요청 본문과 헤더를 설정한 `URLRequest`를 만듭니다.
    ///
    /// POST 방식이며 `Authorization`(Bearer)과 `Content-Type`(application/json) 헤더를 설정합니다.
    ///
    /// - Parameters:
    ///   - body: JSON으로 직렬화할 요청 본문입니다.
    ///   - timeout: 요청 타임아웃(초)입니다.
    /// - Returns: 구성된 `URLRequest`입니다.
    /// - Throws: API 키가 없으면 `missingAPIKey`, URL 생성이나 본문 직렬화에 실패하면 `invalidResponse`를 던집니다.
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

    /// 응답 데이터를 해석해 `Output` 타입으로 디코딩합니다.
    ///
    /// 첫 번째 choice의 메시지에서 `refusal`이 있으면 거부로 처리하고, 없으면 `content`를 JSON으로 디코딩합니다. 키는 snake_case를 camelCase로 변환합니다.
    ///
    /// - Parameter data: 응답 본문 데이터입니다.
    /// - Returns: 디코딩된 `Output` 값입니다.
    /// - Throws: 거부 응답이면 `refused`, 응답 구조나 내용을 디코딩할 수 없으면 `invalidResponse`를 던집니다.
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

/// Chat Completions 응답 중 필요한 부분만 담는 디코딩용 모델입니다.
private struct ChatResponse: Decodable {
    /// 응답의 선택지 하나입니다.
    struct Choice: Decodable {
        /// 선택지에 담긴 메시지입니다.
        let message: Message
    }

    /// 응답 메시지입니다.
    struct Message: Decodable {
        /// 메시지 본문이며, 없을 수 있습니다.
        let content: String?
        /// 모델이 거부한 경우의 거부 내용이며, 없을 수 있습니다.
        let refusal: String?
    }

    /// 응답의 선택지 목록입니다.
    let choices: [Choice]
}

/// `OpenAIError`에 사용자에게 보여줄 메시지 변환을 추가합니다.
extension OpenAIError {
    /// 오류 종류에 맞는 사용자용 안내 문구를 반환합니다.
    ///
    /// 상태 코드 401, 429는 별도 문구를 쓰고, 그 외 상태 코드는 오류 코드를 포함한 문구를 반환합니다.
    ///
    /// - Parameter feature: 문구에 들어가는 기능 이름입니다.
    /// - Returns: 사용자에게 보여줄 한국어 안내 문구입니다.
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
