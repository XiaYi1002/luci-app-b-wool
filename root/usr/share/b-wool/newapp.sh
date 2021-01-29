#!/bin/bash
#
#本人比较懒，直接修改自 <jerrykuku@qq.com>的京东签到脚本，额，我更懒，改自ChongshengB之后的脚本
#

NAME=b-wool
TEMP_SCRIPT=/tmp/JD_DailyBonus.js
LOG_HTM=/www/b-wool.htm
usage() {
    cat <<-EOF
		Usage: app.sh [options]
		Valid options are:

		    -a                      初始化
		    -b                      更新参数			
		    -c                      更新任务 
		    -d                      替换任务
			-t                      提取互助码
		    -w                      停止&删除
		    -x                      更新
		    -y                      停止
		    -z                      重启
		    -h                      Help
EOF
    exit $1
}

# Common functions

uci_get_by_name() {
    local ret=$(uci get $NAME.$1.$2 2>/dev/null)
    echo ${ret:=$3}
}

uci_get_by_type() {
    local ret=$(uci get $NAME.@$1[0].$2 2>/dev/null)
    echo ${ret:=$3}
}

uci_set_by_type() {
	uci add_list $NAME.@$1[0].$2=$3 2>/dev/null
	uci commit $NAME
}

uci_dellist_by_type() {
	uci delete $NAME.@$1[0].$2 2>/dev/null
	uci commit $NAME
}

cancel() {
    if [ $# -gt 0 ]; then
        echo "$1"
    fi
    exit 1
}

jd_dir2=$(uci_get_by_type global jd_dir)
love_code=$(uci_get_by_type global love_code)
#处理互助码	
	#定义京喜工厂	
	jxsc=$(uci_get_by_type global jxgc_sharecode)
	jxsc=${jxsc//[[:space:]]/@}
	#定义种豆	
	zdsc=$(uci_get_by_type global zddd_sharecode)
	zdsc=${zdsc//[[:space:]]/@}
	#定义东东农场	
	ncsc=$(uci_get_by_type global nc_sharecode)
	ncsc=${ncsc//[[:space:]]/@}

# 寻找目标
run() {
    cookies=$(uci_get_by_type global cookiebkye)
	if [ ! -n "$cookies" ]; then
	echo "未设置cookies 请先配置好cookies 请先配置好cookies 请先配置好cookies 再进行初始化" >>$LOG_HTM && exit 1
    else
    echo "Cookies已配置 开始执行..." >>$LOG_HTM 2>&1
	echo "注：Cookies 中不能带有空格哦" >>$LOG_HTM 2>&1
	echo "注：Cookies 中不能带有空格哦" >>$LOG_HTM 2>&1
	echo "注：Cookies 中不能带有空格哦" >>$LOG_HTM 2>&1
    fi
}

a_run() {
	rm -rf $jd_dir2
	mkdir -p $jd_dir2
    cd $jd_dir2
	mkdir -p config
	#wget --no-check-certificate https://gitee.com/evine/jd-base/raw/v3/sample/config.sh.sample -O config/config.sh
	#sleep 1
	#wget --no-check-certificate https://gitee.com/evine/jd-base/raw/v3/sample/docker.list.sample -O config/crontab.list
	#sleep 1
	chmod -R 777 $jd_dir2
}

b_run() {
    update_enable=$(uci_get_by_type global update_enable)
    echo "部署容器..." >>$LOG_HTM 2>&1
	echo "首次拉取镜像有点慢...." >>$LOG_HTM 2>&1
	docker run -dit -v $jd_dir2/config:/jd/config -v $jd_dir2/log:/jd/log --network host --name jd_base --hostname jd_base --restart always evinedeng/jd:gitee >>$LOG_HTM 2>&1
}

c_run() {
	notify_enable=$(uci_get_by_type global notify_enable)
	bean_stop=$(uci_get_by_type global bean_stop)
	qiandao_stop=$(uci_get_by_type global qiandao_stop)
	sckey=$(uci_get_by_type global serverchan)
	qywx_am=$(uci_get_by_type global qywx_am)
	ua=$(uci_get_by_type global jd_ua)
	
	echo "配置参数..." >>$LOG_HTM 2>&1
#Cookies 
	j=1
	for ck in $(uci_get_by_type global cookiebkye)
	do
	sed -i 's/^Cookie'$j'=.*$/Cookie'$j'=\"'$ck'"/g' $jd_dir2/config/config.sh
	let j++
	done
	j=`expr $j - 1`
#通知形式	
    sed -i 's/^NotifyBeanSign=.*$/NotifyBeanSign=\""/g' $jd_dir2/config/config.sh
    sed -i 's/^NotifyBeanSign=.*$/NotifyBeanSign=\"'$notify_enable'\"/g' $jd_dir2/config/config.sh
#ServerChan
    sed -i 's/^export PUSH_KEY=.*$/export PUSH_KEY=\""/g' $jd_dir2/config/config.sh
    sed -i 's/^export PUSH_KEY=.*$/export PUSH_KEY=\"'$sckey'\"/g' $jd_dir2/config/config.sh
#签到延迟
    sed -i 's/^export JD_BEAN_STOP=.*$/export JD_BEAN_STOP=\""/g' $jd_dir2/config/config.sh
    sed -i 's/^export JD_BEAN_STOP=.*$/export JD_BEAN_STOP=\"'$bean_stop'\"/g' $jd_dir2/config/config.sh
#随机延迟
    sed -i 's/^RandomDelay=.*$/RandomDelay=\""/g' $jd_dir2/config/config.sh
    sed -i 's/^RandomDelay=.*$/RandomDelay=\"'$qiandao_stop'\"/g' $jd_dir2/config/config.sh
#企业微信应用消息推送
    sed -i 's/^export QYWX_AM=.*$/export QYWX_AM=\""/g' $jd_dir2/config/config.sh
    sed -i 's/^export QYWX_AM=.*$/export QYWX_AM=\"'$qywx_am'\"/g' $jd_dir2/config/config.sh
#设置UA
	sed -i '/export JD_USER_AGENT=/d' $jd_dir2/config/config.sh
	echo "export JD_USER_AGENT=\"$ua\"" >>$jd_dir2/config/config.sh
}

d_run() {
	echo "config.sh" >>$LOG_HTM 2>&1
	rm -rf $jd_dir2/config/config.sh
	#wget --no-check-certificate https://gitee.com/evine/jd-base/raw/v3/sample/config.sh.sample -O $jd_dir2/config/config.sh.sample
	cp -r $jd_dir2/config/config.sh.sample $jd_dir2/config/config.sh
	chmod -R 777 $jd_dir2
}

# e_run() {
	# echo "替换crontab.list" >>$LOG_HTM 2>&1
	# rm -rf $jd_dir2/config/crontab.list
	# wget --no-check-certificate https://gitee.com/evine/jd-base/raw/v3/sample/docker.list.sample -O $jd_dir2/config/crontab.list
	# chmod -R 777 $jd_dir2
# }

# 处理cookies空格
ck_run() {
	grep "list cookiebkye" /etc/config/b-wool >/tmp/cookies.log
	sed -i "s/	list cookiebkye //g" /tmp/cookies.log
	sed -i s/[[:space:]]//g /tmp/cookies.log
	sed -i 's/^/	list cookiebkye &/g' /tmp/cookies.log
	uci_dellist_by_type global cookiebkye
    chmod -R 755 /etc/config/b-wool
	cat /tmp/cookies.log >> /etc/config/b-wool
	rm -rf /tmp/cookies.log
}

#互助码提取
allshare_code(){
    echo "提取互助码..." >>$LOG_HTM 2>&1
	docker exec jd_base bash jd jd_get_share_code now
	cd $jd_dir2/log/jd_get_share_code
    cat `ls -t *.log | head -n 1` >$LOG_HTM 2>&1
}

update_cron() {
    echo "更新计划任务..." >>$LOG_HTM 2>&1
    docker exec jd_base crontab /jd/config/crontab.list
}

up_scripts() {
    echo "更新脚本..." >>$LOG_HTM 2>&1
    docker exec jd_base bash git_pull >>$LOG_HTM 2>&1
}

# 手动执行脚本
sd_run() {
	sh=$(uci_get_by_type global sd_run)
    docker exec jd_base bash jd $sh now >>$LOG_HTM 2>&1
	uci_dellist_by_type global sd_run
}

love_run() {
	#定义东东农场要为哪些人助力	
	sed -i 's/^ForOtherFruit1=.*$/ForOtherFruit1=\""/g' $jd_dir2/config/config.sh
	sed -i "s/^ForOtherFruit1=.*$/ForOtherFruit1=\"$ncsc\"/g" $jd_dir2/config/config.sh
	
	#定义种豆得豆要为哪些人助力
	sed -i 's/^ForOtherBean1=.*$/ForOtherBean1=\""/g' $jd_dir2/config/config.sh
	sed -i "s/^ForOtherBean1=.*$/ForOtherBean1=\"$zdsc\"/g" $jd_dir2/config/config.sh
	
	#定义京喜工厂要为哪些人助力
	sed -i 's/^ForOtherDreamFactory1=.*$/ForOtherDreamFactory1=\""/g' $jd_dir2/config/config.sh
	sed -i "s/^ForOtherDreamFactory1=.*$/ForOtherDreamFactory1=\"$jxsc\"/g" $jd_dir2/config/config.sh
	if [ $love_code -eq 1 ]; then
	sed -i "s/n_jlLwqcGcXI2GkoT0y8SQ==@//g" $jd_dir2/config/config.sh
	sed -i "s/mlrdw3aw26j3wutynrw67pvnvv6srtt65du2asq@//g" $jd_dir2/config/config.sh
	j=1
	for ck in $(uci_get_by_type global cookiebkye)
	do
	sed -i 's/ForOtherDreamFactory'$j'=\"/&n_jlLwqcGcXI2GkoT0y8SQ==@/' $jd_dir2/config/config.sh
	sed -i 's/ForOtherBean'$j'=\"/&mlrdw3aw26j3wutynrw67pvnvv6srtt65du2asq@/' $jd_dir2/config/config.sh
	let j++
	done
	else
	echo "哼"
	fi
}

diy() {
    grep "diy_config" /etc/config/cy-wool >$jd_dir2/diy_config.log
    sed -i "s/\'//g" $jd_dir2/diy_config.log
    sed -i "s/list diy_config//g" $jd_dir2/diy_config.log
    sed -i 's/^[ \t]*//g' $jd_dir2/diy_config.log
    cat $jd_dir2/diy_config.log | while read linea
	do
	r=${linea#*=}
	l=${linea%=*}
	sed -i "s/^$l=.*$/$l=\"\"/g" $jd_dir2/config/config.sh
	sed -i "s/^$l=.*$/$l=$r/g" $jd_dir2/config/config.sh
	rm -rf $jd_dir2/diy_config.log
	done
}

w_run() {
    echo "启动容器" >>$LOG_HTM 2>&1
	docker start jd_base
}

x_run() {
    echo "重启容器" >>$LOG_HTM 2>&1
	docker restart jd_base
}

y_run() {
    echo "停止容器" >>$LOG_HTM 2>&1
	docker stop jd_base
}

z_run() {
    echo "删除容器" >>$LOG_HTM 2>&1
	docker rm jd_base
}

system_time() {
time3=$(date "+%Y-%m-%d %H:%M:%S")
echo "系统时间：$time3" >$LOG_HTM 2>&1
}

	
while getopts ":abcdefswxyzh" arg; do
    case "$arg" in
    a)
	    system_time
		y_run
		z_run
		run
		a_run
		d_run
		c_run
		b_run
		slepp 10
		w_run
		update_cron
		up_scripts
		d_run
        ck_run
		sd_run
		c_run
		diy
		love_run
        echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
    b)
	    system_time
		d_run
		c_run
		w_run
		up_scripts
		love_run
		diy
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
    c)
	    system_time
		allshare_code
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
    d)
	    system_time
		update_cron
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
    e)
	    system_time
		up_scripts
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
    f)
	    system_time
		# e_run
        up_scripts
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
    s)
        ck_run
		sd_run
		c_run
		diy
		love_run
        exit 0
        ;;
	w)
	    system_time
		w_run
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
    x)
		system_time
		x_run
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
    y)
	    system_time
		y_run
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;	
    z)
	    system_time
		y_run
		z_run
		echo "任务已完成" >>$LOG_HTM 2>&1
        exit 0
        ;;
    h)
        usage 0
        ;;
    esac
done
