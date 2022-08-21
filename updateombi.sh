#!/bin/bash
#devnotes:
# * uses an ombi 4 default install
# * ombi's .db files should be located in /etc and not /opt/Ombi
# * this will autoinstall the latest version the app will prompt you to update to. (pre-release by default)
# * install with: crontab -e, add line: @weekly /bin/bash ~/update.ombi.cron.sh &>/dev/null
# * heads up: if you run this script too quickly a few times github will rate limit you and the download request will fail. the script is working, just wait 10 minutes.

f=/tmp/linux-x64.tar.gz
v=`curl "https://api.github.com/repos/Ombi-app/Ombi/tags" | jq '.[].name' | sort -n | tail -n1|tr -d '"'`
bak=/opt/Ombi.bak.tgz

if [[ "$v" =~ ^"v." ]]; then
 latest_release_url=`curl -s https://api.github.com/repos/Ombi-app/Ombi/releases/latest | grep "linux-x64.tar.gz" | cut -d '"' -f 4 | grep -i 'https://'`

else
 latest_release_url="https://github.com/Ombi-app/Ombi/releases/download/$v/linux-x64.tar.gz"
fi

echo using release: `tput setaf 2`$latest_release_url`tput op`

mkdir -p /etc/Ombi/backup &>/dev/null

cd /tmp

if [[ -f $f ]]; then
 rm -f "$f" &>/dev/null
fi

if curl --output /dev/null --silent --head --fail $latest_release_url; then
 wget -qO $f $latest_release_url
 if [[ ( $? -eq 0 ) && ( -f $f ) ]]; then
 systemctl stop ombi
 tar czpf $bak /opt/Ombi
 tar xf $f -C /opt/Ombi
 chown -R ombi:nogroup /opt/Ombi
 systemctl start ombi
 fi
fi

rm -f $f &>/dev/null

exit 0
