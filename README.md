* 目标


new.sh:  启动例子

launch_linux.sh:  快速启动Linux机型

linux-device.json: 启动磁盘分配, 在这里启用非默认大小的磁盘和多块磁盘
	注意：根分区需要从ami中获取到对应的snapshot信息
	# aws ec2 describe-images --image-ids ami-52d1183f --query 'Images[*].[BlockDeviceMappings]'

linux-user-data.sh:  Linux 系统启动后，自动将第二块硬盘格式化，并加载到 /data 分区

Usage:
   ./launch_linux.sh EC2_NAME AMI_ID IP INSTANCE_TYPE KEY_NAME ROLE_NAME SUBNET_NAME SECURITY_GROUP_NAME


# TODO
* Windows 支持
* ami -> ebs snapshot自动对应
* 异常检查


# 参考

goal:
# Linux : root 20G, /data 30G                                                                                                                                                        #subnet-id:  subnet-8b7111ee | BP1_B_C_011_Mobile001

1. Source AMI: RHEL 7.2 ami-52d1183f

2. Get snapshot id from AMI infomation
# aws ec2 describe-images --image-ids ami-52d1183f
# aws ec2 describe-images --image-ids ami-52d1183f --query 'Images[*].[BlockDeviceMappings]'
{
    "Images": [
        {
            "VirtualizationType": "hvm",
            "Name": "RHEL-7.2_HVM_GA-20151112-x86_64-1-Hourly2-GP2",
            "Hypervisor": "xen",
            "SriovNetSupport": "simple",
            "ImageId": "ami-52d1183f",
            "State": "available",
            "BlockDeviceMappings": [
                {
                    "DeviceName": "/dev/sda1",
                    "Ebs": {
                        "DeleteOnTermination": true,
                        "SnapshotId": "snap-11ccf119",
                        "VolumeSize": 10,
                        "VolumeType": "gp2",
                        "Encrypted": false
                    }
                }
            ],
            "Architecture": "x86_64",
            "ImageLocation": "841258680906/RHEL-7.2_HVM_GA-20151112-x86_64-1-Hourly2-GP2",
            "RootDeviceType": "ebs",
            "OwnerId": "841258680906",
            "RootDeviceName": "/dev/sda1",
            "CreationDate": "2015-11-12T21:28:34.000Z",
            "Public": true,
            "ImageType": "machine",
            "Description": "Provided by Red Hat, Inc."
        }
    ]
}
