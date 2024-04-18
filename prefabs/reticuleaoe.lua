local assets =
{
    Asset("ANIM", "anim/reticuleaoe.zip"),
    --Asset("ANIM", "anim/reticuleaoebase.zip"),
}

local PAD_DURATION = .1
local SCALE = 1.5
local FLASH_TIME = .3

local function UpdatePing(inst, s0, s1, t0, duration, multcolour, addcolour)
    if next(multcolour) == nil then
        multcolour[1], multcolour[2], multcolour[3], multcolour[4] = inst.AnimState:GetMultColour()
    end
    if next(addcolour) == nil then
        addcolour[1], addcolour[2], addcolour[3], addcolour[4] = inst.AnimState:GetAddColour()
    end
    local t = GetTime() - t0
    local k = 1 - math.max(0, t - PAD_DURATION) / duration
    k = 1 - k * k
    local s = Lerp(s0, s1, k)
    local c = Lerp(1, 0, k)
    inst.Transform:SetScale(s, s, s)
    inst.AnimState:SetMultColour(multcolour[1], multcolour[2], multcolour[3], c * multcolour[4])

    k = math.min(FLASH_TIME, t) / FLASH_TIME
    c = math.max(0, 1 - k * k)
    inst.AnimState:SetAddColour(c * addcolour[1], c * addcolour[2], c * addcolour[3], c * addcolour[4])
end

local function MakePing(name, anim, fixedorientation, scaleup)
    local function fn()
        local inst = CreateEntity()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst.AnimState:SetBank("reticuleaoe")
        inst.AnimState:SetBuild("reticuleaoe")
        inst.AnimState:PlayAnimation(anim)
		inst.AnimState:SetOrientation(fixedorientation and ANIM_ORIENTATION.OnGroundFixed or ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.AnimState:SetScale(SCALE, SCALE)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

        local duration = .5
        inst:DoPeriodicTask(0, UpdatePing, nil, 1, scaleup, GetTime(), duration, {}, {})
        inst:DoTaskInTime(duration, inst.Remove)

        return inst
    end

    return Prefab(name, fn, assets)
end

--------------------------------------------------------------------------

--[[local function CreateBase()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")]]
    --[[Non-networked entity]]
    --[[inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("reticuleaoebase")
    inst.AnimState:SetBuild("reticuleaoebase")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGroundFixed)
    inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
    inst.AnimState:SetSortOrder(3)
    inst.AnimState:SetScale(SCALE, SCALE)
    inst.AnimState:SetMultColour(1, 1, 0, 1)

    inst.Transform:SetRotation(90)

    return inst
end

local function OnHideReticule(inst)
    if inst.base ~= nil and inst.base:IsValid() then
        inst.base:Hide()
    end
    inst._Hide(inst)
end

local function OnShowReticule(inst)
    if inst.base ~= nil and inst.base:IsValid() then
        inst.base:Show()
    end
    inst._Show(inst)
end

local function OnRemoveReticule(inst)
    if inst.base ~= nil and inst.base:IsValid() then
        inst.base:Remove()
    end
end]]

local function MakeReticule(name, anim, fixedorientation)
    local function fn()
        local inst = CreateEntity()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")
        --[[Non-networked entity]]
        inst.entity:SetCanSleep(false)
        inst.persists = false

        inst.entity:AddTransform()
        inst.entity:AddAnimState()

        inst.AnimState:SetBank("reticuleaoe")
        inst.AnimState:SetBuild("reticuleaoe")
        inst.AnimState:PlayAnimation(anim)
		inst.AnimState:SetOrientation(fixedorientation and ANIM_ORIENTATION.OnGroundFixed or ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_WORLD_BACKGROUND)
        inst.AnimState:SetSortOrder(3)
        inst.AnimState:SetScale(SCALE, SCALE)

        --[[if ThePlayer ~= nil and not TheInput:ControllerAttached() then
            inst.base = CreateBase()
            inst.base.entity:SetParent(ThePlayer.entity)

            inst._Hide = inst.Hide
            inst._Show = inst.Show
            inst.Hide = OnHideReticule
            inst.Show = OnShowReticule
            inst.OnRemoveEntity = OnRemoveReticule
        end]]

        return inst
    end

    return Prefab(name, fn, assets)
end

--------------------------------------------------------------------------

local FADE_FRAMES = 10

local function OnUpdateTargetFade(inst, r, g, b, a)
    local k
    if inst._fade:value() <= FADE_FRAMES then
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES))
        k = inst._fade:value() / FADE_FRAMES
    else
        inst._fade:set_local(math.min(inst._fade:value() + 1, FADE_FRAMES * 2 + 1))
        k = (FADE_FRAMES * 2 + 1 - inst._fade:value()) / FADE_FRAMES
    end

    inst.AnimState:OverrideMultColour(r, g, b, a * k)

    if inst._fade:value() == FADE_FRAMES then
        inst._fadetask:Cancel()
        inst._fadetask = nil
    elseif inst._fade:value() > FADE_FRAMES * 2 then
        inst:Remove()
    end
end

local function MakeTarget(name, anim, fixedorientation, colour)
    local function OnTargetFadeDirty(inst)
        if inst._fadetask == nil then
            inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateTargetFade, nil, unpack(colour))
        end
        OnUpdateTargetFade(inst, unpack(colour))
    end

    local function KillTarget(inst)
        if inst._fade:value() <= FADE_FRAMES then
            inst._fade:set(FADE_FRAMES * 2 + 1 - inst._fade:value())
            if inst._fadetask == nil then
                inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateTargetFade, nil, unpack(colour))
            end
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("NOCLICK")

        inst.AnimState:SetBank("reticuleaoe")
        inst.AnimState:SetBuild("reticuleaoe")
        inst.AnimState:PlayAnimation(anim)
		inst.AnimState:SetOrientation(fixedorientation and ANIM_ORIENTATION.OnGroundFixed or ANIM_ORIENTATION.OnGround)
        inst.AnimState:SetLayer(LAYER_BACKGROUND)
        inst.AnimState:SetSortOrder(3)--1) --was 1 in forge
        inst.AnimState:SetScale(SCALE, SCALE)
        inst.AnimState:OverrideMultColour(1, 1, 1, 0)

        inst._fade = net_smallbyte(inst.GUID, name.."._fade", "fadedirty")
        inst._fadetask = inst:DoPeriodicTask(FRAMES, OnUpdateTargetFade, nil, unpack(colour))

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            inst:ListenForEvent("fadedirty", OnTargetFadeDirty)

            return inst
        end

        inst.persists = false

        inst.KillFX = KillTarget

        return inst
    end

    return Prefab(name, fn, assets)
end

return MakeReticule("reticuleaoe", "idle", true),
	MakeReticule("reticuleaoesmall", "idle_small", true),
	MakeReticule("reticuleaoesummon", "idle_summon", true),
	MakeReticule("reticuleaoe_1_6", "idle_1_6", true),
	MakeReticule("reticuleaoe_1d2_12", "idle_1d2_12", true),
	MakeReticule("reticuleaoe5line", "idle_5live", false),
	--ping scales to grow radius by .2 (or .1 of inner ring for summons)
	MakePing("reticuleaoeping", "idle", true, 1.05),
	MakePing("reticuleaoesmallping", "idle_small", true, 1.1),
	MakePing("reticuleaoesummonping", "idle_summon", true, 1.0667),
	MakePing("reticuleaoeping_1_6", "idle_1_6", true, 1.1),
	MakePing("reticuleaoeping_1d2_12", "idle_1d2_12", true, 1.08333),
	MakePing("reticuleaoeping5line", "idle_5live", false, 1.08333),    

	MakePing("reticuleaoefiretarget_1ping", "idle_summon_target", true, 1.08333),    

	MakeTarget("reticuleaoehostiletarget", "idle_target", false, { 1, .25, 0, 1 }),
	MakeTarget("reticuleaoefriendlytarget", "idle_target", false, { 0, 1, .25, 1 }),
	MakeTarget("reticuleaoecctarget", "idle_target", false, { .3, .5, .2, 1 }),
	MakeTarget("reticuleaoesmallhostiletarget", "idle_small_target", false, { 1, .25, 0, 1 }),
	MakeTarget("reticuleaoesummontarget", "idle_summon_target", false, { .3, .5, .2, 1 }),
	MakeTarget("reticuleaoesummontarget_1", "idle_target_1", false, { .3, .5, .2, 1 }),
	MakeTarget("reticuleaoesummontarget_1d2", "idle_target_1d2", false, { .3, .5, .2, 1 }),
	MakeTarget("reticuleaoeshadowtarget_6", "idle_target_6", false, { .1, .1, .1, 1 }),
	MakeTarget("reticuleaoefiretarget_1", "idle_summon_target", false, { 255/255, 161/255, 61/255, 1 })
