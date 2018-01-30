#!/bin/bash
keyStr=$1
read -p "请输入${keyStr}库脚本描述:" description
newDateStr=`date +%Y%m%d`
#echo $newDateStr
cd /root/PigSkinBoy/scripts
oldDateStr=`cat .sqlInfo.txt|grep $keyStr|awk '{print $2}'`
#echo $oldDateStr

#先获取次数
oldCounts=`cat .sqlInfo.txt|grep $keyStr|awk '{print $3}'`
oldFileName=${keyStr}"_"${oldDateStr}"_"${oldCounts}".sql"
#echo $oldFileName
#echo $oldCounts
#获取制定字符串的行号
#nl .sqlInfo.txt|grep $keyStr|awk "{print $1}"
#line=`sed -n '/'${keyStr}'/=' .sqlInfo.txt`
#echo $line
#删除该行
#先删除在插入的理念是有问题的，如果删除了最后一行，行号减一，最后一行就无法插入了
#	sed -i "$line d" .sqlInfo.txt
if [ $newDateStr != $oldDateStr ]; then

	
	#在删除的行插入新字符串,
	newstr="$keyStr "${newDateStr}" 1"
#    echo $newstr
else
	#日期一样,其他不变，次数加1
	newCounts=`expr $oldCounts + 1`
#    echo $newCounts
	newstr="$keyStr "${newDateStr}" "${newCounts}
#    echo $newstr
	
fi

sed -i "s/${keyStr}[0-9, ]*/$newstr/g" .sqlInfo.txt
#echo `cat .sqlInfo.txt|grep $keyStr`
sed -i "s/ /-/g" .sqlInfo.txt
newFileName=`cat .sqlInfo.txt|grep $keyStr`.sql
#echo $newFileName
sed -i "s/-/ /g" .sqlInfo.txt
#description=$2
sed "s/?1/${newFileName}/g" insertSqlInfo.sql >.insertSqlInfo.sql
sed -i "s/?2/${description}/g" .insertSqlInfo.sql
mysqldump -uroot -pmysql $keyStr > ${oldFileName} 2>>/root/PigSkinBoy/scripts/log.out 
mysql -uroot -pmysql  -Dtest < .insertSqlInfo.sql  2>>/root/PigSkinBoy/scripts/log.out 
rm -rf .insertSqlInfo.sql
zip -m ./sqlBaks/${oldFileName}.zip ${oldFileName}
