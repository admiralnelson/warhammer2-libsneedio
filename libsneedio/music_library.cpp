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
		CurrentPlaybackTime = 0;
		std::cout << "unable to load audio: " << exception.what() << std::endl;
		return false;
	}
	CurrentPlaybackTime = 0;
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
	bPaused = bIsPaused;
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

bool SneedioMusic::SeekToPosition(float secs)
{
	CurrentPlaybackTime = secs;
	if (Mix_SetMusicPosition(secs) > 0)
	{
		std::cout << "failed to set music position to " << secs << std::endl;
		return false;
	}
	return true;
}

float SneedioMusic::GetVolume()
{
	return MusicVolume;
}

int SneedioMusic::GetPosition()
{
	return CurrentPlaybackTime;
}

void SneedioMusic::Mute(bool mute)
{
	bMute = mute;
	SetVolume(MusicVolume);
}

SneedioMusic::SneedioMusic() : 
	bMute(false), 
	bKeepThreadAlive(true), 
	bSyncThread(false), 
	bPaused(false)
{
	TimerThread = std::thread([this] {
		while (bKeepThreadAlive) {
			auto delta = std::chrono::steady_clock::now() + std::chrono::milliseconds(1000);
			if (!bPaused)
			{
				CurrentPlaybackTime++;
			}
			std::this_thread::sleep_until(delta);
		}
		std::cout << "sneedio: timer thread was quitted." << std::endl;
	});
}

SneedioMusic::~SneedioMusic()
{
	bKeepThreadAlive = false;
	if (TimerThread.joinable())
	{
		TimerThread.join();
	}
	audeo::quit();
}
