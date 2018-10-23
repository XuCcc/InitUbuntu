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
VERSION='0.3.1'
# system
SYSTEM="$(uname -s)"
INFO=`cat /etc/issue`

function welcome(){
    echo -e "\033[36m
   ____     _ __          __  ____             __
  /  _/__  (_) /_        / / / / /  __ _____  / /___ __
 _/ // _ \/ / __/       / /_/ / _ \/ // / _ \/ __/ // /
/___/_//_/_/\__/        \____/_.__/\_,_/_//_/\__/\_,_/

			Version: ${VERSION} 	by: Xu
			System:  ${INFO%\\l}
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

cmdCheck(){
	if ! hash $1 &>/dev/null
	then
		error "Command [${1}] not found"
		return 1
	fi
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
		mkdir -p ~/.pip
	    echo -e "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple" >> ~/.pip/pip.conf
	elif [ ${1} -eq 3 ];then
		# docker dameon.json
		info "[USTC] docker /etc/docker/daemon.json"
    	sudo echo -e "{\n\"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]\n}" > /etc/docker/daemon.json
    fi
}

basicToolsInstall(){
	aptInstall "curl"
	aptInstall "git"
	aptInstall "vim"
}

commonTools(){
	case ${1} in
		1)
			info "aria2 is a lightweight multi-protocol & multi-source command-line download utility"
			aptInstall aria2
			;;
	esac
}

pythonDevelopEnv(){
	case ${1} in
		1)
			info "pip2&pip3"
			aptInstall "python-dev python-pip python3-dev python3-pip"
			;;
		2)
			info "pyenv: Simple Python version management"
			aptInstall "make build-essential libssl-dev zlib1g-dev libbz2-dev
						libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev
						xz-utils tk-dev libffi-dev liblzma-dev"
			curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
			echo '# pyenv' >> ~/.zshrc
			echo 'export PATH="/home/xu/.pyenv/bin:$PATH"' >> ~/.zshrc
			echo '"$(pyenv init -)"' >> ~/.zshrc
			echo '"$(pyenv virtualenv-init -)"' >> ~/.zshrc
			;;
		3)
			info "pipenv: Python Development Workflow for Humans"
			pip install --user pipenv
			echo '# pipenv' >> ~/.zshrc
			echo 'alias pipenv="$HOME/.local/bin/pipenv"' >> ~/.zshrc
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
		2)
			info "maven: A software project management and comprehension tool"
			aptInstall maven
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
			info "docker-compose: a tool for defining and running multi-container Docker applications"
			pip install docker-compose
			;;
	esac
}

shellDevelopEnv(){
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
			info "Config zsh and tmux"
			cp config/zsh ~/.zshrc
			cp config/tmux ~/.tmux.conf
			;;
	esac
}


help(){
	echo "Usage: bash InitUbuntu.sh [type] [target] [options]"
	echo
	echo "TYPE and TARGET"
	echo
	echo "[update]"
	echo "[source]"
	echo "	apt:    http://mirrors.ustc.edu.cn/ubuntu/"
	echo "	pip:    https://pypi.tuna.tsinghua.edu.cn/simple"
	echo "	docker: https://docker.mirrors.ustc.edu.cn"
	echo "[python]"
	echo "	pip: pip2&pip3"
	echo "	pyenv: Simple Python version management"
	echo "	pipenv: Python Development Workflow for Humans"
	echo "	ptpython: an advanced Python REPL"
	echo "[java]"
	echo "	jdk: Oracle JDK"
	echo "	maven: A software project management and comprehension tool"
	echo "[docker]"
	echo "	docker-ce: "
	echo "	docker-compose: A tool for defining and running multi-container Docker applications"
	echo "[shell]"
	echo "	zsh:"
	echo "	zsh-syntax-highlighting: Fish shell like syntax highlighting for Zsh"
	echo "	autojump: shell extension to jump to frequently used directories"
	echo "	tmux: terminal multiplexer"
	echo "	config: zsh&tmux config of Xu"
	echo
	echo "OPTIONS"
	echo
	echo " -b,--basic 	Basic Tools Install: curl,git,vim"
	echo " -v,--Version 	Show version"
	echo " -h,--help 	Show this help message and exit"
	echo
	echo "Example:"
	echo
	echo "	Update System"
	echo "		bash InitUbuntu.sh update"
	echo "	Install java maven"
	echo "		bash InitUbuntu.sh java meven"
	echo "	Install all shell tools"
	echo "		bash InitUbuntu.sh shell"
}

main(){
	if [ $# -eq 0 ]
	then
		welcome
		echo "Usage: bash InitUbuntu.sh [type] [target] [options]"
		echo
		echo "InitUbuntu.sh [--help|-h] [--version|-v] [--basic|-b]"
		echo "	{update,source,python,java,docker,shell} [target]"
		echo
		cmdCheck curl
		cmdCheck git
	else
		case $@ in
			"update")
				updateANDUpgradeSystem
				;;
			"source")
				changeSourceForChina 1
				changeSourceForChina 2
				changeSourceForChina 3
				;;
			"source apt")
				changeSourceForChina 1
				;;
			"source pip")
				changeSourceForChina 2
				;;
			"source docker")
				changeSourceForChina 3
				;;
			"python")
				pythonDevelopEnv 1
				pythonDevelopEnv 2
				pythonDevelopEnv 3
				pythonDevelopEnv 4
				;;
			"python pip")
				pythonDevelopEnv 1
				;;
			"python pyenv")
				pythonDevelopEnv 2
				;;
			"python pipenv")
				pythonDevelopEnv 3
				;;
			"python ptpython")
				pythonDevelopEnv 4
				;;
			"java")
				javaDevelopEnv 1
				javaDevelopEnv 2
				;;
			"java jdk")
				javaDevelopEnv 1
				;;
			"java maven")
				javaDevelopEnv 2
				;;
			"docker")
				dockerDevelopEnv 1
				dockerDevelopEnv 2
				;;
			"docker docker-ce")
				dockerDevelopEnv 1
				;;
			"docker docker-compose")
				dockerDevelopEnv 2
				;;
			"shell")
				shellDevelopEnv 1
				shellDevelopEnv 2
				shellDevelopEnv 3
				shellDevelopEnv 4
				shellDevelopEnv 5
				;;
			"shell zsh")
				shellDevelopEnv 1
				;;
			"shell zsh-syntax-highlighting")
				shellDevelopEnv 2
				;;
			"shell autojump")
				shellDevelopEnv 3
				;;
			"shell tmux")
				shellDevelopEnv 4
				;;
			"shell config")
				shellDevelopEnv 5
				;;
			--basic|-b)
				basicToolsInstall
				;;
			--version|-v)
				echo "Version: ${VERSION}"
				;;
			--help|-h)
				help
				;;
		esac
	fi
}

main $@	
