require("libsneedio_trycatch");
local var_dump = require("var_dump");
local sneedio = sneedio;
local print = print2 or out;
local core = core;
local ForEach = sneedio.ForEach;

sneedio.TM.OnceCallback(
function ()
    sneedio._SneedioFrontEndMain();
end, sneedio.SYSTEM_TICK * 5, "main menu once");
print("=============OK===========\n");