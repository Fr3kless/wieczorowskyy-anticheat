local wieczorData = nil
ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function()
    RegisterNetEvent("wieczorxd")
	AddEventHandler("wieczorxd", function(wczr)
		wieczorData = wczr
	end)
    TriggerServerEvent("wieczor")
end)

RegisterCommand("restart", function()
	CancelEvent()
end)

RegisterCommand("start", function()
	CancelEvent()
end)

RegisterCommand("stop", function()
	CancelEvent()
end)

RegisterCommand("ensure", function()
	CancelEvent()
end)

Citizen.CreateThread(function()
    while wieczorData == nil do
		Citizen.Wait(100)
	end
    if Config.AntiClientEvents then
        for i = 1, #Config.ClientEvents, 1 do
            RegisterNetEvent(Config.ClientEvents[i])
            AddEventHandler(Config.ClientEvents[i], function()
                TriggerServerEvent("Ban", "BlacklistedEvents - "..Config.ClientEvents[i])
            end)
        end
    end
	RegisterNetEvent("wieczorHandler:join")
	AddEventHandler("wieczorHandler:join", function(reason)
		Ban(reason)
	end)
	RegisterNetEvent(wieczorData.d)
	AddEventHandler(wieczorData.d, function()
		local es = {}
		for i = 0, GetNumResources()-1, 1 do
			es[GetResourceByFindIndex(i)] = GetResourceState(GetResourceByFindIndex(i))
		end
		TriggerServerEvent(wieczorData.d, es)
	end)
	RegisterNetEvent(wieczorData.f)
	AddEventHandler(wieczorData.f, function()
		Citizen.CreateThread(function()
			while true do
			end
		end)
	end)
	RegisterNUICallback(GetCurrentResourceName(), function()
		TriggerServerEvent(wieczorData.h, "Anti NUI DevTools")
	end)
end)

function screenshot(key)
    exports["screenshot-basic"]:requestScreenshotUpload(wieczorData.imgserver, 'files[]', function(data)
        local image = json.decode(data)
        local attachments = nil
        if image then
			if image.attachments then
				if image.attachments[1].url then
					Citizen.Wait(1000)
					TriggerServerEvent(wieczorData.r, key, image.attachments[1].url)
				end
			end
        end
    end)
end

function Ban(reason)
	local banned = false
	exports["screenshot-basic"]:requestScreenshotUpload(wieczorData.imgserver, 'files[]', function(data)
		local image = json.decode(data)
		local attachments = nil
		if image then
			if image.attachments then
				if image.attachments[1].url then
					banned = true
					TriggerServerEvent(wieczorData.k, reason, image.attachments[1].url)
				end
			end
		end
	end)
	Wait(2500)
	if not banned then
		TriggerServerEvent(wieczorData.k, reason)
	end
end

Citizen.CreateThread(function()
	while wieczorData == nil do
		Citizen.Wait(100)
	end
	while true do
		Citizen.Wait(10000)
		for k, v in ipairs(GetRegisteredCommands()) do
			local a = v.name
			local name = a:sub(3)
			if (name == "naprawa") then
				TriggerServerEvent(wieczorData.h, 'Wykryto modyfikowanie scheduler.lua')
			end
		end
	end
end)

local screenshot_took = false
Citizen.CreateThread(function()
    while wieczorData == nil do
		Citizen.Wait(100)
	end
	while Config.ScreenshotKeys do
		Citizen.Wait(0)
		if GetSelectedPedWeapon(PlayerPedId()) ~= `WEAPON_UNARMED` then
			SetPlayerLockon(PlayerId(), false)
			SetPlayerLockonRangeOverride(PlayerId(), 0.0)
		else
			SetPlayerLockon(PlayerId(), true)
			SetPlayerLockonRangeOverride(PlayerId(), 5.0)
		end
		for k, v in pairs(Config.Keys) do
			if IsControlJustPressed(0, v.key) then
				if not screenshot_took then
					screenshot(v.name)
					screenshot_took = true
				end
			end
		end
		if screenshot_took then
			Citizen.Wait(15000)
			screenshot_took = false
		end 
	end
end)


Citizen.CreateThread(function()
    while wieczorData == nil do
		Citizen.Wait(100)
	end
	for k, v in pairs(Config.Dicts) do
		SetStreamedTextureDictAsNoLongerNeeded(v)
		while Config.AntiDicts do
			Citizen.Wait(1500)
			if HasStreamedTextureDictLoaded(v) then
				Ban("Dicts - Wykryto Lua Menu: "..v)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while wieczorData == nil do
		Citizen.Wait(100)
	end
	while true do
		Citizen.Wait(500)
		if not IsPedInAnyHeli(PlayerPedId()) then
			if GetUsingseethrough() then
				Ban("Wykryto ThermalVision")
			end
			if GetUsingnightvision() then
				Ban("Wykryto NightVision")
			end
		end
	end
end)

Citizen.CreateThread(function()
	while wieczorData == nil do
		Citizen.Wait(100)
	end
	while true do 
		Citizen.Wait(500)
		local wieczora = GetVehiclePedIsUsing(PlayerPedId())
		local wieczorb = GetEntityModel(wieczora)
		if (IsPedSittingInAnyVehicle(PlayerPedId())) then 
			if (wieczora == oldVehicle and wieczorb ~= oldVehicleModel and oldVehicleModel ~= nil and oldVehicleModel ~= 0) then
				DeleteVehicle(wieczora)
				Ban("Vehicle Hash Changer Detected: "..oldVehicleModel.." -> "..wieczorb)
				return
			end
		end
		oldVehicle = wieczora;oldVehicleModel = wieczorb;
	end
end)
--[[
Citizen.CreateThread(function()
	while wieczorData == nil do
		Citizen.Wait(100)
	end
	while true do
		Citizen.Wait(10000)
		for k, v in ipairs(GetRegisteredCommands()) do
			local a = v.name
			local name = a:sub(3)
			if (name == "naprawa") then
				TriggerServerEvent(wieczorData.h, 'Wykryto modyfikowanie scheduler.lua')
			end
		end
	end
end)]]

Citizen.CreateThread(function()
	while wieczorData == nil do
		Citizen.Wait(100)
	end
	while Config.AntiSpectate do
		Citizen.Wait(1000)
		if NetworkIsInSpectatorMode() then
			if (ESX.GetPlayerData().group == "user") then
				TriggerServerEvent(wieczorData.s)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while Config.AntiAttachPropToPlayer do
		Citizen.Wait(2000)
		for prop in EnumerateObjects() do
			if DoesEntityExist(prop) and IsEntityAnObject(prop) then
				if IsEntityAttachedToEntity(prop, PlayerPedId()) then
					SetEntityAsMissionEntity(prop, true, true)
					DetachEntity(prop, true, true)
					DeleteEntity(prop)
					if DoesEntityExist(prop) then
						DeleteObject(prop)
					end
				end
			end
		end
	end
end)

Citizen.CreateThread(function()
	while Config.AntiAttachPedToPlayer do
		Citizen.Wait(2000)
		for ped in EnumeratePeds() do
			if DoesEntityExist(ped) and not IsPedAPlayer(ped) then
				if IsEntityAttachedToEntity(ped, PlayerPedId()) then
					SetEntityAsMissionEntity(ped, true, true)
					DetachEntity(ped, true, true)
					DeleteEntity(ped)
					if DoesEntityExist(ped) then
						DeleteObject(ped)
					end
				end
			end
		end
	end
end)

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end
		local enum = {
			handle = iter, 
			destructor = disposeFunc
		}
		setmetatable(enum, entityEnumerator)
		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumeratePeds() 
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed) 
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

Citizen.CreateThread(function()
	while wieczorData == nil do
		Citizen.Wait(100)
	end
	while Config.AntiEnhancedHitbox do
		Citizen.Wait(10000)
		if GetEntityModel(PlayerPedId()) == GetHashKey('mp_m_freemode_01') or GetEntityModel(PlayerPedId()) == GetHashKey('mp_f_freemode_01') then
			local min,max = GetModelDimensions(GetEntityModel(PlayerPedId()))
			if min.x > -0.58 or min.x < -0.62 or min.y < -0.252 or min.y < -0.29 or max.z > 0.98 then
                TriggerServerEvent(wieczorData.h, "Wykryto powiększone Hitboxy! Prosimy usunąć to z plików GRY!")
            end
		end
	end
end)

local weapons = {
    GetHashKey('COMPONENT_COMBATPISTOL_CLIP_01'), GetHashKey('COMPONENT_COMBATPISTOL_CLIP_02'), GetHashKey('COMPONENT_APPISTOL_CLIP_01'), GetHashKey('COMPONENT_APPISTOL_CLIP_02'), 
	GetHashKey('COMPONENT_MICROSMG_CLIP_01'), GetHashKey('COMPONENT_MICROSMG_CLIP_02'), GetHashKey('COMPONENT_SMG_CLIP_01'), GetHashKey('COMPONENT_SMG_CLIP_02'),
    GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_01'), GetHashKey('COMPONENT_ASSAULTRIFLE_CLIP_02'), GetHashKey('COMPONENT_CARBINERIFLE_CLIP_01'), GetHashKey('COMPONENT_CARBINERIFLE_CLIP_02'),
    GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_01'), GetHashKey('COMPONENT_ADVANCEDRIFLE_CLIP_02'), GetHashKey('COMPONENT_MG_CLIP_01'), GetHashKey('COMPONENT_MG_CLIP_02'),
    GetHashKey('COMPONENT_COMBATMG_CLIP_01'), GetHashKey('COMPONENT_COMBATMG_CLIP_02'), GetHashKey('COMPONENT_PUMPSHOTGUN_CLIP_01'), GetHashKey('COMPONENT_SAWNOFFSHOTGUN_CLIP_01'),
    GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_01'), GetHashKey('COMPONENT_ASSAULTSHOTGUN_CLIP_02'), GetHashKey('COMPONENT_PISTOL50_CLIP_01'), GetHashKey('COMPONENT_PISTOL50_CLIP_02'),
    GetHashKey('COMPONENT_ASSAULTSMG_CLIP_01'), GetHashKey('COMPONENT_ASSAULTSMG_CLIP_02'), GetHashKey('COMPONENT_AT_RAILCOVER_01'), GetHashKey('COMPONENT_AT_AR_AFGRIP'), GetHashKey('COMPONENT_AT_PI_FLSH'), 
	GetHashKey('COMPONENT_AT_AR_FLSH'), GetHashKey('COMPONENT_AT_SCOPE_MACRO'), GetHashKey('COMPONENT_AT_SCOPE_SMALL'), GetHashKey('COMPONENT_AT_SCOPE_MEDIUM'), GetHashKey('COMPONENT_AT_SCOPE_LARGE'), 
	GetHashKey('COMPONENT_AT_SCOPE_MAX'), GetHashKey('COMPONENT_AT_PI_SUPP'),
}

Citizen.CreateThread(function()
	while wieczorData == nil do
		Citizen.Wait(100)
	end
    while Config.AntiCitizenDMGBoost do
        Citizen.Wait(10000)
		for i = 1, #weapons do
			local dmg_mod = GetWeaponComponentDamageModifier(weapons[i])
			local accuracy_mod = GetWeaponComponentAccuracyModifier(weapons[i])
			if dmg_mod > 1.1 or accuracy_mod > 1.2 then
				TriggerServerEvent(wieczorData.h, "Wykryto DMG Boost w modach. Prosimy usunąć to z plików GRY!")
			end
		end
		local a1 = GetWeaponDamage(`WEAPON_PISTOL`, 1)
		local a2 = GetWeaponDamage(`WEAPON_VINTAGEPISTOL`, 1)
		local a3 = GetWeaponDamage(`WEAPON_SNSPISTOL_MK2`, 1)
		if a1 > 50.0 or a2 > 50.0 or a3 > 50.0 then
			TriggerServerEvent(wieczorData.h, "Wykryto DMG Boost w .meta. Prosimy usunąć to z plików GRY!")
		end
		local a4 = GetWeaponDamage(`WEAPON_UNARMED`, 1)
		if a4 > 50.0 then
			TriggerServerEvent(wieczorData.h, 'Wykryto używanie "pudziana". Prosimy usunąć to z plików GRY!')		
		end
    end
end)

Citizen.CreateThread(function()
	while wieczorData == nil do
		Citizen.Wait(100)
	end
	while Config.AntiDamageModifier do
		Citizen.Wait(1000)
		local damage = GetPlayerWeaponDamageModifier(PlayerId())
		if damage > Config.MaxDamageModifier then
			Ban('Wykryto DMGBoost "cheaterski" ('..damage..')')
		end
	end
end)

Citizen.CreateThread(function()
	local godmodecount = 0
    while true do
        Citizen.Wait(1000)
        if (godmodecount >= 3) then
			Ban('Wykryto godmode!')
        end
        local health = GetEntityHealth(PlayerPedId())
        if (health > 200) then
			Ban('Wykryto ustawienie życia, więcej niż 200hp - '..health..'hp!')
        end
        SetPlayerHealthRechargeMultiplier(PlayerPedId(), 0.0)
        if (health > 2) then
            SetEntityHealth(PlayerPedId(), health - 2)
            Citizen.Wait(50)
            if (GetEntityHealth(PlayerPedId()) > (health - 2)) then
                godmodecount = godmodecount + 1
            elseif(godmodecount > 0) then
                godmodecount = godmodecount - 1
            end
            SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) + 2)
        end
    end
end)

local BlacklistedEntries = {
	"FMMC_KEY_TIP1",
	"TITLETEXT",
	"FMMC_KEY_TIP1_MISC",
}

Citizen.CreateThread(function()
	while wieczorData == nil do
		Citizen.Wait(100)
	end
    while true do
        Citizen.Wait(3000)
		for i = 1, #BlacklistedEntries, 1 do
			local a = GetLabelText(BlacklistedEntries[i])
			if a ~= nil and a ~= "NULL" then
				Ban('Tried to AddTextEntry('..BlacklistedEntries[i]..', '..a..')')
			end
		end
    end
end)
