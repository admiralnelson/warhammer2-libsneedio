local CM = cm;
local print = print2 or out;
local core = core;

CM:add_first_tick_callback(function(ctx)
	local sneedio = sneedio;
	if CM ~= nil then
		sneedio.TM.OnceCallback(function ()
			sneedio._SneedioCampaignMain();
			if( sneedio.GetPlayerFactionPlaylistForCampaign() == nil and
			    sneedio.GetCurrentConfig().NoticeNoMusicFoundForFaction and
			    not sneedio.IsPlaylistEmpty()) then
				sneedio.MessageBox("sneediowarn", "Sneedio\n\n No faction playlist found for this faction: "
									..sneedio.GetPlayerFaction()..
									".\n\nPlease check your user-sneedio.json or contact mod author for custom faction.\n"
									.."You may turn on the default in game music in the option menu.\n\n"
									.."This message can be disabled in user-sneedio.json or via MCT control panel.");
			end
		end, sneedio.SYSTEM_TICK * 5, "campaign once");
	end
end);
