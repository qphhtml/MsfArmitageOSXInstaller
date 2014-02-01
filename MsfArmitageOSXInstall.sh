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
		sh -c 'echo "export PATH=$PATH:/Library/PostgreSQL/9.3/bin" >> ~/profile_test'
		if [ $? -gt 0 ] ; then
			printErr "Failed to export PATH"
			exit -1
		else
			printMsg "Done!"
		fi
	else
		printMsg "grabbing PostgreSQL"
		wget http://get.enterprisedb.com/postgresql/postgresql-9.3.2-2-osx.zip
		if [ $? -gt 0 ] ; then
			printErr "Failed to download postgresql"
			exit -1
		else
			printMsg "Done!"
		fi
		printMsg "Unzipping postgresql..."
		unzip postgresql-9.3.2-2-osx.zip
		if [ $? -gt 0 ] ; then
			printErr "Failed to unzip postgresql"
			exit -1
		else
			printMsg "Done!"
		fi
		printMsg "Executing postgresql installer..."
		open postgresql-9.3.2.-2-osx.app
		if [ $? -gt 0 ] ; then
			printErr "Failed to open .app"
			exit -1
		else
			printMsg "Done!"
		fi
		printMsg "Setting up PATH"
		echo "export PATH=$PATH:/Library/PostgreSQL/9.3/bin" >> ~/profile
		if [ $? -gt 0 ] ; then
			printErr "Failed to export PATH"
			exit -1
		else
			printMsg "Done!"
		fi
	fi
}

function XcodeInstalled() {
	printQuest "Is Xcode already installed? [y/n]"
	read ans
	if [ "$ans" = 'y' ]; then
		printMsg "Congrats... now install command-line dev tools!"
		`xcode-select --install`
		if [ $? -gt 0 ] ; then
			printErr "Failed to start xcode installer"
			exit -1
		else
			printMsg "Done!"
		fi
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
		if [ $? -gt 0 ] ; then
			printErr "Failed to install dependencies via macports"
			exit -1
		else
			printMsg "Done!"
		fi
	else
		printMsg "Grabbing MacPorts"
		wget https://distfiles.macports.org/MacPorts/MacPorts-2.2.1-10.9-Mavericks.pkg --no-check-certificate
		if [ $? -gt 0 ] ; then
			printErr "Failed to wget macports"
			exit -1
		else
			printMsg "Done!"
		fi
		printMsg "Follow the installer..."
		open MacPorts-2.2.1-10.9-Mavericks.pkg
		if [ $? -gt 0 ] ; then
			printErr "Failed to open macports .pkg"
			exit -1
		else
			printMsg "Done!"
		fi
		printMsg "Installing necessary dependencies via MacPorts"
		sh -c "port install zlib libxml2 libxslt readline curl git-core openssl libyaml autoconf libtool ncurses bison wget apr apr-util subversion libpcap"
		if [ $? -gt 0 ] ; then
			printErr "Failed to install dependencies via macports"
			exit -1
        else
			printMsg "Done!"
		fi
	fi
}

function DowngradingRuby() {
	rubycheck=`ruby -v`
	if [[ $rubycheck != *1.9.3* ]]; then
		printMsg "Downgrading ruby... this make take some time!"
		sh -c "curl -L https://get.rvm.io | bash -s stable --autolibs=enabled --ruby=1.9.3"
		if [ $? -gt 0 ] ; then
			printErr "Failed to downgrade/install ruby 1.9.3"
			exit -1
		else
			printMsg "Done!"
		fi
		echo PATH=/usr/local/opt/ruby193/bin:$PATH >> ~/.bash_profile
		if [ $? -gt 0 ] ; then
			printErr "Failed to export PATH"
			exit -1
		else
			printMsg "Done!"
		fi
		source  ~/.bash_profile
		if [ $? -gt 0 ] ; then
			printErr "Failed to set source"
			exit -1
		else
			printMsg "Done!"
		fi
	fi
}

function NmapInstall() {
	printMsg "Now helping you install NMAP..."
	wget http://nmap.org/dist/nmap-6.40-2.dmg
	if [ $? -gt 0 ] ; then
		printErr "Failed to wget nmap"
		exit -1
	else
		printMsg "Done!"
	fi
	open nmap-6.40.2.dmg
	if [ $? -gt 0 ] ; then
		printErr "Failed to open .dmg"
		exit -1
	else
		printMsg "Done!"
	fi
}

function MetasploitInstall() {
	cd /usr/local/share/
	if [ $? -gt 0 ] ; then
		printErr "Failed to cd to /usr/local/share/"
		exit -1
	else
		printMsg "Done!"
	fi
	printMsg "Downloading Metasploit..."
	sh -c "git clone https://github.com/rapid7/metasploit-framework.git"
	if [ $? -gt 0 ] ; then
		printErr "Failed to git clone metasploit"
		exit -1
	else
		printMsg "Done!"
	fi
	cd /metasploit-framework
	if [ $? -gt 0 ] ; then
		printErr "Failed to cd to metasploit-framework"
		exit -1
	else
		printMsg "Done!"
	fi
	printMsg "Setting up symlinks"
	sh -c "for MSF in $(ls msf*); do ln -s /usr/local/share/metasploit-framework/$MSF /usr/local/bin/$MSF;done"
	if [ $? -gt 0 ] ; then
		printErr "Failed to create symlinks for metasploit"
		exit -1
	else
		printMsg "Done!"
	fi
	printMsg "Doing some extra housekeeping"
	chmod go+w /etc/profile
	if [ $? -gt 0 ] ; then
		printErr "Failed to chmod /etc/profile"
		exit -1
	else
		printMsg "Done!"
	fi
	sh -c "echo export MSF_DATABASE_CONFIG=/usr/local/share/metasploit-framework/database.yml >> /etc/profile"
	if [ $? -gt 0 ] ; then
		printErr "Failed to export msf database config"
		exit -1
	else
		printMsg "Done!"
	fi
	sh -c "bundle install"
	if [ $? -gt 0 ] ; then
		printErr "Failed to bundle install"
		exit -1
	else
		printMsg "Done!"
	fi
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
