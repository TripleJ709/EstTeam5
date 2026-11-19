# Feelo — 감정 회고 앱 프로젝트 (오졌조)

> **💡 프로젝트 한 줄 요약**  
> 오늘의 회고를 짧은 글로 기록하고 7가지 감정 색(아우라)으로 남겨, 한 달과 한 주의 감정 흐름을 달력과 통계로 한눈에 확인하는 iOS 앱

## 📌 1. 프로젝트 개요

* **진행 단계:** 핵심 기능 구현 완료, 다듬기 단계 (3일차, 2026.11.18 기준)
* **개발 기간:** `2026.11.16 (월)` ~ `2026.11.22 (일)` (1주)
* **해결할 문제:** 본인의 주간·월간 감정 변화와 회고 기록을 직관적인 색의 흐름으로 한눈에 파악하고 싶은 니즈 해결
* **대상 사용자:** 짧게 **글로 회고**하고, AI의 도움을 받아 오늘의 감정을 정리하며 자신의 감정 흐름을 돌아보고 싶은 사용자 *(※ 음성 입력 기능은 개발 일정상 제외)*
* **기술 스택:** Swift, SwiftUI, SwiftData, `@AppStorage`, OpenAI Chat Completions API (외부 라이브러리 없음)
* **지원 환경:** iOS 17.0 이상 / iPhone 세로 모드 / 한국어 / 라이트·다크 모드 / Dynamic Type 대응
* **필수 구현 핵심 기능 3가지**
  1. 회고록 작성·편집·삭제와 감정 색상 표시 (텍스트 기반 CRUD)
  2. 회고 저장과 감정 색 달력 (월간 캘린더에 날짜별 감정 컬러 표시)
  3. 기간별 통계 표시 (월별·주간 회고 건수와 감정 분포 시각화)

## 👥 2. 팀원 소개 및 역할 분담

* **분담 원칙:** 보이는 영역(UI)과 보이지 않는 영역(로직)으로 크게 나누고, 세부 작업이 나오면 유동적으로 분배
* **협업 환경:** GitHub 저장소와 브랜치 규칙 합의, `feature` 브랜치에서 작업한 뒤 Pull Request로 `develop`에 병합, Figma 팀원 4명 전원 가입

| 이름 | 역할 | 담당 파트 | 3일차까지 한 일 |
| :--- | :---: | :---: | :--- |
| **장주진** | 팀장 | 로직 / 총괄 | • 저장소 관리, PR 병합과 코드 리뷰<br>• 프로젝트 뼈대, SwiftData 모델, `xcconfig` 기반 API 키 설정<br>• 회고 작성 로직 분리(`RetrospectiveDraft`), OpenAI 감정 추천(`EmotionRecommender`)과 작성 화면 연결<br>• 온보딩 화면, 회고 탭 상태별 화면 Figma 적용<br>• Dynamic Type 대응, 설정·테마 선택(라이트·다크 색상 에셋)<br>• 코드 정리: 디버그 코드·주석 제거, Models 폴더 구조 정리, OpenAI 호출 공통화(`OpenAIClient`)<br>• 감정 아우라 이미지 에셋 적용 |
| **백충훈** | 팀원 | 로직 / 통계 | • 월간 감정 달력(`CalendarView`), 회고 작성 시트와 상세 화면 구현<br>• 통계 탭 초기 구현, `EmotionWash` 등 디자인 컴포넌트<br>• 달력·통계 계산을 `Retrospective` 확장으로 분리<br>• 감정 조사 처리 정리, 미사용 화면 삭제, Models 코드 흐름 파악 |
| **임사랑** | 팀원 | UI / 문서화 | • 회고 목록 네비게이션과 초기 화면 구성, Figma-MCP 연결<br>• 통계 화면을 Figma 디자인대로 구현 (막대 그래프, 한마디 카드, 빈 상태, 배경 오라)<br>• 통계 로직을 Models로 분리 (팀장 코드 리뷰 반영)<br>• 주간 AI 회고 리포트(6단계) 구현 <br>• 회의록·`README.md` 정리, 발표 자료(PPT) |
| **전효정** | 팀원 | UI / 디자인 | • Figma 전체 화면 UI/UX 디자인과 작업 분배 기획<br>• 감정 색 이모티콘·표정 디자인, 감정 아우라 이미지 에셋 제작과 앱 적용<br>• 발표 자료(PPT) |

> 위 내용은 GitHub 커밋·PR 기록과 회의록을 바탕으로 정리했습니다. 개인별 표현은 팀원 확인 후 확정합니다.

## ✨ 3. 핵심 기능 및 구현 현황

### 1⃣ 온보딩 (`WelcomeView`)
* 7가지 감정 아우라 구슬 배치와 브랜드 소개(*"오늘의 감정을 색으로 남겨요"*) 첫 실행 화면
* 첫 실행 이후에는 건너뛰고 바로 메인 화면으로 진입 (`hasSeenWelcome`)

### 2⃣ 회고 작성·편집·삭제 (CRUD) 및 7가지 감정 선택 (`RetrospectiveWriteView`)
* 날짜 선택(오늘까지, 과거 날짜 작성 가능), 500자 이내 텍스트 회고 작성·편집·삭제
* 선택한 감정에 따라 상단 배경에 아우라 워시(`EmotionWash`) 적용
* 오늘의 대표 감정을 **7가지 감정 분류** 중에서 선택

| 번호 | 상위 감정 개념 | 포함 세부 감정 키워드 |
| :---: | :--- | :--- |
| **1** | **기쁨** | 즐거움, 행복, 설렘, 신난다, 고맙다 |
| **2** | **성취** | 뿌듯하다, 보람차다, 만족하다, 자신있다 |
| **3** | **안정** | 평안하다, 평온하다, 안도함, 무난하다 |
| **4** | **분노** | 화남, 불쾌하다, 짜증나다, 답답하다, 억울하다 |
| **5** | **두려움** | 불안하다, 걱정함, 초조하다, 긴장된다 |
| **6** | **슬픔** | 우울하다, 아쉽다, 서운하다, 외롭다, 허무하다 |
| **7** | **소진** | 피곤하다, 무기력하다, 번아웃, 지쳤다 |

### 3⃣ 월간 감정 달력 및 일별 회고 조회 (`회고` 탭)
* SwiftData로 회고를 기기에 영구 저장
* 월간 달력(`CalendarView`)에 날짜별 감정 아우라 표시, 앱 시작일 이후 미기록 날짜는 점선으로 표시
* 같은 날 여러 건을 기록하면 가장 최근에 쓴 감정을 달력에 반영하고, 하단 카드 목록에서 전체 내역 확인
* 날짜 상태(첫 사용·오늘·과거·미래)별 빈 화면 안내(`EmptyDayCard`), 상세 화면(`RetrospectiveDetailView`)에서 편집·삭제
* 화면 상단 설정(톱니바퀴) 버튼으로 **테마 선택(시스템 / 라이트 / 다크)**

### 4⃣ AI 감정 추천 (`EmotionRecommender`)
* 회고 본문을 쓴 뒤 **'AI로 감정 추천받기'** 버튼을 누르면 7가지 감정 중 가장 어울리는 감정 하나를 추천
* 추천받은 감정은 사용자가 직접 다른 감정으로 바꿀 수 있음 *(AI 추천 전용으로 둘지는 논의 중)*
* API 키 없음, 네트워크 오류, HTTP 오류, 응답 거부 등 경우별 안내 문구 제공

### 5⃣ 주간·월간 감정 통계 (`통계` 탭)
* **주간 / 월간** 전환과 이전·다음 기간 이동 (주간은 일~토 기준)
* 기간 내 기록 건수와 가장 많이 기록한 감정 요약 카드
* **감정 분포 막대 그래프:** 7가지 감정을 항상 표시하고, 기록이 없는 감정은 흐리게 표시
* **한마디 카드:** 가장 많이 기록한 감정에 맞춰 주간·월간 문구를 보여줌 (감정별로 미리 정한 고정 문구)
* 가장 많이 기록한 감정 색으로 화면 배경 표현
* 기록이 없는 기간에는 안내 카드 표시
* **AI 주간 회고 리포트 (주간 탭):** 버튼을 누르면 그 주의 회고를 AI가 읽고 정리
  * 앱이 먼저 계산한 기록 건수, 감정 분포, 요일별 감정 흐름을 AI에 함께 전달해, 숫자와 대표 감정은 앱 계산값을 그대로 사용
  * 결과 6단계: **일어난 일 / 마음의 흐름 / 좋았던 순간 / 마음 쓰인 일 / 작은 힌트 / 이번 주 한줄**

## 🎨 4. 화면 및 폴더 구조

* **하단 탭바 구성 (2개 탭):** `회고` / `통계` *(회의에서 `달력` / `기록`으로 바꾸기로 했고, 코드 반영 예정)*

| 화면 | 파일명 | 주요 역할 |
| :--- | :--- | :--- |
| 온보딩 | `Views/Onboarding/WelcomeView.swift` | 앱 소개 및 7색 감정 아우라 첫 실행 화면 |
| 회고(달력)·목록 | `Views/Retrospective/RetrospectiveListView.swift`<br>`Views/Calendar/CalendarView.swift` | 월별 감정 달력, 선택 날짜 회고 카드 목록, 테마 선택 |
| 회고 작성·편집 | `Views/Retrospective/RetrospectiveWriteView.swift` | 날짜·감정 선택, 500자 입력, AI 감정 추천 |
| 회고 상세 | `Views/Retrospective/RetrospectiveDetailView.swift` | 회고 전문 열람, 편집 시트 및 삭제 확인 |
| 통계 | `Views/Statistics/StatisticsView.swift` | 주간/월간 전환, 요약 카드, 분포 그래프, 한마디, AI 리포트 |
| 통계 구성 요소 | `Views/Statistics/` 안의 `EmotionBarChart`, `StatisticsFeedbackCard`, `StatisticsEmptyState`, `WeeklyAIReportSection` | 막대 그래프, 한마디 카드, 빈 상태, AI 주간 리포트 |
| 디자인 | `Views/Design/EmotionAuraView.swift`, `Assets.xcassets` | 아우라 컴포넌트, 라이트·다크 색상과 감정 이미지 에셋 |

```text
firstProject/
├── App/          # 앱 진입점(firstProjectApp), 탭 구성(MainTabView)
├── Models/
│   ├── Emotion/        # Emotion 열거형, 감정별 한마디, 조사 처리
│   ├── Retrospective/  # SwiftData 모델, 달력·통계용 확장, 작성 드래프트
│   └── Statistics/     # 기간(StatisticsPeriod), 주간 AI 입력·결과·상태
├── Services/     # OpenAI 호출(OpenAIClient), 감정 추천, 주간 분석, 설정(AppConfig)
└── Views/        # Onboarding, Calendar, Retrospective, Statistics, Settings, Design
```

### 구조 원칙
* 화면(`Views`)에는 표시 코드만 두고, 집계·날짜 계산·AI 요청 같은 로직은 `Models`와 `Services`에 둠
* OpenAI 호출은 `OpenAIClient` 하나로 모아 감정 추천과 주간 분석이 함께 사용

## 🎬 5. 시연 (작성 → 조회 → 통계)

주요 흐름을 짧은 화면 녹화로 보여 줍니다.

| 흐름 | 보여 주는 내용 | 화면 |
| :--- | :--- | :---: |
| **작성** | 회고 쓰기, 감정 선택, AI 감정 추천 | <!-- ![작성](docs/media/01-write.gif) -->촬영 후 추가 |
| **조회** | 달력에서 날짜 선택, 상세 보기, 편집·삭제 | <!-- ![조회](docs/media/02-browse.gif) -->촬영 후 추가 |
| **통계** | 주간·월간 전환, 감정 분포, 한마디, AI 주간 리포트 | <!-- ![통계](docs/media/03-statistics.gif) -->촬영 후 추가 |

> 영상 파일은 `docs/media/` 폴더에 넣고, 위 표의 주석을 풀어 연결합니다.

## 📖 6. API 문서

코드의 공개 API는 Swift 문서화 주석(`///`)으로 설명되어 있습니다. 한국어로 요약, 매개변수(`Parameters`), 반환값(`Returns`), 오류(`Throws`)를 적었습니다.

* **Xcode에서 보기:** 코드를 `Option` + 클릭하면 Quick Help에 설명이 나옵니다.
* **문서 만들기:** Xcode 메뉴 `Product` → `Build Documentation` (`⌃⇧⌘D`)을 누르면 DocC 문서가 생성됩니다.
* **터미널에서 만들기:**
  ```bash
  xcodebuild docbuild -project firstProject/firstProject.xcodeproj -scheme firstProject \
    -destination 'generic/platform=iOS Simulator'
  ```

| 영역 | 문서화한 주요 API |
| :--- | :--- |
| `Models/Emotion` | `Emotion` (감정 7종, 이름, 아우라 색), 주간·월간 한마디, 조사 |
| `Models/Retrospective` | `Retrospective`, `RetrospectiveDraft`, 같은 날 최신 회고·최다 감정·월 요약, 기간 필터와 감정별 집계 |
| `Models/Statistics` | `StatisticsPeriod`, `EmotionCount`, `WeeklyReflectionInput`, `WeeklyReflectionAnalysis`, `WeeklyAnalysisStore` |
| `Services` | `OpenAIClient`, `OpenAIError`, `WeeklyReflectionAnalyzer`, `AppConfig` |
| `Views` | 화면별 역할과 입력 값 |

## ▶️ 7. 설치 및 실행 방법

### 필요 환경
| 항목 | 내용 |
| :--- | :--- |
| 개발 환경 | macOS, Xcode 27.2 (개발에 사용한 버전) |
| 지원 기기 | iPhone (세로 모드), iOS 17.0 이상 |
| 언어 | Swift 5, SwiftUI |
| 외부 서비스 | OpenAI API 키 (AI 기능 사용 시에만 필요) |

### 설치 순서
1. 저장소를 내려받습니다.
   ```bash
   git clone https://github.com/TripleJ709/EstTeam5.git
   cd EstTeam5
   git checkout develop
   ```
2. `firstProject/Config/Secrets.example.xcconfig`를 같은 폴더에 `Secrets.xcconfig`라는 이름으로 복사합니다.
3. `Secrets.xcconfig` 안의 `OPENAI_API_KEY` 값을 본인의 키로 바꿉니다. (따옴표 없이 입력)
4. Xcode에서 `firstProject/firstProject.xcodeproj`를 열고 iPhone 시뮬레이터를 골라 실행(⌘R)합니다.

### 참고
* `Secrets.xcconfig`는 `.gitignore`에 포함되어 GitHub에 올라가지 않습니다. 키는 저장소에 올리지 마세요.
* API 키가 없어도 앱은 실행됩니다. AI 감정 추천과 AI 주간 리포트만 안내 문구와 함께 동작하지 않고, 나머지 기능은 그대로 사용할 수 있습니다.
* AI 기능을 쓰면 회고 본문이 분석을 위해 OpenAI 서버로 전송됩니다.

## 📦 8. 의존 라이브러리

* **외부 라이브러리 없음.** Swift Package Manager, CocoaPods, Carthage를 쓰지 않고 Apple 기본 프레임워크만 사용합니다.

| 프레임워크 | 용도 |
| :--- | :--- |
| `SwiftUI` | 모든 화면 구성 |
| `SwiftData` | 회고(`Retrospective`) 영구 저장 |
| `Observation` | 주간 AI 분석 상태 관리(`@Observable`) |
| `Foundation` | 날짜 계산, 네트워크(`URLSession`), JSON 처리 |

* 외부 API: OpenAI Chat Completions (`json_schema` strict 모드로 응답 형식 고정)

## 📝 9. 회의 기록 요약

### 킥오프 (11/16)
* 앱 이름 **Feelo** 확정, 개발 기간 1주, 핵심 기능 3가지 확정
* 파트 분담: UI(전효정, 임사랑) / 로직(장주진, 백충훈), 산출물(PPT, README) 담당 지정
* GitHub 저장소 생성과 브랜치 규칙 합의, Figma 팀원 전원 가입

### 1일차
* **진행:** 회고 작성 뷰와 로직 분리, GPT API 연동(감정 추천), 회고 탭 네비게이션, 초기 회고·통계 레이아웃, Figma 디자인
* **논의:** AI로 추천받은 감정을 사용자가 직접 바꿀 수 있게 둘지, AI 추천 전용으로 할지 결정 필요
* **수정 사항**
  1. Month Navigation 우측 패딩, Title and Subtitle 간격을 4로 통일
  2. 카테고리/태그 기능과 세부 화면 삭제
  3. 통계 설정 탭 삭제, 가장 많이 쓴 감정 색을 배경 그라데이션 원으로 표시
  4. 감정 분포 그래프를 막대 그래프로 변경, 그래프 아래에 가장 많은 감정에 맞는 칭찬·위로 문구 추가
  5. 회고 탭 상단 설정 버튼을 톱니바퀴 아이콘으로 통일
  6. 새 회고 화면에 'AI로 감정 추천받기' 버튼과 AI 아이콘 추가
  7. 하단 탭 이름 변경: 회고 → 달력, 통계 → 기록
* **튜터 피드백:** 기본 기능 완성도를 먼저 높이고 시간이 남으면 WBS와 추가 기능 고민, 사용자가 느낄 가치를 고객 관점에서 설계, 모닝 스크럼(어제 한 일 · 오늘 할 일 · 고민) 공유 권장, 감정 분포는 막대 그래프와 공감 문구 제공

### 2일차
* **진행:** Dynamic Type·다크 모드 적용, Models 코드 흐름 파악, Figma-MCP 연결과 통계 화면 구현, 주간·월간 AI 분석 작업, 감정 이모티콘·표정 디자인
* **코드 리뷰 논의**
  * `topEmotion`을 아직 배우지 않은 키패스 대신 `for`와 `if`로 풀어 쓰기
  * 회고 500자 제한이 필요한지 (현재는 유지)
  * 과거 날짜 회고 작성을 허용할지 (현재는 과거 날짜 작성 가능, 미래 날짜만 제한)
  * 색상을 에셋으로 옮긴 뒤 `FeeloTokens.swift`가 필요한지 (현재는 삭제하고 에셋 색 사용)

### 3일차 (11/19)
* 회의록에 별도 내용이 없어 Git 기록 기준으로 정리
* **진행:** Models 폴더를 주제별로 정리, OpenAI 호출을 `OpenAIClient` 하나로 공통화, 날짜·로케일 도우미 중복 제거, 코드 가독성 정리, 색상 토큰을 에셋 색으로 교체, 감정 아우라 이미지 에셋 추가와 적용, 통계 화면과 주간 AI 리포트 병합

## 🔧 10. 피드백 반영 현황 및 추후 계획

* [x] 카테고리/태그 및 통계 설정 버튼 제거
* [x] 감정 분포 막대 그래프, 최다 감정 색 배경, 감정별 한마디 카드
* [x] 다크 모드 색상 에셋과 테마 선택, Dynamic Type 대응
* [x] 회고 탭 설정 버튼 톱니바퀴, 'AI로 감정 추천받기' 버튼과 아이콘
* [x] 감정 색 이미지 에셋 적용
* [x] `topEmotion`을 `for`/`if`로 정리, `FeeloTokens.swift` 삭제
* [ ] 하단 탭 이름 변경(달력/기록) 코드 반영
* [ ] AI 추천 감정을 수동 변경 허용할지 최종 확정
* [ ] 모닝 스크럼 공유 체계 도입 (튜터 제안)

**추후 검토 (시간 여유 시)**
* 6가지 색깔 생각법(Six Thinking Hats) 구조화 회고 템플릿과 감정-대안 전환율 분석 (현재는 AI 주간 리포트 6단계로 일부 반영)
* AI 주간 리포트의 월간 확장, 분석 결과 저장
* 사용자 피드백 기능, 일정(WBS) 조정

## 📋 11. 진행 현황 체크리스트

- [x] GitHub 저장소 생성, 팀원 초대 및 브랜치 규칙 합의
- [x] 팀원 역할 분담 및 핵심 기능·7가지 감정 분류 확정
- [x] Figma 전체 화면 디자인 및 색상 정의
- [x] SwiftData 데이터 모델(`Retrospective`) 구축
- [x] 온보딩, 달력·목록·상세·작성 CRUD 구현
- [x] OpenAI API 기반 AI 감정 추천 연동, `OpenAIClient`로 호출 공통화
- [x] 주간·월간 통계 구현 (요약 카드, 막대 그래프, 한마디 카드, 빈 상태)
- [x] AI 주간 회고 리포트(6단계) 추가
- [x] 다크 모드, Dynamic Type 적용
- [x] API 문서화 주석(`///`) 작성
- [ ] 주요 흐름(작성·조회·통계) 시연 영상 녹화와 README 첨부
- [ ] AI 주간 리포트 실제 응답 확인 및 문구 다듬기
- [ ] 통계 화면 Figma 최종 점검 (AI 리포트 영역은 시안 없음)
- [ ] 발표 자료(PPT) 제작 및 최종 문서 정리
