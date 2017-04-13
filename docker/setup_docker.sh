#!/bin/bash

# SETUP ENV
COREOS_IPXE_SERVER_BASE_URL="pp-rancher01.prp.local:4777"
COREOS_IPXE_SERVER_LISTEN_ADDR="0.0.0.0:4777"
VERSIONS=("current")

# PREPARE DIRECTORY STRUCTURE
mkdir -p {configs,images,profiles,sshkeys}

# DOWNLOAD IMAGES
for VERSION in "${VERSIONS[@]}"
do
	echo "Downloading files for version ${VERSION}"
	mkdir -p images/amd64-usr/$VERSION
	wget -nc http://alpha.release.core-os.net/amd64-usr/$VERSION/coreos_production_pxe_image.cpio.gz -O images/amd64-usr/${VERSION}/coreos_production_pxe_image.cpio.gz
	wget -nc http://alpha.release.core-os.net/amd64-usr/$VERSION/coreos_production_pxe.vmlinuz -O images/amd64-usr/${VERSION}/coreos_production_pxe.vmlinuz
done

# CUSTOMIZE COREOS SERVER CONFIGURATION
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4tBuQACn8seokY88d1IA8+e2UOSjqVwYtpkGOG8xdG4rMm5DkibssVE0ksm/vY3FrK6ByyfPxs7lmnzmCIGQDlTulEriSoajo091fPh2pIGAtYxVeyknO5gFdYcy1Gb1eXlsArYhgmaiGNMk2IvzXNNVlzZZmSH5eZympttnUIJF+0I+J/PgIbaAiMf8430nFDYLXRRqyx1lPJInf0DcDysc1mlIQyfeazv9VsZFalTZL0hzAjmrqPZU+rBpbsM4cz8U/4wE8Pjyvl1i1x0DAQP8Dyo9OoZB7LT5h7n+syICetylO32hjHp4LI9h+/UG9OeHGO6+Dpe1kVmTGif5R pp-admin" > sshkeys/coreos.pub

wget -nc https://git.ppdev.io/snippets/134/raw -O configs/development.yml

for VERSION in "${VERSIONS[@]}"
do
	cat > profiles/development_${VERSION}.json <<EOF
{
    "cloud_config": "development",
    "rootfstype": "btrfs",
    "sshkey": "coreos",
    "version": "${VERSION}"
}
EOF
done

# BUILD DOCKER
docker build -t norova/coreos-ipxe-server .

# RUN DOCKER
docker run -d -p 4777:4777 -e "COREOS_IPXE_SERVER_BASE_URL=${COREOS_IPXE_SERVER_BASE_URL}" -e "COREOS_IPXE_SERVER_LISTEN_ADDR=${COREOS_IPXE_SERVER_LISTEN_ADDR}" norova/coreos-ipxe-server --name ipxe

