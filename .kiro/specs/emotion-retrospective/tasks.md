# 감정 회고 앱 구현 작업 목록

> 진행 상황은 이 파일의 체크박스로 기록합니다. Task 하나를 마칠 때마다 `[x]`로 바꿉니다.
> 규칙: develop에서 기능 브랜치를 새로 만들어 진행 / PR 하나는 200~400줄 이하 / 커밋·push 전에 확인 / `!` 강제 언래핑 금지 / (주석 없음)

## 확정된 결정
- AI 추천은 사용자가 버튼을 눌렀을 때만 호출한다.
- Chat Completions + `response_format`(json_schema, strict). 모델 이름은 `AppConfig` 상수 한 곳에서 관리하고 Task 9에서 공식 모델 페이지로 확정한다.
- xcconfig → Info.plist 연결은 Task 1에서 구성하고 가짜 키로 읽히는지 확인한다.
- 하루 대표 감정 동률은 가장 최근 회고의 감정.
- 글꼴 크기 기본값은 "시스템 따름"(시스템 따름/작게/보통/크게).
- 온보딩에 "회고 본문이 AI 분석을 위해 OpenAI로 전송됨" 안내만 넣는다(설정 스위치 없음).
- `@Model` 파일은 Task 1에서 확정하고 이후 변경은 한 사람이 맡는다.
- 역할 분담은 Task 1 이후 결정한다.
- (변경) 감정은 7개: 기쁨(joy), 성취(achievement), 안정(stable), 분노(angry), 두려움(fear), 슬픔(sad), 소진(exhausted). 안정이 기본(fallback) 감정이다.
- (변경) 코드 주석(`///` 포함)은 달지 않는다. Category의 `@Relationship`은 제거했다(기본 동작이 같음을 실험으로 확인).
- (변경) 태그 기능은 만들지 않는다(Tag 모델, 태그 필터, 태그 TOP 5 제외). 분류는 카테고리만 쓴다.
- (변경) 통계는 "선택한 기간(이번 달)에 감정별로 몇 개인지"를 기본으로 한다.
- (변경) 탭은 회고·통계 2개만 둔다. 달력은 회고 화면 맨 위에 합친다. 설정 탭은 만들지 않는다.

## 작업

- [ ] **Task 1: 기초 틀 만들기** (월 오전, `feature/project-skeleton`)
  - [x] 배포 타깃 iOS 17, iPhone 세로 설정
  - [x] 폴더 구조, 모델 3종(Emotion, Retrospective, Category), modelContainer 연결
  - [x] MainTabView 2탭(회고·통계) 빈 화면 (샘플 데이터는 나중에 필요할 때 추가)
  - [x] 감정 Color Set 7개(라이트/다크)
  - [x] Secrets.example.xcconfig, Base.xcconfig, AdditionalInfo.plist, AppConfig 작성. 가짜 키를 `xcodebuild -xcconfig`로 넘겨 Info.plist에 `OPENAI_API_KEY`가 들어가는 것까지 확인
  - [ ] Xcode에서 Project → Info → Configurations의 Debug/Release에 `Config/Base.xcconfig` 연결(수동 1회, 새 프로젝트 형식이라 파일로 자동 설정하지 못함)
  - [ ] README 뼈대
  - [ ] 테스트 타깃 추가(Xcode: File > New > Target > Unit Testing Bundle) 후 Emotion rawValue·색 이름·AppConfig.apiKey 테스트 작성
    - 임시 스크립트로 같은 항목을 검증해 모두 통과함(저장소에는 포함하지 않음)
- [ ] **Task 2: 회고 작성·목록과 감정 선택** (월 오후, `feature/retrospective-create-list`)
- [ ] **Task 3: 상세·편집·삭제** (화, `feature/retrospective-detail-edit-delete`)
- [ ] **Task 4: 카테고리 관리와 연결** (수 오전, `feature/category`)
- [ ] **Task 5: 카테고리 필터** (수 오후, `feature/retrospective-filter`)
- [ ] **Task 6: 월간 감정 색 달력(회고 화면 맨 위에 배치)** (목, `feature/emotion-calendar`)
- [ ] **Task 7: 월별 감정 통계(감정별 개수)** (금 오전, `feature/statistics`)
- [ ] **Task 8: 설정과 온보딩** (금 오후, `feature/settings`) - 설정 탭 제거로 범위 재논의 필요(테마·글꼴·첫 실행 안내를 어디에 둘지)
- [ ] **Task 9: EmotionRecommender 서비스** (토 오전, `feature/ai-recommender-service`)
- [ ] **Task 10: AI 추천 UI 연결과 실패 처리** (토 오후, `feature/ai-recommendation-ui`)
- [ ] **Task 11: 다크모드·접근성 점검** (일 오전, `fix/dark-mode-accessibility`)
- [ ] **Task 12: 문서화와 마무리** (일 오후, `feature/docs-readme`)

## 일정 밀릴 때 뺄 것 (먼저 뺄 것부터)
1) iPad 대응 2) Swift Charts 3) 통계의 카테고리별 건수·주 단위 보기 4) 글꼴 크기 설정 5) 온보딩
절대 빼지 않을 것: CRUD, 달력, AI 실패 처리, API 키 보안, README
