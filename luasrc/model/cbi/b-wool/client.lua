local jd = "b-wool"
local uci = luci.model.uci.cursor()
local sys = require "luci.sys"

m = Map(jd)
-- [[ 薅羊毛Docker版-基本设置 ]]--

s = m:section(TypedSection, "global",
              translate("京东签到-Docker"))
s.anonymous = true

o = s:option(DummyValue, "", "")
o.rawhtml = true
o.template = "b-wool/cookie_tools"


--容器目录
o =s:option(Value, "jd_dir", translate("项目目录"))
o.default = ""
o.rmempty = false
o.description = translate("<br/>目录结尾不要带'/'")

--通知形式
o = s:option(ListValue, "notify_enable", translate("通知形式"))
o.default = 2
o.rmempty = false
o:value(0, translate("关闭通知"))
o:value(1, translate("简洁通知"))
o:value(2, translate("原始通知"))

--cookies
o= s:option(DynamicList, "cookiebkye", translate("cookies"))
o.rmempty = false
o.description = translate("<br/>必填项 不填初始化不了<br/>Cookie的具体形式：pt_key=xxxxxxxxxx;pt_pin=xxxx; <br/>由上到下第一个为cookie1<br/>注：cookies不要带有空格")

--随机延迟
o =s:option(Value, "qiandao_stop", translate("定义随机延迟启动任务"))
o.default = "300"
o.rmempty = false
o.description = translate("<br/>如果任务不是必须准点运行的任务，那么给它增加一个随机延迟，由你定义最大延迟时间，单位为秒")

--签到延迟
o =s:option(Value, "bean_stop", translate("定义每日签到的延迟时间"))
o.default = "0"
o.rmempty = false
o.description = translate("<br/>默认每个签到接口并发无延迟，如需要依次进行每个接口，请自定义延迟时间<br/>单位为毫秒，延迟作用于每个签到接口, 如填入延迟则切换顺序签到(耗时较长)")

--企业微信应用消息推送
o = s:option(Value, "qywx_am", translate("企业微信应用消息推送"))
o.rmempty = true
o.description = translate("<br/>企业微信应用消息推送的值，文档：https://work.weixin.qq.com/api/doc/90000/90135/90236<br/>依次填上corpid的值,corpsecret的值,touser的值,agentid的值，注意用,号隔开")

--Server酱
o = s:option(Value, "serverchan", translate("Server酱 SCKEY"))
o.rmempty = true
o.description = translate("<br/>微信推送，基于Server酱服务<br/>教程： http://sc.ftqq.com/ 绑定并获取 SCKEY<br/>其他通知渠道请直接在配置文件（config.sh）修改")

--爱心助力
o = s:option(Flag, "love_code", translate("为我助力"))
o.default = "1"
o.rmempty = false
o.description = translate("<br/>打钩则为插件作者助力，种豆得豆&惊喜工厂两项，仅占用一个名额❥(^_-)爱你哦")


--手动执行脚本
o = s:option(Value, "sd_run", translate("手动执行脚本"))
o.rmempty = true
o.description = translate("<br/>1、填入需要执行的脚本名称，如京豆变动通知脚本：jd_bean_change（不带后缀）<br/>2、点击 保存&应用 即可<br/>手动执行脚本命令：<br/>docker exec jd_base bash jd 脚本名称 now")

o = s:option(DummyValue, "", "")
o.rawhtml = true
o.template = "b-wool/update_service"

return m
