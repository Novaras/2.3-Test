-- hwrm-anticheat (rules scope): loaded by `leveldata/multiplayer/lib/dev.lua`. Keeps a record of what `autoexec_guard.lua` refused.
-- (Rules files also run in a bare state at startup, with none of these functions; this skips that.)

-- (set up again on every load: this runs once per game, but the state may outlive a game)
if (appendto and date and UI_IsNamedElementVisible) then
	HWRM_ANTICHEAT_PERSIST = {
		file = "uistate.dat",
		key = { 75, 19, 158, 39, 97, 210, 8, 181, 62, 140, 29, 233 },
		reported = nil,
	};

	function HWRM_ANTICHEAT_PERSIST.encode(text)
		local key = HWRM_ANTICHEAT_PERSIST.key;
		local n = getn(key);
		local out = "";
		for i = 1, strlen(text) do
			local e = strbyte(text, i) + key[mod(i - 1, n) + 1] + i * 7;
			out = out .. format("%02x", e - floor(e / 256) * 256);
		end
		return out;
	end

	-- appends `line` (encoded) to `file`, a bare filename in the profile folder
	function HWRM_ANTICHEAT_PERSIST.append(file, line)
		if (appendto(file)) then
			write(HWRM_ANTICHEAT_PERSIST.encode(line) .. "\n");
			writeto();
		end
	end

	function HWRM_ANTICHEAT_PERSIST.report()
		if (HWRM_ANTICHEAT_PERSIST.reported) then
			return nil;
		end
		HWRM_ANTICHEAT_PERSIST.reported = 1;
		if (UI_IsNamedElementVisible("InGameModScreen", "lblHwrmAnticheatTell") ~= 1) then
			return nil;
		end

		-- (reading an empty dropdown crashes, so an item is always added first)
		UI_AddDropDownListboxItem("InGameModScreen", "ddHwrmAnticheatLog", "_", "", 0, "");
		UI_SelectDropDownListboxItemIndex("InGameModScreen", "ddHwrmAnticheatLog", 0);
		local entries = UI_GetDropdownListBoxSelectedCustomDataString("InGameModScreen", "ddHwrmAnticheatLog") or "";
		if (entries == "") then
			entries = "?";
		end

		local stamp = date("%Y-%m-%d %H:%M:%S");
		local start = 1;
		while (start <= strlen(entries)) do
			local stop = strfind(entries, ";", start, 1) or (strlen(entries) + 1);
			HWRM_ANTICHEAT_PERSIST.append(HWRM_ANTICHEAT_PERSIST.file, stamp .. " " .. strsub(entries, start, stop - 1));
			start = stop + 1;
		end
	end

	-- run once, a second or so in, by whichever comes first: a rule, or the deathmatch modes' `UI_init` rule (`lib/ui.lua`)
	-- (`rawset`: the game refuses normal writes to globals holding functions)
	if (Rule_AddInterval) then
		rawset(globals(), "hwrmAnticheatPersistRule", function ()
			Rule_Remove("hwrmAnticheatPersistRule");
			HWRM_ANTICHEAT_PERSIST.report();
		end);
		Rule_AddInterval("hwrmAnticheatPersistRule", 1);
	end
	if (UI_init) then
		local original_UI_init = UI_init;
		rawset(globals(), "UI_init", function ()
			%original_UI_init();
			HWRM_ANTICHEAT_PERSIST.report();
		end);
	end
end
