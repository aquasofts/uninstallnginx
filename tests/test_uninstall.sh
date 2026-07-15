#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
tmp=$(mktemp -d)
[[ $tmp == /* && $tmp != / ]] || exit 1
trap 'rm -rf "$tmp"' EXIT
mkdir "$tmp/bin"

printf '%s\n' '#!/usr/bin/env bash' \
    "printf 'nginx\\tinstall ok installed\\nnginx-common\\tdeinstall ok config-files\\nlibnginx-mod-http-test\\thold ok installed\\nunrelated\\tinstall ok installed\\n'" \
    >"$tmp/bin/dpkg-query"
printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\n" "$*" >>"$APT_LOG"' \
    >"$tmp/bin/apt-get"
chmod +x "$tmp/bin/dpkg-query" "$tmp/bin/apt-get"

export PATH="$tmp/bin:$PATH" APT_LOG="$tmp/apt.log"

"$root/uninstall.sh" --keep-config --dry-run -y --no-autoremove >/dev/null
grep -Fx -- '--simulate -y remove nginx libnginx-mod-http-test' "$APT_LOG" >/dev/null

: >"$APT_LOG"
"$root/uninstall.sh" --purge --dry-run -y --no-autoremove >/dev/null
grep -Fx -- '--simulate -y purge nginx nginx-common libnginx-mod-http-test' "$APT_LOG" >/dev/null

: >"$APT_LOG"
"$root/uninstall.sh" --keep-config --dry-run -y >/dev/null
grep -Fx -- '--simulate -y --autoremove remove nginx libnginx-mod-http-test' "$APT_LOG" >/dev/null

if "$root/uninstall.sh" --keep-config --purge >/dev/null 2>&1; then
    printf '%s\n' '冲突参数未被拒绝' >&2
    exit 1
fi

printf '%s\n' 'ok'
