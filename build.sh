#!/bin/bash
TEAMSPEAK_URL="https://files.teamspeak-services.com/releases/server/3.13.7/teamspeak3-server_linux_amd64-3.13.7.tar.bz2"
# Remove human input
export "DEBIAN_FRONTEND=noninteractive"
export "DEBCONF_NONINTERACTIVE_SEEN=true"

# store list of packages into array (package dependencies)
debpkg=(
  "bzip2"
  "screen"
  "net-tools"
  )

# for loop the array and install the packages while checking exit codes

for i in "${debpkg[@]}"; do
  apt-get install -y --fix-broken $i
  echo $i
    # Check the exit status of the command
    if [ $? -eq 0 ]; then
        echo "###########################################################"
        echo "WARNING: Okay installed $i"
        echo "###########################################################"

    else
        echo "###########################################################"
        echo "ERROR: Package Failed: $i Command failed with exit code $?"
        echo "###########################################################"
    fi
done

# add a new user for teamspeak
useradd -m -s /bin/bash teamspeak
TEAMSPEAK_PASSWORD=`tr -dc '[:alnum:]' < /dev/random | head -c 12`
echo "###########################################################"
echo "Info: TS User Password set to $TEAMSPEAK_PASSWORD"
echo "###########################################################"
sudo -u teamspeak echo 'teamspeak:$TEAMSPEAK_PASSWORD' | sudo chpasswd

#download Teamspeak Binary

sudo -u teamspeak wget -O /home/teamspeak/teamspeak-latest.tar.bz2 "$TEAMSPEAK_URL"
sudo -u teamspeak tar -xvjf /home/teamspeak/teamspeak-latest.tar.bz2 -C /home/teamspeak/
sudo cp /home/ubuntu/ts3server.sqlitedb /home/teamspeak/teamspeak3-server_linux_amd64
sudo chown teamspeak:teamspeak /home/teamspeak/teamspeak3-server_linux_amd64/ts3server.sqlitedb
sudo -u teamspeak echo "license_accepted=1" > /home/teamspeak/teamspeak3-server_linux_amd64/.ts3server_license_accepted
sudo -u teamspeak echo "export TS3SERVER_LICENSE=accept" >> /home/teamspeak/.bashrc
#sudo -u teamspeak /home/teamspeak/teamspeak3-server_linux_amd64/ts3server
sudo -u teamspeak bash -c 'source ~/.bashrc && /home/teamspeak/teamspeak3-server_linux_amd64/ts3server >>/home/teamspeak/first-run.log 2>&1 &'
killall -9 ts3server
sudo -u teamspeak /home/teamspeak/teamspeak3-server_linux_amd64/ts3server_startscript.sh restart
