#!/bin/bash
# paraNum 2 or 1
# para1(not null) svnFloder path
# para2(nullable) inport mysql 
ip="`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v 29|grep -v inet6|awk '{print $2}'`"
cd /root/PigSkinBoy/software
sh /root/PigSkinBoy/scripts/.getFolderFromSVN.sh $1
base_url=/root/PigSkinBoy/software/"`ls -l |grep ^d|grep WH|awk '{print $9}'`"
echo $base_url
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
        echo `date +'%Y-%m-%d %H:%M:%S'` >>/root/PigSkinBoy/scripts/log.out
	cd $base_url
	#base.sql是一个压缩文件
	base_sql_url=${base_url}/"`ls -l |grep ^d|grep BASE|awk '{print $9}'`"
	ftp_url=${base_url}/"`ls -l |grep ^d|grep FTP|awk '{print $9}'`"
        #echo $ftp_url
	mms_url=${base_url}/"`ls -l |grep ^d|grep MMS|awk '{print $9}'`"
	#echo $mms_url
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
                sh /root/PigSkinBoy/scripts/.sqlInfo.sh base
		mysql -uroot -pmysql base < $base_sql_url/*.sql 1>>/root/PigSkinBoy/scripts/log.out 2>&1
	fi
	if [[ $1 =~ "ftp" ]]; then
		sh /root/PigSkinBoy/scripts/.sqlInfo.sh ftp_db
		mysql -uroot -pmysql ftp_db < ${ftp_url}/*.sql  1>>/root/PigSkinBoy/scripts/log.out 2>&1

	fi
	if [[ $1 =~ "mms" ]]; then
		sh /root/PigSkinBoy/scripts/.sqlInfo.sh mms
		mysql -uroot -pmysql mms < ${mms_url}/*.sql 1>>/root/PigSkinBoy/scripts/log.out 2>&1
	fi

}
if [ $# -eq 0 ]; then
	echo "mei you can shu shu ru"
	exit
elif [ $# -eq 1 ]; then
#如果传入参数个数为1，默认全部数据库都不更新，只拉取软件文件并完成部署
#	sh /root/PigSkinBoy/scripts/getFolderFromSVN.sh $1
	dep_sql 
	dep_war
elif [ $# -gt 2 ]; then
#如果传入的参数大于2个	
	echo "ni shu ru le san ge yi shang de can shu"
	exit
elif [ $# == 2  ]; then
#如果传入2个参数
	#sh /root/PigSkinBoy/scripts/getFolderFromSVN.sh $1
	dep_sql $2
	dep_war
fi
service memcached restart
cd /var/local/apache-tomcat-8.0.33/bin
./startup.sh 

