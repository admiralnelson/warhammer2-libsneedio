#pragma once
#include <string>
#include <map>
#include "audeo/audeo.hpp"

class SneedioMusic
{
public:
	static SneedioMusic& Get();

	bool PlayMusic(const std::string& FileName, int Repeats = -1);

	void PauseMusic(bool bIsPaused = true);

	void SetVolume(float Strength);
private:
	audeo::Sound CurrentMusic;
	audeo::SoundSource SoundSource;

	SneedioMusic();

public:
	SneedioMusic(SneedioMusic const&) = delete;
	void operator=(SneedioMusic const&) = delete;
};