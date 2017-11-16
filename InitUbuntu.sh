#!/bin/bash

stty erase ^h

PWD=`pwd`

info(){
	echo -e "\033[34m[*] \033[0m" ${1}
}

aptInstall(){
	sudo rm -rf /var/lib/dpkg/lock
	sudo rm -rf /var/cache/apt/archives/lock
	info "Install ${1}"
	info "Waiting"
	sudo apt install -y $1 > /dev/null
	if [ $? -eq 0 ];then
		echo -e "\033[32m[+] \033[0m" "Install ${1} Success"
		sleep 1
	else
		echo -e "\033[31m[-] \033[0m" "Install ${1} Fail"
		sleep 1
	fi
}

autoSend(){
	expect<<EOF
	spawn $1
	expect {
		$2 {send $3}
	}
	expect eof
EOF
}

updateSource(){
	info "Change sources to USTC"
	sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
	sudo sed -i 's/[a-zA-Z]*.archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
}

updateSystem(){
	info "Update system"
	info "Waiting"
	sudo rm -rf /var/lib/dpkg/lock
	sudo rm -rf /var/cache/apt/archives/lock
	sudo apt-get update > /dev/null
	sudo apt-get upgrade  -y  -q
}


tmpUpdate(){
	info "Update system"
	info "Waiting"
	sudo rm -rf /var/lib/dpkg/lock
	sudo rm -rf /var/cache/apt/archives/lock
	sudo apt-get update > /dev/null
}

basicInstall(){
	info "Basic installation:curl,git,expect"

	aptInstall "expect"
	aptInstall "curl"
	aptInstall "git"
	# sed -i 's/start on runlevel/#start on runlevel/g' /etc/init/ssh.conf

}

configEnv(){
	autoSend "sudo add-apt-repository ppa:webupd8team/java" "Ctrl+c" "\r"

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	tmpUpdate

	aptInstall "python-pip"
	mkdir -p  .pip
	# info "Set pip source to https://pypi.tuna.tsinghua.edu.cn/simple"
	# printf "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\n" >> .pip/pip.conf
	sudo pip install --upgrade pip

	aptInstall "default-jre"
	aptInstall "default-jdk"
	aptInstall "oracle-java8-installer"
	if [ $? -eq 0 ];then
		sudo update-alternatives --config java
	else
		info "Install java failed"
	fi

	aptInstall "ruby-full"
	if [ $? -eq 0 ];then
		echo
		# gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
	else
		info "Install Ruby failed"
	fi

	info "Install node.js v6.10.1"
	wget -q  -O node-v6.10.1.tar.xz https://npm.taobao.org/mirrors/node/v6.10.1/node-v6.10.1-linux-x64.tar.xz
	tar -xJf node-v6.10.1.tar.xz
	sudo mv node-v6.10.1-linux-x64/  /opt/
	sudo ln -s /opt/node-v6.10.1-linux-x64/bin/node  /usr/local/bin/
	sudo ln -s /opt/node-v6.10.1-linux-x64/bin/npm /usr/local/bin/
	sudo ln -s /opt/node-v6.10.1-linux-x64/lib/node_modules/npm/bin/node-gyp-bin/node-gyp /usr/local/bin/
	# info "Set npm registry to https://registry.npm.taobao.org"
	# npm config set registry https://registry.npm.taobao.org
	rm node-v6.10.1.tar.xz
	rm -rf node-v6.10.1-linux-x64

	aptInstall "docker-ce"
	if [ $? -eq 0 ];then
		# echo -e "{\n\t\"registry-mirrors\": [\"https://docker.mirrors.ustc.edu.cn\"]\n}\n" >> /etc/docker/daemon.json
		sudo gpasswd -a ${USER} docker
	else
		info "Install docker failed"
	fi
}

commonTools(){
	aptInstall "vim"
	aptInstall "tmux"
	sudo pip install  powerline-status
	wget -O .tmux.conf https://gist.githubusercontent.com/XuCcc/2f3d5d05a39f10b871aa10095318ca22/raw/e426d859ba69901e4ac3d4a7adb9ab8c4896aaa9/tmux.conf

	aptInstall "screenfetch"
	aptInstall "ipython"
	aptInstall "zsh"
	if [ $? -eq 0 ];then
		wget -q  https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
		sed -i 's/robbyrussell/half-life/g' .zshrc
		sed -i 's/  git/git extract wd/g'  .zshrc
		chsh -s /bin/zsh
	else
		info "zsh install failed"
	fi
}

systemSet(){
	info "Turn off warning"
	sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

	info "Single window minimization"
	gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/launcher-minimize-window true
}

systemClean(){
	info "Delete infrequently used software"
	sudo apt-get remove -y unity-webapps-common thunderbird totem rhythmbox gnome-mines cheese transmission-common gnome-orca webbrowser-app gnome-sudoku  onboard deja-dup simple-scan gnome-mahjongg aisleriot
	sudo apt-get remove -y libreoffice* yelp blue* gnome-software
	sudo apt-get autoremove -y -q
}

desktopBeauty(){
	autoSend "sudo add-apt-repository ppa:noobslab/themes" "Ctrl+c" "\r"
	autoSend "sudo add-apt-repository ppa:noobslab/icons" "Ctrl+c" "\r"
	autoSend "sudo add-apt-repository ppa:noobslab/macbuntu" "Ctrl+c" "\r"
	autoSend "sudo add-apt-repository ppa:numix/ppa" "Ctrl+c" "\r"

	tmpUpdate

	aptInstall "unity-tweak-tool"
	aptInstall "docky"
	aptInstall "flatabulous-theme"
	aptInstall "ultra-flat-icons"
	aptInstall "numix-gtk-theme"
	aptInstall "numix-icon-theme-circle"
}

desktopTools(){
	autoSend "sudo add-apt-repository ppa:webupd8team/unstable" "Ctrl+c" "\r"
	autoSend "sudo add-apt-repository ppa:noobslab/macbuntu" "Ctrl+c" "\r"
	autoSend "sudo add-apt-repository ppa:otto-kesselgulasch/gimp" "Ctrl+c" "\r"
	autoSend "sudo add-apt-repository ppa:webupd8team/sublime-text-3" "Ctrl+c" "\r"
	autoSend "sudo add-apt-repository ppa:nilarimogard/webupd8" "Ctrl+c" "\r"

	wget http://www.linuxidc.com/files/repo/google-chrome.list -P /etc/apt/sources.list.d/
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub  | sudo apt-key add -
	wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -


	sudo add-apt-repository multiverse
	tmpUpdate

	aptInstall "shutter"
	aptInstall "albert"
	aptInstall "bleachbit"
	aptInstall "steam"
	aptInstall "gimp"

	wget -q -O wps.deb http://kdl.cc.ksosoft.com/wps-community/download/a21/wps-office_10.1.0.5672~a21_amd64.deb
	dpkg -i wps.deb
	rm wps.deb

}

main(){
	clear
	info "Initialize Ubuntu"
	info "Chose one of the following"
	while true
	do
		echo
		echo "1. update source to USTC"
		echo "2. update system and install: curl,git,expect"
		echo "3. config environment: pip,java,ruby,nodejs,docker"
		echo "4. install tools: vim,zsh,tmux,ipython"
		echo "5. Auto Complete Step: 2-4"
		echo
		echo "6. System Clean For Ubuntu Desktop"
		echo "7. Tools For Ubuntu Desktop"
		echo
		info "Please input:"

		read choice
		case "$choice" in
			"1")
			updateSource
			clear
			info "Update Source Done"
			;;
			"2")
			updateSystem
			basicInstall
			clear
			info "Update System and Basicial install Done"
			;;
			"3")
			configEnv
			clear
			info "Config Environment Done"
			;;
			"4")
			commonTools
			clear
			info "Install Tools Done"
			;;
			"5")
			updateSystem
			basicInstall
			configEnv
			commonTools
			;;
			"6")
			systemSet
			systemClean
			info "Done"
			;;
			"7")
			desktopBeauty
			desktopTools
			;;
			*)
			clear
			info "Input ERROR"
			;;
		esac
	done
}


main

