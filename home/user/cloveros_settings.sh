#!/bin/bash
gitprefix="https://gitgud.io/cloveros/cloveros/raw/master"

cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if [[ -n "$2" ]]; then
	exit 1
fi

if [[ -n "$1" ]]; then
	choice=$1
else
	echo "1) Update cloveros_settings.sh
2) Update system
3) Change default sound device
4) Update kernel
5) Change emerge to source/binary
6) Revert to default dot files
7) Sync time
8) Set timezone
9) Clean emerge cache
a) ALSA settings configuration
l) Update libre kernel
e) Set keyboard layout
k) Delete all kernels except for $(uname -r)
t) Enable tap to click on touchpad
d) Disable mouse acceleration
c) Update Portage config from binhost
m) Revert to default /etc/portage/make.conf
b) Install Bluetooth manager
i) Install VirtualBox
s) Install and add dnscrypt-proxy to startup
n) Install proprietary Nvidia drivers"
	read -erp "Select option: " -n 1 choice
	echo
fi

case "$choice" in
	1)
		wget $gitprefix/home/user/cloveros_settings.sh -O cloveros_settings.new.sh
		if [[ -s cloveros_settings.new.sh ]]; then
			mv cloveros_settings.new.sh cloveros_settings.sh
			chmod +x cloveros_settings.sh
			echo -e "\ncloveros_settings.sh is now updated. (~/cloveros_settings.sh)"
		else
			echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			exit 1
		fi
		;;

	2)
		if ! grep -q '^EMERGE_DEFAULT_OPTS=".* -G"' /etc/portage/make.conf; then
			echo "Please enable binaries."
			exit 1
		fi
		echo "Running the following:"
		echo "./cloveros_settings.sh 1"
		echo "sudo emerge --sync"
		echo "sudo emerge -uvD @world"
		echo "sudo emerge --depclean"
		echo "./cloveros_settings.sh 4"
		echo "./cloveros_settings.sh 9"
		sleep 2
		./cloveros_settings.sh 1 || exit 1;
		./cloveros_settings.sh zz
		;;

	zz)
		if [ -d /var/db/pkg/x11-terms/rxvt-unicode-9.21*/ ]; then
			sed -i "s/-fn 6x13 -sl 0/-fn 6x13 -letsp 0 -sl 0/g" ~/.fvwm2rc
			sed -i "s/profile=opengl-hq/profile=gpu-hq/" ~/.mpv/config
			if ! grep -q "URxvt.letterSpace: -1" ~/.Xdefaults; then
				echo "URxvt.letterSpace: -1" >> ~/.Xdefaults
			fi
		fi
		if [ -d /var/db/pkg/sys-devel/gcc-8*/ ]; then
			sudo FETCHCOMMAND_HTTPS="wget -O \"\${DISTDIR}/\${FILE}\" \"\${URI}\"" emerge -1 gcc glibc
		fi
		if [[ $(eselect profile show | tail -n1) == "  default/linux/amd64/17.0/hardened" ]]; then
			echo "Updating profile to 17.1..."
			if [ ! -d /usr/local/lib/ ]; then
				sudo mkdir -p /usr/local/lib64/
				cd /usr/local/
				sudo ln -s lib64 lib
				cd -
			fi
			sudo emerge -1 unsymlink-lib
			sudo unsymlink-lib --analyze
			sudo unsymlink-lib --migrate
			sudo unsymlink-lib --finish
			sudo eselect profile set default/linux/amd64/17.1/hardened
		fi
		if [ -d /var/db/pkg/dev-lang/perl-5.2*/ ]; then
			sudo emerge -v1 dev-perl/MailTools:0 dev-perl/Error:0 dev-perl/Digest-HMAC:0 dev-perl/Text-Unidecode:0 dev-perl/Unicode-EastAsianWidth:0 dev-perl/Module-Build:0 dev-perl/TimeDate:0 dev-perl/libintl-perl:0 dev-perl/Authen-SASL:0 dev-vcs/git:0 x11-terms/rxvt-unicode:0 net-irc/weechat:0 virtual/perl-Getopt-Long virtual/perl-ExtUtils-MakeMaker virtual/perl-Perl-OSType virtual/perl-libnet virtual/perl-Scalar-List-Utils virtual/perl-Parse-CPAN-Meta virtual/perl-Text-ParseWords sys-apps/texinfo virtual/perl-ExtUtils-Install virtual/perl-CPAN-Meta virtual/perl-Digest-MD5 virtual/perl-CPAN-Meta-YAML
		fi
		if [ -d /var/db/pkg/games-emulation/mednafen-saturn-libretro*/ ] ; then
			sudo emerge -C games-emulation/mednafen-saturn-libretro
		fi
		if [ ! -d /var/db/pkg/net-libs/gnutls-3.6.7-r1/ ]; then
			sudo FETCHCOMMAND_HTTPS="wget -O \"\${DISTDIR}/\${FILE}\" \"\${URI}\"" emerge -1 gnutls aria2
		fi
		if grep -q "^python3.5$" /etc/python-exec/python-exec.conf; then
			sudo eselect python cleanup
		fi

		sudo emerge --sync
		sudo emerge -uvD @world
		for i in {dev-libs/glib,dev-qt/qtgui,xfce-base/thunar}; do [ -d /var/db/pkg/$i* ] && sudo PORTAGE_BINHOST="https://cloveros.ga/s/nodbus" FETCHCOMMAND_HTTPS="wget -O \"\${DISTDIR}/\${FILE}\" \"\${URI}\"" emerge -1uD $i; done
		sudo emerge --depclean

		kernel=$(uname -r)
		if [[ ${kernel: -3} == "gnu" ]]; then
			./cloveros_settings.sh l
		else
			./cloveros_settings.sh 4
		fi

		./cloveros_settings.sh 9

		sudo eselect wine set 1 &> /dev/null

		echo -e "\nSystem updated."
		;;

	3)
		grep " \[" /proc/asound/cards
		read -erp "Select the audio device to become default: " -n 1 choiceaudio
		echo -e "defaults.pcm.card ${choiceaudio}\ndefaults.ctl.card ${choiceaudio}" > ~/.asoundrc
		echo -e "\nAudio device ${choiceaudio} is now the default for ALSA programs. (~/.asoundrc)"
		;;

	4)
		kernelversion=$(wget -qO - https://cloveros.ga/s/kernel.tar.lzma | lzma -d | strings | grep -aoPm1 "(?<=x86_64-).*(?=-gentoo)")
		if ls /boot/ | grep -q $kernelversion; then
			echo "Kernel up to date."
		else
			rm kernel.tar.lzma kernel.tar.lzma.asc &> /dev/null
			wget https://cloveros.ga/s/kernel.tar.lzma https://cloveros.ga/s/signatures/s/kernel.tar.lzma.asc
			if sudo gpg --verify kernel.tar.lzma.asc kernel.tar.lzma; then
				sudo tar -C / -xf kernel.tar.lzma
				sudo grub-mkconfig -o /boot/grub/grub.cfg
				if grep -q hypervisor /proc/cpuinfo; then
					GRUB_CMDLINE_LINUX_DEFAULT="nomodeset" grub-mkconfig -o /boot/grub/grub.cfg
				fi
				sudo emerge -v @module-rebuild
				sudo depmod $kernelversion-gentoo
				echo -e "\nKernel upgraded. (/boot/, /lib/modules/)"
			else
				echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			fi
			rm kernel.tar.lzma kernel.tar.lzma.asc &> /dev/null
		fi
		;;

	5)
		if ! grep -q '^#EMERGE_DEFAULT_OPTS=".* -G"' /etc/portage/make.conf; then
			sudo sed -ri 's/(PORTAGE_BINHOST|EMERGE_DEFAULT_OPTS|ACCEPT_KEYWORDS|binhost_mirrors|FETCHCOMMAND_HTTPS.*)/#\1/' /etc/portage/make.conf
			echo -e "\nemerge will now install from source. (/etc/portage/make.conf)\nUse ./cloveros_settings.sh c to copy binhost Portage configuration"
		else
			sudo sed -ri 's/#(PORTAGE_BINHOST|EMERGE_DEFAULT_OPTS|ACCEPT_KEYWORDS|binhost_mirrors|FETCHCOMMAND_HTTPS.*)/\1/' /etc/portage/make.conf
			echo -e "\nemerge will now install from binary. (/etc/portage/make.conf)"
		fi
		;;

	6)
		./cloveros_settings.sh 1 || exit 1;
		backupdir=backup$(< /dev/urandom tr -dc 0-9 | head -c 8)
		mkdir $backupdir
		mv .bash_profile .zprofile .zshrc .fvwm2rc .Xdefaults wallpaper.png wallpaper43.png wallpaper1610.png .xbindkeysrc screenfetch-dev cloveros_settings.sh stats.sh rotate_screen.sh .emacs .emacs.d/ .rtorrent.rc .mpv .config/nitrogen/ .config/spacefm/ .config/mimeapps.list .config/nomacs/ $backupdir/
		wget $gitprefix/home/user/{.bash_profile,.zprofile,.zshrc,.fvwm2rc,.Xdefaults,wallpaper.png,wallpaper43.png,wallpaper1610.png,.xbindkeysrc,screenfetch-dev,cloveros_settings.sh,stats.sh,rotate_screen.sh,.emacs,.rtorrent.rc}
		chmod +x screenfetch-dev cloveros_settings.sh stats.sh rotate_screen.sh
		mkdir -p .emacs.d/backups/ .emacs.d/autosaves/ Downloads/ .rtorrent/ .mpv/ .config/spacefm/ .config/nitrogen/ .config/nomacs/ Desktop/
		sed -i "s@/home/user/@/home/$USER/@" .rtorrent.rc
		wget $gitprefix/home/user/.mpv/config -P .mpv/
		wget $gitprefix/home/user/.config/nitrogen/nitrogen.cfg -P .config/nitrogen/
		sed -i "s@/home/user/@/home/$USER/@" .config/nitrogen/nitrogen.cfg
		wget $gitprefix/home/user/.config/nomacs/Image\ Lounge.conf -P .config/nomacs/
		wget $gitprefix/home/user/.config/spacefm/session -P .config/spacefm/
		sed -i "s@/home/user/@/home/$USER/@" .config/spacefm/session
		wget $gitprefix/home/user/.config/mimeapps.list -P .config/
		echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Home\nIcon=user-home\nExec=spacefm ~/" > Desktop/home.desktop
		echo -e "[Desktop Entry]\nEncoding=UTF-8\nType=Link\nName=Applications\nIcon=folder\nExec=spacefm /usr/share/applications/" > Desktop/applications.desktop
		cp /usr/share/applications/{firefox.desktop,smplayer.desktop,emacs.desktop,zzz-gimp.desktop,porthole.desktop,xarchiver.desktop} Desktop/
		echo -e "~rows=0\n1=home.desktop\n2=applications.desktop\n3=firefox.desktop\n4=smplayer.desktop\n5=emacs.desktop\n6=porthole.desktop\n7=zzz-gimp.desktop\n8=xarchiver.desktop" > .config/spacefm/desktop0
		echo -e "\nConfiguration updated to new CloverOS defaults, old settings are moved to ~/$backupdir/ (~)"
		;;

	7)
		sudo date +%s -s @"$(wget -qO - http://www.4webhelp.net/us/timestamp.php | grep -oP '(?<=p" value=").*(?=" s)')"
		echo -e "\nTime set."
		;;

	8)
		echo -e "Available timezones: $(find /usr/share/zoneinfo/ -type f | sed s@/usr/share/zoneinfo/@@ | sort | tr "\n" " ") \n"
		read -erp "Select a timezone: " timezone
		sudo cp /usr/share/zoneinfo/${timezone} /etc/localtime
		echo -e "\nTimezone set to ${timezone}. (/etc/localtime)"
		;;

	9)
		sudo rm -Rf /usr/portage/packages/* /usr/portage/distfiles/* /var/cache/binpkgs/* /var/cache/distfiles/* /var/cache/edb/binhost/* /var/tmp/portage/*
		echo -e "\nPackage cache cleared. (/usr/portage/packages/, /usr/portage/distfiles/, /var/cache/binpkgs/, /var/cache/distfiles/, /var/cache/edb/binhost/, /var/tmp/portage/)"
		;;

	a)
		echo "1) Change default ALSA playback device
2) Change default ALSA capture device
3) Change default ALSA playback device to a Bluetooth device
4) Set sample rate
5) Bypass dmix and use hw (DSD, high sample rate)
6) Configure ALSA for OBS
7) GUI volume control
8) CLI volume control"
		read -erp "Select option: " -n 1 choicealsa
		echo
		case "$choicealsa" in
			1)
				grep " \[" /proc/asound/cards
				read -erp "Select the audio device to become default: " -n 1 choiceaudio
				echo -e "defaults.pcm.card ${choiceaudio}\ndefaults.ctl.card ${choiceaudio}" > ~/.asoundrc
				echo -e "\nAudio device ${choiceaudio} is now the default for ALSA programs. (~/.asoundrc)"
				;;

			2)
				grep " \[" /proc/asound/cards
				read -erp "Select the audio device to become default for playback: " -n 1 choiceaudio
				read -erp "Select the audio device to become default for capture: " -n 1 choicecapture
				echo -e "pcm.!default {\n    type asym\n    playback.pcm \"plughw:${choiceaudio}\"\n    capture.pcm  \"plughw:${choicecapture}\"\n}" > ~/.asoundrc
				echo -e "\nPlayback device ${choiceaudio} and capture device ${choicecapture} are now default for ALSA programs. (~/.asoundrc)"
				;;

			3)
				echo "First pair the Bluetooth device with blueman-manager."
				read -erp "Specify the Bluetooth address: " -i 00:00:00:00:00:00 bluetoothaddress
				echo -e "pcm.!default {\n	type bluealsa\n	device \"${bluetoothaddress}\"\n	profile "a2dp"\n}" > ~/.asoundrc
				echo -e "\nAudio device ${bluetoothaddress} is now the default for ALSA programs. (~/.asoundrc)"
				;;

			4)
				echo "Sample rate examples: 44100 48000 96000 192000"
				read -erp "Select sample rate: " choicesamplerate
				if grep -q "defaults.pcm.dmix.rate" ~/.asoundrc; then
					sed -i "s/defaults.pcm.dmix.rate .*/defaults.pcm.dmix.rate $choicesamplerate/" ~/.asoundrc
				else
					echo "defaults.pcm.dmix.rate $choicesamplerate" >> ~/.asoundrc
				fi
				echo -e "\nSample rate set to $choicesamplerate (~/.asoundrc)"
				;;

			5)
				grep " \[" /proc/asound/cards
				read -erp "Select the audio device (hw) to become default: " -n 1 choiceaudio
				echo -e "pcm.!default {\n  type hw\n  card ${choiceaudio}\n}" > ~/.asoundrc
				echo -e "\nAudio device ${choiceaudio} (hw) is now the default for ALSA programs. Only one program will output audio. (~/.asoundrc)"
				;;
			6)
				echo -e "\nIn progress."
				;;

			7)
				qasmixer&
				;;

			8)
				alsamixer
				;;

			*)
				echo "Invalid option: $choicealsa"
				;;
		esac
		;;

	l)
		kernelversion=$(wget -qO - https://cloveros.ga/s/kernel-libre.tar.lzma | lzma -d | strings | grep -aoPm1 "(?<=x86_64-).*(?=-gentoo)")
		if ls /boot/ | grep -q $kernelversion-gentoo-gnu; then
			echo "Kernel up to date."
		else
			rm kernel-libre.tar.lzma kernel-libre.tar.lzma.asc &> /dev/null
			wget https://cloveros.ga/s/kernel-libre.tar.lzma https://cloveros.ga/s/signatures/s/kernel-libre.tar.lzma.asc
			if sudo gpg --verify kernel-libre.tar.lzma.asc kernel-libre.tar.lzma; then
				sudo tar -C / -xf kernel-libre.tar.lzma
				sudo grub-mkconfig -o /boot/grub/grub.cfg
				if grep -q hypervisor /proc/cpuinfo; then
					GRUB_CMDLINE_LINUX_DEFAULT="nomodeset" grub-mkconfig -o /boot/grub/grub.cfg
				fi
				sudo emerge -v @module-rebuild
				sudo depmod $kernelversion-gentoo-gnu
				echo -e "\nKernel upgraded. (/boot/, /lib/modules/)"
			else
				echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
			fi
			rm kernel-libre.tar.lzma kernel-libre.tar.lzma.asc &> /dev/null
		fi
		;;

	e)
		if [ ! -d /var/db/pkg/x11-apps/setxkbmap-*/ ]; then
			sudo emerge -v setxkbmap
		fi
		echo -e "Available keyboard maps: $(ls /usr/share/X11/xkb/symbols | tr "\n" " ") \n"
		read -erp "Select a keyboard map: " keyboardmap
		setxkbmap $keyboardmap
		echo -e "\nKeyboard map set to ${keyboardmap}. (xsetkbmap ${keyboardmap})"
		;;

	k)
		sudo find /boot/ /lib/modules/ -mindepth 1 -maxdepth 1 -name \*gentoo\* ! -name \*$(uname -r) -exec rm -R {} \;
		sudo grub-mkconfig -o /boot/grub/grub.cfg
		if grep -q hypervisor /proc/cpuinfo; then
			GRUB_CMDLINE_LINUX_DEFAULT="nomodeset" grub-mkconfig -o /boot/grub/grub.cfg
		fi
		sudo sed -i "s/set timeout=5/set timeout=0/" /boot/grub/grub.cfg
		echo "All kernels except for $(uname -r) deleted."
		;;

	t)
		if [ ! -d /var/db/pkg/x11-apps/xinput-*/ ]; then
			sudo emerge -v xinput
		fi
		xinput set-prop "SynPS/2 Synaptics TouchPad" "libinput Tapping Enabled" 1 &> /dev/null
		echo "Tap to click enabled. (xinput set-prop \"SynPS/2 Synaptics TouchPad\" \"libinput Tapping Enabled\" 0)"
		;;

	d)
		if [ ! -d /var/db/pkg/x11-apps/xinput-*/ ]; then
			sudo emerge -v xinput
		fi
		xinput list --name-only | sed "/Virtual core pointer/,/Virtual core keyboard/"\!"d;//d" | xargs -I{} xinput set-prop pointer:{} "libinput Accel Profile Enabled" 0 1 &> /dev/null
		echo -e "\nMouse acceleration disabled. (xinput set-prop \"Your Device\" \"libinput Accel Profile Enabled\" 0 1)"
		;;

	c)
		portageworkdir=portageworkdir$(< /dev/urandom tr -dc 0-9 | head -c 8)
		mkdir -p $portageworkdir/env/ $portageworkdir/repos.conf/
		wget $gitprefix/binhost_settings/etc/portage/{package.use,package.accept_keywords,package.env,package.mask,package.unmask,make.conf} -P $portageworkdir/
		wget $gitprefix/binhost_settings/etc/portage/env/{no-gnu2,no-gold,no-hashgnu,no-lto,no-lto-graphite,no-lto-o3,no-lto-ofast,no-ofast,no-noplt,no-noplt-lto,no-sinter,no-fipapta,pcsx2,size,clang} -P $portageworkdir/env/
		wget $gitprefix/binhost_Settings/etc/portage/repos.conf/eselect-repo.conf -P $portageworkdir/repos.conf/
		if [[ $(find $portageworkdir -type f | wc -l) == "22" ]]; then
			backupportagedir=backupportage$(< /dev/urandom tr -dc 0-9 | head -c 8)
			mkdir $backupportagedir/
			sudo mv /etc/portage/{package.usepackage.accept_keywords,package.env,package.mask,package.unmask} /etc/portage/env/ /etc/portage/repos.conf/ $backupportagedir/
			cp /etc/portage/make.conf $backupportagedir/
			sudo mv $portageworkdir/{package.use,package.keywords,package.accept_keywords,package.env,package.mask,package.unmask} $portageworkdir/env/ $portageworkdir/repos.conf/ /etc/portage/
			useflags=$(grep "^USE=" $portageworkdir/make.conf)
			if ! grep -q "$useflags" /etc/portage/make.conf; then
				echo $useflags | sudo tee --append /etc/portage/make.conf > /dev/null
			else
				sudo sed -i "s/^USE=.*/$useflags/" /etc/portage/make.conf
			fi
			cflags=$(grep "^CFLAGS=\"-Ofast" $portageworkdir/make.conf)
			sudo sed -i "/CFLAGS=\"-O2 -pipe\"/! s/^CFLAGS=.*/$cflags/" /etc/portage/make.conf
			sudo sed -i "s/-mssse3/-march=native/" /etc/portage/make.conf /etc/portage/package.env /etc/portage/env/*
			if grep -qi "intel" /proc/cpuinfo; then
				sudo sed -i "s/-march=native/-march=native -falign-functions=32/" /etc/portage/make.conf /etc/portage/package.env /etc/portage/env/*
			fi
			if [ ! -d /var/db/pkg/app-eselect/eselect-repository-*/ ]; then
				sudo emerge -v eselect-repository
			fi
			echo -e "\nPortage configuration now mirrors binhost Portage configuration. emerge --sync to retrieve overlays (/etc/portage/package.*, /etc/portage/env/, /etc/portage/repos.conf/) Previous Portage config stored in ~/$backupportagedir"
		else
			echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
		fi
		rm -R $portageworkdir
		;;

	m)
		if grep -q PORTDIR=\"/usr/portage\" /etc/portage/make.conf; then
			sudo wget -q $gitprefix/home/user/make.conf2 -O make.conf.new
		else
			sudo wget -q $gitprefix/home/user/make.conf -O make.conf.new
		fi
		if [[ -s make.conf.new ]]; then
			backupmakeconf="make.conf.bak"$(< /dev/urandom tr -dc 0-9 | head -c 8)
			sudo mv /etc/portage/make.conf $backupmakeconf
			sudo mv make.conf.new /etc/portage/make.conf
			echo "/etc/portage/make.conf is now default Previous make.conf saved to $backupmakeconf"
		else
			echo -e "\nCould not retrieve file. Please connect to the Internet or try again."
		fi
		;;

	b)
		echo "Running the following:"
		echo "sudo emerge blueman bluez-alsa"
		echo 'sudo usermod -aG plugdev $USER'
		echo "sudo /etc/init.d/bluetooth start"
		echo "sudo /etc/init.d/bluealsa start"
		echo "blueman-manager &"
		sleep 2
		sudo emerge -v blueman bluez-alsa
		sudo usermod -aG plugdev $USER
		sudo /etc/init.d/bluetooth start
		sudo /etc/init.d/bluealsa start
		blueman-manager &
		echo "blueman installed. To have it automatically start on boot, run: sudo rc-config add bluetooth & sudo rc-config add bluealsa"
		;;

	i)
		echo "Running the following:"
		echo "sudo emerge virtualbox"
		echo "sudo depmod"
		echo "./cloveros_settings.sh 4"
		echo "sudo useradd -a $USER vboxusers"
		echo "sudo modprobe -a vboxdrv vboxnetadp vboxnetflt"
		sleep 2
		sudo emerge -v virtualbox
		sudo depmod
		./cloveros_settings.sh 4
		sudo useradd -g $USER vboxusers
		sudo modprobe -a vboxdrv vboxnetadp vboxnetflt
		echo "Virtualbox installed, please reboot to update kernel."
		;;

	s)
		echo "Running the following:"
		echo "sudo emerge net-dns/dnscrypt-proxy"
		echo "sudo /etc/init.d/dnscrypt-proxy start"
		echo "sudo rc-config add dnscrypt-proxy"
		echo "sudo sh -c 'echo \"static domain_name_servers=127.0.0.1\" >> /etc/dhcpcd.conf'"
		echo "sudo /etc/init.d/dhcpcd restart"
		sleep 2
		sudo emerge -v net-dns/dnscrypt-proxy
		sudo /etc/init.d/dnscrypt-proxy start
		sudo rc-config add dnscrypt-proxy
		sudo sh -c 'echo "static domain_name_servers=127.0.0.1" >> /etc/dhcpcd.conf'
		sudo /etc/init.d/dhcpcd restart
		;;

	n)
		echo Running the following:
		echo 'sudo EMERGE_DEFAULT_OPTS="" emerge \=gentoo-sources-'$(uname -r | sed 's/-.*//')
		echo 'sudo eselect kernel set linux-'$(uname -r)
		echo "sudo wget https://raw.githubusercontent.com/damentz/liquorix-package/$(uname -r | sed 's/\.[^.]*$//')/linux-liquorix/debian/config/kernelarch-x86/config-arch-64 -O /usr/src/linux/.config"
		echo 'sudo sed -i "s/CONFIG_CRYPTO_CRC32C=m/CONFIG_CRYPTO_CRC32C=y/; s/CONFIG_FW_LOADER_USER_HELPER=y/CONFIG_FW_LOADER_USER_HELPER=n/; s/CONFIG_I2C_NVIDIA_GPU=/#CONFIG_I2C_NVIDIA_GPU=/" /usr/src/linux/.config'
		echo "sudo emerge nvidia-drivers bumblebee"
		echo "sudo depmod"
		echo "sudo eselect opengl set nvidia"
		echo "sudo eselect opencl set nvidia"
		echo "sudo sh -c 'echo -e \"blacklist nouveau\nblacklist vga16fb\nblacklist rivafb\nblacklist nvidiafb\nblacklist rivatv\" >> /etc/modprobe.d/blacklist.conf'"
		sleep 2
		sudo EMERGE_DEFAULT_OPTS="" emerge -v \=gentoo-sources-$(uname -r | sed 's/-.*//')
		sudo eselect kernel set linux-$(uname -r)
		sudo wget https://raw.githubusercontent.com/damentz/liquorix-package/$(uname -r | sed 's/\.[^.]*$//')/linux-liquorix/debian/config/kernelarch-x86/config-arch-64 -O /usr/src/linux/.config
		sudo sed -i "s/CONFIG_CRYPTO_CRC32C=m/CONFIG_CRYPTO_CRC32C=y/; s/CONFIG_FW_LOADER_USER_HELPER=y/CONFIG_FW_LOADER_USER_HELPER=n/; s/CONFIG_I2C_NVIDIA_GPU=/#CONFIG_I2C_NVIDIA_GPU=/" /usr/src/linux/.config
		sudo emerge -v nvidia-drivers bumblebee
		sudo depmod
		sudo eselect opengl set nvidia
		sudo eselect opencl set nvidia
		sudo sh -c 'echo -e "blacklist nouveau\nblacklist vga16fb\nblacklist rivafb\nblacklist nvidiafb\nblacklist rivatv" >> /etc/modprobe.d/blacklist.conf'
		sudo sed -i 's/^Driver=$/Driver=nvidia/; s/^Bridge=auto$/Bridge=primus/; s/^VGLTransport=proxy$/VGLTransport=rgb/; s@^PrimusLibraryPath=/usr/lib/primus:/usr/lib32/primus$@PrimusLibraryPath=/usr/lib/primus:/usr/lib32/primus:/usr/lib64/primus@; s/^KernelDriver=$/KernelDriver=nvidia/; s/^PMMethod=auto$/PMMethod=bbswitch/; s@^LibraryPath=$@LibraryPath=/usr/lib64/opengl/nvidia/lib:/usr/lib/opengl/nvidia/lib@; s@^XorgModulePath=$@XorgModulePath=/usr/lib64/opengl/nvidia/lib,/usr/lib64/opengl/nvidia/extensions,/usr/lib64/xorg/modules/drivers,/usr/lib64/xorg/modules@' /etc/bumblebee/bumblebee.conf
		echo -e "\nNvidia drivers installed, please reboot.\nCheck https://wiki.gentoo.org/wiki/NVidia/nvidia-drivers for more info"
		;;

	*)
		echo "Invalid option: $choice"
		;;
esac
