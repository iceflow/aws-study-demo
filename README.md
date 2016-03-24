# 目标
	基于配置文件，快速脚本化部署AWS环境

# 文件说明
* config
	默认使用参数定义，包括默认VPC名称和默认使用user-data脚本

* new.sh
	启动例子

* launch_instance.sh
  启动EC2实例脚本

* block_device_map/block-device.json: 参考例子
    启动磁盘分配, 在这里启用非默认大小的磁盘和多块磁盘: 参考例子，具体生成内容见目录 block_device_map 下内容
* linux-user-data.sh
	Linux 系统启动后，自动将第二块硬盘格式化，并加载到 /data 分区

* Usage:
	./launch_instance.sh EC2_NAME AMI_ID DISK IP|dynamic INSTANCE_TYPE KEY_NAME ROLE_NAME SUBNET_NAME SECURITY_GROUP_NAME"

# TODO
1. Done: ami -> ebs snapshot自动对应
2. 异常检查
3. 配置文档快速导出, 分析后自动启动

# 参考
* Process
1. Source AMI: RHEL 7.2 ami-52d1183f
2. Get snapshot id from AMI infomation - done
