RegisterServerEvent("Scripts:ready")
AddEventHandler("Scripts:ready", function()
    XZCore.Functions.CreateUseableItem("repairkit", function(source, item)
        TriggerClientEvent("Repairkit:start", source, false)
    end)
    
    XZCore.Functions.CreateUseableItem("advancedrepairkit", function(source, item)
        TriggerClientEvent("Repairkit:start", source, true)
    end)
end)