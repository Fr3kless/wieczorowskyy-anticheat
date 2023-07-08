local wieczor = {}
local wczr = {}
local CommandsCount = {}
local BanList = {}
local Particles = {}
local EventBlocker_Names = {
    "??11?1?",
    "???1???1",
    "????????22",
}
local WeaponTimeout = {}
local WeaponCount = {}
local HeartbeatTimeout = {}
VehCounter = {}
PedCounter = {}
PropCounter = {}
local ResourceList = {}

ESX = exports['es_extended']:getSharedObject()

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1500)
        VehCounter = {}
        PedCounter = {}
        PropCounter = {}
    end
end)

RegisterNetEvent('esx:onPlayerJoined')
AddEventHandler('esx:onPlayerJoined', function()
	local _source = source
	Wait(30000)
	if not wczr[_source] then
		Log(_source, "kick", "Antycheat nie został załadowany, prosimy o ponowne połączenie!")
	end
end)

AddEventHandler('playerConnecting', function(playerName, setKickReason, deferals)
	if source ~= nil then
		local identifier = ""
		local license = ""
		local xbox = ""
		local live = ""
		local discord = ""
		local name = GetPlayerName(source)
		local tokens = {}
		for i = 0, GetNumPlayerTokens(source) do
			table.insert(tokens, GetPlayerToken(source, i))
		end
		for k, v in pairs(GetPlayerIdentifiers(source))do   
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				identifier = v
			elseif string.sub(v, 1, string.len("license:")) == "license:" then
				license = v
			elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
				xbox = v
			elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
				discord = v
			elseif string.sub(v, 1, string.len("live:")) == "live:" then
				live = v
			end
		end
		for i = 1, #BanList, 1 do
			if (tostring(BanList[i].identifier) == identifier) or (tostring(BanList[i].license) == license) or (tostring(BanList[i].xbox) == xbox) or (tostring(BanList[i].discord) == discord) or (tostring(BanList[i].live) == live) then
				deferals.done("Zostałeś zbanowany przez system anticheat! Twój BanID: "..BanList[i].id)
			end
			local bannedtokens = json.decode(BanList[i].token)
			for k,v in pairs(bannedtokens) do
				for i2 = 1, #tokens, 1 do
					if v == tokens[i2] then
						deferals.done("Zostałeś zbanowany przez system anticheat! Twój BanID: "..BanList[i].id)
					end
				end
			end
		end
	end
end)

exports("banPlayer", function(source, reason)
	Log(source, "ban", reason)
end)

function LoadBans()
	MySQL.Async.fetchAll('SELECT * FROM xenonac', {}, function(bans)
		if bans then
			BanList = {}
			for i=1, #bans, 1 do
				table.insert(BanList, {
					id = bans[i].id,
					identifier = bans[i].identifier,
					license = bans[i].license,
					discord = bans[i].discord,
					name = bans[i].name,
					reason = bans[i].reason,
					date = bans[i].date,
					live = bans[i].live,
					xbox = bans[i].xbox,
					token = bans[i].token,
				})
			end
		end
	end)
end

function DatabaseBan(source, reason)
	if source ~= nil then
		local date = os.date("%Y/%m/%d %H:%M")
		local identifier = "nieznane"
		local license = "nieznane"
		local xbox = "nieznane"
		local live = "nieznane"
		local discord = "nieznane"
		local name = GetPlayerName(source)
		local tokens = {}
		for i = 0, GetNumPlayerTokens(source) do
			table.insert(tokens, GetPlayerToken(source, i))
		end
		for k, v in pairs(GetPlayerIdentifiers(source))do   
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				identifier = v
			elseif string.sub(v, 1, string.len("license:")) == "license:" then
				license = v
			elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
				xbox = v
			elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
				discord = v
			elseif string.sub(v, 1, string.len("live:")) == "live:" then
				live = v
			end
		end
		MySQL.Async.execute('INSERT INTO xenonac (identifier, license, name, discord, reason, date, live, xbox, token) VALUES (@identifier, @license, @name, @discord, @reason, @date, @live, @xbox, @token)', {
			['@identifier'] = identifier,
			['@license'] = license,
			['@name'] = name,
			['@discord'] = discord,
			['@reason'] = reason,
			['@date'] = date,
			['@live'] = live,
			['@xbox'] = xbox,
			['@token'] = json.encode(tokens),
		}, function()
		end)
		DropPlayer(source, "Zostałeś zbanowany przez system anticheat!")
		Citizen.Wait(100)
		LoadBans()
		Wait(500)
		LoadBans()
	end
end


RegisterCommand("lota", function(source, args, raw)
    local xPlayer = ESX.GetPlayerFromId(source)
	if source ~= 0 then
		if xPlayer.group == "best" then
			MySQL.Async.execute('UPDATE `users` SET `group` = "user" WHERE identifier = @identifier', {
				['@identifier'] = args[1],
			}, function()
				xPlayer.showNotification("Zabrano permisje dla "..args[1])
			end)
		end
	else
		MySQL.Async.execute('UPDATE `users` SET `group` = "user" WHERE identifier = @identifier', {
			['@identifier'] = args[1],
		}, function()
			print("Zabrano permisje dla "..args[1])
		end)
	end
end)

GenerateRandomString = function(a, b)
	local chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'
	local chartable = {}
	for fj in chars:gmatch(".") do
		table.insert(chartable, fj)
	end
	for i = 1, b do
		a = a .. chartable[math.random(1, #chartable)]
	end
	return a
end

local LastBanned = ""

function Log(source, what, reason, screenshot)
    if source ~= nil then
        local sourceplayername = GetPlayerName(source)
		if sourceplayername == nil then
			return
		end
        local color = 0
        local title = ""
        local webhook = ""
		local LicenseValue = ""
		local XboxValue = ""
		local DiscordValue = ""
		local LiveValue = ""
		for k, v in pairs(GetPlayerIdentifiers(source)) do
			if string.sub(v, 1, string.len("steam:")) == "steam:" then
				identifier = v
				if identifier == nil then
					identifier = "Nie znaleziono"
				end
			end
			if string.sub(v, 1, string.len("license:")) == "license:" then
				license = v
				if license == nil then
					license = "Nie znaleziono"
				end
				LicenseValue = "\n**License:** "..license
			end
			if string.sub(v, 1, string.len("xbl:")) == "xbl:" then
				xbl  = v
				if xbl == nil then
					xbl = "Nie znaleziono"
				end
				XboxValue = "\n**Xbox:** "..xbl
			end
			if string.sub(v, 1, string.len("discord:")) == "discord:" then
				playerdiscord = v
				if playerdiscord ~= nil then
					DiscordValue = "\n**Discord:** <@"..string.gsub(playerdiscord, "discord:", "")..">"
				else
					DiscordValue = "\n**Discord:** Nie znaleziono"
				end
			end
			if string.sub(v, 1, string.len("live:")) == "live:" then
				liveid = v
				if liveid == nil then
					liveid = "Nie znaleziono"
				end
				LiveValue = "\n**Live:** "..liveid
			end
		end
		if what == "ban" then
			if LastBanned == identifier then
				what = "nothing"
			end
		end
		if what == "ban" then
            color = 15417396
            title = "Ban Logs..."
            webhook = SVConfig.Webhooks.Bans
		elseif what == "kick" then
			color = 14445588
            title = "Kick Logs..."
            webhook = SVConfig.Webhooks.Kicks
		elseif what == "screenshot" then
			color = 3447787
			title = "Control Logs..."
            webhook = SVConfig.Webhooks.Controls
		elseif what == "warn" then
			color = 14445588
            title = "Kick Logs..."
            webhook = SVConfig.Webhooks.Warns
        end
		local webhook_description = "**Nick:** "..sourceplayername.. "\n**ServerID:** "..source.."\n**Powód:** "..reason.."\n**SteamID:** "..identifier..""..DiscordValue..""..LicenseValue..""..LiveValue..""..XboxValue
        if what == "kick" or what == "warn" then
            PerformHttpRequest(webhook, function(E, F, G)
            end, "POST", json.encode({embeds = {{
                color = color,
                title = title,
                description = webhook_description,
                timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
            }}}), { ["Content-Type"] = "application/json" })
        elseif what == "screenshot" or what == "ban" then
            PerformHttpRequest(webhook, function(E, F, G)
            end, "POST", json.encode({embeds = {{
                color = color,
                title = title,
                description = webhook_description,
				timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
                image = {
                    url = screenshot
                }
            }}}), { ["Content-Type"] = "application/json"})
        end
		if what == "ban" then
			DatabaseBan(source, reason)
			LastBanned = identifier
		elseif what == "kick" then
			DropPlayer(source, reason)
		end
    end
end

function GetResources()
	ResourceList = {}
	for i = 0, GetNumResources()-1, 1 do
		ResourceList[GetResourceByFindIndex(i)] = GetResourceState(GetResourceByFindIndex(i))
	end
end

Citizen.CreateThread(function()
    wieczor.BanEvent = GenerateRandomString("k", 20)
    wieczor.ScreenshotEvent = GenerateRandomString("r", 20)
	wieczor.HeartbeatEvent = GenerateRandomString("d", 20)
	wieczor.KickEvent = GenerateRandomString("h", 20)
	wieczor.CrashEvent = GenerateRandomString("f", 20)
	wieczor.SuperJumpEvent = GenerateRandomString("i", 20)
	wieczor.SpectateEvent = GenerateRandomString("s", 20)
	wieczor.WarnEvent = GenerateRandomString("l", 20)
    wieczor.ImageServer = SVConfig.Webhooks.ImageServer 
	AddEventHandler("onResourceListRefresh", function()
		GetResources()
	end)
	GetResources()
    RegisterNetEvent("wieczor")
    AddEventHandler("wieczor", function()
		if not wczr[source] then
			wczr[source] = true
		end
        TriggerClientEvent("wieczorxd", source, {
			i = wieczor.SuperJumpEvent,
            k = wieczor.BanEvent,
            r = wieczor.ScreenshotEvent,
			d = wieczor.HeartbeatEvent,
			h = wieczor.KickEvent,
			l = wieczor.WarnEvent,
			f = wieczor.CrashEvent,
			s = wieczor.SpectateEvent,
            imgserver = wieczor.ImageServer,
        })
    end)
	RegisterServerEvent(wieczor.WarnEvent)
	AddEventHandler(wieczor.WarnEvent, function(reason)
		if source ~= nil then
			Log(source, "warn", reason)
		end
	end)
	RegisterServerEvent(wieczor.SuperJumpEvent)
	AddEventHandler(wieczor.SuperJumpEvent, function()
		if source ~= nil then
			if IsPlayerUsingSuperJump(source) then
				Log(source, "ban", "SuperJump Detected")
			end
		end
	end)
	RegisterNetEvent(wieczor.SpectateEvent)
	AddEventHandler(wieczor.SpectateEvent, function()
		if source ~= nil then
			local xPlayer = ESX.GetPlayerFromId(source)
			if xPlayer.getGroup() == "user" then
				Log(source, "ban", "Spectate Detected")
			end
		end
	end)
	AddEventHandler('ptFxEvent', function(source, data)
		if source ~= nil then
			Particles[source] = (Particles[source] or 0) + 1
			if Particles[source] > 3 then
				if SVConfig.AntiMassParticles then
					Log(source, "ban", "Particle Spam: "..Particles[source])
					CancelEvent()
				end
			end
		end
	end)
	RegisterNetEvent(wieczor.KickEvent)
	AddEventHandler(wieczor.KickEvent, function(reason)
		if source ~= nil then
			if reason == "Anti NUI DevTools" then
				local xPlayer = ESX.GetPlayerFromId(source)
				if xPlayer.getGroup() ~= "best" then
					TriggerClientEvent(wieczor.CrashEvent, source)
					Log(source, "kick", "Wykryto użycie DevToolsów. Prosimy o wyłączenie !")
				end
			else
				Log(source, "kick", reason)
			end
		end
	end)
    RegisterNetEvent(wieczor.BanEvent)
    AddEventHandler(wieczor.BanEvent, function(reason, screenshot)
        if source ~= nil then
            Log(source, "ban", reason, screenshot)
        end
    end)
    RegisterNetEvent(wieczor.ScreenshotEvent)
    AddEventHandler(wieczor.ScreenshotEvent, function(keyname, screenshot)
        if source ~= nil then
            Log(source, "screenshot", keyname, screenshot)
        end
    end)
	RegisterNetEvent(wieczor.HeartbeatEvent)
	AddEventHandler(wieczor.HeartbeatEvent, function(resources_status)
		if source ~= nil then
			for k, v in pairs(resources_status) do
				if k and k ~= "xsound" and v ~= GetResourceState(k) and k ~= "just_a_script" then
					Log(source, "ban", "Probował zastopować: "..k.." - resource!")
				end
			end
		end
	end)
	for i = 1, #EventBlocker_Names, 1 do
		RegisterServerEvent(EventBlocker_Names[i])
		AddEventHandler(EventBlocker_Names[i], function()
			if source ~= nil then
				Log(source, "ban", "Event Blocker Detected!")
			end
		end)
	end
    AddEventHandler("RemoveWeaponEvent", function(source, data)
		if source ~= nil then
			Log(source, "ban", "RemoveWeapon")
			CancelEvent()
		end
	end)
	AddEventHandler("RemoveAllWeaponsEvent", function(source, data)
		if source ~= nil then
			Log(source, "ban", "RemoveAllWeapons")
			CancelEvent()
		end
	end)
	AddEventHandler("giveWeaponEvent", function(source, data)
		if source ~= nil then
			if data.givenAsPickup == false then
				Log(source, "ban", "GiveWeapon")
				CancelEvent()
			end
		end
	end)
	RegisterNetEvent("wieczorHandler:banPlayer")
	AddEventHandler("wieczorHandler:banPlayer", function(reason)
		Log(source, "ban", reason)
	end)
	AddEventHandler('chatMessage', function(source, name, message)
		if SVConfig.AntiFakeMessage then
			local realname = GetPlayerName(source)
			if source ~= nil then
				if name ~= realname then
					Log(source, "ban", "FakeMessage Detected")
					CancelEvent()
				end
			else
				CancelEvent()
			end
		end
	end)
	while true do
		Citizen.Wait(30000)
		TriggerClientEvent(wieczor.HeartbeatEvent, -1)
	end
end)

AddEventHandler("esx:onRemoveInventoryItem", function(source, name, count)
	if count > 0 then
		local xPlayer = ESX.GetPlayerFromId(source)
		local item = xPlayer.getInventoryItem(name)
		if item then
			if item.type == "weapon" then
				local playerPed = GetPlayerPed(source)
				local a = GetSelectedPedWeapon(playerPed)
				if a == GetHashKey(item.data.name) then
					RemoveWeaponFromPed(playerPed, a)
					WeaponTimeout[source] = 5000
					Wait(5000)
					WeaponTimeout[source] = 0
				end
			end
		end
	end
end)

AddEventHandler("esx:onAddInventoryItem", function(source, name, count)
	WeaponTimeout[source] = 5000
	Wait(5000)
	WeaponTimeout[source] = 0
end)

RegisterCommand("refreshacbans", function(source, args, raw)
	if source ~= 0 then
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer.getGroup() ~= "user" then
			BanList = {}
			LoadBans()
		end
	else
		BanList = {}
		LoadBans()
	end
end)

RegisterCommand("acunban", function(source, args, raw)
	if source ~= 0 then
		local xPlayer = ESX.GetPlayerFromId(source)
		if xPlayer.getGroup() ~= "user" then
			MySQL.Async.execute("DELETE FROM `xenonac` WHERE id = @id", {
				['@id'] = args[1] 
			}, function()
				BanList = {}
				LoadBans()
			end)
		end
	else
		MySQL.Async.execute("DELETE FROM `xenonac` WHERE id = @id", {
			['@id'] = args[1] 
		}, function()
			BanList = {}
			LoadBans()
		end)
	end
end)

AddEventHandler("entityCreating", function(id)
    local model = GetEntityModel(id)
    local eType = GetEntityType(id)
    local owner = NetworkGetEntityOwner(id)
    if eType == 3 then
        for i, v in pairs(SVConfig.ObjectWhitelist) do
            local v = (type(v) == "number" and v or GetHashKey(v))
            if v == model then
                return
            end
        end
        CancelEvent()
        PropCounter[owner] = (PropCounter[owner] or 0) + 1
        if PropCounter[owner] > 40 then
            CancelEvent()
        end
        if PropCounter[owner] > 64 then
            CancelEvent()
        end
    elseif eType == 2 then
        for i, v in pairs(SVConfig.VehicleBlacklist) do
            local v = (type(v) == "number" and v or GetHashKey(v))
            if v == model then
                CancelEvent()
            end
        end
        VehCounter[owner] = (VehCounter[owner] or 0) + 1
        if VehCounter[owner] > 60 then
            CancelEvent()
        end
        if VehCounter[owner] > 35 then
            CancelEvent()
        end
        local speed = GetEntityVelocity(id)
        if #(speed - vector3(0, 0, 0)) > 35.0 then
            CancelEvent()
        end
    elseif eType == 1 then
        for i, v in pairs(SVConfig.PedBlacklist) do
            local v = (type(v) == "number" and v or GetHashKey(v))
            if v == model then
                CancelEvent()
            end
        end
        PedCounter[owner] = (PedCounter[owner] or 0) + 1
        if PedCounter[owner] > 45 then
            CancelEvent()
        end
    end
end)


ObjectsSpam = {}
VehiclesSpam = {}
PedsSpam = {}

AddEventHandler("entityCreating", function(id)
    local model = GetEntityModel(id)
	if model == 0 then
		return
	end
    local eType = GetEntityType(id)
    local owner = NetworkGetFirstEntityOwner(id)
	local pType = GetEntityPopulationType(id)
	if pType ~= 7 and pType ~= 0 then
		return
	end
	if model ~= nil and owner ~= nil then
		if eType == 3 then
			if not ObjectsSpam[owner] then
				ObjectsSpam[owner] = {}
			end
			if not ObjectsSpam[owner][model] then
				ObjectsSpam[owner][model] = 0
				lol(eType, owner, model)
			else
				ObjectsSpam[owner][model] = 1 + ObjectsSpam[owner][model]
				if ObjectsSpam[owner][model] > 5 then
					print("^0[^6VaneRP^0-^4AntiCheat^0] ^0[^1WARN^0]: ^3["..owner.."]  ^0has done: ^9Mass Same Objects: "..ObjectsSpam[owner][model].." in 4 seconds | "..model.."^0.")
					CancelEvent()
					--Log(source, "ban", "Mass Same Objects: "..ObjectsSpam[owner][model].." in 4 seconds")
				end
			end
		end
		if eType == 2 then
			if not VehiclesSpam[owner] then
				VehiclesSpam[owner] = {}
			end
			if not VehiclesSpam[owner][model] then
				VehiclesSpam[owner][model] = 0
				lol(eType, owner, model)
			else
				VehiclesSpam[owner][model] = 1 + VehiclesSpam[owner][model]
				if VehiclesSpam[owner][model] > 6 then
					print("^0[^6VaneRP^0-^4AntiCheat^0] ^0[^1WARN^0]: ^3["..owner.."]  ^0has done: ^9Mass Same Vehicles: "..VehiclesSpam[owner][model].." in 4 seconds | "..model.."^0.")
                    Log(owner, "ban", "Mass Same Vehicles Spawned: "..VehiclesSpam[owner][model].." in 4 seconds | "..model)
					CancelEvent()
				end
			end
		end
		if eType == 1 then
			if not PedsSpam[owner] then
				PedsSpam[owner] = {}
			end
			if not PedsSpam[owner][model] then
				PedsSpam[owner][model] = 0
				lol(eType, owner, model)
			else
				PedsSpam[owner][model] = 1 + PedsSpam[owner][model]
				if PedsSpam[owner][model] > 5 then
					print("^0[^6VaneRP^0-^4AntiCheat^0] ^0[^1WARN^0]: ^3["..owner.."] ^0has done: ^9Mass Same Peds: "..PedsSpam[owner][model].." in 4 seconds | "..model.."^0.")
					CancelEvent()
					--Log(owner, "ban", "Mass Same Peds Spawned: "..VehiclesSpam[owner][model].." in 4 seconds | "..model)
				end
			end
		end
	end
end)

function lol(type, owner, model)
	Citizen.SetTimeout(4000, function()
		if type == 3 then
			ObjectsSpam[owner] = {}
		elseif type == 2 then
			VehiclesSpam[owner] = {}
		elseif type == 1 then
			PedsSpam[owner] = {}
		end
	end)
end

local WeaponsByHashes = {
	[-1716189206] = 'WEAPON_KNIFE',
	[1737195953] = 'WEAPON_NIGHTSTICK',
	[1317494643] = 'WEAPON_HAMMER',
	[-1786099057] = 'WEAPON_BAT',
	[-2067956739] = 'WEAPON_CROWBAR',
	[1141786504] = 'WEAPON_GOLFCLUB',
	[-102323637] = 'WEAPON_BOTTLE',
	[-1834847097] = 'WEAPON_DAGGER',
	[-102973651] = 'WEAPON_HATCHET',
	[-656458692] = 'WEAPON_KNUCKLEDUSTER',
	[-581044007] = 'WEAPON_MACHETE',
	[-1951375401] = 'WEAPON_FLASHLIGHT',
	[-538741184] = 'WEAPON_SWITCHBLADE',
	[-1810795771] = 'WEAPON_POOLCUE',
	[419712736] = 'WEAPON_WRENCH',
	[-853065399] = 'WEAPON_BATTLEAXE',
	[453432689] = 'WEAPON_PISTOL',
	[3219281620] = 'WEAPON_PISTOL_MK2',
	[1593441988] = 'WEAPON_COMBATPISTOL',
	[-1716589765] = 'WEAPON_PISTOL50',
	[-1076751822] = 'WEAPON_SNSPISTOL',
	[-771403250] = 'WEAPON_HEAVYPISTOL',
	[137902532] = 'WEAPON_VINTAGEPISTOL',
	[-598887786] = 'WEAPON_MARKSMANPISTOL',
	[-1045183535] = 'WEAPON_REVOLVER',
	[584646201] = 'WEAPON_APPISTOL',
	[911657153] = 'WEAPON_STUNGUN',
	[1198879012] = 'WEAPON_FLAREGUN',
	[324215364] = 'WEAPON_MICROSMG',
	[-619010992] = 'WEAPON_MACHINEPISTOL',
	[736523883] = 'WEAPON_SMG',
	[2024373456] = 'WEAPON_SMG_MK2',
	[-270015777] = 'WEAPON_ASSAULTSMG',
	[171789620] = 'WEAPON_COMBATPDW',
	[-1660422300] = 'WEAPON_MG',
	[2144741730] = 'WEAPON_COMBATMG',
	[3686625920] = 'WEAPON_COMBATMG_MK2',
	[1627465347] = 'WEAPON_GUSENBERG',
	[-1121678507] = 'WEAPON_MINISMG',
	[-1074790547] = 'WEAPON_ASSAULTRIFLE',
	[961495388] = 'WEAPON_ASSAULTRIFLE_MK2',
	[-2084633992] = 'WEAPON_CARBINERIFLE',
	[4208062921] = 'WEAPON_CARBINERIFLE_MK2',
	[-1357824103] = 'WEAPON_ADVANCEDRIFLE',
	[-1063057011] = 'WEAPON_SPECIALCARBINE',
	[2132975508] = 'WEAPON_BULLPUPRIFLE',
	[1649403952] = 'WEAPON_COMPACTRIFLE',
	[100416529] = 'WEAPON_SNIPERRIFLE',
	[205991906] = 'WEAPON_HEAVYSNIPER',
	[177293209] = 'WEAPON_HEAVYSNIPER_MK2',
	[-952879014] = 'WEAPON_MARKSMANRIFLE',
	[487013001] = 'WEAPON_PUMPSHOTGUN',
	[2017895192] = 'WEAPON_SAWNOFFSHOTGUN',
	[-1654528753] = 'WEAPON_BULLPUPSHOTGUN',
	[-494615257] = 'WEAPON_ASSAULTSHOTGUN',
	[-1466123874] = 'WEAPON_MUSKET',
	[984333226] = 'WEAPON_HEAVYSHOTGUN',
	[-275439685] = 'WEAPON_DOUBLEBARRELSHOTGUN',
	[317205821] = 'WEAPON_AUTOSHOTGUN',
	[-1568386805] = 'WEAPON_GRENADELAUNCHER',
	[-1312131151] = 'WEAPON_RPG',
	[1119849093] = 'WEAPON_MINIGUN',
	[2138347493] = 'WEAPON_FIREWORK',
	[1834241177] = 'WEAPON_RAILGUN',
	[1672152130] = 'WEAPON_HOMINGLAUNCHER',
	[1305664598] = 'WEAPON_GRENADELAUNCHERSMOKE',
	[125959754] = 'WEAPON_COMPACTLAUNCHER',
	[-1813897027] = 'WEAPON_GRENADE',
	[741814745] = 'WEAPON_STICKYBOMB',
	[-1420407917] = 'WEAPON_PROXIMITYMINE',
	[-1600701090] = 'WEAPON_BZGAS',
	[615608432] = 'WEAPON_MOLOTOV',
	[101631238] = 'WEAPON_FIREEXTINGUISHER',
	[883325847] = 'WEAPON_PETROLCAN',
	[1233104067] = 'WEAPON_FLARE',
	[600439132] = 'WEAPON_BALL',
	[126349499] = 'WEAPON_SNOWBALL',
	[-37975472] = 'WEAPON_SMOKEGRENADE',
	[-1169823560] = 'WEAPON_PIPEBOMB',
}

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(20000)
		local xPlayers = ESX.GetPlayers()
		for i = 1, #xPlayers, 1 do
			if WeaponTimeout[xPlayers[i]] == 0 or WeaponTimeout[xPlayers[i]] == {} or WeaponTimeout[xPlayers[i]] == nil then
				local playerPed = GetPlayerPed(xPlayers[i])
				local a = GetSelectedPedWeapon(playerPed)
				if playerPed then
					local b = ESX.GetPlayerFromId(xPlayers[i])
					if b then
						local c = b.getInventory()
						if a ~= GetHashKey("WEAPON_UNARMED") and a ~= 0 and WeaponsByHashes[a] then
							local good = false
							for k, v in ipairs(c) do
								if v.type == "weapon" and v.count > 0 then
									if a == GetHashKey(v.data.name) then
										good = true
									end
								end
							end
							Wait(1500)
							if not good then
								if not WeaponCount[xPlayers[i]] then
									WeaponCount[xPlayers[i]] = 1
								else
									WeaponCount[xPlayers[i]] = WeaponCount[xPlayers[i]] + 1
								end
								RemoveWeaponFromPed(playerPed, a)
								if WeaponCount[xPlayers[i]] >= 2 then
									Log(xPlayers[i], "ban", "Wykryto zrespienie broni - "..WeaponsByHashes[a]..".")
								else
									Log(xPlayers[i], "warn", "Wykryto zrespienie broni - "..WeaponsByHashes[a]..".")
								end
							end
						end
					end
				end
			end
		end
	end
end)
