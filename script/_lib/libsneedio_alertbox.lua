
local Split = function (str, delim, maxNb)
    -- Eliminate bad cases...
    if string.find(str, delim) == nil then
       return { str };
    end
    if maxNb == nil or maxNb < 1 then
       maxNb = 0;
    end
    local result = {};
    local pat = "(.-)" .. delim .. "()";
    local nb = 0;
    local lastPos;
    for part, pos in string.gfind(str, pat) do
       nb = nb + 1;
       result[nb] = part;
       lastPos = pos;
       if nb == maxNb then
          break;
       end
    end
    -- Handle the last field
    if nb ~= maxNb then
       result[nb + 1] = string.sub(str, lastPos);
    end
    return result;
end

local Trim = function (s)
    return s:match'^%s*(.*%S)' or '';
end

local FindEl = function (Parent, ElPath)
	if not is_uicomponent(Parent) then
		ElPath = Parent;
		Parent = core:get_ui_root();
	end

	ElPath = Trim(ElPath);
	local str = string.gsub(ElPath, "%s*root%s*>%s+", "");
	local args = Split(str, ">");
	for k, v in pairs(args) do
		args[k] = Trim(v);
	end
	return find_uicomponent(Parent, unpack(args));
end

local function createConfirmationBox(id, text, on_accept_callback, on_cancel_callback)
	local confirmation_box = core:get_or_create_component(id, "ui/Common UI/dialogue_box")
	confirmation_box:SetVisible(true)
	confirmation_box:RegisterTopMost()
    confirmation_box:PropagatePriority(99999)
	confirmation_box:LockPriority()

	confirmation_box:SequentialFind("ok_group"):SetVisible(false)

	local dy_text = find_uicomponent(confirmation_box, "DY_text")
	dy_text:SetStateText(text, text)

    if on_cancel_callback == nil then
        local root = core:get_ui_root();
        local backButton = FindEl(root, "root > "..id.." > both_group > button_cancel");
        if(backButton) then backButton:Destroy(); end
        local okButton = FindEl(root, "root > "..id.." > both_group > button_tick");
        if(okButton) then okButton:SetDockOffset(0, -3); end
    end

	local accept_fn = function()
        confirmation_box:UnLockPriority()
        confirmation_box:Destroy()
        core:remove_listener(id .. "_confirmation_box_reject")

        if core:is_campaign() then
            cm:release_escape_key_with_callback(id .. "_confirmation_box_esc")
        elseif core:is_battle() then
            bm:release_escape_key_with_callback(id .. "_confirmation_box_esc")
        else
            local _ = effect and effect.disable_all_shortcuts and effect.disable_all_shortcuts(false)
        end

        if on_accept_callback then
            on_accept_callback()
        end
    end

	local cancel_fn = function()
        confirmation_box:UnLockPriority()
        confirmation_box:Destroy()
        core:remove_listener(id .. "_confirmation_box_accept")

        if core:is_campaign() then
            cm:release_escape_key_with_callback(id .. "_confirmation_box_esc")
        elseif core:is_battle() then
            bm:release_escape_key_with_callback(id .. "_confirmation_box_esc")
        else
            local _ = effect and effect.disable_all_shortcuts and effect.disable_all_shortcuts(false)
        end

        if on_cancel_callback then
            on_cancel_callback()
        end
    end

	core:add_listener(
		id .. "_confirmation_box_accept",
		"ComponentLClickUp",
		function(context)
			return context.string == "button_tick"
		end,
		accept_fn,
		false
	)

	core:add_listener(
		id .. "_confirmation_box_reject",
		"ComponentLClickUp",
		function(context)
			return context.string == "button_cancel"
		end,
		cancel_fn,
		false
	)

	if core:is_campaign() then
		cm:steal_escape_key_with_callback(id .. "_confirmation_box_esc", cancel_fn)
	elseif core:is_battle() then
		bm:steal_escape_key_with_callback(id .. "_confirmation_box_esc", cancel_fn)
	else
		local _ = effect and effect.disable_all_shortcuts and effect.disable_all_shortcuts(true)
    end

    return confirmation_box
end


return createConfirmationBox