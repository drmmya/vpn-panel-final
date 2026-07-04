#!/usr/bin/env bash
set -euo pipefail

# VPN Panel Installer Runner
# Usage:
#   sudo bash install.sh        # full install: panel + OpenVPN + OpenConnect + V2Ray
#   sudo bash install.sh panel  # only panel UI
#   sudo bash install.sh v2ray  # only V2Ray/Xray
#   sudo bash install.sh openvpn
#   sudo bash install.sh openconnect

if [[ ${EUID} -ne 0 ]]; then
  echo "ERROR: Run as root: sudo bash install.sh" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

need_file(){
  local f="$1"
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Missing required file: $f" >&2
    exit 1
  fi
}

need_dir(){
  local d="$1"
  if [[ ! -d "$d" ]]; then
    echo "ERROR: Missing required folder: $d" >&2
    exit 1
  fi
}

need_file setup-panel-ui.sh
need_file install-openvpn.sh
need_file install-openconnect.sh
need_file install-v2ray.sh
need_file vpn-control.sh
need_dir panel-admin

chmod +x setup-panel-ui.sh install-openvpn.sh install-openconnect.sh install-v2ray.sh vpn-control.sh
bash -n setup-panel-ui.sh
bash -n install-openvpn.sh
bash -n install-openconnect.sh
bash -n install-v2ray.sh
bash -n vpn-control.sh

MODE="${1:-all}"

run_panel(){
  echo "[1/4] Installing panel UI..."
  bash setup-panel-ui.sh
}

run_openvpn(){
  echo "[2/4] Installing OpenVPN..."
  bash install-openvpn.sh
}

run_openconnect(){
  echo "[3/4] Installing OpenConnect..."
  bash install-openconnect.sh
}

run_v2ray(){
  echo "[4/4] Installing V2Ray/Xray..."
  bash install-v2ray.sh
}

case "$MODE" in
  all)
    run_panel
    run_openvpn
    run_openconnect
    run_v2ray
    ;;
  panel)
    run_panel
    ;;
  openvpn)
    run_openvpn
    ;;
  openconnect)
    run_openconnect
    ;;
  v2ray)
    run_v2ray
    ;;
  *)
    echo "Usage: sudo bash install.sh [all|panel|openvpn|openconnect|v2ray]" >&2
    exit 1
    ;;
esac

SERVER_IP="$(curl -4 -fsSL https://api.ipify.org 2>/dev/null || hostname -I | awk '{print $1}')"

echo ""
echo "========================================"
echo " VPN Panel install completed"
echo " Panel URL: http://${SERVER_IP}/vpn-panel"
echo " Default username: openvpn"
echo " Default password: Easin112233@"
echo " Important: login kore password change kore nin."
echo "========================================"
