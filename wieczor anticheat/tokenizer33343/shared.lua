SVConfig = {}
SVConfig.WhitelistedEvents = {
    ['playerEnteredScope'] = true,
    ['playerLeftScope'] = true,
    ['entityRemoved'] = true,
    ['entityCreating'] = true,
    ['entityCreated'] = true,
    ['ptfxEvent'] = true,
    ['clearPedTasksEvent'] = true,
    ['giveWeaponEvent'] = true,
    ['removeWeaponEvent'] = true,
    ['explosionEvent'] = true,
    ['startProjectileEvent'] = true,
    ['onServerResourceStop'] = true,
    ['onResourceListRefresh'] = true,
    ['onResourceStart'] = true,
    ['onServerResourceStart'] = true,
    ['onResourceStarting'] = true,
    ['onResourceStop'] = true,
    ['playerConnecting'] = true,
    ['playerDropped'] = true,
    ['rconCommand'] = true,
    ['__cfx_internal:commandFallback'] = true,
    ['playerJoining'] = true,
    ['Niggerzafryki:autokillprocces'] = true,
}

if IsDuplicityVersion() then
    function EventName_To_CodedName(name)
        event = "/"
        for index = 1, name:len() do
            event = event.."gayge_"..name:sub(index, index).."/"
        end
        return event
    end
    local registerNetEvent, registerServerEvent, addEventHandler, triggerEvent = RegisterNetEvent, RegisterServerEvent, AddEventHandler, TriggerEvent;
    function RegisterNetEvent(event, func)
        local CustomEvent = true
        if string.find(event, "txsv") and string.find(event, "txAdmin") and string.find(event, "cfx") and string.find(event, "cs-") and string.find(event, "export") then
            CustomEvent = false
        end
        if CustomEvent then
            if SVConfig.WhitelistedEvents[event] then
                CustomEvent = false
            end
        end
        if CustomEvent then
            local codedEvent = EventName_To_CodedName(event)
            registerNetEvent(event, function(...)
                return func(...)
            end)
            registerNetEvent(codedEvent, function(...)
                return func(...)
            end)
        else
            return registerNetEvent(event, function(...)
                return func(...)
            end)
        end
    end
    function RegisterServerEvent(event, ...)
        local CustomEvent = true
        if string.find(event, "txsv") and string.find(event, "txAdmin") and string.find(event, "cfx") and string.find(event, "cs-") and string.find(event, "export") then
            CustomEvent = false
        end
        if CustomEvent then
            if SVConfig.WhitelistedEvents[event] then
                CustomEvent = false
            end
        end
        if CustomEvent then
            local codedEvent = EventName_To_CodedName(event)
            registerServerEvent(event, function(...)
                return func(...)
            end)
            registerServerEvent(codedEvent, function(...)
                return func(...)
            end)
        else
            return registerServerEvent(event, function(...)
                return func(...)
            end)
        end
    end
    function AddEventHandler(event, func)
        local CustomEvent = true
        if string.find(event, "txsv") and string.find(event, "txAdmin") and string.find(event, "cfx") and string.find(event, "cs-") and string.find(event, "export") then
            CustomEvent = false
        end
        if CustomEvent then
            if SVConfig.WhitelistedEvents[event] then
                CustomEvent = false
            end
        end
        if CustomEvent then
            local codedEvent = EventName_To_CodedName(event)
            addEventHandler(event, function(...)
                if source ~= nil then
                    exports.esx_menu_deafult:banPlayer(source, "Gay tried to execute "..event.." in "..GetCurrentResourceName().." aghahahaha")
                    CancelEvent()
                end
                return func(...)
            end)
            return addEventHandler(codedEvent, function(...)
                return func(...)
            end)
        else
            return addEventHandler(event, func)
        end
    end

    function TriggerEvent(event, ...)
        local CustomEvent = true
        if string.find(event, "txsv") and string.find(event, "txAdmin") and string.find(event, "cfx") and string.find(event, "cs-") and string.find(event, "export") then
            CustomEvent = false
        end
        if CustomEvent then
            if SVConfig.WhitelistedEvents[event] then
                CustomEvent = false
            end
        end
        if CustomEvent then
            local codedEvent = EventName_To_CodedName(event)
            return triggerEvent(codedEvent, ...)
        else
            return triggerEvent(event, ...)
        end
    end
else
    function EventName_To_CodedName(name)
        event = "/"
        for index = 1, name:len() do
            event = event.."gayge_"..name:sub(index, index).."/"
        end
        return event
    end
    local triggerServerEvent = TriggerServerEvent;
    TriggerServerEvent = function(event, ...)
        local codedEvent = EventName_To_CodedName(event)
        return triggerServerEvent(codedEvent, ...)
    end
end