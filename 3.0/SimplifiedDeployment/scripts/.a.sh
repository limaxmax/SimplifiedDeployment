#! /bin/bash

war="$1"

if [ "$war"x = "nothing"x ]; then
	exit
else
	#war_url=${war%/*}
	#war_file=${war##*/}
	#war_exname=${war_file##*.}
	#echo $war
	#echo $war_url
	#echo $war_file
	#echo $war_exname
	#rm -rf /var/file/mss
	#mkdir -p /var/file/mss
	#chmod -777 /var/file/mss
	#cd /var/file/mss
	rm -rf /var/local/jenkins/.jenkins/workspace/mss_ust_221
	mkdir -p /var/local/jenkins/.jenkins/workspace/mss_ust_221
        cd /var/local/jenkins/.jenkins/workspace/mss_ust_221

	/usr/expect/bin/expect <<-EOF
	set time 30
	spawn svn co  "$war" /var/local/jenkins/.jenkins/workspace/mss_ust_221
	expect {
	"或(p)永远接受？" {send "p/r";exp_continue}
	"yes/no" { send "yes/r"}
	}
	interact
	expect eof
	EOF

	svn up
fi
