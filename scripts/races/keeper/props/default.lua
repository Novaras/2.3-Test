-- Keeper

Number_Properties_Priority = 1.0

Number_Properties = {
	cfg_race_is_playable = 0.0,
	cfg_race_index_sort = 8.0,
	cfg_race_select_weight = 1.0,
	cfg_race_is_random = 0.0,
	
	cfg_hyperspace_effect_time = 12.5,
	cfg_buildable_subsystems = 1.0,
}

String_Properties_Priority = 1.0

String_Properties = {
	cfg_hyperspace_effect_fx = "hyperspace_gate_kpr",
	cfg_hyperspace_effect_audio = "etg/special/SPECIAL_ABILITIES_HYPERSPACE_IN",
	
	path_build = [[data:scripts/races/keeper/scripts/def_build.lua]],
	path_research = [[data:scripts/races/keeper/scripts/def_research.lua]],
	path_ai = [[data:scripts/races/vaygr/keeper/def_ai.lua]],
}
