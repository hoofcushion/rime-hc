-- package.path      = "./lua/?.lua;" .. package.path
require "dependency/rimeTools"
require "dependency/utf8Sub"
reverse_pro         = require "processor/reverse_pro"
select_char         = require "processor/select_char"
quick_wrap          = require "processor/quick_wrap"
plain_return        = require "processor/plain_return"

module_cn_en        = require "translator/module_cn_en"
module_dmma         = require "translator/module_dmma"
module_dmma_upper   = require "translator/module_dmma_upper"
module_fnua_cn      = require "translator/module_fnua_cn"
module_fnua_triple  = require "translator/module_fnua_triple"

custom_phrase       = require "translator/custom_phrase"
custom_symbol       = require "translator/custom_symbol"
custom_time         = require "translator/custom_time"
save_entry          = require "translator/save_entry"
chinese_number      = require "translator/chinese_number"
ts_cn               = require "translator/ts_cn"
ts_cn_quanpin       = require "translator/ts_cn_quanpin"
ts_triple           = require "translator/ts_triple"
ts_en               = require "translator/ts_en"
ts_zm_double        = require "translator/ts_zm_double"
unicode             = require "translator/unicode"
execute             = require "translator/execute"

fil_Uniquifier      = require "filter/Uniquifier"
fil_KijinSeija      = require "filter/KijinSeija"
fil_Unicode         = require "filter/Unicode"

recorder            = require "other/recorder"

ts_mini_linga_find,
ts_mini_linga       = table.unpack((require"mixed/ts_mini_linga"))

quick_start_p,
quick_start_t       = table.unpack((require"mixed/quick_start"))

ts_fanganlianxi_p,
ts_fanganlianxi_t   = table.unpack((require"mixed/ts_fanganlianxi"))