#pragma once
#include "pch.h"
#include <string>
#include <map>
#include "audeo/audeo.hpp"
class SneedioFX 
{
public:
	static SneedioFX& Get();

	bool LoadAudio(const std::string& Filename, const std::string& UnitClassName);

	bool PlaySound(const std::string& UnitClassName, float MaxDistance = 100);

	bool SetSoundPosition(const std::string& UnitClassName, audeo::vec3f Position);

	void UpdateListenerPosition(audeo::vec3f Position);

	void ClearAll();

	void ClearSound();

	void Pause(bool bIsPaused = true);

	void SetSoundEffectVolume(float Strength);
private:
	std::map<std::string, audeo::Sound> ListOfSounds;
	std::map<std::string, audeo::SoundSource> ListOfSoundSource;

	SneedioFX();

public:
	SneedioFX(SneedioFX const&) = delete;
	void operator=(SneedioFX const&) = delete;
};