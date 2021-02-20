#!/bin/sh

sudo rmmod iwlmvm iwlwifi mac80211 cfg80211
sudo modprobe iwlwifi
sudo modprobe iwlmvm
sudo modprobe cfg80211
sudo modprobe mac80211
