[app_server]
${public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/stage4-tf.pem ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'