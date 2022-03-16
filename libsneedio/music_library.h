#pragma once
#include <string>
#include <map>
#include <thread>
#include <atomic>
#include "audeo/audeo.hpp"

class SneedioMusic
{
public:
	static SneedioMusic& Get();

	bool PlayMusic(const std::string& FileName, int Repeats = -1, float FadesInMs = 2000 );

	bool IsFileValid(const std::string& FileName);

	void Pause(bool bIsPaused = true);

	void SetVolume(float Strength);

	bool SeekToPosition(float secs);

	float GetVolume();

	int GetPosition();

	void Mute(bool bMute = true);
private:
	audeo::Sound CurrentMusic;
	audeo::SoundSource SoundSource;

	std::atomic<int> CurrentPlaybackTime = 0;
	float MusicVolume = 1;
	std::thread TimerThread;
	bool bMute;
	bool bPaused;
	bool bKeepThreadAlive;
	bool bSyncThread;
	SneedioMusic();

public:
	SneedioMusic(SneedioMusic const&) = delete;
	void operator=(SneedioMusic const&) = delete;
	~SneedioMusic();
};