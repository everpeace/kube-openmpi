#! /bin/bash
set -eu -o pipefail

TMP_KEY_DIR=./.ssh
mkdir -p $TMP_KEY_DIR

set +e
yes | ssh-keygen -N "" -f $TMP_KEY_DIR/id_rsa
set -e
chmod 700 $TMP_KEY_DIR
chmod 600 $TMP_KEY_DIR/*

cat << EOS > ssh-key.yaml
sshKey:
  id_rsa: |
$(cat $TMP_KEY_DIR/id_rsa | sed 's/^/    /g')

  id_rsa_pub: |
$(cat $TMP_KEY_DIR/id_rsa.pub | sed 's/^/    /g')
EOS
