#!/bin/sh
#脚本是部署持续集成Jenkins
#制作者:张如亮
read -p  "请确定要安装的环境版本：
		git:git-2.9.5.tar.gz
		jdk:jdk-8u151-linux-x64.tar.gz
		maven:apache-maven-3.5.3-bin.tar.gz
		tomcat:apache-tomcat-9.0.1.tar.gz
		jenkins版本要选择8版本，如果您的机器没有，请先联系脚本制作人获取后再安装
按"y"安装，按任意键退出:" i
case $i in
y)
	:
;;
*)
	exit 0
esac
##测试网络
ping -c1 www.baidu.com &>/dev/null || exit 1
##安装编译器和依赖包
yum -y install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker &>/dev/null 
if [ $?==0 ];then
	:
else 
	echo "yum有问题，请先配置yum源"
	exit 2
fi
##准备git
echo "准备软件中……"
mkdir /jencfg
cd /jencfg/
mv `find / -name git-2.9.5.tar.gz` ./
mv `find / -name apache-maven-3.5.3-bin.tar.gz` ./
mv `find / -name apache-tomcat-9.0.1.tar.gz` ./
mv `find / -name jdk-8u151-linux-x64.tar.gz` ./
mv `find / -name jenkins.war` ./
if [ ! -f git-2.9.5.tar.gz ] ;then
	wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.9.5.tar.gz &>/dev/null -O ./
fi
if [ ! -f jdk-8u151-linux-x64.tar.gz ];then
	wget http://mirror.bit.edu.cn/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz -O ./ &>/dev/null
	wget http://mirrors.hust.edu.cn/apache/tomcat/tomcat-9/v9.0.1/bin/apache-tomcat-9.0.1.tar.gz  -O ./ &> /dev/null
	wget http://updates.jenkins-ci.org/download/war/2.127/jenkins.war -O /jencfg &> /dev/null
	echo "官网只能下载10以后的jdk，请拷贝"
	exit 
fi
echo "git配置中……"
echo "解压中……"
cd /jencfg
tar xvzf git-2.9.5.tar.gz  -C /usr/local &>/dev/null
cd /usr/local/git-2.9.5
mv /usr/local/git-2.9.5 /usr/local/git
echo "编译中……"
make prefix=/usr/local/git all 
make prefix=/usr/local/git install 
echo "PATH=$PATH:$HOME/bin:/usr/local/git/bin" >>/etc/bashrc
source /etc/bashrc
git --version	&>/dev/null
if [ $? -eq 0 ];then
	rpm -e --nodeps git &>/dev/null
	source /etc/bashrc
	git --version &>/dev/null
	if [ $? -eq 0 ];then
		echo "git部署完成"
	else 
		echo "git部署失败，请重试..."
		exit 3
	fi  
else 
	exit 4 
fi
# jdk环境部署
echo "正在准备jdk……"
cd /jencfg
tar -xvzf jdk-8u151-linux-x64.tar.gz -C /usr/local/ 
cd /usr/local/
mv jdk1.8.0_151 jdk
cd jdk
yum remove -y `rpm -qa |grep jdk` &>/dev/null
echo "配置环境变量中……"
echo "JAVA_HOME=/usr/local/jdk
export PATH=$PATH:$JAVA_HOME/bin" >>/etc/profile
source /etc/profile
java -version
if [ $? -eq 0 ];then 
	echo "jdk部署完成"
else
	echo "jdk部署失败"
	exit 5
fi

##maven环境
echo "正在配置maven……"
cd /jencfg/
tar xvzf apache-maven-3.5.3-bin.tar.gz -C /usr/local/ &>/dev/null
mv /usr/local/apache-maven-3.5.3/ /usr/local/maven
echo "正在配置环境变量……"
echo "export M2_HOME=/usr/local/maven
	  export M2=$M2_HOME/bin
	  PATH=$M2:$PATH:$HOME/bin:/usr/local/git/bin
	  export JAVA_HOME=/usr/local/jdk
	  export PATH"  >>/etc/bashrc
source /etc/bashrc
mvn --version &> /dev/null
if [ $? -eq 0 ];then 
	echo "maven安装完成"
fi 
##tomcat环境
echo"正在部署tomcat……"
tar xvzf apache-tomcat-9.0.1.tar.gz  -C /usr/local/ &>/dev/null
mv /usr/local/apache-tomcat-9.0.1 /usr/local/tomcat
echo "正在更改环境变量……"
echo "
CATALINA_HOME=/usr/local/tomcat 
export CATALINA_HOME" >>/etc/bashrc
source /etc/profile
echo "正在测试tomcat……"
/usr/local/tomcat/bin/startup.sh
if [ $? -eq 0 ];then
	echo "tomcat部署完成"
else
	echo "tomcat部署出了问题"
	exit 6
fi
/usr/local/tomcat/bin/shutdown.sh
echo "正在更改配置文件……"
sed -ri 's,</tomcat-users>,,' /usr/local/tomcat/conf/tomcat-users.xml 
echo '
<role rolename="manager-gui"/>
<role rolename="admin"/>
<role rolename="manager"/>
<role rolename="manager-script"/>
<user username="tomcat" password="tomcat" roles="manager-gui,admin,manager,manager-script"/>
</tomcat-users>'
##部署jenkins
cd /jencfg/
cp jenkins.war  /usr/local/tomcat/webapps/
echo "正在开启tomcat"
/usr/local/tomcat/bin/startup.sh
if [ $? -eq 0 ];then
	echo "配置成功，请用本机打开浏览器配置jenkins，网址为http://127.0.0.1:8080/jenkins"
else
	echo "配置失败"
	exit 10
fi
