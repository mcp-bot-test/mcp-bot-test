#!/usr/bin/env bash
# 동시 다중 사용자 요청 테스트 (동시성 검증)
# 사용법: ./scripts/mcp-test-concurrent.sh <MCP_ENDPOINT> [동시_프로세스_수]
# 예: ./scripts/mcp-test-concurrent.sh http://localhost:3000/mcp 10

set -e

ENDPOINT="${1:-http://localhost:3000/mcp}"
CONCURRENT="${2:-5}"
# URL에 /mcp 없으면 붙임 (단, http://host:port/ 처럼 루트만 있으면 그대로 사용 - GitHub MCP 등)
if [[ "$ENDPOINT" != *"/mcp"* ]]; then
  if [[ "$ENDPOINT" =~ ^https?://[^/]+/$ ]]; then
    : # use as-is
  else
    ENDPOINT="${ENDPOINT%/}/mcp"
  fi
fi

echo "========================================="
echo "MCP 동시성 테스트"
echo "========================================="
echo "엔드포인트: $ENDPOINT"
echo "동시 사용자 수: $CONCURRENT"
echo ""

INIT_PAYLOAD='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"roots":{"listChanged":true},"sampling":{}},"clientInfo":{"name":"concurrent-test","version":"1.0.0"}}}'
LIST_PAYLOAD='{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}'

TMPDIR="${TMPDIR:-/tmp}"
RESULT_DIR=$(mktemp -d "${TMPDIR}/mcp-concurrent-XXXXXX")
trap "rm -rf '$RESULT_DIR'" EXIT

do_one_client() {
  local id=$1
  local out="$RESULT_DIR/result_$id"
  local code=1
  local session_id=""
  local full
  full=$(curl -s -i -w "\nHTTP_CODE:%{http_code}" -X POST -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "$INIT_PAYLOAD" "$ENDPOINT" 2>&1) || true
  echo "$full" > "$out.raw"
  code=$(echo "$full" | grep "HTTP_CODE:" | cut -d: -f2)
  session_id=$(echo "$full" | grep -i "mcp-session-id" | head -1 | sed 's/.*: *//' | tr -d '\r' | tr -d ' ')
  if [ "$code" = "200" ] && [ -n "$session_id" ]; then
    local tools_code
    tools_code=$(curl -s -o /dev/null -w "%{http_code}" -X POST -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -H "Mcp-Session-Id: $session_id" -d "$LIST_PAYLOAD" "$ENDPOINT" 2>&1) || true
    [ "$tools_code" = "200" ] && echo "ok" > "$out" || echo "tools_fail" > "$out"
  elif [ "$code" = "200" ]; then
    # Stateless 서버는 세션 ID 없을 수 있음 - 200이면 성공으로 간주
    echo "ok" > "$out"
  else
    echo "fail" > "$out"
  fi
}

echo "동시에 $CONCURRENT 개 요청 전송 중..."
for i in $(seq 1 "$CONCURRENT"); do
  do_one_client "$i" &
done
wait

OK=$(grep -l "ok" "$RESULT_DIR"/result_* 2>/dev/null | wc -l | tr -d ' ')
FAIL=$((CONCURRENT - OK))
echo ""
echo "========================================="
echo "동시성 테스트 결과"
echo "========================================="
echo "성공: $OK / $CONCURRENT"
echo "실패: $FAIL"
if [ "$FAIL" -gt 0 ]; then
  echo ""
  echo "실패한 클라이언트 상세 (처음 3개):"
  for f in "$RESULT_DIR"/result_*; do
    if grep -q "fail\|tools_fail" "$f" 2>/dev/null; then
      echo "  $f:"
      head -5 "${f}.raw" 2>/dev/null | sed 's/^/    /'
    fi
  done | head -30
  exit 1
fi
echo "✅ 동시 요청이 모두 정상 처리되었습니다."
exit 0
