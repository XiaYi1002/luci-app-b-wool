-- Copyright (C) 2020 jerrykuku <jerrykuku@gmail.com>
-- Licensed to the public under the GNU General Public License v3.
module("luci.controller.b-wool", package.seeall)
function index() 
    if not nixio.fs.access("/etc/config/b-wool") then 
        return 
    end
    
    entry({"admin", "services", "b-wool"}, alias("admin", "services", "b-wool", "client"), _("JD_Base"), 10).dependent = true -- 首页
    entry({"admin", "services", "b-wool", "client"}, cbi("b-wool/client"),_("Client"), 10).leaf = true -- 基本设置
    entry({"admin", "services", "b-wool", "log"},form("b-wool/log"),_("Log"), 60).leaf = true -- 日志页面
    entry({"admin", "services", "b-wool", "script"},form("b-wool/script"),_("参数配置"), 20).leaf = true -- 直接配置脚本
	entry({"admin", "services", "b-wool", "script2"},form("b-wool/script2"),_("任务列表"), 20).leaf = true -- 直接配置脚本
    entry({"admin", "services", "b-wool", "run"}, call("run")) -- 执行程序
    entry({"admin", "services", "b-wool", "update"}, call("update")) -- 执行更新
    entry({"admin", "services", "b-wool", "check_update"}, call("check_update")) -- 检查更新
end


-- 执行程序

function run()
	local up_code = luci.http.formvalue("good")
	--初始化
	if up_code == "up_service" then
		luci.sys.call("/usr/share/b-wool/newapp.sh -a &")
	--更换config
	elseif up_code == "up_config" then
        luci.sys.call("/usr/share/b-wool/newapp.sh -b &")
	--查看互助码	
	elseif up_code == "get_c" then
        luci.sys.call("/usr/share/b-wool/newapp.sh -c &")
	--更新任务
	elseif up_code == "up_cron" then
        luci.sys.call("/usr/share/b-wool/newapp.sh -d &")
	--更新脚本
	elseif up_code == "up_scripts" then
        luci.sys.call("/usr/share/b-wool/newapp.sh -e &")
	--替换任务列表
	elseif up_code == "up_list" then
        luci.sys.call("/usr/share/b-wool/newapp.sh -f &")
	--启动容器	
	elseif up_code == "st_service" then
        luci.sys.call("/usr/share/b-wool/newapp.sh -w &")
	--重启容器
	elseif up_code == "rt_service" then
        luci.sys.call("/usr/share/b-wool/newapp.sh -x &")
	--关闭容器	
	elseif up_code == "sp_service" then
        luci.sys.call("/usr/share/b-wool/newapp.sh -y &")
	--删除容器
	elseif up_code == "del_service" then
        luci.sys.call("/usr/share/b-wool/newapp.sh -z &")
	--更新插件
	elseif up_code == "up_app" then
        luci.sys.call("/usr/share/b-wool/update_client.sh &")
	end
end
