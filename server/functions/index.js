const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { askOpenAI } = require("./openAI");
const { emotionPrompt, emotionSchema, weeklyPrompt, weeklySchema } = require("./prompts");

// Secret Manager에 저장한 OpenAI 키입니다. 코드에는 키를 적지 않습니다.
const openAIKey = defineSecret("OPENAI_API_KEY");

const options = {
  region: "asia-northeast3", // 서울
  secrets: [openAIKey],
  enforceAppCheck: true, // Feelo 앱이 보낸 요청이 아니면 거절합니다.
  maxInstances: 5, // 서버가 한 번에 늘어날 수 있는 최대 개수입니다.
  timeoutSeconds: 60,
};

// 앱은 회고를 500자까지 받지만, 이모지는 여기서 2글자 이상으로 세기도 해서 넉넉하게 둡니다.
const maxReflectionLength = 2000;
// 주간 분석은 한 주의 회고를 모두 모아 보냅니다.
const maxWeeklyLength = 20000;

// 회고 한 건을 읽고 어울리는 감정과 이유를 돌려줍니다.
exports.recommendEmotion = onCall(options, async (request) => {
  const content = checkContent(request.data, maxReflectionLength);
  return await askOpenAI(openAIKey.value(), {
    system: emotionPrompt,
    user: content,
    schemaName: "emotion_recommendation",
    schema: emotionSchema,
  });
});

// 한 주의 회고를 6가지 항목으로 정리해 돌려줍니다.
exports.analyzeWeek = onCall(options, async (request) => {
  const content = checkContent(request.data, maxWeeklyLength);
  return await askOpenAI(openAIKey.value(), {
    system: weeklyPrompt,
    user: content,
    schemaName: "weekly_reflection_analysis",
    schema: weeklySchema,
  });
});

// 앱이 보낸 내용이 비어 있거나 너무 길면 거절합니다.
function checkContent(data, maxLength) {
  if (!data || typeof data.content !== "string" || data.content.trim() === "") {
    throw new HttpsError("invalid-argument", "내용이 비어 있습니다.");
  }
  if (data.content.length > maxLength) {
    throw new HttpsError("invalid-argument", "내용이 너무 깁니다.");
  }
  return data.content;
}
