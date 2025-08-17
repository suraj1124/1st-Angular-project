!#!/bin/bash
sudo dnf install -y nginx
sudo service nginx start
sudo chkconfig nginx on
sudo service nginx restart