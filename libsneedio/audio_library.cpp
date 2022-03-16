#include "pch.h"
#include "audio_library.h"
#include <iostream>
SneedioFX& SneedioFX::Get()
{
	static SneedioFX instance;
	return instance;
}

bool SneedioFX::LoadVoiceBattle(const std::string& Filename, const std::string& UnitClassName)
{
	try 
	{
		audeo::SoundSource source = audeo::load_source(Filename, audeo::AudioType::Effect);
		UnitToSoundSourceBattle[UnitClassName].push_back(source);
	}	
	catch (const audeo::exception& exception) 
	{
		std::cout << "unable to load audio: " << exception.what() << std::endl;
		return false;
	}
	return true;
}

bool SneedioFX::PlayVoiceBattle(const std::string& UnitClassName, int AudioIndex, audeo::vec3f Position, float MaxDistance, float Volume)
{
	if (UnitToSoundSourceBattle.find(UnitClassName) != UnitToSoundSourceBattle.end())
	{
		if (AudioIndex < 0 || AudioIndex > UnitToSoundSourceBattle[UnitClassName].size())
		{
			std::cout << "cannot play audio. invalid AudioIndex";
			return false;
		}
		float mute = (bMute) ? 0 : 1;
		audeo::Sound sound = audeo::play_sound(UnitToSoundSourceBattle[UnitClassName][AudioIndex], 0, 250);
		/*audeo::set_default_volume(UnitToSoundSourceBattle[UnitClassName][AudioIndex], SoundVolume * mute);
		audeo::set_default_position(UnitToSoundSourceBattle[UnitClassName][AudioIndex], Position);
		audeo::set_default_distance_range_max(UnitToSoundSourceBattle[UnitClassName][AudioIndex], MaxDistance);*/

		audeo::set_volume(sound, SoundVolume * mute);
		audeo::set_position(sound, Position);
		audeo::set_distance_range_max(sound, MaxDistance);

		UnitToSoundBattle[UnitClassName] = sound;
		UnitToVolumeBattle[UnitClassName] = SoundVolume;
		return true;
	}
	else
	{
		std::cout << "cannot play audio. invalid unitclassname: " << UnitClassName << " make sure it is registered ";
		return false;
	}
}

bool SneedioFX::SetSoundPositionBattle(const std::string& UnitClassName, audeo::vec3f Position)
{
	if (UnitToSoundBattle.find(UnitClassName) != UnitToSoundBattle.end())
	{
		audeo::set_position(UnitToSoundBattle[UnitClassName], Position);
		return true;
	}
	else
	{
		std::cout << "cannot set audio position. invalid unitclassname (also PlaySound must be called first): " << UnitClassName << " make sure it is registered ";
		return false;
	}
}

void SneedioFX::UpdateListenerPosition(audeo::vec3f Position, audeo::vec3f Target)
{
	audeo::set_listener_position(Position);
	audeo::set_listener_forward(Target);
}

void SneedioFX::ClearBattle()
{
	UnitToSoundBattle.clear();
	UnitToSoundSourceBattle.clear();
	UnitToVolumeBattle.clear();
}

void SneedioFX::Pause(bool bIsPaused)
{
	for (auto& sound : UnitToSoundBattle)
	{
		if (bIsPaused)
		{
			audeo::pause_sound(sound.second);
		}
		else
		{
			audeo::resume_sound(sound.second);
		}
	}
}

void SneedioFX::SetSoundEffectVolume(float Strength)
{
	if (Strength < 0) Strength = 0;
	if (Strength > 1) Strength = 1;
	for (auto& unit : UnitToSoundSourceBattle)
	{
		float mute = (bMute) ? 0 : 1;
		for (auto& index : unit.second)
		{
			audeo::set_default_volume(index, mute * Strength);
		}
	}
	SoundVolume = Strength;
}

float SneedioFX::GetSoundEffectVolume()
{
	return SoundVolume;
}

void SneedioFX::Mute(bool mute)
{
	bMute = mute;
	SetSoundEffectVolume(GetSoundEffectVolume());
}

SneedioFX::SneedioFX() : bMute(false), SoundVolume(0.7)
{
	
}

void SneedioFX::ClearSound()
{
	UnitToSoundBattle.clear();
}