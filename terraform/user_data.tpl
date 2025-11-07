#cloud-config
package_update: true
package_upgrade: false
runcmd:
  - [ bash, -lc, 'amazon-linux-extras enable epel' ]
  - [ bash, -lc, 'dnf install -y jq' ]
  - [ bash, -lc, 'mkdir -p /opt/presto-bootstrap' ]
  - [ bash, -lc, 'curl -o /root/install_presto.sh https://raw.githubusercontent.com/luisfneu/prestoDB/refs/heads/main/presto-docker/install_presto.sh || true' ]
  - [ bash, -lc, 'aws s3 cp s3://${CONFIG_BUCKET}/bootstrap/install_presto.sh /root/install_presto.sh' ]
  - [ bash, -lc, 'chmod +x /root/install_presto.sh' ]
  - [ bash, -lc, '/root/install_presto.sh' ]
