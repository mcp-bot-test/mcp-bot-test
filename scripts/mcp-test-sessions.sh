#!/usr/bin/env bash
# 세션 다수 생성 후 일부만 정리 (세션/메모리 누수 검증 - Stateful MCP용)
# 사용법: ./scripts/mcp-test-sessions.sh <MCP_ENDPOINT> [세션_개수]
# 예: ./scripts/mcp-test-sessions.sh http://localhost:3000/mcp 20

set -e

ENDPOINT="${1:-http://localhost:3000/mcp}"
NUM_SESSIONS="${2:-20}"
if [[ "$ENDPOINT" != *"/mcp"* ]]; then
  if [[ "$ENDPOINT" =~ ^https?://[^/]+/$ ]]; then
    : # use as-is (e.g. GitHub MCP at root)
  else
    ENDPOINT="${ENDPOINT%/}/mcp"
  fi
fi

echo "========================================="
echo "MCP 세션 부하 테스트 (Stateful 서버 검증)"
echo "========================================="
echo "엔드포인트: $ENDPOINT"
echo "생성할 세션 수: $NUM_SESSIONS (절반만 명시적으로 정리)"
echo ""

INIT_PAYLOAD='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"roots":{"listChanged":true},"sampling":{}},"clientInfo":{"name":"session-test","version":"1.0.0"}}}'
LIST_PAYLOAD='{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'

TMPDIR="${TMPDIR:-/tmp}"
SESSION_FILE="$TMPDIR/mcp-sessions-$$.txt"
touch "$SESSION_FILE"
trap "rm -f '$SESSION_FILE'" EXIT

echo "1) 세션 $NUM_SESSIONS 개 생성 중..."
for i in $(seq 1 "$NUM_SESSIONS"); do
  full=$(curl -s -i -w "\nHTTP_CODE:%{http_code}" -X POST -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "$INIT_PAYLOAD" "$ENDPOINT" 2>&1) || true
  code=$(echo "$full" | grep "HTTP_CODE:" | cut -d: -f2)
  sid=$(echo "$full" | grep -i "mcp-session-id" | head -1 | sed 's/.*: *//' | tr -d '\r' | tr -d ' ')
  if [ "$code" = "200" ] && [ -n "$sid" ]; then
    echo "$sid" >> "$SESSION_FILE"
  fi
done
CREATED=$(wc -l < "$SESSION_FILE" | tr -d ' ')
echo "   생성된 세션 수: $CREATED"
if [ "$CREATED" -eq 0 ]; then
  echo "   (Stateless 서버이거나 세션 ID를 헤더로 반환하지 않을 수 있음. 이 테스트는 Stateful 서버용입니다.)"
  exit 0
fi

echo ""
echo "2) 모든 세션에서 tools/list 호출..."
while read -r sid; do
  curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -H "Mcp-Session-Id: $sid" -d "$LIST_PAYLOAD" "$ENDPOINT" > /dev/null || true
done < "$SESSION_FILE"

echo "3) 절반 세션만 DELETE로 정리 (나머지는 정리하지 않음)..."
TOTAL=$CREATED
HALF=$((TOTAL / 2))
n=0
while read -r sid && [ "$n" -lt "$HALF" ]; do
  curl -s -o /dev/null -X DELETE -H "Mcp-Session-Id: $sid" "$ENDPOINT" || true
  n=$((n + 1))
done < "$SESSION_FILE"

echo "   정리한 세션: $HALF / $TOTAL"
echo ""
echo "========================================="
echo "세션 테스트 완료"
echo "========================================="
echo "이후 컨테이너 메모리를 확인하세요: docker stats <container_id>"
echo "정리하지 않은 세션이 서버 메모리에 남아 있을 수 있습니다 (세션 누수 가능성)."
exit 0
