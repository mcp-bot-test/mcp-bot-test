"""
Application Configuration
"""
from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    """Application settings"""
    
    # API Settings
    API_V1_PREFIX: str = "/api/v1"
    PROJECT_NAME: str = "Auto-Changelog & Retrospective Agent"
    
    # CORS Settings
    CORS_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8000"]
    
    # MCP Settings
    MCP_NOTION_SERVER_PATH: str = ""
    MCP_JIRA_SERVER_PATH: str = ""
    MCP_GITHUB_SERVER_PATH: str = ""
    MCP_SLACK_SERVER_PATH: str = ""
    
    # Notion Settings
    NOTION_API_KEY: str = ""
    NOTION_DATABASE_ID: str = ""
    
    # Jira Settings
    JIRA_URL: str = ""
    JIRA_EMAIL: str = ""
    JIRA_API_TOKEN: str = ""
    
    # GitHub Settings
    GITHUB_TOKEN: str = ""
    GITHUB_REPO: str = ""
    
    # Slack Settings
    SLACK_BOT_TOKEN: str = ""
    SLACK_CHANNEL: str = ""
    
    # LLM Settings
    LLM_PROVIDER: str = "openai"  # openai, anthropic
    OPENAI_API_KEY: str = ""
    ANTHROPIC_API_KEY: str = ""
    LLM_MODEL: str = "gpt-4"
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
