#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
	echo -e "\n\e[38;5;9mError: need use sudo.\e[0m\n"
	exit 1
fi


cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

[ ! -e "/home/share/bin" ] && mkdir -p /home/share/bin

chmod a+x ./*
for i in ./*
do
	if [ "$i" = "./install.sh" ] ; then
		continue
	fi
	cp -v "$i" /home/share/bin
done

echo 'export PATH="$PATH:/home/share/bin"' > /etc/profile.d/share_bin.sh

chown root:root /home/share/bin -R


echo '[Unit]
Description=kick idle sessions (15min)

[Service]
Type=oneshot
ExecStart=/bin/bash --login /home/share/bin/idle-kick
Restart=no
User=root

' > /lib/systemd/system/kick-idle.service

echo '[Unit]
Description=15min timer

[Timer]
OnBootSec=0min
OnUnitActiveSec=15min

[Install]
WantedBy=basic.target
' > /lib/systemd/system/kick-idle.timer

systemctl daemon-reload
systemctl disable --now kick-idle.timer

