#include "pch.h"
#include "music_library.h"
#include <iostream>
SneedioMusic& SneedioMusic::Get()
{
    static SneedioMusic instance;
    return instance;
}

bool SneedioMusic::PlayMusic(const std::string& FileName, int Repeats, float FadesInMs)
{	
	try
	{
		SoundSource = audeo::load_source(FileName, audeo::AudioType::Music);
		if (Repeats >= 0)
		{
			CurrentMusic = audeo::play_sound(SoundSource, Repeats, FadesInMs);
		}
		else
		{
			CurrentMusic = audeo::play_sound(SoundSource, audeo::loop_forever, FadesInMs);
		}
	}
	catch (const audeo::exception& exception)
	{
		std::cout << "unable to load audio: " << exception.what() << std::endl;
		return false;
	}
	return true;
}

bool SneedioMusic::IsFileValid(const std::string& FileName)
{
	try
	{
		audeo::SoundSource source = audeo::load_source(FileName, audeo::AudioType::Music);		
	}
	catch (const audeo::exception& exception)
	{
		std::cout << "unable to load audio: " << exception.what() << std::endl;
		return false;
	}
	return true;
}

void SneedioMusic::Pause(bool bIsPaused)
{
	if (bIsPaused)
	{
		audeo::pause_sound(CurrentMusic);
	}
	else
	{
		audeo::resume_sound(CurrentMusic);
	}
}

void SneedioMusic::SetVolume(float Strength)
{
	float mute = (bMute) ? 0 : 1;
	audeo::set_volume(CurrentMusic, Strength * mute);
	MusicVolume = Strength;
}

float SneedioMusic::GetVolume()
{
	return MusicVolume;
}

void SneedioMusic::Mute(bool mute)
{
	bMute = mute;
	SetVolume(MusicVolume);
}

SneedioMusic::SneedioMusic() : bMute(false)
{
}
