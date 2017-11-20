#!/bin/bash

stty erase ^h

PWD=`pwd`

info(){
	echo -e "\033[34m[*]\033[0m" ${1}
}

fail(){
	echo -e "\033[31m[-]\033[0m" ${1}
}

success(){
	echo -e "\033[32m[+]\033[0m" ${1}
}
aptInstall(){
	sudo rm -rf /var/lib/dpkg/lock
	sudo rm -rf /var/cache/apt/archives/lock
	info "Install ${1}"
	info "Waiting"
	sudo apt install -y $1 > /dev/null
	if [ $? -eq 0 ];then
		success "Install ${1} Success"
		sleep 1
	else
		fail "Install ${1} Failed"
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
	# sudo sed -i 's/[a-zA-Z]*.archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
}

updateSystem(){
	tmpUpdate
	sudo apt-get upgrade  -y  -q
}


tmpUpdate(){
	info "Update system"
	success "Waiting"
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
	sudo add-apt-repository -y ppa:webupd8team/java

	curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

	tmpUpdate

	aptInstall "python-pip"
	mkdir -p  ~/.pip
	# info "Set pip source to https://pypi.tuna.tsinghua.edu.cn/simple"
	# printf "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\n" >> .pip/pip.conf
	sudo pip install --upgrade pip

	aptInstall "default-jre"
	aptInstall "default-jdk"
	aptInstall "oracle-java8-installer"
	if [ $? -eq 0 ];then
		sudo update-alternatives --config java
	else
		fail "Install java failed"
	fi

	aptInstall "ruby-full"
	if [ $? -eq 0 ];then
		echo
		# gem sources --add https://gems.ruby-china.org/ --remove https://rubygems.org/
	else
		fail "Install Ruby failed"
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
		fail "Install docker failed"
	fi
}

commonTools(){
	aptInstall "vim"
	aptInstall "tmux"
	sudo pip install  powerline-status
	wget -O ~/.tmux.conf https://gist.githubusercontent.com/XuCcc/2f3d5d05a39f10b871aa10095318ca22/raw/e426d859ba69901e4ac3d4a7adb9ab8c4896aaa9/tmux.conf

	aptInstall "screenfetch"
	aptInstall "ipython"
	aptInstall "zsh"
	if [ $? -eq 0 ];then
		wget -q  https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
		wget -O ~/.zshrc https://gist.githubusercontent.com/XuCcc/2f3d5d05a39f10b871aa10095318ca22/raw/f58d03c981b0c278ca8a4fe3bede84f2cfc9bf25/zshrc
		chsh -s /bin/zsh
	else
		fail "zsh install failed"
	fi
}

systemSet(){
	info "Turn off warning"
	sudo sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

	info "Single window minimization"
	gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/launcher-minimize-window true

	info "Sync Time"
	sudo timedatectl set-local-rtc 1
}

systemClean(){
	info "Delete infrequently used software"
	sudo apt-get remove -y unity-webapps-common thunderbird totem rhythmbox gnome-mines cheese transmission-common gnome-orca webbrowser-app gnome-sudoku  onboard deja-dup simple-scan gnome-mahjongg aisleriot
	sudo apt-get remove -y libreoffice* yelp  gnome-software
	sudo apt-get autoremove -y -q
}

desktopBeauty(){
	sudo add-apt-repository -y ppa:noobslab/themes
	sudo add-apt-repository -y ppa:noobslab/icons

	tmpUpdate

	aptInstall "unity-tweak-tool"
	aptInstall "docky"
	aptInstall "flatabulous-theme"
	aptInstall "ultra-flat-icons"
}

desktopTools(){
	while true
	do
		clear
		info "GUI Tools for Ubuntu Desktop"
		info "Chose one of the following"
		echo
		echo "1. Theme and icons: noobslab"
		echo "2. Sublime-Text 3"
		echo "3. Steam"
		echo "4. Albert"
		echo "5. SystemBack"
		echo "6. fluxgui"
		echo
		echo "b. Back"

		read choice
		case $choice in
			"1")
			desktopBeauty
			;;
			"2")
			sudo add-apt-repository -y ppa:webupd8team/sublime-text-3
			tmpUpdate
			aptInstall "sublime-text"
			;;
			"3")
			aptInstall "steam"
			;;
			"4")
			sudo add-apt-repository -y ppa:nilarimogard/webupd8
			tmpUpdate
			aptInstall "albert"
			;;
			"5")
			sudo add-apt-repository -y ppa:nemh/systemback
			tmpUpdate
			aptInstall "systemback"
			;;
			"6")
			sudo add-apt-repository -y ppa:nathan-renniewaldock/flux
			tmpUpdate
			aptInstall "fluxgui"
			"b")
			clear
			break
			;;
			*)
			fail "Input ERROR"
			;;
		esac
	done
	# autoSend "sudo add-apt-repository ppa:webupd8team/unstable" "Ctrl+c" "\r"
	# autoSend "sudo add-apt-repository ppa:noobslab/macbuntu" "Ctrl+c" "\r"
	# autoSend "sudo add-apt-repository ppa:otto-kesselgulasch/gimp" "Ctrl+c" "\r"
	# autoSend "sudo add-apt-repository ppa:webupd8team/sublime-text-3" "Ctrl+c" "\r"
	# autoSend "sudo add-apt-repository ppa:nilarimogard/webupd8" "Ctrl+c" "\r"
	#
	# wget http://www.linuxidc.com/files/repo/google-chrome.list -P /etc/apt/sources.list.d/
	# wget -q -O - https://dl.google.com/linux/linux_signing_key.pub  | sudo apt-key add -
	# wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
	#
	#
	# sudo add-apt-repository multiverse
	# tmpUpdate
	#
	# aptInstall "shutter"
	# aptInstall "albert"
	# aptInstall "bleachbit"
	# aptInstall "steam"
	# aptInstall "gimp"
	#
	# wget -q -O wps.deb http://kdl.cc.ksosoft.com/wps-community/download/a21/wps-office_10.1.0.5672~a21_amd64.deb
	# dpkg -i wps.deb
	# rm wps.deb

}

main(){
	clear
	info "Initialize Ubuntu"
	info "Chose one of the following"
	while true
	do
		echo
		info "Ubuntu Serve"
		echo
		echo "1. Update source to USTC"
		echo "2. Update system and install: curl,git,expect"
		echo "3. Config environment: pip,java,ruby,nodejs,docker"
		echo "4. Instal tools: vim,zsh,tmux,ipython"
		echo "5. Auto Complete Step: 2-4"
		echo
		info "Ubuntu Desktop"
		echo
		echo "6. System Clean"
		echo "7. Tools"
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
			clear
			info "Done"
			;;
			"7")
			desktopTools
			;;
			*)
			clear
			fail "Input ERROR"
			;;
		esac
	done
}


main

