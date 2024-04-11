
-- static data on the gravwell memgroup (constants etc)
GW_MEM_PROTO = {
	target_types = {
		"hgn_scout",
		"hgn_interceptor",
		"hgn_attackbomber",
		"hgn_assaultcorvette",
		"hgn_pulsarcorvette",
		"hgn_minelayercorvette",
		"vgr_scout",
		"vgr_interceptor",
		"vgr_lancefighter",
		"vgr_bomber",
		"vgr_missilecorvette",
		"vgr_lasercorvette",
		"vgr_commandcorvette",
		"vgr_minelayercorvette",
		"kus_scout",
		"kus_interceptor",
		"kus_attackbomber",
		"kus_defender",
		"kus_cloakedfighter",
		"kus_lightcorvette",
		"kus_heavycorvette",
		"kus_repaircorvette",
		"kus_multiguncorvette",
		"kus_minelayercorvette",
		"tai_scout",
		"tai_interceptor",
		"tai_attackbomber",
		"tai_defender",
		"tai_defensefighter",
		"tai_lightcorvette",
		"tai_heavycorvette",
		"tai_repaircorvette",
		"tai_multiguncorvette",
		"tai_minelayercorvette",
		--32
		"junk_junkyarddog",
		"tur_fighter",
		"tur_missilecorvette",
		"tur_standardcorvette",
		"kad_swarmer",
		"kad_advancedswarmer"
	},
	salvager_types = "kus_salvagecorvette, tai_salvagecorvette",
	effect_range = 3000,
	glow_animation = "PowerOff",
	tick_self_damage = 0.0190,
	abilities_to_disable = { AB_Move, AB_Targeting, AB_Attack, AB_Dock, AB_Custom },
	tumble_randtable = { -- premade random table
		0.69,
		1 / 0.37,
		0.51,
		0.64,
		1 / 0.14,
		1 / 0.32,
		0.15,
		0.35,
		1 / 0.33,
		0.70,
		0.47,
		1 / 0.02
	},
	tumble_randtable_index = 1,
}

GW_MEM = MemGroup.Create('gravwells', GW_MEM_PROTO)

function GW_MEM:Get(group, player_index, ship_id)
	local gravwell = self:get(ship_id);

	if (gravwell == nil) then
		gravwell = self:Create(group, player_index, ship_id);
	end

	return gravwell;
end

--
-- ===== AUTORUN: =====
--

-- register new gravwell in the memgroup
-- sets up various instance data fields, including
-- the methods a gravwell can perform
function GW_MEM:Create(own_group, player_index, ship_id)
	local GRAVWELL_PROTO = {
		own_group = own_group,
		player_index = player_index,
		ship_id = ship_id,
		previously_stunned = SobGroup_CreateAndClear("gravwell-" .. ship_id .. "-previously-stunned"),
	} -- instance static data/methods
	
	-- should be called once, essentially a housekeep for the gravwell
	-- plays glow fx, applies self damage, and saves the stunned group for the next pass
	function GRAVWELL_PROTO:SelfEffects()
		-- print("[" .. self.id .. "]:SelfEffects start");
		FX_StartEvent(self.own_group, "PowerUp");
		SobGroup_TakeDamage(self.own_group, GW_MEM.tick_self_damage);
		-- print("[" .. self.id .. "]:SelfEffects end");
	end

	function GRAVWELL_PROTO:CalcStunnableTargets()
		local all_ships = Universe_GetAllActiveShips();

		local all_in_range = SobGroup_CreateAndClear("gravwell-" .. self.ship_id .. "-in-range");
		SobGroup_FillProximitySobGroup(all_in_range, all_ships, self.own_group, GW_MEM.effect_range);

		local stunnables = SobGroup_CreateAndClear("gravwell-" .. self.ship_id .. "-stunnables");
		for _, ship_type in GW_MEM_PROTO.target_types do
			local ships_of_type = SobGroup_CreateAndClear("gravwell-" .. self.ship_id .. "-ships-of-type-" .. ship_type);
			SobGroup_FillShipsByType(ships_of_type, all_in_range, ship_type);
			SobGroup_SobGroupAdd(stunnables, ships_of_type);
		end

		print(self.ship_id .. " calced stunnable group containing " .. SobGroup_Count(stunnables) .. " ships");

		return stunnables;
	end

	function GRAVWELL_PROTO:StunGroup(group, stunned)
		stunned = stunned or 1;

		local set = mod(stunned + 1, 2); -- stunned = 0? set to 1, otherwise if 1 set to 0

		for _, ability in GW_MEM_PROTO.abilities_to_disable do
			SobGroup_AbilityActivate(group, ability, set);
		end

		SobGroup_SetSpeed(group, set);
	end

	-- tumbles the ships in `group`, as a function of their positions
	function GRAVWELL_PROTO:TumbleGroup(group, tumble)
		-- print("[" .. self.id .. "]:TumbleGroup start")#
		if (not Vec3) then
			dofilepath("data:scripts/lib/vec3.lua");
		end

		if (not SobGroup_Split) then
			dofilepath("data:scripts/lib/sobgroup_util.lua");
		end

		tumble = tumble or 1;

		if (tumble == 1) then
			local subgroups = SobGroup_Split(group);

			for _, subgroup in subgroups do
				local tumble_vector = Vec3(SobGroup_GetPosition(subgroup));

				tumble_vector = Vec3:unit(tumble_vector);

				-- for some reason the tumble vector should be capped at `.45`
				for k, v in tumble_vector do
					local abs = abs(v);
					if (abs > 0.45) then
						-- v <= 1; due to being component of unit vector
						-- 1 / x < 0.45;
						-- > 1 / 0.45 = x
						-- > 1 / 2.[2] < 0.45
						-- > v / 2.23 < 0.45
						tumble_vector[k] = v / 2.23;
					end
				end

				SobGroup_Tumble(subgroup, tumble_vector);

				FX_PlayEffect("blue_flash", subgroup, 1);
			end
		else
			SobGroup_ClearTumble(group);
		end

		-- print("[" .. self.id .. "]:TumbleGroup end")
		return group;
	end

	return self:set(ship_id, GRAVWELL_PROTO)
end

-- didnt touch this; sp-only (Fear)
function GW_MEM:Update(CustomGroup, playerIndex, shipID)
	SobGroup_NoSalvageScuttle(CustomGroup)

	if
		(Player_GetLevelOfDifficulty(playerIndex) > 0 and
			Player_GetNumberOfSquadronsOfTypeAwakeOrSleeping(-1, "Special_Splitter") == 1)
	 then
		local listCount = getn(GravityWellGeneratorShipList)
		local alliedShips, enemyShips = 0, 0

		for i = 0, Universe_PlayerCount() - 1 do
			if (Player_IsAlive(i) == 1) then
				SobGroup_Clear("GravWell_Temp0")

				for x = 1, listCount do
					SobGroup_FillShipsByType("GravWell_Temp0", "Player_Ships" .. i, GravityWellGeneratorShipList[x])
					SobGroup_SobGroupAdd("GravWell_Temp1", "GravWell_Temp0")
				end

				if (SobGroup_FillProximitySobGroup("GravWell_Temp0", "GravWell_Temp1", CustomGroup, GravityWellDistance) == 1) then
					if (AreAllied(playerIndex, i) == 1) then
						alliedShips = alliedShips + SobGroup_Count("GravWell_Temp0")
					else
						enemyShips = enemyShips + SobGroup_Count("GravWell_Temp0")
					end
				end
			end
		end

		if (enemyShips > 8 and enemyShips > (alliedShips * 2)) then
			SobGroup_CustomCommand(CustomGroup)
		end

		SobGroup_FillShipsByType(
			"GravWell_Temp0",
			"Player_Ships" .. playerIndex,
			PlayerRace_GetString(playerIndex, "def_type_mothership", "")
		)

		if (SobGroup_Count("GravWell_Temp0") > 0) then
			SobGroup_ParadeSobGroup(CustomGroup, "GravWell_Temp0", 0)
		else
			SobGroup_FillShipsByType(
				"GravWell_Temp0",
				"Player_Ships" .. playerIndex,
				PlayerRace_GetString(playerIndex, "def_type_carrier", "")
			)

			if (SobGroup_Count("GravWell_Temp0") > 0) then
				SobGroup_ParadeSobGroup(CustomGroup, "GravWell_Temp0", 0)
			end
		end
	end

	--hw1 mission 12
	SobGroup_CreateIfNotExist("GravwellTeam1")
	SobGroup_CreateIfNotExist("GravwellTeam2")
	SobGroup_CreateIfNotExist("GravwellTeam3")
	if
		SobGroup_GroupInGroup("GravwellTeam1", CustomGroup) == 1 or SobGroup_GroupInGroup("GravwellTeam2", CustomGroup) == 1 or
			SobGroup_GroupInGroup("GravwellTeam3", CustomGroup) == 1
	 then
		SobGroup_AbilityActivate(CustomGroup, AB_Move, 0)
	end
end

function GW_MEM:Destroy(group, player_index, ship_id)
	print("GW " .. ship_id .. " DESTROY")

	local gw = self:Get(group, player_index, ship_id);

	if (gw.previously_stunned) then
		gw:TumbleGroup(gw.previously_stunned, 0);
		gw:StunGroup(gw.previously_stunned, 0);
	end

	self:delete(ship_id);
	print("END GW " .. ship_id .. " DESTROY")
end

---
--- ===== ABILITY: =====
---

function GW_MEM:Start(group, player_index, ship_id)
	local this_gravwell = self:Get(group, player_index, ship_id)
	print("GW " .. ship_id .. " START")
	-- printTbl(this_gravwell)
	FX_StartEvent(this_gravwell.own_group, "gravwellon_sfx" .. max(1, mod(ship_id, 4)));
	SobGroup_AbilityActivate(this_gravwell.own_group, AB_Hyperspace, 0)
	print("END GW " .. ship_id .. " START")
end

function GW_MEM:Do(group, player_index, ship_id)
	print("GW " .. ship_id .. " DO");

	local gw = self:Get(group, player_index, ship_id);

	gw:SelfEffects();

	local new_stunnables = gw:CalcStunnableTargets();

	-- first clean up the delta from last run, if any
	if (SobGroup_Count(gw.previously_stunned) > 0) then
		local stunnables_delta = SobGroup_CreateAndClear("gravwell-" .. gw.ship_id .. "-stunnables-delta");
		SobGroup_FillSubstract(stunnables_delta, gw.previously_stunned, new_stunnables); -- delta = previous - current

		print(gw.ship_id .. " calced a delta of " .. SobGroup_Count(stunnables_delta) .. " ships");

		-- free the ships
		gw:TumbleGroup(stunnables_delta, 0);
		gw:StunGroup(stunnables_delta, 0);
	end

	gw:TumbleGroup(new_stunnables, 1);
	gw:StunGroup(new_stunnables, 1);

	SobGroup_Overwrite(gw.previously_stunned, new_stunnables);

	print("END GW " .. ship_id .. " DO");
end

function GW_MEM:Finish(group, player_index, ship_id)
	print("GW " .. ship_id .. " FINISH");

	local gw = self:Get(group, player_index, ship_id);

	if (gw.previously_stunned) then
		gw:TumbleGroup(gw.previously_stunned, 0);
		gw:StunGroup(gw.previously_stunned, 0);
	end

	FX_StartEvent(gw.own_group, "gravwellcollapse_sfx" .. max(1, mod(ship_id, 4)));
	SobGroup_AbilityActivate(group, AB_Hyperspace, 1);

	print("END GW " .. ship_id .. " FINISH");
end