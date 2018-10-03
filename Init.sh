#!/bin/bash

# Init option {{{
Color_off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# verison
VERSION='0.2.0'
# system
SYSTEM="$(uname -s)"

function welcome(){
    echo -e "\033[36m
   ____     _ __          __  ____             __
  /  _/__  (_) /_        / / / / /  __ _____  / /___ __
 _/ // _ \/ / __/       / /_/ / _ \/ // / _ \/ __/ // /
/___/_//_/_/\__/        \____/_.__/\_,_/_//_/\__/\_,_/

\033[0m"
}

# success/info/error/warn {{{
msg() {
  printf '%b\n' "$1" >&2
}

info() {
  msg "${Blue}[➭]${Color_off} ${1}${2}"
}

warn () {
  msg "${Red}[►]${Color_off} ${1}${2}"
}

error() {
  msg "${Red}[✘]${Color_off} ${1}${2}"
  exit 1
}
success() {
  msg "${Green}[✔]${Color_off} ${1}${2}"
}

aptInstall(){
    # sudo rm -rf /var/lib/dpkg/lock
    # sudo rm -rf /var/cache/apt/archives/lock
    info "Install ${1}"
    warn "Waiting"
    if sudo apt-get install -y $1 > /dev/null;then
        success "Install ${1} Success"
    else
        fail "Install ${1} Failed"
    fi
}

updateANDUpgradeSystem(){
    info "Update system"
    warn "Waiting"
    # sudo rm -rf /var/lib/dpkg/lock
    # sudo rm -rf /var/cache/apt/archives/lock
    sudo apt-get update > /dev/null
    sudo apt-get upgrade -y -q
}

changeSourceForChina(){
	if [ ${1} -eq 1 ];then
		# etc/sources.list
		info "[USTC] System /etc/apt/sources.list"
	    sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
	    sudo sed -i 's/[a-zA-Z]*.archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
        # sudo sed -i 's/[a-zA-Z]*.archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
	elif [ ${1} -eq 2 ];then
		# python pip sources
		info "[tsinghua] python pip ~/.pip/pip.conf"
	    printf "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\n" >> .pip/pip.conf
	elif [ ${1} -eq 3 ];then
		# docker dameon.json
		info "[USTC] docker /etc/docker/daemon.json"
    	sudo echo -e "{\n\"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]\n}" > /etc/docker/daemon.json
    fi
}

basicToolsInstall(){
	aptInstall "curl"
	aptInstall "git"
}

pythonDevelopEnv(){
	case ${1} in
		1)
			info "pip2 && pip3"
			aptInstall "python-dev python-pip python3-dev python3-pip"
			;;
		2)
			info "pyenv: Simple Python version management"
			curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
			;;
		3)
			info "pipenv: Python Development Workflow for Humans"
			curl https://raw.githubusercontent.com/kennethreitz/pipenv/master/get-pipenv.py | python
			;;
		4)
			info "ptpython: an advanced Python REPL"
			pip install ptpython
			;;
	esac
}


javaDevelopEnv(){
	case ${1} in
		1)
			info "Oracle JDK"
			sudo add-apt-repository -y ppa:webupd8team/java
			sudo apt update > /dev/null
			sudo apt install -y oracle-java8-set-default
			;;
	esac
}

dockerDevelopEnv(){
	case ${1} in
		1)
			info "docker-ce"
			curl https://get.docker.com/|bash
			;;
		2)
			info "docker-compose"
			pip install docker-compose
			;;
	esac
}

zshDevelopEnv(){
	case ${1} in
		1)
			aptInstall "zsh"
			sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
			;;
		2)
			info "zsh-syntax-highlighting"
			git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
			;;
		3)
			aptInstall "autojump"
			;;
		4)
			aptInstall "tmux"
			;;
		5)
			info "Config zsh and tmux with Xu's style from https://gist.githubusercontent.com/XuCcc/"
			wget -q -O ~/.zshrc https://gist.githubusercontent.com/XuCcc/9859c4721ccc4949c8583d3202fc6483/raw/dbb84320118c36bd3e628645736a87f7f1133a43/zshrc
			wget -q -O ~/.tmux.conf https://gist.githubusercontent.com/XuCcc/5e6b50e0d07f7c82b8f880e2ad59b6a9/raw/250fd957fd7bf57b0dbaacda8fabad6f7fc5a53b/tmux.conf
			;;
	esac
}



welcome
