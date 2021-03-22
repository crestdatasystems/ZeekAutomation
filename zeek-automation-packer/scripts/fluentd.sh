# This script adds the cloud agent's package repository to our VM and installs the Fluentd (Cloud Logging agent).
# After the installation, it starts the Fluentd service.
# Further, it adds the Zeek configuration file to its respective Fluentd directory and restarts the Fluentd service.


#! /bin/bash

curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
bash add-logging-agent-repo.sh

apt-get update      # necessary to update
apt-get install -y google-fluentd google-fluentd-catch-all-config-structured

service google-fluentd start

cp -f /tmp/files/zeek.conf /etc/google-fluentd/config.d/

service google-fluentd force-reload
service google-fluentd restart

echo "---------------------------------------- Fluentd Configurations Completed!"