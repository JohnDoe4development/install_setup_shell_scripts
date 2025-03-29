#!/bin/bash

curl --output-dir /etc/apt/trusted.gpg.d -O https://apt.fruit.je/fruit.gpg

sudo touch /etc/apt/sources.list.d/fruit.list
echo 'deb [arch=amd64] https://apt.fruit.je/ubuntu noble mpv' | sudo tee /etc/apt/sources.list.d/fruit.list

sudo apt-get update
sudo apt-get install -y mpv
