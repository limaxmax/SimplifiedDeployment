#!/bin/bash

ip="`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v 29|grep -v inet6|awk '{print $2}'`"
cd /var/file
base_url=/var/file/"`ls -l |grep ^d|grep WH|awk '{print $9}'`"
#echo $base_url
function dep_war(){
	cd $base_url
	war_url=${base_url}/"`ls -l |grep ^d|grep WH|awk '{print $9}'`"
	#echo $war_url
	cd /var/local/apache-tomcat-8.0.33/webapps/

	#service tomcat stop
	tomcat_pid="`ps -ef|grep tomcat-8.0.33|grep -v grep|awk '{print $2}'`"
	if [ "$tomcat_pid" = "" ]; then
		echo 'tomcat is dead!'
	else
		ps -ef|grep tomcat-8.0.33|grep -v grep |awk '{print $2}'|xargs kill -9
	fi

	rm -rf mss*
	cp ${war_url}/*war mss.war
	unzip -oq mss.war -d mss
	#cd /var/local/apache-tomcat-8.0.33/webapps/mss/js/mms

	sleep 5

	#sed -i "s/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/"${ip}"/g" main.js
	cd /var/local/apache-tomcat-8.0.33/webapps/mss/WEB-INF/classes/spring
	sed -i "s/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/"${ip}"/g" spring-data.xml
	sed -i "s/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/"${ip}"/g" spring-memcached.xml
	sed -i "s/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/"${ip}"/g" spring-mq.xml
	sed -i "s/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/"${ip}"/g" ../props/ftp.properties
	#echo "s/\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}/"${ip}"/g"
}
function dep_sql(){
	cd $base_url
	#base.sql是一个压缩文件
	base_sql_url=${base_url}/"`ls -l |grep ^d|grep BASE|awk '{print $9}'`"
	ftp_url=${base_url}/"`ls -l |grep ^d|grep FTP|awk '{print $9}'`"
	mms_url=${base_url}/"`ls -l |grep ^d|grep MMS|awk '{print $9}'`"
	#解压缩base文件
	cd $base_sql_url
	#echo $base_sql_url
	lineNum="`ls -l|awk '{print NR}'|tail -n1`"
	base_name="`ls -l|sed -n ${lineNum}'p'|awk '{print $9}'`"
	base_exname=${base_name##*.}
	#echo "$base_exname"
	if [ "$base_exname"x = "zip"x ]; then
		unzip -oq $base_name
	elif [ "$base_exname"x = "rar"x ]; then
		unrar e $base_file
	elif [ "$base_exname"x = "7z"x ]; then 
		7za x $base_file
	fi

	if [[ $1 =~ "base" ]]; then
		mysql -uroot -pmysql base < $base_sql_url/*.sql
	fi
	if [[ $1 =~ "ftp" ]]; then
		mysql -uroot -pmysql ftp_db < ${ftp_url}/*.sql
	fi
	if [[ $1 =~ "mms" ]]; then
		mysql -uroot -pmysql mms < ${mms_url}/*.sql
	fi

}

if [ $# -eq 0 ]; then
#如果传入参数个数为0，默认全部数据库都不更新
	dep_sql 
	dep_war
	service memcached restart
	cd /var/local/apache-tomcat-8.0.33/bin
	./startup.sh 
	cd /var/file
        rm -rf *WH*
elif [ $# -gt 1 ]; then
#如果传入的参数大于1个	
	echo "ni shu ru le liang ge yi shang de can shu"
elif [ $# == 1  ]; then
#如果传入一个参数
	dep_sql $1
	dep_war
	service memcached restart
	cd /var/local/apache-tomcat-8.0.33/bin
	./startup.sh
	cd /var/file
	rm -rf *WH*	
fi
