#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
    cat <<'EOF'
用法：uninstall.sh [选项]

  --keep-config     卸载 Nginx，保留软件包配置
  --purge           卸载 Nginx，并清除软件包配置
  --no-autoremove   不清理自动安装且已不再需要的依赖
  --dry-run         仅预演，不修改系统
  -y, --yes         自动确认 apt-get 提示
  -h, --help        显示帮助

不指定卸载模式时，将进入交互选择。
EOF
}

die() {
    printf '错误：%s\n' "$*" >&2
    exit 1
}

mode=''
assume_yes=false
dry_run=false
autoremove=true

while (($#)); do
    case "$1" in
        --keep-config)
            [[ -z $mode || $mode == keep ]] || die '不能同时指定 --keep-config 和 --purge'
            mode=keep
            ;;
        --purge)
            [[ -z $mode || $mode == purge ]] || die '不能同时指定 --keep-config 和 --purge'
            mode=purge
            ;;
        --no-autoremove) autoremove=false ;;
        --dry-run) dry_run=true ;;
        -y|--yes) assume_yes=true ;;
        -h|--help)
            usage
            exit 0
            ;;
        *) die "未知参数：$1（使用 --help 查看帮助）" ;;
    esac
    shift
done

if [[ -z $mode ]]; then
    [[ -t 0 ]] || die '非交互环境请指定 --keep-config 或 --purge'
    printf '%s\n' '1) 保留 Nginx 配置' '2) 清除 Nginx 配置'
    read -r -p '请选择 [1/2]：' choice
    case "$choice" in
        1) mode=keep ;;
        2) mode=purge ;;
        *) die '无效输入，请输入 1 或 2' ;;
    esac
fi

command -v apt-get >/dev/null 2>&1 || die '未找到 apt-get，仅支持 Debian/Ubuntu 等 apt 系统'
command -v dpkg-query >/dev/null 2>&1 || die '未找到 dpkg-query'

packages=()
while IFS=$'\t' read -r package status; do
    [[ $package == nginx* || $package == libnginx-mod-* ]] || continue
    if [[ $status == *' installed' || ( $mode == purge && $status == *' config-files' ) ]]; then
        packages+=("$package")
    fi
done < <(dpkg-query -W -f='${binary:Package}\t${Status}\n' 2>/dev/null)

if ((${#packages[@]} == 0)); then
    printf '%s\n' '未发现可卸载的 Nginx 软件包。'
    exit 0
fi

if [[ $mode == keep ]]; then
    action=remove
    description='卸载并保留配置'
    result='配置已保留'
else
    action=purge
    description='彻底卸载'
    result='软件包配置已清除'
fi

printf '将%s以下软件包：\n' "$description"
printf '  %s\n' "${packages[@]}"

privilege=()
if ! $dry_run && ((EUID != 0)); then
    command -v sudo >/dev/null 2>&1 || die '请使用 root 用户运行，或安装 sudo'
    privilege=(sudo)
fi

run_apt() {
    local options=()
    $dry_run && options+=(--simulate)
    $assume_yes && options+=(-y)
    $autoremove && options+=(--autoremove)

    printf '执行：'
    printf ' %q' "${privilege[@]}" apt-get "${options[@]}" "$@"
    printf '\n'
    "${privilege[@]}" apt-get "${options[@]}" "$@"
}

run_apt "$action" "${packages[@]}"

if $dry_run; then
    printf '%s\n' '预演完成，系统未被修改。'
else
    printf 'Nginx 卸载完成（%s）。\n' "$result"
fi
