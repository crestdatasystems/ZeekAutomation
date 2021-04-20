# This script updates the packages and installs new packages that are required for the Zeek installation.
# After the packages are installed, the Zeek repository is cloned and installed.
# After the installation, it copies custom Zeek scripts to their respective directory and appends the content to the "local.zeek" file for loading custom Zeek scripts.
# Further, it adds Zeek path to environment variables and starts the ZeekControl (a tool for operating Zeek installations) to manage Zeek.


#! /bin/bash

crontab -r

apt-get update
apt-get -y install git cmake make gcc g++ flex bison libpcap-dev libssl-dev python-dev python-ipaddress swig zlib1g-dev python3-pip dos2unix apache2

git clone --recursive https://github.com/zeek/zeek /usr/local/zeek

/usr/local/zeek/configure --builddir=/usr/local/zeek/build && make -C /usr/local/zeek/build && make -C /usr/local/zeek/build install

find /tmp/files/ -type f -print0 | xargs -0 dos2unix                               # for converting dos file format to unix file format

cp -f /tmp/files/json-streaming-logs.zeek /usr/local/zeek/share/zeek/site/
cp -f /tmp/files/add_fields.zeek /usr/local/zeek/share/zeek/site/

cat /tmp/files/append_local.zeek >> /usr/local/zeek/share/zeek/site/local.zeek     # appending content

echo "---------------------------------------- Zeek Configurations Completed!"