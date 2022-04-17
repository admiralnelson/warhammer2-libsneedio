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

	bool PlayMusic(const std::string& FileName, float FadesInMs = 2000 );

	bool IsFileValid(const std::string& FileName);

	void Pause(bool bIsPaused = true);

	void SetVolume(float Strength);

	bool SeekToPosition(float secs);

	float GetVolume();

	int GetPosition();

	void Mute(bool bMute = true);

	void EnableRepeat(bool bEnable = true);
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
	bool bRepeat;
	SneedioMusic();

public:
	SneedioMusic(SneedioMusic const&) = delete;
	void operator=(SneedioMusic const&) = delete;
	~SneedioMusic();
};