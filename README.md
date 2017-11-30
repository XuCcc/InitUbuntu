<h1 align="center">Init Ubuntu</h1>

[![Travis](https://img.shields.io/travis/XuCcc/InitUbuntu.svg?style=plastic)]()
[![Github release](https://img.shields.io/badge/release-0.1.0-green.svg)](https://github.com/XuCcc/InitUbuntu/releases/tag/0.1.0)
[![platform](https://img.shields.io/badge/platform-ubuntu-lightgrey.svg)]()

- [中文文档](README-cn.md)

## Screenshot

### menu

![menu](images/menu.png)

### run

![run](images/run.png)

## Profile

- source

```sh
# os
sudo sed -i 's/[a-zA-Z]*.archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
# sudo sed -i 's/[a-zA-Z]*.archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
...
# pip
printf "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\n" >> .pip/pip.conf

# npm
gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org

# docker
echo -e "{\n\t\"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]\n}\n" >> /etc/docker/daemon.json
```

- terminal config
	- [tmux & zsh](https://gist.github.com/XuCcc/2f3d5d05a39f10b871aa10095318ca22)

- vim
	- [spf13](http://vim.spf13.com/)

## Result

### Terminal

![term](images/term.png)

### Gui

![desktop](images/desktop.png)