#bin/bash
#系统初始化脚本
for i in `seq 100`
do
read -p "请选择配置选项(1.配置IP 2.配置aliyum源 3.搭建LAMP环境 4.退出程序):" p

	if [ "$p" -eq "1" ];  then
			read -p "请选择IP配置方式【1.系统分配 2.手动配置（请手动开启桥接模式） 3.退出配置】：" a
				if [ $a -eq "1" ]; then
					sed 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-ens33
					systemctl restart network
					ping -c1 www.baidu.com && echo "自动配置成功" ||echo "自动配置失败，请手动配置"
				elif [ $a -eq "2" ];then
					read -p "请输入ip:" q 
					read -p "请输入prefix:" w
					read -p "请输入gateway:" e
					read -p "请输入dns:" r
					sed -ri 's/IPA.*//' /etc/sysconfig/network-scripts/ifcfg-ens33
					sed -ri 's/PRE.*//' /etc/sysconfig/network-scripts/ifcfg-ens33
					sed -ri 's/GATE.*//' /etc/sysconfig/network-scripts/ifcfg-ens33
					sed -ri 's/DNS.*//' /etc/sysconfig/network-scripts/ifcfg-ens33
					sed -ri 's/NETMA.*//' /etc/sysconfig/network-scripts/ifcfg-ens33
					sed -ri 's/BOOTPROTO=dhcp/BOOTPROTO=none/' /etc/sysconfig/network-scripts/ifcfg-ens33
					sed -ri 's/ONBOOT=no/ONBOOT=yes/' /etc/sysconfig/network-scripts/ifcfg-ens33
					echo -e "IPADDR=$q\nPREFIX=$w\nGATEWAY=$e\nDNS1=$r" >> /etc/sysconfig/network-scripts/ifcfg-ens33 
					echo "请1秒钟后尝试ctrl+c，如果不能成功连接，请重新连接服务器,并且检查是否为桥接"
					systemctl restart network 	
				elif [ $a -eq "3" ]; then
					continue
				else 
					echo "输入错误，请重新输入"
				fi	
	elif [ "$p" -eq "2" ]; then
		ping -c1 www.baidu.com &>/dev/null
		if [ "$?" -eq "0" ]; then
			echo "正在配置yum源，请稍等……"
			yum -y install wget  &>/dev/null
				if [ $? -eq 0 ];then 	
					rm -rf /etc/yum.repos.d/* 
					wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo &>/dev/null
					wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo  &>/dev/null
					yum -y install at &>/dev/null
			 			if [ $? -eq 0 ]; then
							echo "配置成功，正在更新缓存……"
							yum clean all &>/dev/null
							yum repolist &>/dev/null
							echo "yum源缓存更新成功"
						else 
							echo "配置失败，请重新配置"
						fi
				else
					echo "您的yum源有问题，请挂载本地光盘后重试"
				fi
		else
			echo "网络连接不成功，请检查网络"
			continue
		fi
	elif [ "$p" -eq "3" ]; then
		ping -c1 www.baidu.com &>/dev/null 
		if [ $? -eq 0 ]; then
			echo "正在安装，请稍等……" 
			yum -y install httpd php php-mysql mariadb-server &>/dev/null	
				if [ $? -eq 0 ];then
					echo "安装完成，正在开启服务……"
					systemctl start httpd 
					systemctl start mariadb
					echo "正在关闭防火墙"
					systemctl stop firewalld
					systemctl disable firewalld
					echo "正在关闭selinux"
					setenforce=0
					sed -ri 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config &>/dev/null
					echo "LAMP基础环境搭建完成"
				else	
					echo "yum源配置问题，请查看yum源配置"
				fi		
		else 
			echo "您的网络有问题，请检查网络配置"	
		fi
	fi
done
		
		
		
	

	

