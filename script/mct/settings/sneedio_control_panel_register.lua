local SNEEDIO_MCT_CONTROL_PANEL_ID = "Sneedio";
local SECTION_NAME = "General";
local CheckMuteControlId = "MusicMute";
local CheckSoundMuteControlId = "SoundMute";
local SliderMusicVolumeControlId = "MusicVolume";
local SliderSoundVolumeControlId = "SoundVolume";
local CheckNoticeNoMusicFoundForFactionControlId = "NoticeNoMusicFoundForFaction";
local AllowModToModifyMenuMusicId = "AllowModToModifyMenuMusic";
local AllowModToModifyFactionMusicId = "AllowModToModifyFactionMusic";
local AllowModToDownloadAudioId = "AllowModToDownloadAudio";

local M = mct:register_mod(SNEEDIO_MCT_CONTROL_PANEL_ID);
M:set_title("Sneedio");
M:set_author(" ")
M:set_description("Configures sneedio audio, for advanced configuration check user-sneedio.json");

M:add_new_section(SECTION_NAME, "General");

local CheckMute = M:add_new_option(CheckMuteControlId, "checkbox");
CheckMute:set_text("Mute Sneedio Audio");
CheckMute:set_tooltip_text("Mute music from sneedio audio");
CheckMute:set_default_value(false);

local CheckSoundMute = M:add_new_option(CheckSoundMuteControlId, "checkbox");
CheckSoundMute:set_text("Mute Sound Effects");
CheckSoundMute:set_tooltip_text("Mute all sound effects from sneedio");
CheckSoundMute:set_default_value(false);

local CheckNoticeNoMusicFoundForFaction = M:add_new_option(CheckNoticeNoMusicFoundForFactionControlId, "checkbox");
CheckNoticeNoMusicFoundForFaction:set_text("Notify when no music was found for current faction");
CheckNoticeNoMusicFoundForFaction:set_tooltip_text("Shows a message box when no music was found for the current faction");
CheckNoticeNoMusicFoundForFaction:set_default_value(true);

local CheckAllowModToModifyMenuMusic = M:add_new_option(AllowModToModifyMenuMusicId, "checkbox");
CheckAllowModToModifyMenuMusic:set_text("Allow mod to override menu music");
CheckAllowModToModifyMenuMusic:set_tooltip_text("Allows mods to override the menu music");
CheckAllowModToModifyMenuMusic:set_default_value(true);

local CheckAllowModToModifyFactionMusicId = M:add_new_option(AllowModToModifyFactionMusicId, "checkbox");
CheckAllowModToModifyFactionMusicId:set_text("Allow mod to add new music for factions");
CheckAllowModToModifyFactionMusicId:set_tooltip_text("Disabling this will prevent mods from adding new music for factions");
CheckAllowModToModifyFactionMusicId:set_default_value(true);

local CheckAllowModToDownloadAudioId = M:add_new_option(AllowModToDownloadAudioId, "checkbox");
CheckAllowModToDownloadAudioId:set_text("Allow mod to use yt-dlp to download audio");
CheckAllowModToDownloadAudioId:set_tooltip_text("Disabling this will prevent mods from using yt-dlp to download music or additional audio");
CheckAllowModToDownloadAudioId:set_default_value(true);

local SliderMusicVolume = M:add_new_option(SliderMusicVolumeControlId, "slider");
SliderMusicVolume:set_text("Music Volume");
SliderMusicVolume:set_tooltip_text("Adjust music volume channel from sneedio");
SliderMusicVolume:slider_set_min_max(0, 100);
SliderMusicVolume:slider_set_step_size(1);
SliderMusicVolume:set_default_value(15);

local SliderSoundVolume = M:add_new_option(SliderSoundVolumeControlId, "slider");
SliderSoundVolume:set_text("Sound Effect Volume");
SliderSoundVolume:set_tooltip_text("Adjust sound effect volume channel from sneedio");
SliderSoundVolume:slider_set_min_max(0, 100);
SliderSoundVolume:slider_set_step_size(1);
SliderSoundVolume:set_default_value(70);

local controls = {CheckMute, CheckSoundMute, SliderMusicVolume, SliderSoundVolume};

for index, value in ipairs(controls) do
    value:set_assigned_section(SECTION_NAME);
end