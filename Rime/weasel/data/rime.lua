-- package.path      = "./lua/?.lua;" .. package.path
require"dependency/rimeTools"
reverse_pro                          =require"processor/reverse_pro"
select_char                          =require"processor/select_char"
quick_wrap                           =require"processor/quick_wrap"
plain_return                         =require"processor/plain_return"
smart_punct                          =require"processor/smart_punct"
module_cn_en                         =require"translator/module_cn_en"
module_dmma                          =require"translator/module_dmma"
module_dmma_upper                    =require"translator/module_dmma_upper"
module_fnua_cn                       =require"translator/module_fnua_cn"
module_fnua_triple                   =require"translator/module_fnua_triple"
module_fnua_shape                    =require"translator/module_fnua_shape"
save_entry                           =require"translator/save_entry"
chinese_number                       =require"translator/chinese_number"
unicode                              =require"translator/unicode"
execute                              =require"translator/execute"
custom_symbol                        =require"translator/custom_symbol"
custom_time                          =require"translator/custom_time"
ts_cn                                =require"translator/ts_fixed".setup({syllableLength=2})
ts_cn_quanpin                        =require"translator/ts_cn_quanpin"
ts_triple                            =require"translator/ts_fixed".setup({syllableLength=3})
ts_shape                             =require"translator/ts_shape"
ts_en                                =require"translator/ts_en"
fil_Uniquifier                       =require"filter/Uniquifier"
fil_KijinSeija                       =require"filter/KijinSeija"
fil_Unicode                          =require"filter/Unicode"
recorder                             =require"other/recorder"
ts_mini_linga_find,
ts_mini_linga                        =table.unpack((require"mixed/ts_mini_linga"))
quick_start_p,
quick_start_t                        =table.unpack((require"mixed/quick_start"))
ts_fanganlianxi_p,
ts_fanganlianxi_t                    =table.unpack((require"mixed/ts_fanganlianxi"))
option_swither_p=require("mixed/option_swither").prosessor
option_swither_t=require("mixed/option_swither").translator