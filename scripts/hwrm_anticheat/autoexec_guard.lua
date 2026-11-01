-- hwrm-anticheat: stops the game running `autoexec.lua` (and `-exec <path>` scripts), which it loads through the global
-- `dofilepath` at game start. Loaded before that by `ui/newui/notforpublicdisplay.lua` and `ui/newui/modder/ingamemodscreen.lua`.
-- Only `data:` paths are loaded (all the game's own scripts use); anything else is checked, then refused.
-- (`rawset`: the game refuses normal writes to globals holding functions. The UI state persists between games, so this installs
-- once per session.)

if (HWRM_ANTICHEAT_GUARD == nil) then
	HWRM_ANTICHEAT_GUARD = 1;

	local original_dofilepath = dofilepath;

	-- (`_ALERT` goes to HwRM.log even without `-luatrace`, unlike `print`; it's logged as "LUA '<file>' -- <message>")
	local alert = _ALERT;
	local log = function (message)
		%alert("[hwrm-anticheat] " .. message .. "\n");
	end;

	dofilepath("data:scripts/hwrm_anticheat/cheat_functions.lua");
	local cheat_functions = HWRM_ANTICHEAT_CHEAT_FUNCTIONS;

	local passthrough = {
		"type", "tostring", "tonumber", "getn", "next", "foreach", "foreachi", "rawget", "rawset", "globals", "getglobal",
		"setglobal", "call", "dostring", "error", "assert", "tinsert", "tremove", "sort", "strlen", "strsub", "strlower", "strupper",
		"strrep", "strbyte", "strchar", "strfind", "format", "gsub", "abs", "ceil", "floor", "max", "min", "mod", "sqrt", "sin",
		"cos", "tan", "asin", "acos", "atan", "atan2", "deg", "rad", "exp", "log", "log10", "frexp", "ldexp",
	};

	local makeStub = function (calls, name)
		return function (...)
			%calls[%name] = (%calls[%name] or 0) + 1;
			return 0;
		end;
	end;

	local makeRuleStub = function (calls, rules, name)
		return function (rule_name)
			%calls[%name] = (%calls[%name] or 0) + 1;
			local n = %rules.count + 1;
			%rules.count = n;
			%rules[n] = rule_name;
			return 0;
		end;
	end;

	local dryRun = function (path)
		-- (globals are per-state, so everything needed while they're swapped is kept in locals)
		local real = globals();
		local swap = globals;
		local protect = call;
		local kind = type;
		local load = %original_dofilepath;

		local calls = {};
		local rules = { count = 0 };
		local sandbox = {};
		-- (plain values are copied: the game's `dofilepath` finds its "self" through a global)
		for name, value in real do
			local value_kind = kind(value);
			if (value_kind == "function") then
				sandbox[name] = %makeStub(calls, name);
			elseif (value_kind ~= "table") then
				sandbox[name] = value;
			end
		end
		for name, category in %cheat_functions do
			sandbox[name] = %makeStub(calls, name);
		end
		for i = 1, getn(%passthrough) do
			sandbox[%passthrough[i]] = real[%passthrough[i]];
		end
		sandbox.Rule_Add = %makeRuleStub(calls, rules, "Rule_Add");
		sandbox.Rule_AddInterval = %makeRuleStub(calls, rules, "Rule_AddInterval");
		sandbox.Universe_PlayerCount = function () return 2; end;
		sandbox._ERRORMESSAGE = function (message) end;

		swap(sandbox);
		protect(load, { path }, "x");
		local i = 1;
		while (i <= rules.count and i <= 20) do
			local rule = sandbox[rules[i]];
			if (kind(rule) == "function") then
				protect(rule, {}, "x");
			end
			i = i + 1;
		end
		swap(real);

		local found = nil;
		for name, category in %cheat_functions do
			if (calls[name]) then
				found = (found and (found .. ", ") or "") .. name .. " (" .. category .. ")";
			end
		end
		for name, count in calls do
			if (strsub(name, 1, 5) == "Rule_") then
				found = (found and (found .. ", ") or "") .. name .. " (rules)";
			end
		end
		return found;
	end;

	-- this level's refused scripts, for `persist.lua` (rules scope), which reads them from the screen's dropdown
	local entries = { text = "" };

	rawset(globals(), "dofilepath", function (path)
		if (type(path) == "string" and strlower(strsub(path, 1, 5)) == "data:") then
			return %original_dofilepath(path);
		end
		local found = %dryRun(path);
		local first = UI_IsNamedElementVisible("InGameModScreen", "lblHwrmAnticheatTell") ~= 1;
		UI_ShowScreen("InGameModScreen", ePopup);
		UI_SetElementVisible("InGameModScreen", "lblHwrmAnticheatTell", 1);
		if (found) then
			UI_SetTextLabelText("InGameModScreen", "lblHwrmAnticheatTell", "..");
		end
		if (UI_IsNamedElementVisible("InGameModScreen", "lblHwrmAnticheatTell") == 1) then -- (this mod's screen is loaded)
			local entry = tostring(path) .. (found and ("|" .. found) or "");
			if (first) then
				%entries.text = entry;
			else
				%entries.text = %entries.text .. ";" .. entry;
			end
			UI_ClearDropDownListbox("InGameModScreen", "ddHwrmAnticheatLog");
			UI_AddDropDownListboxItem("InGameModScreen", "ddHwrmAnticheatLog", "_", "", 0, %entries.text);
		end
		%log("refused to load: " .. tostring(path));
		return nil;
	end);

	log("autoexec guard installed");
end
