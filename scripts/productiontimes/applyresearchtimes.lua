-- Add the research times to each research option
doscanpath("data:ui", "playerspatch_ui_util.lua");

if (GetProductionTimeSetting() == 2) then

	doscanpath("data:Scripts/Productiontimes", "LocaleEnglish.lua");

	--Check locale
	for i, research_item in research do
		local upgrade_value_str = "";

		if (research_item.UpgradeValue) then
			percent_change = research_item.UpgradeValue * 100 - 100;
			upgrade_value_str = "\n<b>Value:</b> ";

			if (percent_change > 0) then
				upgrade_value_str = upgrade_value_str .. "+"
			end

			upgrade_value_str = upgrade_value_str .. percent_change .. "% ";
		end

		local locale_description = localization[research_item.Description];
		if (locale_description) then
			research[i].Description = locale_description .. "  \n" .. upgrade_value_str .. "\n<b>Base Time:</b> " .. research_item.Time .. "s";
		end
	end
end