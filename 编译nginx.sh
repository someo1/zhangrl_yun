#!/bin/bash
#nginx源码安装
#张如亮
#最后修改时间：2018.05.31
ping -c1 www.baidu.com &>/dev/null && : || exit 
while [ "$i"!==1 ]
do
	read -p "请确认nginx版本（nginx-1.14.0.tar.gz）、模块、如果您有希望的模块该脚本里没有的话，请联系脚本制作人,按'y'开始安装nginx,按'n'退出脚本: " nginx
	case $nginx in 
	y) 
	echo "正在创建nginx用户及组"
	groupadd nginx   &>/dev/null
	useradd -g nginx nginx &>/dev/null
	echo "正在安装编译器"
	yum -y install gcc wget gcc-c++ git automake autoconf libtool libxml2-devel libxslt-devel perl-devel perl-ExtUtils-Embed pcre-devel openssl-devel  &>/dev/null
	if [ $? -eq 0 ];then
		if [ ! -f  nginx-1.14.0.tar.gz ];then
			echo "正在下载源码包"
			wget http://nginx.org/download/nginx-1.14.0.tar.gz  &>/dev/null
		else 
			echo "源码包存在"
		fi
		if [ ! -d echo-nginx-module ];then
			echo "正在下载echo模块"
			git clone https://github.com/openresty/echo-nginx-module.git  &>/dev/null
		else
			echo "echo模块已存在"
		fi
		if [ ! -d /usr/local/src/nginx-1.14.0 ];then
			tar xvf nginx-1.14.0.tar.gz -C /usr/local/src   &>/dev/null
		else 
			echo "解压完毕"
		fi
		if [ ! -d /usr/local/src/echo-nginx-module ];then 
		cp -a echo-nginx-module  /usr/local/src/  &>/dev/null
		else
			:
		fi
		cd /usr/local/src/nginx-1.14.0   &>/dev/null	
		mkdir -p /usr/local/nginx/tmp 
	    echo "正在配置，稍等……"
		 ./configure \
		--prefix=/usr/local/nginx \
		--lock-path=/usr/local/nginx/logs/nginx.lock \
		--http-client-body-temp-path=/usr/local/nginx/tmp/client \
		--http-proxy-temp-path=/usr/local/nginx/tmp/proxy \
		--http-fastcgi-temp-path=/usr/local/nginx/tmp/fcgi \
		--http-uwsgi-temp-path=/usr/local/nginx/tmp/uwsgi \
		--http-scgi-temp-path=/usr/local/nginx/tmp/scgi \
		--user=nginx \
		--group=nginx \
		--with-pcre \
		--with-http_v2_module \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-file-aio \
		--with-http_v2_module \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--add-module=/usr/local/src/echo-nginx-module  &>/dev/null
		echo "配置完成，正在编译"
		make &>/dev/null
		echo "make successful"
		echo "make install  ing"
		make install &>/dev/null
		echo "make install complete"
	else
		echo "yum你配好了么？去配好了再来找我好不？"
		exit 3
	fi
	;;
	n) exit
	;;
	*) echo "输入错误，请重新输入"
	;;
	esac
done

