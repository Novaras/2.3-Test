-- Add the build times to each build option
doscanpath("data:ui", "playerspatch_ui_util.lua");

local prod_time_setting = GetProductionTimeSetting();
print("applybuildtimes.lua");
print("setting value is " .. prod_time_setting)

if prod_time_setting == 2 then
	dofilepath("data:scripts/productiontimes/buildtimes.lua");

	print("APPLYING BUILD TIMES...");

	dofilepath("data:scripts/productiontimes/localeenglish.lua");

	for i, build_item in build do
		if (build_item.Description and build_item.ThingToBuild) then
			local build_time = buildtimes[build_item.ThingToBuild];
			if build_time then
				local locale_description = localization[build_item.Description]

				build[i].Description = locale_description .. "  \n\n<b>Base Time:</b>  " .. build_time .. "s";

				print("description set to " .. build[i].Description);
			end
		end
	end
end
