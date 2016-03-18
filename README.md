# 目标
基于配置文件，快速脚本化部署AWS环境


# 文件说明
* new.sh
启动例子

* launch_linux.sh
	快速启动Linux机型

* launch_windows.sh
	快速启动Windows机型

* linux-device.json
    启动磁盘分配, 在这里启用非默认大小的磁盘和多块磁盘
	注意：根分区需要从ami中获取到对应的snapshot信息
	> aws ec2 describe-images --image-ids ami-52d1183f --query 'Images[*].[BlockDeviceMappings]'
* windows-device.json
   Windows对应分区系统, 可以多块硬盘，并设置大小，获取snapshot信息如上
* linux-user-data.sh
	Linux 系统启动后，自动将第二块硬盘格式化，并加载到 /data 分区

* Usage:
   ./launch_linux.sh EC2_NAME AMI_ID IP INSTANCE_TYPE KEY_NAME ROLE_NAME SUBNET_NAME SECURITY_GROUP_NAME


# TODO
* ami -> ebs snapshot自动对应
* 异常检查


# 参考
* Process
Linux : root 20G, /data 30G                                                                                                                                                        #subnet-id:  subnet-8b7111ee | BP1_B_C_011_Mobile001
1. Source AMI: RHEL 7.2 ami-52d1183f
2. Get snapshot id from AMI infomation
