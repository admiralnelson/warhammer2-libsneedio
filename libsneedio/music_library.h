#pragma once
#include <string>
#include <map>
#include "audeo/audeo.hpp"

class SneedioMusic
{
public:
	static SneedioMusic& Get();

	bool PlayMusic(const std::string& FileName, int Repeats = -1, float FadesInMs = 2000 );

	bool IsFileValid(const std::string& FileName);

	void Pause(bool bIsPaused = true);

	void SetVolume(float Strength);

	float GetVolume();

	void Mute(bool bMute = true);
private:
	audeo::Sound CurrentMusic;
	audeo::SoundSource SoundSource;

	float MusicVolume = 1;
	bool bMute;

	SneedioMusic();

public:
	SneedioMusic(SneedioMusic const&) = delete;
	void operator=(SneedioMusic const&) = delete;
};