#!/bin/bash
LOG="/tmp/MsfArmitageInstall.log"

function printMsg() {
	echo -e "[+] $1"
}

function printErr() {
	echo -e "[!] $1"
}

function printQuest() {
	echo -e "[?] $1"
}

function PostgreSQLInstalled() {
	printQuest "Have you already installed PostgreSQL? [y/n]"
	read ans
	if [ "$ans" = 'y' ]; then
		printMsg "We'll now finish the PostgreSQL setup."
		echo "export PATH=$PATH:/Library/PostgreSQL/9.3/bin" >> ~/profile_test
	else
		printMsg "grabbing PostgreSQL"
		wget http://get.enterprisedb.com/postgresql/postgresql-9.3.2-2-osx.zip
		printMsg "Unzipping postgresql..."
		unzip postgresql-9.3.2-2-osx.zip
		printMsg "Executing postgresql installer..."
		open postgresql-9.3.2.-2-osx.app
		printMsg "Setting up PATH"
		echo "export PATH=$PATH:/Library/PostgreSQL/9.3/bin" >> ~/profile
	fi
}

function XcodeInstalled() {
	printQuest "Is Xcode already installed? [y/n]"
	read ans
	if [ "$ans" = 'y' ]; then
		printMsg "Congrats... now install command-line dev tools!"
		`xcode-select --install` >> $LOG 2>&1
	else
		printErr "Download Xcode first from https://developer.apple.com/xcode/"
		printMsg "Before re-running this script hit 'sudo xcodebuild -license' and accept the xcode license"
		exit
	fi	
}

function MacPortsInstall() {
	printQuest "Do you have MacPorts installed already? [y/n]"
	read ans
	if [ "$ans" = 'y' ]; then
		printMsg "Installing necessary dependencies via MacPorts"
		sh -c "port install zlib libxml2 libxslt readline curl git-core openssl libyaml autoconf libtool ncurses bison wget apr apr-util subversion libpcap"
	else
		printMsg "Grabbing MacPorts"
		wget https://distfiles.macports.org/MacPorts/MacPorts-2.2.1-10.9-Mavericks.pkg --no-check-certificate
		printMsg "Follow the installer..."
		open MacPorts-2.2.1-10.9-Mavericks.pkg
		printMsg "Installing necessary dependencies via MacPorts"
		sh -c "port install zlib libxml2 libxslt readline curl git-core openssl libyaml autoconf libtool ncurses bison wget apr apr-util subversion libpcap"
	fi
}

function DowngradingRuby() {
	rubycheck=`ruby -v`
	if [[ $rubycheck != *1.9.3* ]]; then
		printMsg "Downgrading ruby... this make take some time!"
		sh -c "curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --ruby=1.9.3"
		echo PATH=/usr/local/opt/ruby193/bin:$PATH >> ~/.bash_profile
		source  ~/.bash_profile
	fi
}

function NmapInstall() {
	printMsg "Now helping you install NMAP..."
	wget http://nmap.org/dist/nmap-6.40-2.dmg
	open nmap-6.40.2.dmg
}

function MetasploitInstall() {
	cd /usr/local/share/
	printMsg "Downloading Metasploit..."
	sh -c "git clone https://github.com/rapid7/metasploit-framework.git"
	cd /metasploit-framework
	printMsg "Setting up symlinks"
	sh -c "for MSF in $(ls msf*); do ln -s /usr/local/share/metasploit-framework/$MSF /usr/local/bin/$MSF;done"
	printMsg "Doing some extra housekeeping"
	chmod go+w /etc/profile
	sh -c "echo export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/database.yml >> /etc/profile"
	sh -c "bundle install"
}

echo -e "\t\t ------------------------------------------"
echo -e "\t\t| Msf/Armitage Installer for OSX 10.9.1    |"
echo -e "\t\t| Based on the blog post by @lightbulbone  |"
echo -e "\t\t| Coded by @Sh3llc0d3                      |"
echo -e "\t\t ------------------------------------------"

echo -e "\n\n[+] Begin? [y/n]"
read ans
if [ "$ans" = 'y' ]; then
	XcodeInstalled
	PostgreSQLInstalled
	MacPortsInstall
	DowngradingRuby
	NmapInstall
	MetasploitInstall
else
	exit -1
fi
