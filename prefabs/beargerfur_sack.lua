local ASSETS_CONTAINER =
{
    Asset("ANIM", "anim/beargerfur_sack.zip"),
}

local ASSETS_FX =
{
    Asset("ANIM", "anim/icebox_open_fx.zip"),
}

local PREFABS_CONTAINER =
{
    "beargerfur_sack_frost_fx",
}

local PREFABS_FX =
{

}

-----------------------------------------------------------------------------------------------

local sounds =
{
    open = "rifts3/bearger_sack/open_f5_loopstart",
    close = "rifts3/bearger_sack/close",
}

local OPEN_SOUNDNAME = "openloop"

-----------------------------------------------------------------------------------------------

local function ToggleFrostFX(inst, start, remove)
    if inst._opentask ~= nil then
        inst._opentask:Cancel()
        inst._opentask = nil
    end

    if start and inst._frostfx == nil then
        inst._frostfx = SpawnPrefab("beargerfur_sack_frost_fx")
        inst._frostfx.entity:SetParent(inst.entity)
        inst._frostfx.Follower:FollowSymbol(inst.GUID, "ground", -25, -15, 0)

    elseif inst._frostfx ~= nil then
        if remove then
            inst._frostfx:Remove()
        else
            inst._frostfx:Kill()
        end

        inst._frostfx = nil
    end
end

local function StartOpenSound(inst)
    if inst._startsoundtask ~= nil then
        inst._startsoundtask:Cancel()
        inst._startsoundtask = nil
    end

    inst.SoundEmitter:PlaySound(inst._sounds.open, OPEN_SOUNDNAME)
end

local function OnOpen(inst)
    inst.AnimState:PlayAnimation("open")

    if inst._startsoundtask ~= nil then
        inst._startsoundtask:Cancel()
    end

    inst._startsoundtask = inst:DoTaskInTime(5*FRAMES, inst.StartOpenSound)

    if inst._opentask ~= nil then
        inst._opentask:Cancel()
    end

    local time = inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime()
    inst._opentask = inst:DoTaskInTime(time, inst.ToggleFrostFX, true)
end

local function OnClose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.AnimState:PushAnimation("closed", false)

    inst.SoundEmitter:KillSound(OPEN_SOUNDNAME)

    if not inst:IsInLimbo() then
        inst.SoundEmitter:PlaySound(inst._sounds.close)
    end

    inst:ToggleFrostFX(false)
end

local function OnPutInInventory(inst)
    inst:ToggleFrostFX(false, true)

    inst.components.container:Close()
    inst.AnimState:PlayAnimation("closed", false)
end

local function OnRemoveEntity(inst)
    inst:ToggleFrostFX(false, true)
end

-----------------------------------------------------------------------------------------------

local function FX_OnKillTask(inst)
    inst.AnimState:PlayAnimation("pst")
    inst._killtask = inst:DoTaskInTime(inst.AnimState:GetCurrentAnimationLength() + 2 * FRAMES, inst.Remove)
end

local function FX_Kill(inst)
    if inst._killtask == nil then
        local time = inst.AnimState:GetCurrentAnimationLength() - inst.AnimState:GetCurrentAnimationTime()
        inst._killtask = inst:DoTaskInTime(time, inst.OnKillTask)
    end
end

-----------------------------------------------------------------------------------------------

local floatable_swap_data = { bank = "beargerfur_sack", anim = "closed" }

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("beargerfur_sack.png")

    inst.AnimState:SetBank("beargerfur_sack")
    inst.AnimState:SetBuild("beargerfur_sack")
    inst.AnimState:PlayAnimation("closed")

    inst.AnimState:SetSymbolBloom("crystalbase")
    inst.AnimState:SetSymbolLightOverride("Glow_FX", 0.7)
    inst.AnimState:SetSymbolLightOverride("crystalbase", 0.5)

    inst.AnimState:SetLightOverride(0.1)

    MakeInventoryPhysics(inst)

    MakeInventoryFloatable(inst, "small", 0.35, 1.15, nil, nil, floatable_swap_data)

    inst:AddTag("portablestorage")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst._sounds = sounds
    inst._frostfx = nil

    inst.ToggleFrostFX = ToggleFrostFX
    inst.StartOpenSound = StartOpenSound

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("beargerfur_sack")
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.droponopen = true

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(TUNING.BEARGERFUR_SACK_PRESERVER_RATE)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)

    inst.OnRemoveEntity = OnRemoveEntity

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("icebox_open_fx")
    inst.AnimState:SetBuild("icebox_open_fx")
    inst.AnimState:PlayAnimation("pre")
    inst.AnimState:PushAnimation("loop")
    inst.AnimState:SetFinalOffset(3)

    inst.AnimState:SetLightOverride(0.7)

    inst.Transform:SetScale(0.7, 0.7, 0.7)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst._killtask = nil
    inst._opentask = nil

    inst.Kill = FX_Kill
    inst.OnKillTask = FX_OnKillTask

    return inst
end


return
        Prefab( "beargerfur_sack",          fn,   ASSETS_CONTAINER, PREFABS_CONTAINER ),
        Prefab( "beargerfur_sack_frost_fx", fxfn, ASSETS_FX,        PREFABS_FX        )