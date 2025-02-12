M = {}

local whitenoise = require("noisemachine.white-noise")
local brownnoise = require("noisemachine.brown-noise")
local pinknoise = require("noisemachine.pink-noise")

local soundgenerators = { whitenoise, brownnoise, pinknoise }
local generatorindex = 0

local playing = false

M.play = function()
	if playing then
		return
	end
	soundgenerators[generatorindex + 1].play()
	playing = true
end

M.nextgenerator = function()
	if playing then
		soundgenerators[generatorindex + 1].stop()
	end

	generatorindex = (generatorindex + 1) % #soundgenerators

	if playing then
		soundgenerators[generatorindex + 1].play()
	end
end

M.stop = function()
	if not playing then
		return
	end
	soundgenerators[generatorindex + 1].stop()
	playing = false
end

return M
