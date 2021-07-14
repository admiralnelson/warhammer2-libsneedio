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
		ListOfSoundSourceBattle[UnitClassName].push_back(source);
	}	
	catch (const audeo::exception& exception) 
	{
		std::cout << "unable to load audio: " << exception.what() << std::endl;
		return false;
	}
	return true;
}

bool SneedioFX::PlayVoiceBattle(const std::string& UnitClassName, int AudioIndex, audeo::vec3f Position, float MaxDistance)
{
	if (ListOfSoundSourceBattle.find(UnitClassName) != ListOfSoundSourceBattle.end())
	{
		if (AudioIndex < 0 || AudioIndex > ListOfSoundSourceBattle[UnitClassName].size())
		{
			std::cout << "cannot play audio. invalid AudioIndex";
			return false;
		}
		audeo::Sound sound = audeo::play_sound(ListOfSoundSourceBattle[UnitClassName][AudioIndex]);
		audeo::set_distance_range_max(sound, MaxDistance);
		audeo::set_position(sound, Position);
		ListOfSoundsBattle[UnitClassName] = sound;
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
	if (ListOfSoundsBattle.find(UnitClassName) != ListOfSoundsBattle.end())
	{
		audeo::set_position(ListOfSoundsBattle[UnitClassName], Position);
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
	ListOfSoundsBattle.clear();
	ListOfSoundSourceBattle.clear();
}

void SneedioFX::Pause(bool bIsPaused)
{
	for (auto& sound : ListOfSoundsBattle)
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
	for (auto& sound : ListOfSoundsBattle)
	{
		audeo::set_volume(sound.second, Strength);
	}
}

SneedioFX::SneedioFX()
{
	
}

void SneedioFX::ClearSound()
{
	ListOfSoundsBattle.clear();
}