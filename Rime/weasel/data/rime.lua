-- package.path = "./lua/?.lua;" .. package.path
require("rimeTools")
require("utf8")
custom_cn_phrase=require("custom_cn_phrase")
custom_phrase=require("custom_phrase")
custom_symbol=require("custom_symbol")
custom_time=require("custom_time")
en_saver=require("en_saver")
fil=require("fil")
module_cn_en=require("module_cn_en")
module_dmma=require("module_dmma")
module_dmma_upper=require("module_dmma_upper")
module_fnua_cn=require("module_fnua_cn")
module_fnua_triple=require("module_fnua_triple")
module_fnua_processor=require("module_fnua_processor")
number_uppercaser=require("number_uppercaser")
recorder=require("recorder")
select_character=require("select_character")
ts_cn=require("ts_cn")
ts_cn_quanpin=require("ts_cn_quanpin")
ts_en=require("ts_en")
ts_triple=require("ts_triple")
unicode=require("unicode")

do
 local a=require("ts_mini_linga")
 ts_mini_linga_find=a[1]
 ts_mini_linga=a[2]
end
do
 local a=require("quickstart")
 quickstart=a[1]
 quickstarthint=a[2]
end
do
 local a=require("ts_fanganlianxi")
 ts_fanganlianxi_p=a[1]
 ts_fanganlianxi_t=a[2]
end

calculator_translator=require("calculator_translator")