# [프로젝트명: 업무 자동화 AI Agent]

### : MCP를 활용한 Jira, Notion, GitHub 통합 워크플로우 구축

## 1. 프로젝트 개요

* **개발 기간:** 2025.12 ~ 2026.01 (약 2개월)
* **개발자:** 구연우([@bluelayzxx](https://github.com/nuyeo)), 김형민([@hyeong8465](https://github.com/hyeong8465))
* **한 줄 소개:** Claude Desktop 환경에서 사내 협업 툴(Jira, Notion, GitHub)을 MCP(Model Context Protocol)로 연결하여, 대화만으로 주간 업무 리포트를 자동 생성하고 이슈를 동기화하는 AI Agent 서비스입니다.

## 2. 기획 배경 (Problem & Solution)

* **문제(Problem):** 개발 업무 진행 시 코드 작성 외에 Jira 티켓 상태 변경, Notion 회의록 정리, GitHub PR 연동 등 반복적인 '컨텍스트 스위칭' 비용이 발생함.
* **해결(Solution):** LLM이 실시간으로 외부 툴의 데이터를 조회하고 수정할 수 있는 표준 프로토콜인 **MCP**를 도입하여, 하나의 인터페이스(Claude)에서 모든 업무 툴을 제어하는 환경을 구축.

## 3. 기술 스택 (Tech Stack)

* **Core:** Claude Desktop App, Model Context Protocol (MCP) SDK
* **Connectors:**
* `@modelcontextprotocol/server-github`
* `@modelcontextprotocol/server-jira`
* `@modelcontextprotocol/server-notion`


* **Infra/Deployment:** Google Cloud Run (MCP 서버 배포), Node.js (mcp-proxy 활용)

## 4. 시스템 아키텍처 및 주요 기능

*(이곳에 간단한 도식을 넣으면 좋습니다: User -> Claude Desktop <-> [MCP Proxy] <-> [Remote MCP Server] <-> APIs)*

1. **Jira 이슈 트래킹 자동화:** "이번 주 내게 할당된 이슈 보여줘" 요청 시 JQL 쿼리를 자동 생성하여 데이터 조회.
2. **Notion 문서 동기화:** Jira의 이슈 진행 상황을 요약하여 Notion '주간 업무 보고' 페이지에 자동 기입.
3. **GitHub 리포지토리 연동:** 특정 이슈와 관련된 PR 상태를 확인하고 코드 리뷰 요청 내역 요약.

## 5. 핵심 트러블 슈팅 (Troubleshooting)

**이슈: 배포된 원격 MCP 서버 연결 불가 현상**

* **상황:** Cloud Run에 배포된 MCP 서버 URL(`https://.../mcp`)을 `claude_desktop_config.json`에 직접 입력했으나 연결되지 않음.
* **원인:** 현재 Claude Desktop은 보안 및 SSE(Server-Sent Events) 처리 방식의 차이로 인해 원격 URL의 직접 연결을 완벽히 지원하지 않는 경우가 있음.
* **해결:** Claude Desktop 설정 > 커스텀 커넥터로 엔드포인트 연결



## 6. 성과 및 회고

* **성과:** 매주 30분 이상 소요되던 업무 리포트 작성 시간을 1분 미만(프롬프트 1회)으로 단축.
* **배운 점:** LLM이 단순 챗봇을 넘어 실제 시스템의 API를 제어하는 'Agent'로 동작하기 위한 인터페이스 설계 경험 습득. 분산된 SaaS API들의 인증 방식(OAuth, PAT 등)을 통합 관리하는 보안 설정의 중요성 체감.
