local M = {}

local ffi = require("ffi")

ffi.cdef([[
typedef int ALenum;
typedef int ALsizei;
typedef float ALfloat;
typedef unsigned int ALuint;
typedef unsigned char ALboolean;
typedef int ALint;

void alGenBuffers(ALsizei n, ALuint* buffers);
void alBufferData(ALuint buffer, ALenum format, const void* data, ALsizei size, ALsizei freq);
void alGenSources(ALsizei n, ALuint* sources);
void alSourcei(ALuint source, ALenum param, ALint value);
void alSourcePlay(ALuint source);
void alSourceStop(ALuint source);
void alDeleteSources(ALsizei n, const ALuint* sources);
void alDeleteBuffers(ALsizei n, const ALuint* buffers);

ALenum alGetError(void);
]])

local openal = ffi.load("openal")

local source, buffer

local function generate_brown_noise(sample_rate, duration)
	local samples = sample_rate * duration
	local data = ffi.new("int16_t[?]", samples)

	local previous = 0 -- Start at zero
	local max_amplitude = 32767
	local min_amplitude = -32768

	for i = 0, samples - 1 do
		-- Generate a small random step change
		local step = math.random(-1000, 1000) -- Adjust step size for smoothness
		previous = previous + step

		-- Clamp to prevent overflow
		if previous > max_amplitude then
			previous = max_amplitude
		elseif previous < min_amplitude then
			previous = min_amplitude
		end

		data[i] = previous
	end

	return data, samples * 2
end

local function check_error()
	local err = openal.alGetError()
	if err ~= 0 then
		print("Openal Error:", err)
	end
end

function M.play()
	if source then
		print("White noise already playing.")
		return
	end

	ffi.cdef([[
		typedef void* ALCdevice;
		typedef void* ALCcontext;
		ALCdevice* alcOpenDevice(const char* devicename);
		ALCcontext* alcCreateContext(ALCdevice* device, const int* attrlist);
		ALboolean alcMakeContextCurrent(ALCcontext* context);
	]])

	local device = openal.alcOpenDevice(nil)
	if device == nil then
		print("Failed to open OpenAL device")
		return
	end

	local context = openal.alcCreateContext(device, nil)
	if context == nil then
		print("Failed to create OpenAL context")
		return
	end

	openal.alcMakeContextCurrent(context)

	buffer = ffi.new("ALuint[1]")
	source = ffi.new("ALuint[1]")

	openal.alGenBuffers(1, buffer)
	check_error()
	if buffer[0] == 0 then
		print("Failed to generate buffer")
		return
	end

	openal.alGenSources(1, source)
	check_error()
	if source[0] == 0 then
		print("Failed to generate source")
		return
	end

	local noise_data, size = generate_brown_noise(44100, 5)

	local AL_FORMAT_MONO16 = 0x1101
	openal.alBufferData(buffer[0], AL_FORMAT_MONO16, noise_data, size, 44100)
	check_error()

	openal.alSourcei(source[0], 0x1009, buffer[0]) -- Attach buffer
	openal.alSourcei(source[0], 0x1007, 1)
	check_error()

	openal.alSourcePlay(source[0])
	check_error()
end

function M.stop()
	if not source then
		print("No white noise playing.")
		return
	end

	openal.alSourceStop(source[0])
	openal.alDeleteSources(1, source)
	openal.alDeleteBuffers(1, buffer)

	source, buffer = nil, nil

	check_error()
end

return M
