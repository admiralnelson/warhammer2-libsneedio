#include "pch.h"
#include "audio_library.h"
#include <iostream>
SneedioFX& SneedioFX::Get()
{
	static SneedioFX instance;
	return instance;
}

bool SneedioFX::LoadAudio(const std::string& Filename, const std::string& UnitClassName)
{
	try 
	{
		audeo::SoundSource source = audeo::load_source(Filename, audeo::AudioType::Effect);
		ListOfSoundSource[UnitClassName] = source;
	}	
	catch (const audeo::exception& exception) 
	{
		std::cout << "unable to load audio: " << exception.what() << std::endl;
		return false;
	}
	return true;
}

bool SneedioFX::PlaySound(const std::string& UnitClassName, float MaxDistance)
{
	if (ListOfSoundSource.find(UnitClassName) != ListOfSoundSource.end())
	{
		audeo::Sound sound = audeo::play_sound(ListOfSoundSource[UnitClassName]);
		audeo::set_distance_range_max(sound, MaxDistance);
		ListOfSounds[UnitClassName] = sound;
		return true;
	}
	else
	{
		std::cout << "cannot play audio. invalid unitclassname: " << UnitClassName << " make sure it is registered ";
		return false;
	}
}

bool SneedioFX::SetSoundPosition(const std::string& UnitClassName, audeo::vec3f Position)
{
	if (ListOfSounds.find(UnitClassName) != ListOfSounds.end())
	{
		audeo::set_position(ListOfSounds[UnitClassName], Position);
		return true;
	}
	else
	{
		std::cout << "cannot set audio position. invalid unitclassname (also PlaySound must be called first): " << UnitClassName << " make sure it is registered ";
		return false;
	}
}

void SneedioFX::UpdateListenerPosition(audeo::vec3f Position)
{
	audeo::set_listener_position(Position);
}

void SneedioFX::ClearAll()
{
	ListOfSounds.clear();
	ListOfSoundSource.clear();
}

void SneedioFX::Pause(bool bIsPaused)
{
	for (auto& sound : ListOfSounds)
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
	for (auto& sound : ListOfSounds)
	{
		audeo::set_volume(sound.second, Strength);
	}
}

SneedioFX::SneedioFX()
{
	
}

void SneedioFX::ClearSound()
{
	ListOfSounds.clear();
}