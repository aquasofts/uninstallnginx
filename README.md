<h1>Uninstall nginx</h1>

### 使用方法

一键脚本：

`wget -qO uninstall.sh https://raw.githubusercontent.com/aquasofts/uninstallnginx/main/uninstall.sh && chmod +x uninstall.sh && ./uninstall.sh`

直接指定模式：`--keep-config` 保留配置，`--purge` 清除配置；另支持 `--dry-run`、`--no-autoremove` 和 `-y`。

例如：`./uninstall.sh --purge --dry-run`

### 啰嗦一句

自动识别已安装的 Nginx 软件包和模块，不再下载额外子脚本；旧版代码放在 `old` 目录。

适用于 Debian/Ubuntu 等 apt 系统，目前仅在 Debian 12 测试通过。
