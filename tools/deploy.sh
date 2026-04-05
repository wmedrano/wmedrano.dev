#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if [ $# -lt 2 ]; then
  echo -e "${RED}Usage: $0 <user@host> <remote_path> [port]${NC}"
  exit 1
fi

TARGET="$1"
REMOTE_PATH="$2"
PORT="${3:-22}"

echo -e "[deploy] ${GREEN}Target: ${TARGET}:${PORT}${NC}"
echo -e "[deploy] ${YELLOW}Remote path: ${REMOTE_PATH}${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo -e "[deploy] ${YELLOW}Building...${NC}"
"${SCRIPT_DIR}/build.sh"
echo -e "[deploy] ${GREEN}Build complete.${NC}"

echo -e "[deploy] ${YELLOW}Uploading files...${NC}"
sftp -P "$PORT" "$TARGET" <<EOF
put -r public/* ${REMOTE_PATH}
EOF
echo -e "[deploy] ${GREEN}Upload complete.${NC}"
