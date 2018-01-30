#! /bin/bash
# 该脚本用于实现从SVN服务器中拉去文件用
# paraNum =1
# para  svn文件夹的路径，建议在执行脚本输入参数时，将参数引号包裹
svnFile="$1"

if [ $# == 0  ]; then
  	echo "mei you svn lu jing shu ru"
	 exit
elif [ $# -gt 1  ]; then
	echo "ni shu ru le liang ge yi shang de can shu"
	exit
else
	svnFolder="$1"
 	rm -rf /root/PigSkinBoy/software
        mkdir -p /root/PigSkinBoy/software
        cd /root/PigSkinBoy/software

        /usr/expect/bin/expect <<-EOF
        set time 30
        spawn svn co "$svnFolder" /root/PigSkinBoy/software
        expect {
        "或(p)永远接受？" {send "p/r";exp_continue}
        "yes/no" { send "yes/r"}
        }
        interact
        expect eof
	EOF
	svn cleanup
        svn up
fi
