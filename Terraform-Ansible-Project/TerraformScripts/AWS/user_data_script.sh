#!/bin/bash

#If dir not mentioned, terraform will create everything in root dir.
cd /home/ec2-user
mkdir dir_creted_by_user_data
cd dir_creted_by_user_data
touch newFile.txt