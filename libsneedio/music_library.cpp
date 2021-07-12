#include "pch.h"
#include "music_library.h"
#include <iostream>
SneedioMusic& SneedioMusic::Get()
{
    static SneedioMusic instance;
    return instance;
}

bool SneedioMusic::PlayMusic(const std::string& FileName, int Repeats)
{	
	try
	{
		SoundSource = audeo::load_source(FileName, audeo::AudioType::Music);
		if (Repeats >= 0)
		{
			audeo::play_sound(SoundSource, Repeats, 500);
		}
		else
		{
			audeo::play_sound(SoundSource, audeo::loop_forever, 500);
		}
	}
	catch (const audeo::exception& exception)
	{
		std::cout << "unable to load audio: " << exception.what() << std::endl;
		return false;
	}
	return true;
}

void SneedioMusic::PauseMusic(bool bIsPaused)
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
	audeo::set_volume(CurrentMusic, Strength);
}

SneedioMusic::SneedioMusic()
{
}
