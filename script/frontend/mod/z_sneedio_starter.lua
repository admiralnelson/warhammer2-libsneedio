local sneedio = sneedio;
local print = print2 or out;
local core = core;

sneedio.TM.OnceCallback(
function ()
    sneedio._SneedioFrontEndMain();
end, sneedio.SYSTEM_TICK * 5, "main menu once");
print("=============OK===========\n");