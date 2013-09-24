#!/bin/bash

sudo /etc/init.d/jenkins stop
sudo rm /var/lib/jenkins/jobs
cd /var/lib/jenkins
sudo ln -s jobs2 jobs
sudo /etc/init.d/jenkins start
