#!/bin/bash
#kvm manager
#2017/08/02 by liuchao.
#for centos7

images_dir=/var/lib/libvirt/images
xml_dir=/etc/libvirt/qemu
red_col="\e[1;31m"
blue_col="\e[1;34m"
reset_col="\e[0m"

centos6u8_base_img=centos6u8_base.qcow2
centos7u3_base_img=centos7u3_base.qcow2
win7_base_img=win7_base.qcow2

centos6u8_base_xml=centos6u8_base.xml
centos7u3_base_xml=centos7u3_base.xml
win7_base_xml=win7_base.xml

menu() {
cat <<-EOF
+------------------------------------------------+
|						 |
|		======================		 |
|		  虚拟机基本管理 v4.0		 |
|		            by tianyun		 |
|		======================		 |
|		1. 安装KVM			 |		
|		2. 安装或重置CentOS-6.8 	 |
|		3. 安装或重置CentOS-7.3  	 |
|		4. 安装或重置Windows-7 	 	 |
|		5. 删除所有虚拟机		 |
|		q. 退出管理程序			 | 
|						 |
+------------------------------------------------+	
EOF
}

kvm_install_hint() {
	systemctl libvirtd status &>/dev/null
	if [ $? -ne 0 ];then
		echo -e "${red_col}未安装KVM软件或未启动libvirtd进程，请检查${reset_col}"
		continue
	fi
}

download_kvm_script() {
	wget -O /root/Desktop/virt-manager.desktop ftp://10.18.40.100/kvm/virt-manager.desktop &>/dev/null
	wget -O /root/Desktop/Readme.txt ftp://10.18.40.100/kvm/readme.txt &>/dev/null
	chmod a+x /root/Desktop/virt-manager.desktop &>/dev/null

	wget -O /root/桌面/virt-manager.desktop ftp://10.18.40.100/virt-manager.desktop &>/dev/null
	wget -O /root/桌面/Readme.txt ftp://10.18.40.100/kvm/readme.txt &>/dev/null
	chmod a+x /root/桌面/virt-manager.desktop &>/dev/null

	wget -O /usr/local/sbin/kvm-manager ftp://10.18.40.100/kvm/kvm-manager.sh &>/dev/null
	chmod a+x /usr/local/sbin/kvm-manager &>/dev/null
}

conn_test() {
	ping -c1 10.18.40.100 &>/dev/null
	if [ $? -ne 0 ];then
		echo -e "${red_col}无法访问10.18.40.100, 请检查网络或稍后再试!${reset_col}"	
		echo
		exit
	fi
}

menu

while :
do
	
	echo -en "${blue_col}请选择相应的操作[1-7], 显示菜单[m]: ${reset_col}"
	read choose

	case $choose in 
	1)
		conn_test
		download_kvm_script

		read -p "确认开始安装KVM [y]: " kvm_install
		if [ ! "${kvm_install}" = "y" ];then
			echo -e "$red_col输入不正确! $reset_col"
			continue					
		fi
		
		rpm -q virt-manager &>/dev/null
		if [ $? -ne 0 ];then
			echo "开始安装KVM......"
			yum -y groupinstall "virtual*"
			systemctl start libvirtd
			systemctl enable libvirtd
		fi


		echo "-----------------------------------------------------------"
		echo "KVM 安装完成，请查看桌面上的Readme文件..."
		echo "-----------------------------------------------------------"
		;;
	2)
		conn_test
		download_kvm_script

		read -p "确认重置CentOS 6.8 虚拟机吗?[y]: " rebuild_centos6u8
		if [ ! "${rebuild_centos6u8}" = "y" ];then
			echo -e "$red_col输入不正确! $reset_col"
			continue					
		fi

		if [ ! -f ${images_dir}/${centos6u8_base_img} ];then
			echo "正在下载镜像文件，请稍候......"
			wget -O ${images_dir}/${centos6u8_base_img} ftp://10.18.40.100/kvm/base_image/${centos6u8_base_img}
		fi

		for i in {1..5}
		do
			vm_name=centos6u8-${i}
                        vm_uuid=$(uuidgen)
			vm_disk=${vm_name}.qcow2
                        vm_xml=${xml_dir}/${vm_name}.xml
                        vm_mac="52:54:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed -r 's/^(..)(..)(..)(..).*$/\1:\2:\3:\4/')"
			base_xml=${xml_dir}/centos6u8_base.xml

			virsh destroy ${vm_name} &>/dev/null
			virsh undefine ${vm_name} &>/dev/null
			rm -rf ${xml_dir}/${vm_xml}
			rm -rf ${images_dir}/${vm_name}.*

			#disk
			qemu-img create -f qcow2 -b ${images_dir}/${centos6u8_base_img} ${images_dir}/${vm_disk} &>/dev/null

			#xml
			wget -q ftp://10.18.40.100/kvm/base_xml/${centos6u8_base_xml} -O ${base_xml}
			cp ${base_xml} ${vm_xml}
			sed -i -r "s#VM_NAME#$vm_name#" ${vm_xml}
			sed -i -r "s#VM_UUID#$vm_uuid#" ${vm_xml}
			sed -i -r "s#VM_DISK#$vm_disk#" ${vm_xml}
			sed -i -r "s#VM_MAC#$vm_mac#" ${vm_xml}
			
			#define
			virsh define ${vm_xml} &>/dev/null
			echo "虚拟机${vm_name} 重置完成..."
		done
		;;
	
	3)
		conn_test
		download_kvm_script

		read -p "确认重置所有的CentOS7.3虚拟机吗?[y]: " rebuild_centos7u3
		if [ ! "${rebuild_centos7u3}" = "y" ];then
			echo -e "$red_col输入不正确! $reset_col"
			continue					
		fi

		if [ ! -f ${images_dir}/${centos7u3_base_img} ];then
			echo "正在下载镜像文件，请稍候......"
			wget -O ${images_dir}/${centos7u3_base_img} ftp://10.18.40.100/kvm/base_image/${centos7u3_base_img}
		fi

		for i in {1..5}
		do
			vm_name=centos7u3-${i}
                        vm_uuid=$(uuidgen)
			vm_disk=${vm_name}.qcow2
                        vm_xml=${xml_dir}/${vm_name}.xml
                        vm_mac="52:54:$(dd if=/dev/urandom count=1 2>/dev/null | md5sum | sed -r 's/^(..)(..)(..)(..).*$/\1:\2:\3:\4/')"
			base_xml=${xml_dir}/centos7u3_base.xml

			virsh destroy ${vm_name} &>/dev/null
			virsh undefine ${vm_name} &>/dev/null
			rm -rf ${xml_dir}/${vm_xml}
			rm -rf ${images_dir}/${vm_name}.*

			#disk
			qemu-img create -f qcow2 -b ${images_dir}/${centos7u3_base_img} ${images_dir}/${vm_disk} &>/dev/null

			#xml
			wget -q ftp://10.18.40.100/kvm/base_xml/${centos7u3_base_xml} -O ${base_xml}
			cp ${base_xml} ${vm_xml}
			sed -i -r "s#VM_NAME#$vm_name#" ${vm_xml}
			sed -i -r "s#VM_UUID#$vm_uuid#" ${vm_xml}
			sed -i -r "s#VM_DISK#$vm_disk#" ${vm_xml}
			sed -i -r "s#VM_MAC#$vm_mac#" ${vm_xml}
			
			#define
			virsh define ${vm_xml} &>/dev/null
			echo "虚拟机${vm_name} 重置完成..."
		done
		;;
	
	4)
		conn_test
		download_kvm_script

		read -p "确认重置 windows 7 虚拟机吗?[y]: " rebuild_win7
		if [ ! "${rebuild_win7}" = "y" ];then
			echo -e "$red_col输入不正确! $reset_col"
			continue					
		fi

		if [ ! -f ${images_dir}/${win7_base_img} ];then
			echo "正在下载镜像文件，请稍候......"
			wget -O ${images_dir}/${win7_base_img} ftp://10.18.40.100/kvm/base_image/${win7_base_img}
		fi

		virsh destroy win7 &>/dev/null
		virsh undefine win7 &>/dev/null
		rm -rf ${xml_dir}/win7.xml
		rm -rf ${images_dir}/win7.qcow2

		qemu-img create -f qcow2 -b ${images_dir}/${win7_base_img} ${images_dir}/win7.qcow2 &>/dev/null

		wget -q ftp://10.18.40.100/kvm/base_xml/win7_base.xml -O ${xml_dir}/win7.xml
		virsh define ${xml_dir}/win7.xml &>/dev/null
		echo "虚拟机 windows 重置完成..."
		;;

	5)
		conn_test
		download_kvm_script

		all_vm=$(virsh list --all |awk '/[0-9]/{print $2}')

		echo -en "${red_col}确认删除所有虚拟机吗?[y]:${reset_col} " 
		read delete_all

		if [ ! "${delete_all}" = "y" ];then
			echo -e "$red_col放弃删除! $reset_col"
			continue					
		fi

		for vm in ${all_vm}
		do
			virsh destroy $vm &>/dev/null
			virsh undefine $vm &>/dev/null
			
			rm -rf ${xml_dir}/${vm}.xml
			rm -rf ${images_dir}/${vm}*
			echo "已删除虚拟机 $vm"
		done
		;;

	m)
		clear
		menu
		;;
	q)
		exit
		;;
	'')
		;;
	*)
		echo "输入错误！"
		
	esac

done
