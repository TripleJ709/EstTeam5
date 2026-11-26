const { HttpsError } = require("firebase-functions/v2/https");

const endpoint = "https://api.openai.com/v1/chat/completions";
const model = "gpt-6-luna";
const timeoutMilliseconds = 50000;

// OpenAI에 요청을 보내고, 응답 JSON을 객체로 바꿔 돌려줍니다.
// 회고 내용이 서버 기록에 남지 않도록, 오류가 나도 본문은 출력하지 않습니다.
async function askOpenAI(apiKey, request) {
  const response = await sendRequest(apiKey, request);

  if (response.status === 429) {
    throw new HttpsError("resource-exhausted", "요청이 많습니다.");
  }
  if (!response.ok) {
    console.error("OpenAI 오류 코드:", response.status);
    throw new HttpsError("unavailable", "OpenAI 응답 오류입니다.");
  }

  const message = await readMessage(response);
  if (message.refusal) {
    throw new HttpsError("failed-precondition", "처리할 수 없는 내용입니다.");
  }
  return parseContent(message.content);
}

async function sendRequest(apiKey, request) {
  try {
    return await fetch(endpoint, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${apiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model: model,
        reasoning_effort: "none",
        messages: [
          { role: "system", content: request.system },
          { role: "user", content: request.user },
        ],
        response_format: {
          type: "json_schema",
          json_schema: { name: request.schemaName, strict: true, schema: request.schema },
        },
      }),
      signal: AbortSignal.timeout(timeoutMilliseconds),
    });
  } catch (error) {
    console.error("OpenAI 연결 실패:", error.name);
    throw new HttpsError("unavailable", "OpenAI에 연결하지 못했습니다.");
  }
}

async function readMessage(response) {
  try {
    const body = await response.json();
    return body.choices[0].message;
  } catch (error) {
    console.error("OpenAI 응답 읽기 실패:", error.name);
    throw new HttpsError("internal", "응답을 읽지 못했습니다.");
  }
}

function parseContent(content) {
  try {
    return JSON.parse(content);
  } catch (error) {
    console.error("OpenAI 응답 해석 실패:", error.name);
    throw new HttpsError("internal", "응답을 읽지 못했습니다.");
  }
}

module.exports = { askOpenAI };
