dofilepath("data:scripts/lib/table_util.lua");
dofilepath("data:scripts/lib/print_table.lua");

---@class
PP_LevelList = {
	---@type table[]
	levels = {};
};

function PP_LevelList:load()
	local Buffer = {
		names = {
			Root = 0,
			Tags = 0,
			LevelList = 0
		},
	};

	function Buffer:set(global_name, val)
		if (self.names[global_name]) then
			if (global_name == 'Tags') then
				if (not strsplit) then
					dofilepath("data:scripts/lib/string_util.lua");
				end
				val = strsplit(val, ',', 1);
			end

			self.names[global_name] = val;
		else
			print("levellist: not setting val for self.names." .. global_name);
		end
	end

	function Buffer:allSet()
		for _, v in self.names do
			if (v == 0) then
				return nil;
			end
		end
		return 1;
	end

	function Buffer:clear()
		for k, _ in self.names do
			self.names[k] = 0;
		end
	end

	for global_name, _ in Buffer.names do
		rawset(globals(), global_name, {});

		local tag = newtag();
		local hook = function (_, _, new_val)
			%Buffer:set(%global_name, new_val);

			if (%Buffer:allSet()) then
				%self.levels = tbl_concat(%self.levels, %Buffer.names.LevelList);
				%Buffer:clear();
			end
		end

		-- print("setting tag for " .. global_name);
		settag(rawget(globals(), global_name), tag);
		settagmethod(tag, 'setglobal', hook);
	end

	doscanpath("data:leveldata/multiplayer", "*.levels");

	for _, level in PP_LevelList.levels do
		print(level.Name);
	end
end

