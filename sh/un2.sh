    sudo apt-get purge nginx nginx-common # 卸载nginx所有文件，包括删除配置文件。

    sudo apt-get autoremove # 在上面命令结束后执行，主要是卸载删除Nginx的不再被使用的依赖包。

    sudo apt-get remove nginx-full nginx-common #卸载删除两个主要的包。

    clean

    echo 已卸载完成