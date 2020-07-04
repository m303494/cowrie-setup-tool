#/bin/bash

# First we update and upgrade the system
sudo apt-get update && sudo apt-get full-upgrade
sudo systemctl stop ssh

# Now we will install the required dependencies
echo "Installing dependencies..."
sudo apt-get install -y git python-virtualenv libssl-dev libffi-dev build-essential libpython3-dev python3-minimal authbind virtualenv

# We add a password-disabled user, cowrie
echo "Adding cowrie user (provide information if necessary)..."
sudo adduser --disabled-password cowrie # Here user input is required

# We switch to the cowrie user to perform some user-specific tasks
echo "Switching to cowrie user..."
sudo -i -u cowrie bash << EOF
# Clone the git repository to the user's home folder
echo "Cloning git..."
git clone http://github.com/cowrie/cowrie
cd cowrie
# Create a virtual environment inside the cloned folder
echo "Creating a virtual environment..."
pwd
virtualenv --python=python3 cowrie-env
# Activate the environment and install the packages
echo "Activating virtual environment and installing packages..."
source cowrie-env/bin/activate
pip install --upgrade pip
pip install --upgrade -r requirements.txt
# Switching back to the root user to choose the ssh port to listen to
echo "Switching to root user"
EOF
echo "Choose an SSH port to listen to: " # If we were to listen on port 22, logging into the ssh service wouldn't get us to the honeypot
read sshport
sudo touch /etc/authbind/byport/$sshport
sudo chown cowrie:cowrie /etc/authbind/byport/$sshport
sudo chmod 770 /etc/authbind/byport/$sshport
# We switch back to the cowrie user to change the cowrie configuration file
sudo -i -u cowrie bash << EOF
cp /home/cowrie/cowrie/etc/cowrie.cfg.dist /home/cowrie/cowrie/etc/cowrie.cfg
sed -i -e 's/listen_endpoints = tcp:2222:interface=0.0.0.0/listen_endpoints = tcp:$sshport:interface=0.0.0.0/g' /home/cowrie/cowrie/etc/cowrie.cfg # Port 2222 is the default Cowrie port for SSH
echo "Successful installation. Starting Cowrie..."
cd cowrie
bin/cowrie start # We start Cowrie on the selected port
EOF
echo "Started on port $sshport"
echo "Start or stop Cowrie with 'cowrie/bin/cowrie [start/stop]' while logged into cowrie user"
