#!/usr/bin/env bash
# MCP 서버 헬스체크 (배포 전 기본 가동 확인)
# 사용법: ./scripts/mcp-test-health.sh [BASE_URL]
# 예: ./scripts/mcp-test-health.sh http://localhost:3000

set -e

BASE_URL="${1:-http://localhost:3000}"
# URL 끝에 / 있으면 제거
BASE_URL="${BASE_URL%/}"

echo "========================================="
echo "MCP 서버 헬스체크"
echo "========================================="
echo "Base URL: $BASE_URL"
echo ""

# 1) /health (Notion MCP 등)
HEALTH_URL="${BASE_URL}/health"
echo "1) GET $HEALTH_URL"
if CODE=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 "$HEALTH_URL"); then
  if [ "$CODE" = "200" ]; then
    echo "   ✅ HTTP $CODE"
    curl -s "$HEALTH_URL" | head -5
    echo ""
  else
    echo "   ⚠️  HTTP $CODE (엔드포인트 없을 수 있음)"
  fi
else
  echo "   ❌ 연결 실패 (서버 가동 여부 확인)"
fi
echo ""

# 2) MCP initialize (실제 MCP 엔드포인트 가동 확인)
# Notion MCP 등 대부분 HTTP MCP 서버는 /mcp 경로 사용
if [[ "$BASE_URL" == *"/mcp"* ]]; then
  MCP_URL="$BASE_URL"
elif [[ "$BASE_URL" =~ ^https?://[^/]+$ ]]; then
  MCP_URL="${BASE_URL}/mcp"
else
  MCP_URL="${BASE_URL}/mcp"
fi

INIT_PAYLOAD='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"health-check","version":"1.0.0"}}}'
echo "2) POST $MCP_URL (initialize)"
RESP=$(curl -s -w "\nHTTP_CODE:%{http_code}" -X POST -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "$INIT_PAYLOAD" --connect-timeout 5 "$MCP_URL" 2>&1) || true
HTTP_CODE=$(echo "$RESP" | grep "HTTP_CODE:" | cut -d: -f2)
if [ "$HTTP_CODE" = "200" ]; then
  echo "   ✅ HTTP $HTTP_CODE - MCP 엔드포인트 정상"
else
  echo "   ❌ HTTP $HTTP_CODE"
  echo "$RESP" | sed '/HTTP_CODE:/d' | head -3
fi
echo ""
echo "========================================="
echo "헬스체크 완료"
echo "========================================="
