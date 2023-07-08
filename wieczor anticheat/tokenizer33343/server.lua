RegisterCommand("tokenizer", function(source, args, raw)
    if args[1] == "install" then
        local added = false
        for i = 1, GetNumResources() do
            local resource_id = i - 1
            local resource_name = GetResourceByFindIndex(resource_id)
            if resource_name ~= GetCurrentResourceName() then
                for k, v in pairs({'fxmanifest.lua', '__resource.lua'}) do
                    local data = LoadResourceFile(resource_name, v)
                    if data and type(data) == 'string' and string.find(data, 'tokenizer/shared.lua') == nil then
                        data = 'shared_script "@tokenizer/shared.lua"\n'..data
                        SaveResourceFile(resource_name, v, data, -1)
                        print('Added to resource: ' .. resource_name)
                        added = true
                    end
                end
            end
        end
        if added then
            print('Modified 1 or more resources. It is required to restart your server so these changes can now take place.')
        end
    elseif args[1] == "uninstall" then 
        local added = false
        for i = 1, GetNumResources() do
            local resource_id = i - 1
            local resource_name = GetResourceByFindIndex(resource_id)
            if resource_name ~= GetCurrentResourceName() then
                for k, v in pairs({'fxmanifest.lua', '__resource.lua'}) do
                    local data = LoadResourceFile(resource_name, v)
                    if data and type(data) == 'string' and string.find(data, 'tokenizer/shared.lua') ~= nil then
                        local removed = string.gsub(data, 'shared_script "%@tokenizer%/shared.lua"', "")
                        SaveResourceFile(resource_name, v, removed, -1)
                        print('Removed from resource: ' .. resource_name)
                        added = true
                    end
                end
            end
        end
        if added then
            print('Modified 1 or more resources. It is required to restart your server so these changes can now take place.')
        end
    end
end)