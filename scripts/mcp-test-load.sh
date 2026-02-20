#!/usr/bin/env bash
# 지속 부하 테스트 (CPU/메모리, 타임아웃, 에러율)
# 사용법: ./scripts/mcp-test-load.sh <MCP_ENDPOINT> [테스트_초]
# 예: ./scripts/mcp-test-load.sh http://localhost:3000/mcp 30

set -e

ENDPOINT="${1:-http://localhost:3000/mcp}"
DURATION="${2:-30}"
if [[ "$ENDPOINT" != *"/mcp"* ]]; then
  if [[ "$ENDPOINT" =~ ^https?://[^/]+/$ ]]; then
    : # use as-is (e.g. GitHub MCP at root)
  else
    ENDPOINT="${ENDPOINT%/}/mcp"
  fi
fi

echo "========================================="
echo "MCP 지속 부하 테스트"
echo "========================================="
echo "엔드포인트: $ENDPOINT"
echo "테스트 시간: ${DURATION}초"
echo ""

INIT_PAYLOAD='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{"roots":{"listChanged":true},"sampling":{}},"clientInfo":{"name":"load-test","version":"1.0.0"}}}'

START=$(date +%s)
SUCCESS=0
FAIL=0

while true; do
  NOW=$(date +%s)
  ELAPSED=$((NOW - START))
  [ "$ELAPSED" -ge "$DURATION" ] && break

  code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 -m 15 -X POST -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "$INIT_PAYLOAD" "$ENDPOINT" 2>/dev/null) || code=000
  if [ "$code" = "200" ]; then
    SUCCESS=$((SUCCESS + 1))
    printf "."
  else
    FAIL=$((FAIL + 1))
    printf "x"
  fi
done

echo ""
TOTAL=$((SUCCESS + FAIL))
echo ""
echo "========================================="
echo "부하 테스트 결과"
echo "========================================="
echo "총 요청: $TOTAL (${DURATION}초)"
echo "성공: $SUCCESS"
echo "실패: $FAIL"
if [ "$TOTAL" -gt 0 ]; then
  RATE=$((SUCCESS * 100 / TOTAL))
  echo "성공률: ${RATE}%"
  if [ "$RATE" -lt 95 ]; then
    echo "⚠️  성공률이 95% 미만입니다. 타임아웃/리소스 설정을 확인하세요."
    exit 1
  fi
fi
echo ""
echo "동시에 docker stats <container_id> 로 메모리/CPU를 확인하세요."
exit 0
