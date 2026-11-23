#!/usr/bin/env bash
#
# Interactive screenshot session for a theme running on a remote handheld.
#
# Navigate the UI on the device yourself, then capture the current screen
# over SSH. Each capture is pulled back into the current folder with a
# sequential name (solo-ultra-01.png, solo-ultra-02.png, ...).
#
# Usage:
#   ./tools/capture-screenshots.sh 192.168.2.135
#   DEVICE_IP=192.168.2.135 ./tools/capture-screenshots.sh
#
# Keys:
#   c or Enter   capture the current device screen
#   q            quit
#   h            show help
#
# Environment overrides:
#   DEVICE_IP    device address (or pass it as the first argument)
#   REMOTE_USER  SSH user (default: ark)
#   OUT_DIR      destination folder (default: the current directory)
#   PREFIX       filename prefix (default: solo-ultra)
#   REMOTE_TMP   remote temp folder (default: /tmp)
#
# Capture method matches docs/REMOTE_TEST.md: DRM/KMS grab with ffmpeg,
# writing a PNG on the device, then scp back. If your device lacks kmsgrab,
# edit the ffmpeg line in capture() (e.g. -f fbdev -i /dev/fb0).

set -u

usage() {
  sed -n '3,27p' "$0" | sed 's/^# \{0,1\}//'
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi

DEVICE_IP="${DEVICE_IP:-${1:-}}"
REMOTE_USER="${REMOTE_USER:-ark}"
OUT_DIR="${OUT_DIR:-$PWD}"
PREFIX="${PREFIX:-solo-ultra}"
REMOTE_TMP="${REMOTE_TMP:-/tmp}"

if [ -z "$DEVICE_IP" ]; then
  echo "error: no device address given." >&2
  echo "usage: DEVICE_IP=192.168.2.135 $0" >&2
  exit 1
fi

for bin in ssh scp; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "error: '$bin' is not installed or not on PATH." >&2
    exit 1
  fi
done

SSH_TARGET="$REMOTE_USER@$DEVICE_IP"
SSH_OPTS="-o ConnectTimeout=8"

mkdir -p "$OUT_DIR" || {
  echo "error: cannot create output folder '$OUT_DIR'." >&2
  exit 1
}

echo "Checking SSH connection to $SSH_TARGET ..."
if ! ssh $SSH_OPTS "$SSH_TARGET" true </dev/null; then
  echo "error: cannot reach $SSH_TARGET over SSH." >&2
  echo "       Check DEVICE_IP, Wi-Fi, and that the SSH key is authorized." >&2
  exit 1
fi

next_index() {
  local last
  last=$(ls -1 "$OUT_DIR/$PREFIX-"*.png 2>/dev/null \
    | sed -n 's/.*-\([0-9][0-9]*\)\.png$/\1/p' \
    | sort -n | tail -n 1)
  if [ -n "$last" ]; then
    # 10# forces base-10: "08"/"09" would otherwise be parsed as invalid octal
    echo $((10#$last + 1))
  else
    echo 1
  fi
}

capture() {
  local idx name remote
  idx=$(next_index)
  case "$idx" in
    ''|*[!0-9]*) idx=1 ;;
  esac
  name=$(printf '%s-%02d.png' "$PREFIX" "$idx")
  remote="$REMOTE_TMP/${PREFIX}-capture-$$-$idx.png"

  printf 'Capturing -> %s ... ' "$OUT_DIR/$name"

  if ! ssh $SSH_OPTS "$SSH_TARGET" \
      "sudo ffmpeg -loglevel error -y -f kmsgrab -i - -vf 'hwdownload,format=bgr0' -vframes 1 '$remote'" \
      </dev/null; then
    echo "FAILED (remote capture)."
    echo "       Check that passwordless sudo works over SSH and that kmsgrab is available;" >&2
    echo "       if it is not, edit capture() to use fbdev (-f fbdev -i /dev/fb0)." >&2
    return 1
  fi

  if ! ssh $SSH_OPTS "$SSH_TARGET" "test -s '$remote'" </dev/null; then
    echo "FAILED (no image produced on device)."
    return 1
  fi

  if ! scp -q "$SSH_TARGET:$remote" "$OUT_DIR/$name"; then
    echo "FAILED (copy back)."
    ssh $SSH_OPTS "$SSH_TARGET" "rm -f '$remote'" >/dev/null 2>&1
    return 1
  fi

  ssh $SSH_OPTS "$SSH_TARGET" "rm -f '$remote'" >/dev/null 2>&1
  echo "saved $OUT_DIR/$name"
  return 0
}

captured=0
echo
echo "Ready. Navigate on the device, then capture."
echo "Saving to: $OUT_DIR (prefix: $PREFIX)"

while :; do
  printf '\n[c]apture (or Enter)  [q]uit  [h]elp > '
  if ! IFS= read -r key; then
    echo
    break
  fi

  case "$key" in
    c|C|"")
      if capture; then
        captured=$((captured + 1))
      fi
      ;;
    q|Q)
      break
      ;;
    h|H|'?')
      usage
      ;;
    *)
      echo "unknown key: '$key' (use c, q or h)"
      ;;
  esac
done

echo
echo "Session ended. Captured $captured screenshot(s) this run."
