local SNEEDIO_MCT_CONTROL_PANEL_ID = "Sneedio";
local SECTION_NAME = "General";
local CheckMuteControlId = "MusicMute";
local SliderMusicVolumeControlId = "MusicVolume";

local M = mct:register_mod(SNEEDIO_MCT_CONTROL_PANEL_ID);
M:set_title("Sneedio");
M:set_description("Configures sneedio audio, for advanced configuration check user-sneedio.json");

local controls = {};
M:add_new_section(SECTION_NAME);

local CheckMute = M:add_new_option(CheckMuteControlId, "checkbox");
CheckMute:set_text("Mute Sneedio Audio");
CheckMute:set_tooltip_text("Mute all audio from sneedio audio");
CheckMute:set_default_value(false);

local SliderMusicVolume = M:add_new_option(SliderMusicVolumeControlId, "slider");
SliderMusicVolume:set_text("Music Volume");
CheckMute:set_tooltip_text("Adjust music volume channel from sneedio");
SliderMusicVolume:slider_set_min_max(0, 100);
SliderMusicVolume:slider_set_step_size(1);
SliderMusicVolume:set_default_value(10);

for index, value in ipairs(controls) do
    value:set_assigned_section(SECTION_NAME);
end