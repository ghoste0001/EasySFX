export type ReverbProperties = {
	Enabled: boolean?,
	DecayTime: number?,
	Density: number?,
	Diffusion: number?,
	DryLevel: number?,
	WetLevel: number?,
	Priority: number?
}

export type EchoProperties = {
	Enabled: boolean?,
	Delay: number?,
	Feedback: number?,
	DryLevel: number?,
	WetLevel: number?,
	Priority: number?
}

export type EqualizerProperties = {
	Enabled: boolean?,
	HighGain: number?,
	MidGain: number?,
	LowGain: number?,
	Priority: number?
}

export type CompressorProperties = {
	Enabled: boolean?,
	Attack: number?,
	GainMakeup: number?,
	Ratio: number?,
	Release: number?,
	Threshold: number?,
	SideChain: Instance?,
	Priority: number?
}

export type ChorusProperties = {
	Enabled: boolean?,
	Depth: number?,
	Mix: number?,
	Rate: number?,
	Priority: number?
}

export type TremoloProperties = {
	Enabled: boolean?,
	Depth: number?,
	Duty: number?,
	Frequency: number?,
	Priority: number?
}

export type DistortionProperties = {
	Enabled: boolean?,
	Level: number?,
	Priority: number?
}

export type PitchShiftProperties = {
	Enabled: boolean?,
	Octave: number?,
	Priority: number?
}

export type FlangeProperties = {
	Enabled: boolean?,
	Depth: number?,
	Mix: number?,
	Rate: number?,
	Priority: number?
}

return nil