<h1 align="center">Init Ubuntu</h1>

[![Travis](https://img.shields.io/travis/XuCcc/InitUbuntu.svg?style=plastic)]()
[![Github release](https://img.shields.io/badge/release-0.1.0-green.svg)](https://github.com/XuCcc/InitUbuntu/releases/tag/0.1.0)
[![](https://img.shields.io/badge/platform-ubuntu-lightgrey.svg)]()

- [Document](README.md)

## 截图

菜单

![menu](images/menu.png)

运行截图

![run](images/run.png)

## 配置文件

- source.list

可以自己切换为Aliyun的,感觉最近Aliyun update有点慢 = =

```sh
sudo sed -i 's/[a-zA-Z]*.archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
# sudo sed -i 's/[a-zA-Z]*.archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
```

- zsh && tmux

集成了个人最常用的几个功能   

https://gist.github.com/XuCcc/2f3d5d05a39f10b871aa10095318ca22

- 各种源的替换,按需求取消对应注释即可

```sh
# pip
printf "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\n" >> .pip/pip.conf

# npm
gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org

# docker
echo -e "{\n\t\"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]\n}\n" >> /etc/docker/daemon.json
```

## 最终效果

### 终端

![term](images/term.png)

### Desktop图形化

![desktop](images/desktop.png)

