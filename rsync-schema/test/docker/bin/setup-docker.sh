#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
# GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
# Add repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
# Update
sudo apt-get update
# Install
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
wget https://desktop.docker.com/linux/main/amd64/docker-desktop-4.22.1-amd64.deb?utm_source=docker&utm_medium=webreferral&utm_campaign=docs-driven-download-linux-amd64&_gl=1*11pxwe2*_ga*MTI0MzY5MDc5Mi4xNjkzNDk1MDU5*_ga_XJWPQMJYHQ*MTY5MzQ5NTA1OC4xLjEuMTY5MzQ5NjE3Ni42MC4wLjA.

# Launch Desktop
systemctl --user start docker-desktop