#!/usr/bin/env bash

DEB_FILENAME=google-chrome-stable_current_amd64.deb
SAVE_FILENAME=google-chrome.deb
sudo apt install -yq \
    wget \
    fonts-liberation \
    libnss3 \
    libnspr4 \
    libu2f-udev \
    xdg-utils

wget --quiet https://dl.google.com/linux/direct/${DEB_FILENAME} -O ${SAVE_FILENAME}
sudo dpkg -i ${SAVE_FILENAME}
rm -rf ${SAVE_FILENAME}
