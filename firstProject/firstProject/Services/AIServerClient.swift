import FirebaseFunctions
import Foundation

/// AI 서버 요청 처리 중 발생할 수 있는 오류입니다.
enum AIServerError: Error, Equatable {
    /// 네트워크 연결에 실패했거나 제한 시간이 지났습니다.
    case network
    /// 요청이 너무 많습니다.
    case tooManyRequests
    /// 보낸 내용이 너무 깁니다.
    case tooLong
    /// AI가 내용을 처리하지 않겠다고 거절했습니다.
    case refused
    /// 서버가 이 앱을 진짜 Feelo 앱으로 확인하지 못했습니다.
    case unverifiedApp
    /// 서버에 문제가 있습니다.
    case server
    /// 응답을 해석할 수 없습니다.
    case invalidResponse
}

/// 서버에 보내는 요청 내용입니다.
nonisolated struct AIServerRequest: Encodable {
    /// AI가 읽을 내용입니다.
    let content: String
}

/// Firebase 서버의 AI 함수를 호출하는 클라이언트입니다.
///
/// OpenAI 키와 프롬프트는 서버에만 있고, 앱은 내용만 보내고 결과만 받습니다.
struct AIServerClient {
    /// 서버가 있는 지역입니다. (서울)
    private static let region = "asia-northeast3"

    /// 서버 함수를 호출하고, 응답을 `Output` 타입으로 바꿔 반환합니다.
    ///
    /// - Parameters:
    ///   - functionName: 호출할 서버 함수의 이름입니다.
    ///   - content: AI가 읽을 내용입니다.
    ///   - timeout: 요청 제한 시간(초)입니다.
    /// - Returns: 응답을 디코딩한 `Output` 값입니다.
    /// - Throws: 요청이 취소되면 `CancellationError`, 그 밖의 실패는 `AIServerError`를 던집니다.
    func send<Output: Decodable & Sendable>(
        functionName: String,
        content: String,
        timeout: TimeInterval
    ) async throws -> Output {
        let functions = Functions.functions(region: Self.region)
        var callable: Callable<AIServerRequest, Output> = functions.httpsCallable(functionName)
        callable.timeoutInterval = timeout

        do {
            let output = try await callable.call(AIServerRequest(content: content))
            try Task.checkCancellation()
            return output
        } catch {
            if Task.isCancelled {
                throw CancellationError()
            }
            throw Self.serverError(from: error)
        }
    }

    /// Firebase가 던진 오류를 `AIServerError`로 바꿉니다.
    ///
    /// - Parameter error: Firebase가 던진 오류입니다.
    /// - Returns: 오류에 해당하는 `AIServerError`입니다.
    private static func serverError(from error: Error) -> AIServerError {
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        guard nsError.domain == FunctionsErrorDomain,
              let code = FunctionsErrorCode(rawValue: nsError.code) else {
            return .invalidResponse
        }

        switch code {
        case .deadlineExceeded: return .network
        case .resourceExhausted: return .tooManyRequests
        case .invalidArgument: return .tooLong
        case .failedPrecondition: return .refused
        case .unauthenticated: return .unverifiedApp
        default: return .server
        }
    }
}

/// `AIServerError`를 사용자에게 보여줄 메시지로 바꾸는 확장입니다.
extension AIServerError {
    /// 오류에 해당하는 사용자용 한국어 안내 문구를 반환합니다.
    ///
    /// - Parameter feature: 문구에 넣을 기능 이름입니다. 예: "추천", "분석".
    /// - Returns: 사용자에게 보여줄 안내 문구입니다.
    func userMessage(for feature: String) -> String {
        switch self {
        case .network: "네트워크 연결을 확인하고 다시 시도해 주세요."
        case .tooManyRequests: "요청이 많아요. 잠시 후 다시 시도해 주세요."
        case .tooLong: "내용이 너무 길어서 \(feature)할 수 없어요."
        case .refused: "이 내용은 \(feature)할 수 없어요."
        case .unverifiedApp: "앱을 확인하지 못했어요. 앱을 다시 켜고 시도해 주세요."
        case .server: "\(feature) 서버에 문제가 있어요. 잠시 후 다시 시도해 주세요."
        case .invalidResponse: "\(feature) 결과를 읽지 못했어요. 다시 시도해 주세요."
        }
    }
}
