local prefabs =
{
    "rocky",
}

local ROCKY_CANT = {"shadowthrall_parasite_hosted"}

local function CanSpawn(inst)
    -- Note that there are other conditions inside periodic spawner governing this as well.

    if inst.components.herd == nil or inst.components.herd:IsFull() then
        return false
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    return #TheSim:FindEntities(x, y, z, inst.components.herd.gatherrange, { "herdmember", inst.components.herd.membertag },ROCKY_CANT) < TUNING.ROCKYHERD_MAX_IN_RANGE
end

local function OnSpawned(inst, newent)
    if inst.components.herd ~= nil then
        inst.components.herd:AddMember(newent)
        newent.components.scaler:SetScale(TUNING.ROCKY_MIN_SCALE)
    end
end

--local function OnFull(inst)
    --TODO: mark some beefalo for death
--end

local function SeasonalSpawningChanges(inst, season)
    local spawndelay = SpringGrowthMod(TUNING.ROCKY_SPAWN_DELAY, season == SEASONS.SPRING)
    inst.components.periodicspawner:SetRandomTimes(spawndelay, TUNING.ROCKY_SPAWN_VAR)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    --[[Non-networked entity]]

    inst:AddTag("herd")
    --V2C: Don't use CLASSIFIED because herds use FindEntities on "herd" tag
    inst:AddTag("NOBLOCK")
    inst:AddTag("NOCLICK")

    inst:AddComponent("herd")
    inst.components.herd:SetMemberTag("rocky")
    inst.components.herd:SetGatherRange(TUNING.ROCKYHERD_RANGE)
    inst.components.herd:SetUpdateRange(20)
    inst.components.herd:SetOnEmptyFn(inst.Remove)
    --inst.components.herd:SetOnFullFn(OnFull)
    inst.components.herd.maxsize = 6

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("rocky")
    inst.components.periodicspawner:SetOnSpawnFn(OnSpawned)
    inst.components.periodicspawner:SetSpawnTestFn(CanSpawn)
    inst.components.periodicspawner:SetDensityInRange(TUNING.ROCKYHERD_SPAWNER_RANGE, TUNING.ROCKYHERD_SPAWNER_DENSITY)
    inst.components.periodicspawner:Start()
    inst.components.periodicspawner:SetOnlySpawnOffscreen(true)
    SeasonalSpawningChanges(inst, TheWorld.state.season)
    inst:WatchWorldState("season", SeasonalSpawningChanges)

    return inst
end

return Prefab("rockyherd", fn, nil, prefabs)
