local CM = cm;
local print = print2 or out;
local core = core;

CM:add_first_tick_callback(function(ctx)
	if(core == nil) then
		print("FUCK off CORE was null");
	else
		print("core object existed")
	end

	local sneedio = sneedio or require("sneedio");

	if CM ~= nil then
		sneedio.TM.OnceCallback(function () sneedio._SneedioCampaignMain(); end, sneedio.SYSTEM_TICK * 5, "campaign once");
	end
end);
