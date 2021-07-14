#pragma once
#include "pch.h"
#include <string>
#include <map>
#include "audeo/audeo.hpp"
class SneedioFX 
{
public:
	static SneedioFX& Get();

	bool LoadVoiceBattle(const std::string& Filename, const std::string& UnitClassName);

	bool PlayVoiceBattle(const std::string& UnitClassName, int AudioIndex = 0 ,  audeo::vec3f Position = {0,0,0}, float MaxDistance = 255, float Volume = 1.0f);

	bool SetSoundPositionBattle(const std::string& UnitClassName, audeo::vec3f Position);

	void UpdateListenerPosition(audeo::vec3f Position, audeo::vec3f Target);

	void ClearBattle();

	void ClearSound();

	void Pause(bool bIsPaused = true);

	void SetSoundEffectVolume(float Strength);
private:
	std::map<std::string, audeo::Sound> UnitToSoundBattle;
	std::map<std::string, std::vector<audeo::SoundSource>> UnitToSoundSourceBattle;
	std::map<std::string, float> UnitToVolumeBattle;

	SneedioFX();
	audeo::vec3f CameraPosition;
	float SoundVolumeMultiplier = 1.0f;
public:
	SneedioFX(SneedioFX const&) = delete;
	void operator=(SneedioFX const&) = delete;
};