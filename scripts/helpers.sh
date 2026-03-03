#!/usr/bin/env bash
# ─── Shared helpers for install scripts ──────────────────────────────────────
# Source this at the top of any script to get colored output helpers.
# Safe to source multiple times — functions are idempotent.

if ! declare -f info &>/dev/null; then
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  RED='\033[0;31m'
  BLUE='\033[0;34m'
  NC='\033[0m'

  info()    { echo -e "${GREEN}[✓]${NC} $1"; }
  warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
  error()   { echo -e "${RED}[✗]${NC} $1"; }
  section() { echo -e "\n${BLUE}══════ $1 ══════${NC}"; }
fi
