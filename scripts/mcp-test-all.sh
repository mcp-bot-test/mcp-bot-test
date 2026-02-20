#!/usr/bin/env bash
# 실행 중인 MCP 서버들에 대해 scripts 내 테스트를 모두 적용
# 사용법:
#   ./scripts/mcp-test-all.sh                    # mcp-servers.conf 또는 MCP_SERVERS 사용
#   ./scripts/mcp-test-all.sh [CONFIG_FILE]      # 지정한 설정 파일 사용
#   MCP_SERVERS="http://localhost:3000 http://localhost:8082" ./scripts/mcp-test-all.sh
#
# 설정 파일 형식: 한 줄에 BASE_URL 하나 (주석 # 제외)

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="${1:-$SCRIPT_DIR/mcp-servers.conf}"

# 설정에서 URL 목록 읽기 (주석·빈줄 제거)
read_servers() {
  if [ -n "$MCP_SERVERS" ]; then
    echo "$MCP_SERVERS" | tr ' \t' '\n' | sed 's/^[ \t]*//;s/[ \t]*$//' | grep -v '^$'
    return
  fi
  if [ -f "$CONFIG_FILE" ]; then
    sed 's/#.*//;s/^[ \t]*//;s/[ \t]*$//' "$CONFIG_FILE" | grep -v '^$'
    return
  fi
  return 1
}

SERVERS=$(read_servers) || true
if [ -z "$SERVERS" ]; then
  echo "사용법: $0 [CONFIG_FILE]"
  echo "  또는 MCP_SERVERS=\"http://localhost:3000 http://localhost:8082\" $0"
  echo ""
  echo "CONFIG_FILE 기본값: $CONFIG_FILE"
  echo "설정 파일에 BASE URL을 한 줄에 하나씩 넣거나, 환경변수 MCP_SERVERS를 설정하세요."
  exit 1
fi

echo "========================================="
echo "MCP 서버 테스트 (동적 포트/URL)"
echo "========================================="
echo "설정: $CONFIG_FILE"
echo "대상 서버:"
echo "$SERVERS" | sed 's/^/  - /'
echo ""

FAILED=0
for BASE in $SERVERS; do
  BASE="${BASE%/}"
  # 엔드포인트는 모두 /mcp
  [[ "$BASE" == *"/mcp"* ]] && ENDPOINT="$BASE" || ENDPOINT="${BASE}/mcp"

  echo "########################################################"
  echo "# 서버: $BASE"
  echo "########################################################"

  echo ""
  echo "--- 1) 헬스체크 ---"
  if ! "$SCRIPT_DIR/mcp-test-health.sh" "$BASE"; then
    echo "   ⚠️  헬스체크 실패"
    FAILED=$((FAILED + 1))
  fi

  echo ""
  echo "--- 2) 세션 테스트 (20개 생성, 절반 정리) ---"
  if ! "$SCRIPT_DIR/mcp-test-sessions.sh" "$ENDPOINT" 20; then
    echo "   ⚠️  세션 테스트 실패"
    FAILED=$((FAILED + 1))
  fi

  echo ""
  echo "--- 3) 부하 테스트 (10초) ---"
  if ! "$SCRIPT_DIR/mcp-test-load.sh" "$ENDPOINT" 10; then
    echo "   ⚠️  부하 테스트 실패"
    FAILED=$((FAILED + 1))
  fi

  echo ""
  echo "--- 4) 동시성 테스트 (5개) ---"
  if ! "$SCRIPT_DIR/mcp-test-concurrent.sh" "$ENDPOINT" 5; then
    echo "   ⚠️  동시성 테스트 실패"
    FAILED=$((FAILED + 1))
  fi

  echo ""
done

echo "========================================="
echo "전체 테스트 완료"
echo "========================================="
if [ "$FAILED" -gt 0 ]; then
  echo "실패한 테스트 수: $FAILED"
  exit 1
fi
exit 0
