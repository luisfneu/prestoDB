#!/usr/bin/env bash
set -euo pipefail

# Diretórios
mkdir -p /opt/presto-bootstrap/etc/catalog
mkdir -p /opt/presto-bootstrap/data

# Baixa configs do S3
aws s3 cp "s3://${CONFIG_BUCKET}/bootstrap/docker-compose.yml" /opt/presto-bootstrap/docker-compose.yml
aws s3 cp "s3://${CONFIG_BUCKET}/bootstrap/etc/" /opt/presto-bootstrap/etc/ --recursive

# Exporta região para hive.properties (usando envsubst-like)
AWS_REGION="us-west-2"
sed -i "s|\${AWS_REGION}|${AWS_REGION}|g" /opt/presto-bootstrap/etc/catalog/hive.properties

# Instala Docker + Compose plugin (Amazon Linux 2023)
dnf update -y
dnf install -y docker jq
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user || true

# Docker Compose via plugin
mkdir -p /usr/libexec/docker/cli-plugins
curl -L https://github.com/docker/compose/releases/download/v2.29.2/docker-compose-linux-x86_64 -o /usr/libexec/docker/cli-plugins/docker-compose
chmod +x /usr/libexec/docker/cli-plugins/docker-compose

cd /opt/presto-bootstrap
docker compose up -d

echo "PrestoDB iniciado."
