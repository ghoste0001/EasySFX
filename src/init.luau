--!optimize 2
--!native

-- Version: [1.0.2]
-- EasySFX, a simple sound effect management module by [@Withoutruless].
-- Feel free to modify anything and use it for your games,
-- Crediting me would be appreciated but its not necessary.

local api = {}
------------------------

-- Exporting Properties --
local types = require(script.types)
export type reverbProperties = types.ReverbProperties
export type echoProperties = types.EchoProperties
export type equalizerProperties = types.EqualizerProperties
export type compressorProperties = types.CompressorProperties
export type chorusProperties = types.ChorusProperties
export type tremoloProperties = types.TremoloProperties
export type distortionProperties = types.DistortionProperties
export type pitchshiftProperties = types.PitchShiftProperties
export type flangeProperties = types.FlangeProperties
------------------------

-- This table contains all of the loaded sounds (hence its name).
local loadedSounds = {}

------------------------

-- You can set this here or through the '.Logging()' function.
local logging = false

------------------------

-- Simple logging function that puts the name of the module beforehand.
local function log(...)
	if logging then
		warn("EasySFX:", ...)
	end
end

-- Set logging to true or false (Default: false).
function api.Logging(value: boolean)
	if typeof(value) == "boolean" then
		logging = value
		log("Logging set to", value)
	end
end

-- This function returns an effect instance based on the name it receives.
local function returnEffect(s: string)
	return Instance.new(s)
end

-- This function executes functions passed through .OnUnload()
local function callbackFunction(con: {})
	for _, func in ipairs(con) do
		func()
	end
	table.clear(con)
end

-- This function applies properties to the provided effect.
local function applyProperties(instance: Instance, properties: { [string]: any }?)
	if not properties or typeof(properties) ~= "table" then return end
	for property, value in pairs(properties) do
		local success = pcall(function()
			if instance[property] ~= value then
				instance[property] = value
				log(instance.Name .. "." .. property, "=", value)
			end
		end)
		if not success then
			log("Invalid property", property, "for", instance.ClassName)
		end
	end
end

-- This function does most of the work
-- Applies the effect, the properties and loads it up into the module.
local function effectInternal(audio: Sound,effect: string,props: any?)
	if not loadedSounds[audio]["SoundEffects"][effect] then
		local se = returnEffect(effect)
		applyProperties(se,props)
		loadedSounds[audio]["SoundEffects"][effect] = se
		se.Parent = audio
		log("Adding "..se.Name.. " To "..audio.Name)
		return se
	else
		local se = loadedSounds[audio]["SoundEffects"][effect]
		applyProperties(se,props)
		return se
	end
end

-- Load a sound into the module (Returns table)
function api:Load(audio: Sound)
	if audio.ClassName == "Sound" then
		if not loadedSounds[audio] then
			log("Loaded "..audio.Name)
			loadedSounds[audio] = {}
			loadedSounds[audio]["SoundEffects"] = {}
			local connections = {}
			local easySFXObj = {
				Sound = audio,
			}

			-- Removes the specified sound effect from the sound.
			-- Takes sound effects as input.
			function easySFXObj.RemoveEffect(effect: Instance?)
				if effect then else return nil end
				if typeof(effect) == "Instance" then else return nil end
				if effect.Parent ~= audio then
					log("Different effect parent provided for removal: "..effect.ClassName)
					return nil
				else
					if loadedSounds[audio] then
						if loadedSounds[audio]["SoundEffects"][effect.ClassName] then
							effect:Destroy()
							loadedSounds[audio]["SoundEffects"][effect.ClassName] = nil
							log(effect.ClassName.." removed from "..audio.Name)
							return true
						else
							return nil
						end
					end
				end
			end
			-- Returns effects currently on Sound.
			-- Returns a normal table containing their names.
			function easySFXObj.GetEffectNames(): { [number]: string }
				if loadedSounds[audio] then
					if loadedSounds[audio]["SoundEffects"] then
						local t = {}
						for i,_ in pairs(loadedSounds[audio]["SoundEffects"]) do
							table.insert(t,i)
						end
						return t
					end
				end
				return {}
			end
			-- Returns effects currently on Sound.
			-- Returns their instances with their names as indexes.
			function easySFXObj.GetEffects(): { [string]: Instance }
				if loadedSounds[audio] then
					if loadedSounds[audio]["SoundEffects"] then
						return loadedSounds[audio]["SoundEffects"]
					end
				end
				return {}
			end
			-- Executes connection(s) on :Unload() and :Destroy().
			function easySFXObj.OnUnload(Function: (any?))
				if typeof(Function) == "function" then
					table.insert(connections,Function)
				else
					log("Invalid function provided (OnUnload)")
				end
			end
			-- Unloads the sound from the module (removes all effects).
			function easySFXObj.Unload()
				if loadedSounds[audio] then
					local audioTable = loadedSounds[audio]
					if audioTable["SoundEffects"] then
						for _,v in pairs(audioTable["SoundEffects"]) do
							v:Destroy()
						end
						loadedSounds[audio]["SoundEffects"] = {}
						loadedSounds[audio] = nil
						log("Unloaded "..audio.Name)
						callbackFunction(connections)
						return true
					else
						loadedSounds[audio] = nil
						log("Unloaded "..audio.Name)
						callbackFunction(connections)
						return true
					end
				else
					return nil
				end
			end
			-- Removes the sound from the module and destroys it.
			function easySFXObj.Destroy()
				if loadedSounds[audio] then
					local audioTable = loadedSounds[audio]
					if audioTable["SoundEffects"] then
						for _,v in pairs(audioTable["SoundEffects"]) do
							v:Destroy()
						end
						loadedSounds[audio]["SoundEffects"] = {}
						loadedSounds[audio] = nil
						log("Destroyed "..audio.Name)
						callbackFunction(connections)
						audio:Destroy()
						return true
					else
						loadedSounds[audio] = nil
						log("Destroyed "..audio.Name)
						callbackFunction(connections)
						audio:Destroy()
						return true
					end
				else
					return nil
				end
			end
			-- Adds reverb to the sound (or returns existing instance).
			function easySFXObj:Reverb(properties: reverbProperties)
				local se = effectInternal(audio,"ReverbSoundEffect",properties)
				return se :: ReverbSoundEffect
			end
			-- Adds echo to the sound (or returns existing instance).
			function easySFXObj:Echo(properties: echoProperties)
				local se = effectInternal(audio,"EchoSoundEffect",properties)
				return se :: EchoSoundEffect
			end
			-- Adds an equalizer to the sound (or returns existing instance).
			function easySFXObj:Equalizer(properties: equalizerProperties)
				local se = effectInternal(audio,"EqualizerSoundEffect",properties)
				return se :: EqualizerSoundEffect
			end
			-- Adds a compressor to the sound (or returns existing instance).
			function easySFXObj:Compressor(properties: compressorProperties)
				local se = effectInternal(audio,"CompressorSoundEffect",properties)
				return se :: CompressorSoundEffect
			end
			-- Adds chorus to the sound (or returns existing instance).
			function easySFXObj:Chorus(properties: chorusProperties)
				local se = effectInternal(audio,"ChorusSoundEffect",properties)
				return se :: ChorusSoundEffect
			end
			-- Adds tremolo to the sound (or returns existing instance).
			function easySFXObj:Tremolo(properties: tremoloProperties)
				local se = effectInternal(audio,"TremoloSoundEffect",properties)
				return se :: TremoloSoundEffect
			end
			-- Adds distortion to the sound (or returns existing instance).
			function easySFXObj:Distortion(properties: distortionProperties)
				local se = effectInternal(audio,"DistortionSoundEffect",properties)
				return se :: DistortionSoundEffect
			end
			-- Adds pitch shift to the sound.
			function easySFXObj:PitchShift(properties: pitchshiftProperties)
				local se = effectInternal(audio,"PitchShiftSoundEffect",properties)
				return se :: PitchShiftSoundEffect
			end
			-- Adds flange to the sound (or returns existing instance).
			function easySFXObj:Flange(properties: flangeProperties)
				local se = effectInternal(audio,"FlangeSoundEffect",properties)
				return se :: FlangeSoundEffect
			end
			loadedSounds[audio]["Functions"] = easySFXObj
			return easySFXObj
		else
			if loadedSounds[audio] then
				if loadedSounds[audio]["Functions"] then
					log("Returning existing Functions.")
					return loadedSounds[audio]["Functions"]
				end
			end
		end
	else
		log(audio.Name.." Is not a Sound.")
		return nil
	end
end
return api