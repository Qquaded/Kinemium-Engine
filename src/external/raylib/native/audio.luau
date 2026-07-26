--!strict
--!optimize 2
--!native

local ffi = zune.ffi

local adapter = require("./raylib")

local structs = adapter.structs

local void = ffi.types.void
local int = ffi.types.i32
local uint = ffi.types.u32
local bool = ffi.types.u8
local float = ffi.types.float
local cstring = ffi.types.pointer
type int = number
type uint = number
type bool = number
type float = number
type cstring = string | buffer | FFIPointer

local Wave = structs.Wave
local Sound = structs.Sound
local Music = structs.Music
local AudioStream = structs.AudioStream
type Wave = adapter.Wave
type Sound = adapter.Sound
type Music = adapter.Music
type AudioStream = adapter.AudioStream

local function fn(returns: any, args: { any })
	return {
		returns = returns,
		args = args,
	}
end

export type Fns = {
	InitAudioDevice: () -> (),
	CloseAudioDevice: () -> (),
	IsAudioDeviceReady: () -> bool,
	SetMasterVolume: (volume: float) -> (),
	GetMasterVolume: () -> float,
	LoadWave: (fileName: cstring) -> Wave,
	LoadWaveFromMemory: (fileType: cstring, fileData: FFIPointer, dataSize: int) -> Wave,
	IsWaveValid: (wave: Wave) -> bool,
	LoadSound: (fileName: cstring) -> Sound,
	LoadSoundFromWave: (wave: Wave) -> Sound,
	LoadSoundAlias: (source: Sound) -> Sound,
	IsSoundValid: (sound: Sound) -> bool,
	UpdateSound: (sound: Sound, data: FFIPointer, sampleCount: int) -> (),
	UnloadWave: (wave: Wave) -> (),
	UnloadSound: (sound: Sound) -> (),
	UnloadSoundAlias: (alias: Sound) -> (),
	ExportWave: (wave: Wave, fileName: cstring) -> bool,
	ExportWaveAsCode: (wave: Wave, fileName: cstring) -> bool,
	PlaySound: (sound: Sound) -> (),
	StopSound: (sound: Sound) -> (),
	PauseSound: (sound: Sound) -> (),
	ResumeSound: (sound: Sound) -> (),
	IsSoundPlaying: (sound: Sound) -> bool,
	SetSoundVolume: (sound: Sound, volume: float) -> (),
	SetSoundPitch: (sound: Sound, pitch: float) -> (),
	SetSoundPan: (sound: Sound, pan: float) -> (),
	WaveCopy: (wave: Wave) -> Wave,
	WaveCrop: (wave: FFIPointer, initFrame: int, finalFrame: int) -> (),
	WaveFormat: (wave: FFIPointer, sampleRate: int, sampleSize: int, channels: int) -> (),
	LoadWaveSamples: (wave: Wave) -> FFIPointer,
	UnloadWaveSamples: (samples: FFIPointer) -> (),
	LoadMusicStream: (fileName: cstring) -> Music,
	LoadMusicStreamFromMemory: (fileType: cstring, data: FFIPointer, dataSize: int) -> Music,
	IsMusicValid: (music: Music) -> bool,
	UnloadMusicStream: (music: Music) -> (),
	PlayMusicStream: (music: Music) -> (),
	IsMusicStreamPlaying: (music: Music) -> bool,
	UpdateMusicStream: (music: Music) -> (),
	StopMusicStream: (music: Music) -> (),
	PauseMusicStream: (music: Music) -> (),
	ResumeMusicStream: (music: Music) -> (),
	SeekMusicStream: (music: Music, position: float) -> (),
	SetMusicVolume: (music: Music, volume: float) -> (),
	SetMusicPitch: (music: Music, pitch: float) -> (),
	SetMusicPan: (music: Music, pan: float) -> (),
	GetMusicTimeLength: (music: Music) -> float,
	GetMusicTimePlayed: (music: Music) -> float,
	LoadAudioStream: (sampleRate: uint, sampleSize: uint, channels: uint) -> AudioStream,
	IsAudioStreamValid: (stream: AudioStream) -> bool,
	UnloadAudioStream: (stream: AudioStream) -> (),
	UpdateAudioStream: (stream: AudioStream, data: FFIPointer, frameCount: int) -> (),
	IsAudioStreamProcessed: (stream: AudioStream) -> bool,
	PlayAudioStream: (stream: AudioStream) -> (),
	PauseAudioStream: (stream: AudioStream) -> (),
	ResumeAudioStream: (stream: AudioStream) -> (),
	IsAudioStreamPlaying: (stream: AudioStream) -> bool,
	StopAudioStream: (stream: AudioStream) -> (),
	SetAudioStreamVolume: (stream: AudioStream, volume: float) -> (),
	SetAudioStreamPitch: (stream: AudioStream, pitch: float) -> (),
	SetAudioStreamPan: (stream: AudioStream, pan: float) -> (),
	SetAudioStreamBufferSizeDefault: (size: int) -> (),
	SetAudioStreamCallback: (stream: AudioStream, callback: FFIPointer) -> (),
	AttachAudioStreamProcessor: (stream: AudioStream, processor: FFIPointer) -> (),
	DetachAudioStreamProcessor: (stream: AudioStream, processor: FFIPointer) -> (),
	AttachAudioMixedProcessor: (processor: FFIPointer) -> (),
	DetachAudioMixedProcessor: (processor: FFIPointer) -> (),
}

return {
	def = {
		-- void InitAudioDevice(void);
		InitAudioDevice = fn(void, {}),
		-- void CloseAudioDevice(void);
		CloseAudioDevice = fn(void, {}),
		-- bool IsAudioDeviceReady(void);
		IsAudioDeviceReady = fn(bool, {}),
		-- void SetMasterVolume(float volume);
		SetMasterVolume = fn(void, { float }),
		-- float GetMasterVolume(void);
		GetMasterVolume = fn(float, {}),
		-- Wave LoadWave(const char *fileName);
		LoadWave = fn(Wave, { cstring }),
		-- Wave LoadWaveFromMemory(const char *fileType, const unsigned char *fileData, int dataSize);
		LoadWaveFromMemory = fn(Wave, { cstring, ffi.types.pointer, int }),
		-- bool IsWaveValid(Wave wave);
		IsWaveValid = fn(bool, { Wave }),
		-- Sound LoadSound(const char *fileName);
		LoadSound = fn(Sound, { cstring }),
		-- Sound LoadSoundFromWave(Wave wave);
		LoadSoundFromWave = fn(Sound, { Wave }),
		-- Sound LoadSoundAlias(Sound source);
		LoadSoundAlias = fn(Sound, { Sound }),
		-- bool IsSoundValid(Sound sound);
		IsSoundValid = fn(bool, { Sound }),
		-- void UpdateSound(Sound sound, const void *data, int sampleCount);
		UpdateSound = fn(void, { Sound, ffi.types.pointer, int }),
		-- void UnloadWave(Wave wave);
		UnloadWave = fn(void, { Wave }),
		-- void UnloadSound(Sound sound);
		UnloadSound = fn(void, { Sound }),
		-- void UnloadSoundAlias(Sound alias);
		UnloadSoundAlias = fn(void, { Sound }),
		-- bool ExportWave(Wave wave, const char *fileName);
		ExportWave = fn(bool, { Wave, cstring }),
		-- bool ExportWaveAsCode(Wave wave, const char *fileName);
		ExportWaveAsCode = fn(bool, { Wave, cstring }),
		-- void PlaySound(Sound sound);
		PlaySound = fn(void, { Sound }),
		-- void StopSound(Sound sound);
		StopSound = fn(void, { Sound }),
		-- void PauseSound(Sound sound);
		PauseSound = fn(void, { Sound }),
		-- void ResumeSound(Sound sound);
		ResumeSound = fn(void, { Sound }),
		-- bool IsSoundPlaying(Sound sound);
		IsSoundPlaying = fn(bool, { Sound }),
		-- void SetSoundVolume(Sound sound, float volume);
		SetSoundVolume = fn(void, { Sound, float }),
		-- void SetSoundPitch(Sound sound, float pitch);
		SetSoundPitch = fn(void, { Sound, float }),
		-- void SetSoundPan(Sound sound, float pan);
		SetSoundPan = fn(void, { Sound, float }),
		-- Wave WaveCopy(Wave wave);
		WaveCopy = fn(Wave, { Wave }),
		-- void WaveCrop(Wave *wave, int initFrame, int finalFrame);
		WaveCrop = fn(void, { ffi.types.pointer, int, int }),
		-- void WaveFormat(Wave *wave, int sampleRate, int sampleSize, int channels);
		WaveFormat = fn(void, { ffi.types.pointer, int, int, int }),
		-- float *LoadWaveSamples(Wave wave);
		LoadWaveSamples = fn(ffi.types.pointer, { Wave }),
		-- void UnloadWaveSamples(float *samples);
		UnloadWaveSamples = fn(void, { ffi.types.pointer }),
		-- Music LoadMusicStream(const char *fileName);
		LoadMusicStream = fn(Music, { cstring }),
		-- Music LoadMusicStreamFromMemory(const char *fileType, const unsigned char *data, int dataSize);
		LoadMusicStreamFromMemory = fn(Music, { cstring, ffi.types.pointer, int }),
		-- bool IsMusicValid(Music music);
		IsMusicValid = fn(bool, { Music }),
		-- void UnloadMusicStream(Music music);
		UnloadMusicStream = fn(void, { Music }),
		-- void PlayMusicStream(Music music);
		PlayMusicStream = fn(void, { Music }),
		-- bool IsMusicStreamPlaying(Music music);
		IsMusicStreamPlaying = fn(bool, { Music }),
		-- void UpdateMusicStream(Music music);
		UpdateMusicStream = fn(void, { Music }),
		-- void StopMusicStream(Music music);
		StopMusicStream = fn(void, { Music }),
		-- void PauseMusicStream(Music music);
		PauseMusicStream = fn(void, { Music }),
		-- void ResumeMusicStream(Music music);
		ResumeMusicStream = fn(void, { Music }),
		-- void SeekMusicStream(Music music, float position);
		SeekMusicStream = fn(void, { Music, float }),
		-- void SetMusicVolume(Music music, float volume);
		SetMusicVolume = fn(void, { Music, float }),
		-- void SetMusicPitch(Music music, float pitch);
		SetMusicPitch = fn(void, { Music, float }),
		-- void SetMusicPan(Music music, float pan);
		SetMusicPan = fn(void, { Music, float }),
		-- float GetMusicTimeLength(Music music);
		GetMusicTimeLength = fn(float, { Music }),
		-- float GetMusicTimePlayed(Music music);
		GetMusicTimePlayed = fn(float, { Music }),
		-- AudioStream LoadAudioStream(unsigned int sampleRate, unsigned int sampleSize, unsigned int channels);
		LoadAudioStream = fn(AudioStream, { uint, uint, uint }),
		-- bool IsAudioStreamValid(AudioStream stream);
		IsAudioStreamValid = fn(bool, { AudioStream }),
		-- void UnloadAudioStream(AudioStream stream);
		UnloadAudioStream = fn(void, { AudioStream }),
		-- void UpdateAudioStream(AudioStream stream, const void *data, int frameCount);
		UpdateAudioStream = fn(void, { AudioStream, ffi.types.pointer, int }),
		-- bool IsAudioStreamProcessed(AudioStream stream);
		IsAudioStreamProcessed = fn(bool, { AudioStream }),
		-- void PlayAudioStream(AudioStream stream);
		PlayAudioStream = fn(void, { AudioStream }),
		-- void PauseAudioStream(AudioStream stream);
		PauseAudioStream = fn(void, { AudioStream }),
		-- void ResumeAudioStream(AudioStream stream);
		ResumeAudioStream = fn(void, { AudioStream }),
		-- bool IsAudioStreamPlaying(AudioStream stream);
		IsAudioStreamPlaying = fn(bool, { AudioStream }),
		-- void StopAudioStream(AudioStream stream);
		StopAudioStream = fn(void, { AudioStream }),
		-- void SetAudioStreamVolume(AudioStream stream, float volume);
		SetAudioStreamVolume = fn(void, { AudioStream, float }),
		-- void SetAudioStreamPitch(AudioStream stream, float pitch);
		SetAudioStreamPitch = fn(void, { AudioStream, float }),
		-- void SetAudioStreamPan(AudioStream stream, float pan);
		SetAudioStreamPan = fn(void, { AudioStream, float }),
		-- void SetAudioStreamBufferSizeDefault(int size);
		SetAudioStreamBufferSizeDefault = fn(void, { int }),
		-- void SetAudioStreamCallback(AudioStream stream, AudioCallback callback);
		SetAudioStreamCallback = fn(void, { AudioStream, ffi.types.pointer }),
		-- void AttachAudioStreamProcessor(AudioStream stream, AudioCallback processor);
		AttachAudioStreamProcessor = fn(void, { AudioStream, ffi.types.pointer }),
		-- void DetachAudioStreamProcessor(AudioStream stream, AudioCallback processor);
		DetachAudioStreamProcessor = fn(void, { AudioStream, ffi.types.pointer }),
		-- void AttachAudioMixedProcessor(AudioCallback processor);
		AttachAudioMixedProcessor = fn(void, { ffi.types.pointer }),
		-- void DetachAudioMixedProcessor(AudioCallback processor);
		DetachAudioMixedProcessor = fn(void, { ffi.types.pointer }),
	},
}
