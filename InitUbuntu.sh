#!/bin/bash

stty erase ^h

INCHINA=0 

# banner
function welcome(){
	echo -e "\033[36m
   ____     _ __          __  ____             __
  /  _/__  (_) /_        / / / / /  __ _____  / /___ __
 _/ // _ \/ / __/       / /_/ / _ \/ // / _ \/ __/ // /
/___/_//_/_/\__/        \____/_.__/\_,_/_//_/\__/\_,_/

\033[0m"
}

# pretty output
function info(){
	echo -e "\033[34m[*]\033[0m" ${1}
}

function warn(){
	echo -e "\033[33m[!]\033[0m" ${1}
}

function fail(){
	echo -e "\033[31m[-]\033[0m" ${1}
}

function success(){
	echo -e "\033[32m[+]\033[0m" ${1}
}

function waiting(){
  echo -e -n "\033[5m[.]\033[5m" ${1}
}


function aptInstall(){
	sudo rm -rf /var/lib/dpkg/lock
	sudo rm -rf /var/cache/apt/archives/lock
	info "Install ${1}"
	warn "Waiting"
	if sudo apt-get install -y $1 > /dev/null;then
		success "Install ${1} Success"
	else
		fail "Install ${1} Failed"
	fi
}

function tmpUpdate(){
	info "Update system"
	warn "Waiting"
	sudo rm -rf /var/lib/dpkg/lock
	sudo rm -rf /var/cache/apt/archives/lock
	sudo apt-get update > /dev/null
}


# autoSend(){
# 	expect<<EOF
# 	spawn $1
# 	expect {
# 		$2 {send $3}
# 	}
# 	expect eof
# EOF
# }

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



function basicTools(){
	if [ ${1} -eq 1 ];then
		aptInstall "curl"
	elif [ ${1} -eq 2 ];then
		aptInstall "git"
	fi
}

function terminalTools(){
	if [ ${1} -eq 1 ];then
	aptInstall "zsh"
		if [ $? -eq 0 ];then
			wget -q  https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh
			# config for zsh
			wget -q -O ~/.zshrc https://gist.githubusercontent.com/XuCcc/2f3d5d05a39f10b871aa10095318ca22/raw/f58d03c981b0c278ca8a4fe3bede84f2cfc9bf25/zshrc
			chsh -s /bin/zsh
		else
			fail "zsh install failed"
		fi
	elif [ ${1} -eq 2 ];then
		aptInstall "tmux"
		# config for tmux
		wget -q -O ~/.tmux.conf https://gist.githubusercontent.com/XuCcc/2f3d5d05a39f10b871aa10095318ca22/raw/e426d859ba69901e4ac3d4a7adb9ab8c4896aaa9/tmux.conf
	elif [ ${1} -eq 3 ];then
		info "Install powerline-status"
		sudo pip -q install powerline-status
	elif [ ${1} -eq 4 ];then
      info "Install SpaceVim"
      curl -sLf https://spacevim.org/install.sh | bash
	fi
}

function developTools(){

# info "Set pip source to https://pypi.tuna.tsinghua.edu.cn/simple"
	# printf "[global]\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple\n" >> .pip/pip.conf
	# info "Set npm registry to https://registry.npm.taobao.org"
	# npm config set registry https://registry.npm.taobao.org


	if [ ${1} -eq 1 ];then
		aptInstall "python-pip"
		# TODO 源
	elif [ ${1} -eq 2 ];then
		info "Install ptpython"
		sudo pip -q install ptpython
		# config for ptpython
		mkdir -p ~/.ptpython
		wget -q -O ~/.ptpython/config.py https://gist.githubusercontent.com/XuCcc/2f3d5d05a39f10b871aa10095318ca22/raw/d2ae31bc68ebaf18078ca9bbd8f7c03f50b5c94b/config.py
	elif [ ${1} -eq 3 ];then
		aptInstall "ruby-full"
		# TODO 
    elif [ ${1} -eq 4 ];then
        sudo apt-get remove -y docker docker-engine docker.io
        sudo apt-get install -y  apt-transport-https ca-certificates  software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	    sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
        tmpUpdate
        aptInstall "docker-ce"
        if [ $? -eq 0 ];then
            sudo gpasswd -a ${USER} docker
        else
            fail "Install docker failed"
        fi
    elif [ ${1} -eq 5 ];then
        aptInstall "default-jdk"
    elif [ ${1} -eq 6 ];then
        curl -sL https://deb.nodesource.com/setup_9.x | sudo -E bash -
        aptInstall "nodejs"
	fi
}

function dailyTools(){
	if [ ${1} -eq 1 ];then
		aptInstall "screenfetch"
	elif [ ${1} -eq 2 ];then
		info "Install shadowsocks"
		sudo pip install shadowsocks
	elif [ ${1} -eq 3 ];then
		echo
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
			;;
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




# Insttall Menu
function installMain(){
	clear
    # Check GFW
    info  "Find Address..Waiting"
    msg=`curl  http://ipinfo.io/ -s`
    if echo $msg|grep -Eqi "China";then
        $INCHINA=1 
        warn "In China"
    else
        success "Not In China"
    fi
    welcome
    while true
	do
		info "Please choose the application:"

		info "Basic Tools"
		echo -e "11->curl\t\t 12->git"
		echo -e "10->All Basic Tools"
		info "Terminal Tools"
		echo -e "21->oh-my-zsh\t 22->tmux\t 23->powerline\t 24->SpaceVim"
		echo -e "20->All Terminal Tools"
		info "Develop Tools"
		echo -e "31->ipython\t 32->ptpython\t 33->ruby\t 34->Docker\t 35->JDK\t 36->NodeJs"
		echo -e "30->All Develop Tools"
		info "Daily Tools"
		echo -e "41->screenfetch\t 42->shadowsocks"
        echo -e "40->All Daily Tools"
		warn "Exit"
		echo -e "0 ->exit"

		info "Your InPut"
        echo -n "==> "
		read choice
		case $choice in
			"0")
			exit 0
			;;
			"10")
			basicTools "1"
			basicTools "2"
			;;
			"11")
			basicTools "1"
			;;
			"12")
			basicTools "2"
			;;
			"20")
			terminalTools "1"
			terminalTools "2"
			terminalTools "3"
            terminalTools "4"
			;;
			"21")
			terminalTools "1"
			;;
			"22")
			terminalTools "2"
			;;
			"23")
			terminalTools "3"
			;;
            "24")
            terminalTools "4"
            ;;
			"30")
			developTools "1"
			developTools "2"
			developTools "3"
            developTools "4"
            developTools "5"
            developTools "6"
			;;
			"31")
			developTools "1"
			;;
			"32")
			developTools "2"
			;;
			"33")
			developTools "3"
			;;
            "34")
            developTools "4"
            ;;
            "35")
            developTools "5"
            ;;
            "36")
            developTools "6"
            ;;
            "40")
            dailyTools "1"
            dailyTools "2"
            ;;
            "41")
			dailyTools "1"
			;;
			"42")
			dailyTools "2"
			;;
			*)
			fail "InPut ERROR"
			;;
		esac
		echo
		echo
	done
}
installMain

