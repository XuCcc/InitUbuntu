#!/bin/bash

PWD = `pwd`
echo $PWD

info(){
	echo -e "\033[34m[*] \033[0m" ${1}
}

install_tools(){
	sudo rm -rf /var/lib/dpkg/lock
	sudo rm -rf /var/cache/apt/archives/lock
	sudo apt install -y $1
	if [ $? -eq 0 ];then
		echo -e "\033[32m[+] \033[0m" "Install ${1} Success"
		sleep 2
	else
		echo -e "\033[31m[-] \033[0m" "Install ${1} Fail"
		sleep 2
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

update_source(){
	info "Change sources to aliyun"
	sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
	sudo sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
}

update_system(){
	info "update system"
	sudo rm -rf /var/lib/dpkg/lock
	sudo rm -rf /var/cache/apt/archives/lock
	sudo apt-get update
	sudo apt-get upgrade  -y
}

basic_install(){
	info "Basic installation:curl,git,expect"

	install_tools "expect"
	install_tools "curl"
	install_tools "git"
	# sed -i 's/start on runlevel/#start on runlevel/g' /etc/init/ssh.conf

}

environment(){
	send_command "add-apt-repository ppa:webupd8team/java" "Ctrl+c" "\r"

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
	add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	sudo apt-get update

	info "Install python-pip"
	install_tools "python-pip"
	mkdir -p  .pip
	info "Set pip source to https://pypi.tuna.tsinghua.edu.cn/simple"
	printf "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\n" >> .pip/pip.conf
	sudo pip install --upgrade pip

	info "Install java"
	install_tools "default-jre"
	install_tools "default-jdk"
	install_tools "oracle-java-installer"
	if [ $? -eq 0 ];then
		sudo update-alternatives --config java
	else
		info "Install java failed"
	fi

	info "Install ruby"
	install_tools "ruby-full"
	if [ $? -eq 0 ];then
		echo
		gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
	else
		info "Install Ruby failed"
	fi

	info "Install node.js v6.10.1"
	wget -O node-v6.10.1.tar.xz https://npm.taobao.org/mirrors/node/v6.10.1/node-v6.10.1-linux-x64.tar.xz
	tar -xJf node-v6.10.1.tar.xz
	mv node-v6.10.1-linux-x64/  /opt/
	ln -s /opt/node-v6.10.1-linux-x64/bin/node  /usr/local/bin/
	ln -s /opt/node-v6.10.1-linux-x64/bin/npm /usr/local/bin/
	ln -s /opt/node-v6.10.1-linux-x64/lib/node_modules/npm/bin/node-gyp-bin/node-gyp /usr/local/bin/
	info "Set npm registry to https://registry.npm.taobao.org"
	npm config set registry https://registry.npm.taobao.org
	rm node-v6.10.1.tar.xz
	rm -rf node-v6.10.1-linux-x64

	info "docker"
	install_tools "docker-ce"
	if [ $? -eq 0 ];then
		printf "{\n\t\"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]\n}\n" >> /etc/docker/daemon.json
		gpasswd -a ${USER} docker
	else
		info "Install docker failed"
	fi
}

tools(){
	info "Install: vim,zsh,tmux,ipython"
	install_tools "vim"
	install_tools "tmux"
	sudo pip install  powerline-status

	install_tools "ipython"
	install_tools "zsh"
	if [ $? -eq 0 ];then
		wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
		sed -i 's/robbyrussell/ys/g' .zshrc
		sed -i 's/(git)/(git extract autojump wd)/g'  .zshrc
		chsh -s /bin/zsh
	else
		info "zsh install failed"
	fi
}

main(){
	clear
	info "Initialize Ubuntu"
	info "Chose one of the following"
	while true
	do
		echo
		echo "1. update source to Aliyun"
		echo "2. update system and install: curl,git,expect"
		echo "3. config environment: pip,java,ruby,nodejs,docker"
		echo "4. install tools: vim,zsh,tmux,ipython"
		echo
		info "Please input:"

		read choice
		case "$choice" in
			"1")
			update_source
			clear
			info "Update Source Done"
			;;
			"2")
			update_system
			basic_install
			clear
			info "Update System and Basicial install Done"
			;;
			"3")
			environment
			clear
			info "Config Environment Done"
			;;
			"4")
			tools
			clear
			info "Install Tools Done"
			;;
			*)
			info "Input ERROR"
			clear
		esac
	done
		# info "Ruby sources is `su xu --shell=/bin/bash -c "gem sources -u"`"
		# info	"Npm sources is `su xu --shell=/bin/bash -c "npm config get registry"`"
		# info "docker sources is `cat /etc/docker/daemon.json`"
}
main

