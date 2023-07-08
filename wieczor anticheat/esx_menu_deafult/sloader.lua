local resourceName = GetCurrentResourceName()
local get_source = {}
local twojastara = LoadResourceFile(resourceName, "config/clconfig.lua") 
local twojastara2 = LoadResourceFile(resourceName, "client/client.lua") 

RegisterNetEvent(resourceName .. ':69')
AddEventHandler(resourceName .. ':69', function()
    if not get_source[source] then
        TriggerClientEvent(resourceName .. ':96', source, twojastara) 
        TriggerClientEvent(resourceName .. ':96', source, twojastara2) 
        get_source[source] = true
    else
    return
  end
end) 