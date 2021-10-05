local sneedio = require("sneedio");
local print = print2 or out;
if(core == nil) then
    print("CORE WAS NULLLLL!");
end
if(sneedio.ForceStartTimer()) then
    print("SNEEDIO HAS LOADED");
else
    print("SNEEDIO FAILED to LOAD");
end