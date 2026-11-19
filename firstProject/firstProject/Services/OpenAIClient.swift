import Foundation

/// OpenAI 호출에서 생길 수 있는 오류입니다.
enum OpenAIError: Error, Equatable {
    /// API 키가 설정되지 않았습니다.
    case missingAPIKey
    /// 네트워크 연결에 문제가 있어 요청을 보내지 못했습니다.
    case network
    /// 서버가 성공이 아닌 상태 코드를 돌려줬습니다. 상태 코드를 함께 담습니다.
    case http(statusCode: Int)
    /// AI가 내용 처리를 거부했습니다.
    case refused
    /// 응답을 읽을 수 없습니다.
    case invalidResponse
}

/// OpenAI Chat Completions API를 부르는 공통 클라이언트입니다.
///
/// 응답 형식을 JSON 스키마(`strict`)로 고정해, 받은 내용을 지정한 타입으로 바로 해석합니다.
/// AI 감정 추천과 AI 주간 분석이 함께 사용합니다.
struct OpenAIClient {
    private static let endpoint = "https://api.openai.com/v1/chat/completions"

    private let session: URLSession
    private let apiKey: String?

    /// 클라이언트를 만듭니다.
    ///
    /// - Parameters:
    ///   - session: 네트워크 요청에 쓸 세션. 테스트에서 바꿔 끼울 수 있습니다.
    ///   - apiKey: OpenAI API 키. 기본값은 앱 설정의 키입니다.
    init(session: URLSession = .shared, apiKey: String? = AppConfig.openAIAPIKey) {
        self.session = session
        self.apiKey = apiKey
    }

    /// 시스템 지시문과 사용자 입력을 보내고, 스키마에 맞는 응답을 `Output` 타입으로 받습니다.
    ///
    /// - Parameters:
    ///   - system: AI의 역할과 규칙을 적은 시스템 지시문.
    ///   - user: 분석할 사용자 입력.
    ///   - schemaName: 응답 JSON 스키마의 이름.
    ///   - schema: 응답이 따라야 할 JSON 스키마.
    ///   - timeout: 요청 제한 시간(초).
    /// - Returns: 응답을 `Output`으로 해석한 값.
    /// - Throws: `OpenAIError`(키 없음, 네트워크, HTTP 오류, 거부, 응답 해석 실패)와, 요청이 취소되었을 때의 `CancellationError`.
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

private struct ChatResponse: Decodable {
    struct Choice: Decodable {
        let message: Message
    }

    struct Message: Decodable {
        let content: String?
        let refusal: String?
    }

    let choices: [Choice]
}

extension OpenAIError {
    /// 사용자에게 보여 줄 안내 문구를 만듭니다.
    ///
    /// - Parameter feature: 문구에 넣을 기능 이름. 예: `추천`, `분석`
    /// - Returns: 오류 종류에 맞는 한국어 안내 문구.
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
