#!/bin/bash

# Launch RHEL7.2  instance
./launch_linux.sh EC2_Name ami-52d1183f 192.168.129.104 t2.micro testkey test_role test_subnet test_sg

# Launch Windows 2012 instance`
./launch_windows.sh QD011_Prod_ZXDB_004 ami-cbca01a6 168.161.129.120 t2.micro test AppZLTHangQing BP1_B_C_011_Cache001 BP1_B_C_QD011_Cache001



exit 0
