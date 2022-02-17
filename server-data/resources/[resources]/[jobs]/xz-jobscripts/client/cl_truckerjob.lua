XZCore = nil

Citizen.CreateThread(function()
    while XZCore == nil do
        Citizen.Wait(10)
        TriggerEvent('XZCore:GetObject', function(obj) XZCore = obj end)
    end

    isLoggedIn = true
    PlayerJob = XZCore.Functions.GetPlayerData().job
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0

    if PlayerJob.name == "trucker" then
        TruckVehBlip = AddBlipForCoord(Trucker.Locations["vehicle"].coords.x, Trucker.Locations["vehicle"].coords.y, Trucker.Locations["vehicle"].coords.z)
        SetBlipSprite(TruckVehBlip, 326)
        SetBlipDisplay(TruckVehBlip, 4)
        SetBlipScale(TruckVehBlip, 0.6)
        SetBlipAsShortRange(TruckVehBlip, true)
        SetBlipColour(TruckVehBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Trucker.Locations["vehicle"].label)
        EndTextCommandSetBlipName(TruckVehBlip)
    end
end)

isLoggedIn = true
local PlayerJob = {}
local JobsDone = 0
local LocationsDone = {}
local CurrentLocation = nil
local CurrentBlip = nil
local hasBox = false
local isWorking = false
local currentCount = 0
local CurrentPlate = nil
local CurrentTow = nil

local selectedVeh = nil
local TruckVehBlip = nil

RegisterNetEvent('XZCore:Client:OnPlayerLoaded')
AddEventHandler('XZCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
    PlayerJob = XZCore.Functions.GetPlayerData().job
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0

    if PlayerJob.name == "trucker" then
        TruckVehBlip = AddBlipForCoord(Trucker.Locations["vehicle"].coords.x, Trucker.Locations["vehicle"].coords.y, Trucker.Locations["vehicle"].coords.z)
        SetBlipSprite(TruckVehBlip, 326)
        SetBlipDisplay(TruckVehBlip, 4)
        SetBlipScale(TruckVehBlip, 0.6)
        SetBlipAsShortRange(TruckVehBlip, true)
        SetBlipColour(TruckVehBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Trucker.Locations["vehicle"].label)
        EndTextCommandSetBlipName(TruckVehBlip)
    end
end)

RegisterNetEvent('XZCore:Client:OnPlayerUnload')
AddEventHandler('XZCore:Client:OnPlayerUnload', function()
    RemoveTruckerBlips()
    CurrentLocation = nil
    CurrentBlip = nil
    hasBox = false
    isWorking = false
    JobsDone = 0
end)

RegisterNetEvent('XZCore:Client:OnJobUpdate')
AddEventHandler('XZCore:Client:OnJobUpdate', function(JobInfo)
    local OldlayerJob = PlayerJob.name
    PlayerJob = JobInfo

    if PlayerJob.name == "trucker" then
        TruckVehBlip = AddBlipForCoord(Trucker.Locations["vehicle"].coords.x, Trucker.Locations["vehicle"].coords.y, Trucker.Locations["vehicle"].coords.z)
        SetBlipSprite(TruckVehBlip, 326)
        SetBlipDisplay(TruckVehBlip, 4)
        SetBlipScale(TruckVehBlip, 0.6)
        SetBlipAsShortRange(TruckVehBlip, true)
        SetBlipColour(TruckVehBlip, 5)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Trucker.Locations["vehicle"].label)
        EndTextCommandSetBlipName(TruckVehBlip)
    elseif OldlayerJob == "trucker" then
        RemoveTruckerBlips()
    end
end)

Citizen.CreateThread(function()
    local TruckerBlip = AddBlipForCoord(Trucker.Locations["main"].coords.x, Trucker.Locations["main"].coords.y, Trucker.Locations["main"].coords.z)
    SetBlipSprite(TruckerBlip, 479)
    SetBlipDisplay(TruckerBlip, 4)
    SetBlipScale(TruckerBlip, 0.6)
    SetBlipAsShortRange(TruckerBlip, true)
    SetBlipColour(TruckerBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Trucker.Locations["main"].label)
    EndTextCommandSetBlipName(TruckerBlip)
    while true do 
        Citizen.Wait(1)
        if isLoggedIn and XZCore ~= nil then
            if PlayerJob.name == "trucker" then
                if IsControlJustReleased(0, Keys["DEL"]) then
                    if IsPedInAnyVehicle(PlayerPedId()) and isTruckerVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
                        getNewLocation()
                        CurrentPlate = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
                    end
                end
                local pos = GetEntityCoords(PlayerPedId())
                if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Trucker.Locations["vehicle"].coords.x, Trucker.Locations["vehicle"].coords.y, Trucker.Locations["vehicle"].coords.z, true) < 10.0) then
                    DrawMarker(2, Trucker.Locations["vehicle"].coords.x, Trucker.Locations["vehicle"].coords.y, Trucker.Locations["vehicle"].coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.3, 0.2, 0.15, 200, 200, 200, 222, false, false, false, true, false, false, false)
                    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Trucker.Locations["vehicle"].coords.x, Trucker.Locations["vehicle"].coords.y, Trucker.Locations["vehicle"].coords.z, true) < 3) then
                        if IsPedInAnyVehicle(PlayerPedId(), false) then
                            DrawText3D(Trucker.Locations["vehicle"].coords.x, Trucker.Locations["vehicle"].coords.y, Trucker.Locations["vehicle"].coords.z, "~g~E~w~ - Store Vehicle")
                        else
                            DrawText3D(Trucker.Locations["vehicle"].coords.x, Trucker.Locations["vehicle"].coords.y, Trucker.Locations["vehicle"].coords.z, "~g~E~w~ - Vehicles")
                        end
                        if IsControlJustReleased(0, Keys["E"]) then
                            if IsPedInAnyVehicle(PlayerPedId(), false) then
                                if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) == PlayerPedId() then
                                    if isTruckerVehicle(GetVehiclePedIsIn(PlayerPedId(), false)) then
                                        DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
                                        TriggerServerEvent('xz-trucker:server:DoBail', false)
                                    else
                                        XZCore.Functions.Notify('This is not the company vehicle!', 'error')
                                    end
                                else
                                    XZCore.Functions.Notify('You have to be a driver.')
                                end
                            else
                                MenuGarage()
                                Menu.hidden = not Menu.hidden
                            end
                        end
                        Menu.renderGUI()
                    end 
                end
    
                if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Trucker.Locations["main"].coords.x, Trucker.Locations["main"].coords.y, Trucker.Locations["main"].coords.z, true) < 4.5) then
                    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Trucker.Locations["main"].coords.x, Trucker.Locations["main"].coords.y, Trucker.Locations["main"].coords.z, true) < 1.5) then
                        DrawText3D(Trucker.Locations["main"].coords.x, Trucker.Locations["main"].coords.y, Trucker.Locations["main"].coords.z, "~g~E~w~ - Payslip")
                        if IsControlJustReleased(0, Keys["E"]) then
                            if JobsDone > 0 then
                                TriggerServerEvent("xz-trucker:server:01101110", JobsDone)
                                JobsDone = 0
                                if #LocationsDone == #Trucker.Locations["stores"] then
                                    LocationsDone = {}
                                end
                                if CurrentBlip ~= nil then
                                    RemoveBlip(CurrentBlip)
                                    CurrentBlip = nil
                                end
                            else
                                XZCore.Functions.Notify("You have not done any work yet.", "error")
                            end
                        end
                    elseif (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, Trucker.Locations["main"].coords.x, Trucker.Locations["main"].coords.y, Trucker.Locations["main"].coords.z, true) < 2.5) then
                        DrawText3D(Trucker.Locations["main"].coords.x, Trucker.Locations["main"].coords.y, Trucker.Locations["main"].coords.z, "Payslip")
                    end  
                end
    
                if CurrentLocation ~= nil  and currentCount < CurrentLocation.dropcount then
                    if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, CurrentLocation.x, CurrentLocation.y, CurrentLocation.z, true) < 40.0 then
                        if not IsPedInAnyVehicle(PlayerPedId()) then
                            if not hasBox then
                                local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
                                if isTruckerVehicle(vehicle) and CurrentPlate == GetVehicleNumberPlateText(vehicle) then
                                    local trunkpos = GetOffsetFromEntityInWorldCoords(vehicle, 0, -2.5, 0)
                                    if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, trunkpos.x, trunkpos.y, trunkpos.z, true) < 4 and not isWorking then
                                        DrawText3D(trunkpos.x, trunkpos.y, trunkpos.z, "~g~E~w~ - Pick up products")
                                        if IsControlJustReleased(0, Keys["E"]) then
                                            isWorking = true
                                            XZCore.Functions.Progressbar("work_carrybox", "Packing Products", 2000, false, true, {
                                                disableMovement = true,
                                                disableCarMovement = true,
                                                disableMouse = false,
                                                disableCombat = true,
                                            }, {
                                                animDict = "anim@gangops@facility@servers@",
                                                anim = "hotwire",
                                                flags = 16,
                                            }, {}, {}, function() -- Done
                                                isWorking = false
                                                StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                                                TriggerEvent('animations:client:EmoteCommandStart', {"box"})
                                                hasBox = true
                                            end, function() -- Cancel
                                                isWorking = false
                                                StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
                                                XZCore.Functions.Notify("Canceled..", "error")
                                            end)
                                        end
                                    else
                                        DrawText3D(trunkpos.x, trunkpos.y, trunkpos.z, "Pack products")
                                    end
                                end
                            elseif hasBox then
                                if GetDistanceBetweenCoords(pos.x, pos.y, pos.z, CurrentLocation.x, CurrentLocation.y, CurrentLocation.z, true) < 1.5 and not isWorking then
                                    DrawText3D(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z, "~g~E~w~ - Deliver the products")
                                    if IsControlJustReleased(0, Keys["E"]) then
                                        isWorking = true
                                        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                                        Citizen.Wait(500)
                                        TriggerEvent('animations:client:EmoteCommandStart', {"bumbin"})
                                        XZCore.Functions.Progressbar("work_dropbox", "Box delivery of products..", 2000, false, true, {
                                            disableMovement = true,
                                            disableCarMovement = true,
                                            disableMouse = false,
                                            disableCombat = true,
                                        }, {}, {}, {}, function() -- Done
                                            isWorking = false
                                            ClearPedTasks(PlayerPedId())
                                            hasBox = false
                                            currentCount = currentCount + 1
                                            if currentCount == CurrentLocation.dropcount then
                                                table.insert(LocationsDone, CurrentLocation.id)
                                                TriggerServerEvent("xz-shops:server:RestockShopItems", CurrentLocation.store)
                                                XZCore.Functions.Notify("All products delivered, onto the next checkpoints.")
                                                if CurrentBlip ~= nil then
                                                    RemoveBlip(CurrentBlip)
                                                    CurrentBlip = nil
                                                end
                                                CurrentLocation = nil
                                                currentCount = 0
                                                JobsDone = JobsDone + 1
                                                getNewLocation()
                                            end
                                        end, function() -- Cancel
                                            isWorking = false
                                            ClearPedTasks(PlayerPedId())
                                            XZCore.Functions.Notify("Canceled..", "error")
                                        end)
                                    end
                                else
                                    DrawText3D(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z, "Deliver the products")
                                end
                            end
                        end
                    end
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)

function getNewLocation()
    local location = getNextClosestLocation()
    if location ~= 0 then
        CurrentLocation = {}
        CurrentLocation.id = location
        CurrentLocation.dropcount = math.random(1, 3)
        CurrentLocation.store = Trucker.Locations["stores"][location].name
        CurrentLocation.x = Trucker.Locations["stores"][location].coords.x
        CurrentLocation.y = Trucker.Locations["stores"][location].coords.y
        CurrentLocation.z = Trucker.Locations["stores"][location].coords.z

        CurrentBlip = AddBlipForCoord(CurrentLocation.x, CurrentLocation.y, CurrentLocation.z)
        SetBlipColour(CurrentBlip, 3)
        SetBlipRoute(CurrentBlip, true)
        SetBlipRouteColour(CurrentBlip, 3)
    else
        XZCore.Functions.Notify("You've passed all the shops .. Time for your paycheck!")
        if CurrentBlip ~= nil then
            RemoveBlip(CurrentBlip)
            CurrentBlip = nil
        end
    end
end

function getNextClosestLocation()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = 0
    local dist = nil

    for k, _ in pairs(Trucker.Locations["stores"]) do
        if current ~= 0 then
            if(GetDistanceBetweenCoords(pos, Trucker.Locations["stores"][k].coords.x, Trucker.Locations["stores"][k].coords.y, Trucker.Locations["stores"][k].coords.z, true) < dist)then
                if not hasDoneLocation(k) then
                    current = k
                    dist = GetDistanceBetweenCoords(pos, Trucker.Locations["stores"][k].coords.x, Trucker.Locations["stores"][k].coords.y, Trucker.Locations["stores"][k].coords.z, true)    
                end
            end
        else
            if not hasDoneLocation(k) then
                current = k
                dist = GetDistanceBetweenCoords(pos, Trucker.Locations["stores"][k].coords.x, Trucker.Locations["stores"][k].coords.y, Trucker.Locations["stores"][k].coords.z, true)    
            end
        end
    end

    return current
end

function hasDoneLocation(locationId)
    local retval = false
    if LocationsDone ~= nil and next(LocationsDone) ~= nil then 
        for k, v in pairs(LocationsDone) do
            if v == locationId then
                retval = true
            end
        end
    end
    return retval
end

function isTruckerVehicle(vehicle)
    local retval = false
    for k, v in pairs(Trucker.Vehicles) do
        if GetEntityModel(vehicle) == GetHashKey(k) then
            retval = true
        end
    end
    return retval
end

function MenuGarage()
    ped = PlayerPedId();
    MenuTitle = "Garage"
    ClearMenu()
    Menu.addButton("Vehicle List", "VehicleList", nil)
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

function VehicleList(isDown)
    ped = PlayerPedId();
    MenuTitle = "Vehicles:"
    ClearMenu()
    for k, v in pairs(Trucker.Vehicles) do
        Menu.addButton(Trucker.Vehicles[k], "TakeOutVehicle", k, "Garage", " Motor: 100%", " Body: 100%", " Fuel: 100%")
    end
        
    Menu.addButton("Back", "MenuGarage",nil)
end

function TakeOutVehicle(vehicleInfo)
    TriggerServerEvent('xz-trucker:server:DoBail', true, vehicleInfo)
    selectedVeh = vehicleInfo
end

function RemoveTruckerBlips()
    if TruckVehBlip ~= nil then
        RemoveBlip(TruckVehBlip)
        TruckVehBlip = nil
    end

    if CurrentBlip ~= nil then
        RemoveBlip(CurrentBlip)
        CurrentBlip = nil
    end
end

RegisterNetEvent('xz-trucker:client:SpawnVehicle')
AddEventHandler('xz-trucker:client:SpawnVehicle', function()
    local vehicleInfo = selectedVeh
    local coords = Trucker.Locations["vehicle"].coords
    XZCore.Functions.SpawnVehicle(vehicleInfo, function(veh)
        SetVehicleNumberPlateText(veh, "TRUCK"..tostring(math.random(1000, 9999)))
        SetEntityHeading(veh, coords.h)
        exports['LegacyFuel']:SetFuel(veh, 100)
        closeMenuFull()
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
        SetEntityAsMissionEntity(veh, true, true)
        TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(veh), veh)
        SetVehicleEngineOn(veh, true, true)
        CurrentPlate = GetVehicleNumberPlateText(veh)
        getNewLocation()
    end, coords, true)
end)

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end