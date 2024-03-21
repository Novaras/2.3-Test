base_research = nil 
base_research = {

	{
		Name =			"ProximitySensor",
		RequiredResearch =	"",
		RequiredSubSystems =	"Research",
		Cost = 			700,
		Time = 			65,
		DisplayedName =		"$11552",
		ShortDisplayedName =	"$11552",
		DisplayPriority =		51,
		Description =		"$11553",
		Icon = 			Icon_Build,
		TargetName =		"Tai_ProximitySensor",
	},
	{
		Name =			"SensorArray",
		RequiredResearch =	"ProximitySensor",
		RequiredSubSystems =	"Research",
		Cost = 			500,
		Time = 			50,
		DisplayedName =		"$11554",
		ShortDisplayedName =	"$11554",
		DisplayPriority =		52,
		Description =		"$11555",
		Icon = 			Icon_Build,
		TargetName =		"Tai_SensorArray",
	},
	{
		Name =			"GravityGenerator",
		RequiredResearch =	"CapitalShipDrive",
		RequiredSubSystems =	"Research",
		Cost = 			1000,
		Time = 			100,
		DisplayedName =		"$11556",
		ShortDisplayedName =	"$11556",
		DisplayPriority =		53,
		Description =		"$11557",
		Icon = 			Icon_Build,
		TargetName =		"Tai_GravWellGenerator",
	},
	{
		Name =			"CloakGenerator",
		RequiredResearch =	"CapitalShipDrive",
		RequiredSubSystems =	"Research",
		Cost = 			500,
		Time = 			30,
		DisplayedName =		"$11558",
		ShortDisplayedName =	"$11558",
		DisplayPriority =		54,
		Description =		"$11559",
		Icon = 			Icon_Build,
		TargetName =		"Tai_CloakGenerator",
	},
	
	{
		Name = "HyperspaceDamageReductionUpgrade", 
		RequiredResearch = "", 
		RequiredSubSystems = "", 
		Cost = 0, 
		Time = 0, 
		DisplayedName = "Hyperspace Damage Reduction", 
		DisplayPriority = 950, 
		Description = "Enhances the fleet's hyperspace drive systems, reducing the hyperspace damage caused by gravity wells. Ships only take 10% damage when forced out of hyperspace.", 
		UpgradeType = Modifier, 
		TargetType = AllShips, 
		UpgradeName = "HyperSpaceAbortDamage", 
		UpgradeValue = 0.4, 
		TargetName = "Tai_fleet", 
		Icon = Icon_Hyperspace, 
		ShortDisplayedName = "10% Hyperspace Exit Damage", 
		DoNotGrant = 1,
	},

	{
		Name = "HyperspaceDamageReductionUpgradeHC", 
		RequiredResearch = "", 
		RequiredSubSystems = "", 
		Cost = 0, 
		Time = 0, 
		DisplayedName = "Hyperspace Damage Reduction", 
		DisplayPriority = 951, 
		Description = "Enhances the fleet's hyperspace drive systems, reducing the hyperspace damage caused by gravity wells. Heavy Cruisers only take 0% damage when forced out of hyperspace.", 
		UpgradeType = Modifier, 
		TargetType = Ship, 
		UpgradeName = "HyperSpaceAbortDamage", 
		UpgradeValue = 0.0, 
		TargetName = "Tai_HeavyCruiser", 
		Icon = Icon_Hyperspace, 
		ShortDisplayedName = "0% HC Hyperspace Exit Damage", 
		DoNotGrant = 1,
	},
	
	{
		Name = "FighterDamageLevel0", 
		RequiredResearch = "", 
		RequiredSubSystems = "", 
		Cost = 0, 
		Time = 0, 
		DisplayedName = "Upgradable base damage for HW1 fighters", 
		DisplayPriority = 1, 
		Description = "All fighters deal -25% damage (upgrade to lvl 2 to achieve 0%)", 
		UpgradeName = "WeaponDamage", 
		UpgradeValue = 0.75,
		UpgradeType = Modifier,
		TargetName = "Fighter",
		TargetType = Family,
		Icon = Icon_Tech, 
		ShortDisplayedName = "Fighter Damage 0", 
		DoNotGrant = 1,
	},
	{
		Name = "CorvetteDamageLevel0", 
		RequiredResearch = "", 
		RequiredSubSystems = "", 
		Cost = 0, 
		Time = 0, 
		DisplayedName = "Upgradable base damage for HW1 corvettes", 
		DisplayPriority = 1, 
		Description = "All coprvettes deal -25% damage (upgrade to lvl 2 to achieve 0%)", 
		UpgradeName = "WeaponDamage", 
		UpgradeValue = 0.75,
		UpgradeType = Modifier,
		TargetName = "Corvette",
		TargetType = Family,
		Icon = Icon_Tech, 
		ShortDisplayedName = "Corvette Damage 0", 
		DoNotGrant = 1,
	},
}

-- Add these items to the research tree!
for i,e in base_research do
	research[res_index] = e
	res_index = res_index+1
end


base_research = nil 
