# Auto-Changelog & Retrospective Agent

> **"흩어진 개발 파편(Fragment)을 모아, 팀의 완벽한 회고(Insight)를 완성하다."**

MCP(Model Context Protocol)를 활용하여 GitHub, Jira, Notion, Slack 등 여러 플랫폼의 데이터를 통합하고, AI를 통해 자동으로 주간 회고 및 요약을 생성하는 FastAPI 기반 서비스입니다.

## 🚀 프로젝트 개요

개발자들의 가장 큰 Pain Point인 **"주간 보고", "배포 노트 작성", "회고"** 업무를 자동화하는 AI 에이전트 서비스입니다.

## 📋 주요 기능

- **멀티 소스 데이터 통합**: Notion, Jira, GitHub, Slack 등 여러 플랫폼 데이터 수집
- **재귀적 맥락 연결**: Linked Data 추적을 통한 작업 흐름 완전성 확보
- **팀 중심 자동화**: 프로젝트 단위 모니터링 및 기여도 추적
- **자동 회고 생성**: LLM을 활용한 고품질 보고서 자동 생성

## 🛠️ 기술 스택

- **Framework**: FastAPI
- **Language**: Python 3.10+
- **Protocol**: MCP (Model Context Protocol)
- **LLM**: OpenAI / Anthropic Claude

## 📦 설치 및 실행

### 1. 가상환경 생성 및 활성화

```bash
# Windows
python -m venv venv
venv\Scripts\activate

# Linux/Mac
python -m venv venv
source venv/bin/activate
```

### 2. 의존성 설치

```bash
pip install -r requirements.txt
```

### 3. 환경 변수 설정

`.env` 파일을 생성하고 필요한 설정을 추가하세요:

```env
# LLM Settings
LLM_PROVIDER=openai
OPENAI_API_KEY=your_api_key_here

# MCP Server Paths
MCP_NOTION_SERVER_PATH=
MCP_JIRA_SERVER_PATH=
MCP_GITHUB_SERVER_PATH=
MCP_SLACK_SERVER_PATH=

# 각 서비스별 API 키 및 설정
NOTION_API_KEY=
JIRA_URL=
JIRA_EMAIL=
JIRA_API_TOKEN=
GITHUB_TOKEN=
SLACK_BOT_TOKEN=
```

### 4. 서버 실행

```bash
# 개발 모드
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 프로덕션 모드
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

### 5. API 문서 확인

서버 실행 후 다음 URL에서 API 문서를 확인할 수 있습니다:

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 📁 프로젝트 구조

```
mcp-bot-test/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI 애플리케이션 진입점
│   ├── api/                    # API 라우터
│   │   ├── __init__.py
│   │   └── endpoints/
│   │       ├── health.py
│   │       └── retrospective.py
│   ├── core/                   # 핵심 설정
│   │   ├── __init__.py
│   │   └── config.py           # 환경 변수 및 설정
│   ├── schemas/                 # Pydantic 스키마
│   │   ├── __init__.py
│   │   └── retrospective.py
│   └── services/                # 비즈니스 로직
│       ├── __init__.py
│       ├── mcp_client.py        # MCP 클라이언트
│       └── retrospective_service.py
├── requirements.txt
├── pyproject.toml
├── .env.example
├── .gitignore
└── README.md
```

## 🔌 API 엔드포인트

### Health Check
- `GET /` - 기본 정보
- `GET /health` - 헬스 체크
- `GET /api/v1/health` - API 헬스 체크

### Retrospective
- `POST /api/v1/retrospective/generate` - 기간 지정 회고 생성
- `GET /api/v1/retrospective/generate/weekly` - 최근 7일 회고 자동 생성

## 🧪 개발

### 코드 포맷팅

```bash
black app/
ruff check app/
```

### 테스트 실행

```bash
pytest
```

## 📝 현재 진행 상황

- ✅ FastAPI 기본 구조 구성
- ✅ MCP 클라이언트 서비스 구조 설계
- ✅ API 엔드포인트 기본 구현
- 🔄 GitHub MCP 연결 (진행 중)
- ⏳ 자동화 트리거 구축 (예정)
- ⏳ Noise Filtering 로직 강화 (예정)

## 📚 참고 문서

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [MCP Documentation](https://modelcontextprotocol.io/)
- [프로젝트 상세 명세서](./mcp-bot-test.md)
