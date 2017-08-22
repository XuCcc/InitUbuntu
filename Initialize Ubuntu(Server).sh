#!/bin/sh
# @Date    : 2017-03-30 19:58:52
# @Author  : Xu
# @Link    : http://xuccc.github.io/
# @Version : $Id$
# @Description:

DIR="$( cd "$( dirname "$0"  )" && pwd  )"
ali_sources="# deb cdrom:[Ubuntu 16.04 LTS _Xenial Xerus_ - Release amd64 (20160420.1)]/ xenial main restricted\ndeb-src http://archive.ubuntu.com/ubuntu xenial main restricted #Added by software-properties\ndeb http://mirrors.aliyun.com/ubuntu/ xenial main restricted\ndeb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe #Added by software-properties\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted\ndeb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted multiverse universe #Added by software-properties\ndeb http://mirrors.aliyun.com/ubuntu/ xenial universe\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe\ndeb http://mirrors.aliyun.com/ubuntu/ xenial multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse #Added by software-properties\ndeb http://archive.canonical.com/ubuntu xenial partner\ndeb-src http://archive.canonical.com/ubuntu xenial partner\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted\ndeb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted multiverse universe #Added by software-properties\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-security universe\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse"
backup_path="/media/xu/Backups/ubuntu"
success=""
fail=""

message(){
	echo "====================================================================="
	echo $1
	echo "====================================================================="
}
install_tools(){
	rm -rf /var/lib/dpkg/lock
	rm -rf /var/cache/apt/archives/lock
	apt install -y $1
	if [ $? -eq 0 ];then
		echo "-----------------------------------------------------------------"
		echo "Successfully install ${1}---------------------------------"
		echo "-----------------------------------------------------------------"
		sleep 2
		success=${success}$1"\n"


	else
		echo "-----------------------------------------------------------------"
		echo "Install ${1} failed---------------------------------------"
		echo "-----------------------------------------------------------------"
		sleep 2
		fail=${fail}$1"\n"
	fi
}

backup_system(){
	tar -cvpzf $backup_path --exclude=/proc --exclude=/lost+found --exclude=/mnt --exclude=/sys --exclude=/media /
}

system_setting(){
	message "Change sources to aliyun"
	cp /etc/apt/sources.list /etc/apt/sources.list.old
	rm /etc/apt/sources.list
	echo $ali_sources >> /etc/apt/sources.list
}

update_system(){
	message "update system"
	rm -rf /var/lib/dpkg/lock
	rm -rf /var/cache/apt/archives/lock
	apt-get update
	apt-get upgrade  -y
}
basic_install(){
	message "Basic installation:curl,git,openssh,expect......."

	install_tools "expect"
	install_tools "curl"
	install_tools "git"
	install_tools "openssh-server"
	sed -i 's/start on runlevel/#start on runlevel/g' /etc/init/ssh.conf

	apt-get update
	
}
environment_deployment(){
	message "Install python-pip"
	install_tools "python-pip"
	mkdir .pip
	printf "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\n" >> .pip/pip.conf
	pip install --upgrade pip

	pip install lxml
	pip install requests
	pip install gmpy

	send_command "add-apt-repository ppa:webupd8team/java" "Ctrl+c" "\r"
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	rm -rf /var/lib/dpkg/lock
	rm -rf /var/cache/apt/archives/lock
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt-get update

	message "Install java"
	install_tools "oracle-java8-installer"
	if [ $? -eq 0 ];then
		install_tools "oracle-java8-set-default"
	else
		message "Install java failed"
	fi

	message "Install ruby"
	install_tools "ruby-full"
	if [ $? -eq 0 ];then
		su xu --shell=/bin/bash -c "gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/"
	else
		message "Install Ruby failed"
	fi

	message "Install node.js"
	wget -O node-v6.10.1.tar.xz https://npm.taobao.org/mirrors/node/v6.10.1/node-v6.10.1-linux-x64.tar.xz
	tar -xJf node-v6.10.1.tar.xz
	mv node-v6.10.1-linux-x64/  /opt/
	ln -s /opt/node-v6.10.1-linux-x64/bin/node  /usr/local/bin/
	ln -s /opt/node-v6.10.1-linux-x64/bin/npm /usr/local/bin/
	ln -s /opt/node-v6.10.1-linux-x64/lib/node_modules/npm/bin/node-gyp-bin/node-gyp /usr/local/bin/
	su xu --shell=/bin/bash -c "npm config set registry https://registry.npm.taobao.org"
	rm node-v6.10.1.tar.xz
	rm -rf node-v6.10.1-linux-x64

	message "docker"
	#apt-get install linux-image-extra-$(uname -r) -y
	install_tools "docker-ce"
	if [ $? -eq 0 ];then
		printf "{\n\t\"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]\n}\n" >> /etc/docker/daemon.json
	else
		message "Install docker failed"
	fi
}

my_tools(){
	message "Install shadowsocks\nchrome\natom\nsublime3\nzsh\tmux"

	install_tools "vim"
	install_tools "tmux"
	echo "set-option -g prefix C-a\nunbind ^a\nbind -r ^a next-window" > ~/.tmux.conf
	install_tools "ipython"
	install_tools "zsh"

	if [ $? -eq 0 ];then
		su xu --shell=/bin/bash -c "wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh"
		echo "zsh" >> $DIR/.bashrc
		sed -i 's/robbyrussell/ys/g' $DIR/.zshrc
		sed -i 's/(git)/(git extract autojump wd)/g' $DIR/.zshrc
	else
		message "zsh install failed"
	fi
}

send_command(){
	expect<<EOF
	spawn $1
	expect {
		$2 {send $3}
	}
	expect eof
EOF
}
main(){
	system_setting
	update_system
	basic_install
	environment_deployment
	my_tools

	echo "----------------Successfully installed-------------------------------"
	message $success
	echo "----------------somethings fail to installed-------------------------"
	message $fail
	message "Ruby sources is `su xu --shell=/bin/bash -c "gem sources -u"`"
	message	"Npm sources is `su xu --shell=/bin/bash -c "npm config get registry"`"
	message "docker sources is `cat /etc/docker/daemon.json`"
}
main
