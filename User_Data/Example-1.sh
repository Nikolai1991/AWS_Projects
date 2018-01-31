#!/bin/bash
sudo yum update -y
sudo yum install git -y
git config --global user.name "<username>"
git config --global user.email "<Email>"
sudo yum install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo yum install -y https://centos6.iuscommunity.org/ius-release.rpm
sudo yum install -y python35u python35u-pip
sudo pip3.5 install virtualenv
sudo yum upgrade -y
sudo reboot
