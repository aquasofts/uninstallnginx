#!/bin/bash

echo "如果输入 '1'，则保留nginx配置；"
echo "如果输入 '2'，则不保留nginx配置"
read input

if [ "$input" == "1" ]; then
    wget -N --no-check-certificate https://raw.githubusercontent.com/aquasofts/uninstallnginx/main/sh/un1.sh && chmod +x un1.sh && ./un1.sh
elif [ "$input" == "2" ]; then
    wget -N --no-check-certificate https://raw.githubusercontent.com/aquasofts/uninstallnginx/main/sh/un2.sh && chmod +x un2.sh && ./un2.sh
else
    echo "无效输入，请输入 '1' 或 '2' "
fi