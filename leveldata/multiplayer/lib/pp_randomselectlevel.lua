dofilepath("data:scripts/lib/table_util.lua");

---@return table|nil
PP_RandomLevel = PP_RandomLevel or function (player_count, excluded_groups)
    player_count = player_count or 2;
    excluded_groups = excluded_groups or {};

    -- !!TODO!! need to somehow find a way to use `write` during runtime to re-gen this list of gamemodes

    local gamemodes = tbl_pack(tbl_filter({ 'dm_hw1', 'dm_hw2', 'Ace_Maps' }, function (groupname)
        return tbl_includesValue(%excluded_groups, groupname) == nil;
    end));
    local gamemode_idx = 1;
    if (tbl_length(gamemodes) > 1) then
        gamemode_idx = random(1, tbl_length(gamemodes));
    end
    --- Can be nil in the case randomN is chosen but there are no N sized maps
    ---@type string|nil
    local gamemode = gamemodes[gamemode_idx];

    if (gamemode == nil) then
        return nil;
    end

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
            print("random map: " .. path);

            level.path = path;

            return level;
        end
    end

    tbl_push(excluded_groups, gamemode);
    return PP_RandomLevel(player_count, excluded_groups);
end

function PP_ImportRandomLevel(player_count)
    print("import rand level for " .. player_count .. " players");
    local level = nil;
    -- if we try picking random for N players and there are no N sized maps, we will try picking N+1 until 8
    for i = player_count, 8 do
        level = PP_RandomLevel(i);
        if (level) then
            break;
        end
    end

    dofilepath(level.path);
    -- we need to re-overwrite the level desc since the imported level set it
    dofilepath("data:leveldata/multiplayer/dm_pp.levels"); -- so we can look up the level desc
    levelDesc = LevelList[player_count - 1].Desc;
    maxPlayers = player_count;
end