import Foundation

enum OpenAIError: Error, Equatable {
    case missingAPIKey
    case network
    case http(statusCode: Int)
    case refused
    case invalidResponse
}

struct OpenAIClient {
    private static let endpoint = "https://api.openai.com/v1/chat/completions"

    private let session: URLSession
    private let apiKey: String?

    init(session: URLSession = .shared, apiKey: String? = AppConfig.openAIAPIKey) {
        self.session = session
        self.apiKey = apiKey
    }

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
