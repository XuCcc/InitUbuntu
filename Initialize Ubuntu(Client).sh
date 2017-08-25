DIR="$( cd "$( dirname "$0"  )" && pwd  )"
ali_sources="# deb cdrom:[Ubuntu 16.04 LTS _Xenial Xerus_ - Release amd64 (20160420.1)]/ xenial main restricted\ndeb-src http://archive.ubuntu.com/ubuntu xenial main restricted #Added by software-properties\ndeb http://mirrors.aliyun.com/ubuntu/ xenial main restricted\ndeb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted multiverse universe #Added by software-properties\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted\ndeb-src http://mirrors.aliyun.com/ubuntu/ xenial-updates main restricted multiverse universe #Added by software-properties\ndeb http://mirrors.aliyun.com/ubuntu/ xenial universe\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-updates universe\ndeb http://mirrors.aliyun.com/ubuntu/ xenial multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-updates multiverse\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse\ndeb-src http://mirrors.aliyun.com/ubuntu/ xenial-backports main restricted universe multiverse #Added by software-properties\ndeb http://archive.canonical.com/ubuntu xenial partner\ndeb-src http://archive.canonical.com/ubuntu xenial partner\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted\ndeb-src http://mirrors.aliyun.com/ubuntu/ xenial-security main restricted multiverse universe #Added by software-properties\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-security universe\ndeb http://mirrors.aliyun.com/ubuntu/ xenial-security multiverse"
backup_path="/media/xu/Backups/ubuntu"
success=""
fail=""
mkdir -p tmp

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
	message "Turn off warning"
	sed -i 's/enabled=1/enabled=0/g' /etc/default/apport

	message "Single window minimization"
	su xu --shell=/bin/bash -c "gsettings set org.compiz.unityshell:/org/compiz/profiles/unity/plugins/unityshell/launcher-minimize-window true"

	message "Disable guest"
	printf "[SeatDefaults]\nallow-guest=false\n" >> /usr/share/lightdm/lightdm.conf.d/50-no-guest.conf

	message "Change sources to aliyun"
	cp /etc/apt/sources.list /etc/apt/sources.list.old
	rm /etc/apt/sources.list
	echo $ali_sources >> /etc/apt/sources.list
}
delete_infrequently_used_software(){
	message "delete_infrequently_used_software"
	rm -rf /var/lib/dpkg/lock
	rm -rf /var/cache/apt/archives/lock
	apt-get purge   unity-webapps-common thunderbird totem rhythmbox gnome-mines cheese transmission-common gnome-orca webbrowser-app gnome-sudoku  onboard deja-dup simple-scan gnome-mahjongg aisleriot   -y
	apt-get autoclean
	apt-get clean
	apt-get autoremove
}
update_system(){
	message "update system"
	rm -rf /var/lib/dpkg/lock
	rm -rf /var/cache/apt/archives/lock
	apt-get update
	apt-get upgrade  -y
}
basic_install(){
	#curl git openssh expect systemback
	message "Basic installation:curl,git,openssh,expect......."

	install_tools "expect"
	install_tools "curl"
	install_tools "git"
	#install_tools "openssh-server"
	#sed -i 's/start on runlevel/#start on runlevel/g' /etc/init/ssh.conf
	install_tools "gdebi"

	send_command "add-apt-repository ppa:nemh/systemback" "Ctrl+c" "\r" 
	apt-get update
	apt install systemback -y
	
}
environment_deployment(){	#环境部署
	#pip java ruby nodejs docker
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
		echo 1
		#printf "{\n\t"registry-mirrors": ["https://docker.mirrors.ustc.edu.cn"]\n}\n" >> /etc/docker/daemon.json
	else
		message "Install docker failed"
	fi
}
environment_embellish(){
	#unity-tweak-tools docky
	message "Begin environment_embellish"
	send_command "add-apt-repository ppa:noobslab/themes" "Ctrl+c" "\r"
	send_command "add-apt-repository ppa:noobslab/icons" "Ctrl+c" "\r"
	send_command "add-apt-repository ppa:noobslab/macbuntu" "Ctrl+c" "\r"
	send_command "add-apt-repository ppa:numix/ppa" "Ctrl+c" "\r"

	apt-get update
	install_tools "unity-tweak-tool"
	install_tools "docky"
	install_tools "flatabulous-theme"
	install_tools "ultra-flat-icons"
	install_tools "numix-gtk-theme"
	install_tools "numix-icon-theme-circle"

}
common_software_installation(){
	#shutter guake macbuntu screenfetch vim wps bleachbit gimp steam
	message "Install shutter\nvim\nalbert\nscreenfetch\nguake\nbleachbit\nwps\nwangyiyun"
	send_command "add-apt-repository ppa:webupd8team/unstable" "Ctrl+c" "\r"
	send_command "add-apt-repository ppa:noobslab/macbuntu" "Ctrl+c" "\r"
	send_command "add-apt-repository ppa:otto-kesselgulasch/gimp" "Ctrl+c" "\r"

	
	rm -rf /var/lib/dpkg/lock
	rm -rf /var/cache/apt/archives/lock
	add-apt-repository multiverse
	apt-get update

	install_tools "shutter"
	install_tools "vim"
	#install_tools "albert"
	install_tools "screenfetch"
	#install_tools "guake"
	install_tools "bleachbit"
	install_tools "steam"
	install_tools "gimp"

	#wget -O wps.deb http://kdl.cc.ksosoft.com/wps-community/download/a21/wps-office_10.1.0.5672~a21_amd64.deb
	#dpkg -i wps.deb
	#rm wps.deb

}
my_tools(){
	#ss chrome  sublime3  zsh ipython indicator-sysmonitor
	message "Install shadowsocks\nchrome\natom\nsublime3\nzsh"
	send_command "add-apt-repository ppa:webupd8team/sublime-text-3" "Ctrl+c" "\r"
	send_command "add-apt-repository ppa:fossfreedom/indicator-sysmonitor" "Ctrl+c" "\r"
	#vbox
	wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
	#chrome
	wget http://www.linuxidc.com/files/repo/google-chrome.list -P /etc/apt/sources.list.d/
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub  | sudo apt-key add -
	apt-get update

	install_tools "shadowsocks"
	install_tools "polipo"
	install_tools "indicator-sysmonitor"
	install_tools "sublime-text-installer"
	install_tools "google-chrome-stable"
	install_tools "virtualbox-dkms"
	install_tools "virtualbox"
	install_tools "ipython"
	install_tools "zsh"

	if [ $? -eq 0 ];then
		su xu --shell=/bin/bash -c "wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh"
		echo "zsh" >> $DIR/.bashrc
		sed -i 's/robbyrussell/ys/g' $DIR/.zshrc
		sed -i 's/(git)/(git extract autojump)/g' $DIR/.zshrc

	else
		message "zsh install failed"
	fi
}

software_else(){
	message "Download somethings"
	#mkdir -p tmp
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
	delete_infrequently_used_software
	update_system
	backup_system
	basic_install
	environment_deployment
	environment_embellish
	my_tools
	common_software_installation

	echo "----------------Successfully installed-------------------------------"
	message $success
	echo "----------------somethings fail to installed-------------------------"
	message $fail
	message "Ruby sources is `su xu --shell=/bin/bash -c "gem sources -u"`"
	message	"Npm sources is `su xu --shell=/bin/bash -c "npm config get registry"`"
	message "docker sources is `cat /etc/docker/daemon.json`"
}
main
