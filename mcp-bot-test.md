지금까지 논의된 내용을 바탕으로, 현재 구연우 님께서 개발 중인 **"Auto-Changelog & Retrospective Agent"** 프로젝트에 대한 요약 명세서를 작성해 드립니다.

---

# 🚀 Project: Auto-Changelog & Retrospective Agent

> **"흩어진 개발 파편(Fragment)을 모아, 팀의 완벽한 회고(Insight)를 완성하다."**

### 1. 프로젝트 개요 (Overview)

개발자들의 가장 큰 Pain Point인 **"주간 보고", "배포 노트 작성", "회고"** 업무를 자동화하는 AI 에이전트 서비스입니다.
Notion, Jira, GitHub 등 여러 플랫폼에 분산된 업무 기록을 **MCP(Model Context Protocol)**를 통해 실시간으로 수집하고, 문맥(Context)을 파악하여 **단 한 번의 요청(Single-turn)**으로 고품질의 보고서를 생성합니다.

### 2. 해결하려는 문제 (Problem Statement)

* **기억의 한계:** "지난주에 뭐 했지?"를 떠올리기 위해 커밋 로그와 칸반 보드를 뒤적거리는 비효율 발생.
* **데이터 파편화:** 기획(Notion), 이슈 관리(Jira), 코드 구현(GitHub)이 분리되어 있어, 하나의 작업 흐름으로 연결하기 어려움.
* **작성 귀차니즘:** 개발 생산성을 떨어뜨리는 수동 문서 작업의 반복.

### 3. 핵심 기능 (Key Features)

#### A. 멀티 소스 데이터 통합 (Multi-Source Aggregation)

* **Notion:** 기획 의도(Why), 스펙 문서, 회의록 수집. (DB vs Simple Table 구조 구분 처리)
* **Jira:** 상세 구현 요건(What), 진행 상태, 담당자 파악.
* **GitHub:** 실제 코드 변경 사항(How), PR 및 커밋 메시지, 기술적 트러블슈팅 내역 수집.

#### B. 재귀적 맥락 연결 (Recursive Context Discovery)

* 단순 검색이 아닌, **Linked Data** 추적 방식 적용.
* GitHub PR에서 Jira 티켓 번호 추출 → Jira 이슈 조회 → Jira 내 Notion 링크 발견 → Notion 기획서 조회.
* **Deep Linking**을 통해 작업의 **[배경 - 구현 - 결과]**를 하나의 스토리로 완성.

#### C. 팀 중심 자동화 (Team-Centric Automation)

* 특정 개인뿐만 아니라, **지정된 프로젝트(Scope)** 전체를 모니터링.
* **Attribution(기여 확인):** 각 작업이 누구(Assignee/Author)에 의해 수행되었는지 명확히 식별하여 표기.
* **Objective Reporting:** 감정을 배제하고 사실(Fact)과 성과(Result) 위주의 건조한 보고서 작성.

### 4. 기술 아키텍처 및 스택 (Tech Stack)

* **Core Engine:** LLM (Claude/OpenAI) + **MCP (Model Context Protocol)**
* **MCP Servers:**
* **Notion:** Node.js 기반 (공식/Custom), 페이지 및 데이터베이스 조회.
* **Jira:** Python (`uv` 기반), `sooperset/mcp-atlassian` 활용, JQL 검색 지원.
* **GitHub:** (예정) PR, Commit, Issue Search API 연동.


* **Prompt Engineering:**
* **Role:** Team Auto-Scrum Master.
* **Logic:** Harvest(수집) → Map(매핑) → Synthesize(통합).
* **Constraint:** Hallucination 방지, 타겟 범위(Scope) 제한.



### 5. 현재 진행 상황 (Status)

* ✅ **Notion MCP 연결:** 로컬 서버 구축 및 데이터 구조(DB/Table) 인식 테스트 완료.
* ✅ **Jira MCP 연결:** Python(`uv`) 환경에서 인증 및 이슈 조회 성공.
* ✅ **데이터 검증:** 시간 핸들링(최근 7일), 휴리스틱(작성자/날짜 기반) 테스트 시나리오 확보.
* ✅ **프롬프트 고도화:** 개인용 툴에서 **팀 단위 협업 도구**로 프롬프트 로직 격상 (Project-Centric).

### 6. 향후 로드맵 (Next Steps)

1. **GitHub MCP 연결:** 실제 코드 레벨의 데이터(PR Body, Commit Msg) 수집 파이프라인 구축.
2. **자동화 트리거 구축:** 채팅 입력 없이 매주 금요일 오후 5시에 자동 실행되도록 스케줄링.
3. **Noise Filtering:** `chore`, `typo` 등 의미 없는 데이터를 걸러내는 전처리 로직 강화.

### prompt
```
@mcp-bot-test.md 이 문서는 제가 개발하려고 하는 mcp-bot에 대한 설명입니다. github, jira, notion, slack 등을 mcp로 연결해서 자동으로 주간 회고 및 요약을 작성해주는 봇을 개발하려고 합니다. 현재 mcp 연결 및 jira 트래킹 테스트까지 완료했고, 이제 github repository를 연결해서 commmit message나 PR에 적힌 내용 뿐만 아니라 코드 내용도 분석하고 어떤 기능을 개발했는지 추적 가능 여부를 테스트 해보려고 합니다.
```