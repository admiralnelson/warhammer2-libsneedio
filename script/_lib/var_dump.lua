local inspect = require("libsneedio_inspect");
local out = out;
local print2 = print2 or out;
local MAX_DEPTH = 10;

local function var_dump(...)
    local args = {...}
    if #args > 1 then
        var_dump(args)
    else
        if(type(args[1]) == "table" or type(args[1] == "userdata")) then
            print2(inspect(args[1], {depth = MAX_DEPTH}))
        else
            print2(tostring(args[1]))
        end
    end
end
return var_dump