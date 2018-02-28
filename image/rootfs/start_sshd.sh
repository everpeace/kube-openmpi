#! /bin/sh

# detecting userinfo which runs this script.
ME=$(id -u)
MY_NAME=$(getent passwd "$ME" | cut -d: -f1)

if [ "$ME" = "0" ]; then
  PERMIT_ROOT_LOGIN=yes
else
  PERMIT_ROOT_LOGIN=no
fi

# Please mount ssh key here.
MOUNTED_KEY_DIR=${KEY_DIR:-/.ssh-key}

# local sshd key dirs
# SSHD_DIR must match with IdentitiFile entry
# in /etc/ssh/ssh_config
BASE_DIR=/.sshd
SSHD_DIR=/.sshd/$MY_NAME

# Generating ephemeral hostkeys
mkdir -p $SSHD_DIR
ssh-keygen -f $SSHD_DIR/host_rsa_key -C '' -N '' -t rsa
ssh-keygen -f $SSHD_DIR/host_dsa_key -C '' -N '' -t dsa

# copy mounted ssh key files to local directory
# to correct their permissions (600 for files, 700 for directories).
mkdir -p $SSHD_DIR
chmod 700 $SSHD_DIR
chown $MY_NAME:$MY_NAME $SSHD_DIR
cp $MOUNTED_KEY_DIR/* $SSHD_DIR
chmod 600 $SSHD_DIR/*
chown $MY_NAME:$MY_NAME $SSHD_DIR/*

# generating sshd_config
cat << EOT > $SSHD_DIR/sshd_config
# Package generated configuration file
# See the sshd_config(5) manpage for details

# What ports, IPs and protocols we listen for
Port 2022
# Use these options to restrict which interfaces/protocols sshd will bind to
#ListenAddress ::
#ListenAddress 0.0.0.0
Protocol 2

# HostKeys for protocol version 2
HostKey $SSHD_DIR/host_rsa_key
HostKey $SSHD_DIR/host_dsa_key

#Privilege Separation is turned on for security
UsePrivilegeSeparation no

# Lifetime and size of ephemeral version 1 server key
KeyRegenerationInterval 3600
ServerKeyBits 768

# Logging
SyslogFacility AUTH
LogLevel INFO

# Authentication:
LoginGraceTime 120
PermitRootLogin $PERMIT_ROOT_LOGIN
StrictModes yes

RSAAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile $BASE_DIR/%u/authorized_keys

# Don't read the user's ~/.rhosts and ~/.shosts files
IgnoreRhosts yes
# For this to work you will also need host keys in /etc/ssh_known_hosts
RhostsRSAAuthentication no
# similar for protocol version 2
HostbasedAuthentication no
# Uncomment if you don't trust ~/.ssh/known_hosts for RhostsRSAAuthentication
#IgnoreUserKnownHosts yes

# To enable empty passwords, change to yes (NOT RECOMMENDED)
PermitEmptyPasswords no

# Change to yes to enable challenge-response passwords (beware issues with
# some PAM modules and threads)
ChallengeResponseAuthentication no

X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
#UseLogin no

# Allow client to pass locale environment variables
AcceptEnv LANG LC_*

Subsystem sftp /usr/lib/openssh/sftp-server

# Set this to 'yes' to enable PAM authentication, account processing,
# and session processing. If this is enabled, PAM authentication will
# be allowed through the ChallengeResponseAuthentication and
# PasswordAuthentication.  Depending on your PAM configuration,
# PAM authentication via ChallengeResponseAuthentication may bypass
# the setting of "PermitRootLogin without-password".
# If you just want the PAM account and session checks to run without
# PAM authentication, then enable this but set PasswordAuthentication
# and ChallengeResponseAuthentication to 'no'.
UsePAM no

# we need this to set various variables (LD_LIBRARY_PATH etc.) for users
# since sshd wipes all previously set environment variables when opening
# a new session
PermitUserEnvironment yes
EOT

# dummy supervisor..
while true
do
  echo "starting sshd"
  /usr/sbin/sshd -eD -f $SSHD_DIR/sshd_config
  echo "sshd exited with return code $?"
done
