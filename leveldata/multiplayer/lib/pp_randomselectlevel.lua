dofilepath("data:scripts/lib/table_util.lua");

---@return string|nil
PP_RandomLevel = PP_RandomLevel or function (player_count, excluded_groups)
    player_count = player_count or 2;
    excluded_groups = excluded_groups or {};

    -- !!TODO!! need to somehow find a way to use `write` during runtime to re-gen this list of gamemodes

    local gamemodes = tbl_pack(tbl_filter({ 'dm_hw1', 'dm_hw2', 'Ace_Maps' }, function (groupname)
        return tbl_includesValue(%excluded_groups, groupname) == nil;
    end));
    local group_idx = 1;
    if (tbl_length(gamemodes) > 1) then
        group_idx = random(1, tbl_length(gamemodes));
    end
    --- Can be nil in the case randomN is chosen but there are no N sized maps
    ---@type string|nil
    local gamemode = gamemodes[group_idx];

    dofilepath("data:leveldata/multiplayer/" .. gamemode .. ".levels");

    if (Root and LevelList and tbl_length(LevelList) > 0) then
        local levels = tbl_pack(
            tbl_filter(
                LevelList,
                function (level)
                    return level.MaxPlayers == %player_count;
                end
            )
        );
        local levels_count = tbl_length(levels);

        if (levels_count > 0) then
            local index = 1;
            if (levels_count > 1) then
                index = random(1, levels_count);
            end

            local level = levels[index];

            local path = Root .. "\\" .. level.Name .. ".level";
            dofilepath(path);

            return path;
        end
    end

    tbl_push(excluded_groups, gamemode);
    return PP_RandomLevel(player_count, excluded_groups);
end