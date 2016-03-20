#!/bin/bash

# Launch RHEL7.2  instance
./launch_linux.sh EC2_Name ami-52d1183f 192.168.129.104 t2.micro testkey test_role test_subnet test_sg

# Launch Windows 2012 instance`
./launch_windows.sh EC2_Name ami-52d1183f 192.168.129.104 t2.micro testkey test_role test_subnet test_sg



exit 0
