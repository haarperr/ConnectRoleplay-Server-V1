local isLoggedIn = true
local InApartment = false
local ClosestHouse = nil
local CurrentApartment = nil
local IsOwned = false

local CurrentDoorBell = 0

local CurrentOffset = 0

local houseObj = {}
local POIOffsets = nil

local rangDoorbell = nil

Citizen.CreateThread(function()
    while true do
        if isLoggedIn and not InApartment then
            SetClosestApartment()
        end
        Citizen.Wait(10000)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if isLoggedIn and ClosestHouse ~= nil then
            if InApartment then
                local pos = GetEntityCoords(PlayerPedId())
                local entrancedist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z))
                local stashdist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.stash.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.stash.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.stash.z))
                local outfitsdist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.clothes.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.clothes.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.clothes.z))
                local logoutdist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.logout.x, Apartments.Locations[ClosestHouse].coords.enter.y + POIOffsets.logout.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.logout.z))

                -- Enter
                if CurrentDoorBell ~= 0 then
                    if entrancedist < 1.2 then
                        DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z + 0.1, '~g~G~w~ - Open door')
                        if IsControlJustPressed(0, 47) then -- G
                            TriggerServerEvent("apartments:server:OpenDoor", CurrentDoorBell, CurrentApartment, ClosestHouse)
                            CurrentDoorBell = 0
                        end
                    end
                end

                --Exit
                if entrancedist < 3 then
                    DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.exit.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.exit.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.exit.z, '~g~E~w~ - Leave Apartment')
                    if IsControlJustPressed(0, 38) then -- E
                        LeaveApartment(ClosestHouse)
                    end
                end

                --Stash
                if stashdist < 1.2 then
                    DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.stash.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.stash.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.stash.z, '~g~E~w~ - Stash')
                    if IsControlJustPressed(0, 38) then -- E
                        if CurrentApartment ~= nil then
                            TriggerEvent("InteractSound_CL:PlayOnOne","zipper",0.5)
                            TriggerServerEvent("inventory:server:OpenInventory", "stash", CurrentApartment)
                            TriggerEvent("inventory:client:SetCurrentStash", CurrentApartment)
                        end
                    end
                elseif stashdist < 3 then
                    DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.stash.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.stash.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.stash.z, 'Stash')
                end

                --Outfits
                if outfitsdist < 1.2 then
                    DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.clothes.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.clothes.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.clothes.z, '~g~E~w~ - Outfits')
                    if IsControlJustPressed(0, 38) then -- E
                        TriggerEvent('xz-outfits-ido:client:forceUI')
                    end
                elseif outfitsdist < 3 then
                    DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.clothes.x, Apartments.Locations[ClosestHouse].coords.enter.y - POIOffsets.clothes.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.clothes.z, 'Outfits')
                end

                --Logout
                if logoutdist < 1.5 then
                    DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.logout.x, Apartments.Locations[ClosestHouse].coords.enter.y + POIOffsets.logout.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.logout.z, '~g~E~w~ - Log out')
                    if IsControlJustPressed(0, 38) then -- E
                        TriggerServerEvent('xz-houses:server:LogoutLocation')
                    end
                elseif logoutdist < 3 then
                    DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x - POIOffsets.logout.x, Apartments.Locations[ClosestHouse].coords.enter.y + POIOffsets.logout.y, Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset + POIOffsets.logout.z, 'Log out')
                end

            else
                local pos = GetEntityCoords(PlayerPedId())
                local doorbelldist = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.doorbell.x, Apartments.Locations[ClosestHouse].coords.doorbell.y,Apartments.Locations[ClosestHouse].coords.doorbell.z))
                local entrance = #(pos - vector3(Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y,Apartments.Locations[ClosestHouse].coords.enter.z))

                if doorbelldist < 1.2 then
                    DrawText3Ds(Apartments.Locations[ClosestHouse].coords.doorbell.x, Apartments.Locations[ClosestHouse].coords.doorbell.y, Apartments.Locations[ClosestHouse].coords.doorbell.z, '~g~G~w~ - Ring Doorbell')
                    if IsControlJustPressed(0, 47) then -- G
                        MenuOwners()
                        Menu.hidden = not Menu.hidden
                    end
                    Menu.renderGUI()
                end

                if IsOwned then
                   if entrance < 1.2 then
                        DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y, Apartments.Locations[ClosestHouse].coords.enter.z, '~g~E~w~ - Enter Apartment')
                        if IsControlJustPressed(0, 38) then -- E
                            XZCore.Functions.TriggerCallback('apartments:GetOwnedApartment', function(result)
                                if result ~= nil then
                                    EnterApartment(ClosestHouse, result.name)
                                end
                            end)
                        end
                    end
                elseif not IsOwned then
                    if entrance < 1.2 then
                        DrawText3Ds(Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y, Apartments.Locations[ClosestHouse].coords.enter.z, '~g~G~w~ - Change Apartment')
                        if IsControlJustPressed(0, 47) then -- G
                            TriggerServerEvent("apartments:server:UpdateApartment", ClosestHouse)
                            IsOwned = true
                        end
                    end
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if houseObj ~= nil then
            exports['xz-interior']:DespawnInterior(houseObj, function()
                CurrentApartment = nil
                TriggerEvent('xz-weathersync:client:EnableSync')
                DoScreenFadeIn(500)
                while not IsScreenFadedOut() do
                    Citizen.Wait(10)
                end
                SetEntityCoords(PlayerPedId(), Apartments.Locations[ClosestHouse].coords.enter.x, Apartments.Locations[ClosestHouse].coords.enter.y,Apartments.Locations[ClosestHouse].coords.enter.z)
                SetEntityHeading(PlayerPedId(), Apartments.Locations[ClosestHouse].coords.enter.w)
                Citizen.Wait(1000)
                InApartment = false
                DoScreenFadeIn(1000)
            end)
        end
    end
end)

RegisterNetEvent('apartments:client:setupSpawnUI', function(cData)
    XZCore.Functions.TriggerCallback('apartments:GetOwnedApartment', function(result)
        if result ~= nil then
            TriggerEvent('xz-spawn:client:setupSpawns', cData, false, nil)
            TriggerEvent('xz-spawn:client:openUI', true)
            TriggerEvent("apartments:client:SetHomeBlip", result.type)
        else
            TriggerEvent('xz-spawn:client:setupSpawns', cData, true, Apartments.Locations)
            TriggerEvent('xz-spawn:client:openUI', true)
        end
    end, cData.citizenid)
end)

RegisterNetEvent('XZCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('XZCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
    CurrentApartment = nil
    InApartment = false
    CurrentOffset = 0
end)

RegisterNetEvent('apartments:client:SpawnInApartment', function(apartmentId, apartment)
    if rangDoorbell ~= nil then
        local dist = #(pos - Apartments.Locations[rangDoorbell].coords.enter)
        if dist > 5 then
            return
        end
    end
    ClosestHouse = apartment
    EnterApartment(apartment, apartmentId, true)
    IsOwned = true
end)

RegisterNetEvent('xz-apartments:client:LastLocationHouse', function(apartmentType, apartmentId)
    ClosestHouse = apartmentType
    EnterApartment(apartmentType, apartmentId, false)
end)

RegisterNetEvent('apartments:client:SetHomeBlip', function(home)
    Citizen.CreateThread(function()
        SetClosestApartment()
        for name, apartment in pairs(Apartments.Locations) do
            RemoveBlip(Apartments.Locations[name].blip)

            Apartments.Locations[name].blip = AddBlipForCoord(Apartments.Locations[name].coords.enter.x, Apartments.Locations[name].coords.enter.y, Apartments.Locations[name].coords.enter.z)
            if (name == home) then
                SetBlipSprite(Apartments.Locations[name].blip, 475)
            else
                SetBlipSprite(Apartments.Locations[name].blip, 476)
            end
            SetBlipDisplay(Apartments.Locations[name].blip, 4)
            SetBlipScale(Apartments.Locations[name].blip, 0.65)
            SetBlipAsShortRange(Apartments.Locations[name].blip, true)
            SetBlipColour(Apartments.Locations[name].blip, 3)
    
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(Apartments.Locations[name].label)
            EndTextCommandSetBlipName(Apartments.Locations[name].blip)
        end
    end)
end)

RegisterNetEvent('apartments:client:RingDoor', function(player, house)
    CurrentDoorBell = player
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
    XZCore.Functions.Notify("Someone Is At The Door!")
end)


function EnterApartment(house, apartmentId, new)
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
    openHouseAnim()
    TriggerServerEvent("xz-apartments:enterBucket")
    Citizen.Wait(250)
    XZCore.Functions.TriggerCallback('apartments:GetApartmentOffset', function(offset)
        if offset == nil or offset == 0 then
            XZCore.Functions.TriggerCallback('apartments:GetApartmentOffsetNewOffset', function(newoffset)
                if newoffset > 230 then
                    newoffset = 210
                end
                CurrentOffset = newoffset
                TriggerServerEvent("apartments:server:AddObject", apartmentId, house, CurrentOffset)
                
                local coords = { x = Apartments.Locations[house].coords.enter.x, y = Apartments.Locations[house].coords.enter.y, z = Apartments.Locations[house].coords.enter.z - CurrentOffset}
                data = exports['xz-interior']:CreateApartmentFurnished(coords)
                Citizen.Wait(100)
                houseObj = data[1]
                POIOffsets = data[2]

                InApartment = true
                CurrentApartment = apartmentId
                ClosestHouse = house
                rangDoorbell = nil
                
                Citizen.Wait(500)
                SetRainLevel(0.0)
                TriggerEvent('xz-weathersync:client:DisableSync')
                Citizen.Wait(100)
                SetWeatherTypePersist('EXTRASUNNY')
                SetWeatherTypeNow('EXTRASUNNY')
                SetWeatherTypeNowPersist('EXTRASUNNY')
                NetworkOverrideClockTime(23, 0, 0)
                TriggerServerEvent('xz-apartments:server:SetInsideMeta', house, apartmentId, true)
                

                TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
                TriggerServerEvent("XZCore:Server:SetMetaData", "currentapartment", CurrentApartment)
            end, house)
        else
            if offset > 230 then
                offset = 210
            end
            CurrentOffset = offset
            TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
            TriggerServerEvent("apartments:server:AddObject", apartmentId, house, CurrentOffset)
            local coords = { x = Apartments.Locations[ClosestHouse].coords.enter.x, y = Apartments.Locations[ClosestHouse].coords.enter.y, z = Apartments.Locations[ClosestHouse].coords.enter.z - CurrentOffset}
            data = exports['xz-interior']:CreateApartmentFurnished(coords)
            
            Citizen.Wait(100)
            houseObj = data[1]
            POIOffsets = data[2]

            InApartment = true
            CurrentApartment = apartmentId
            
            Citizen.Wait(500)
            SetRainLevel(0.0)
            TriggerEvent('xz-weathersync:client:DisableSync')
            Citizen.Wait(100)
            SetWeatherTypePersist('EXTRASUNNY')
            SetWeatherTypeNow('EXTRASUNNY')
            SetWeatherTypeNowPersist('EXTRASUNNY')
            NetworkOverrideClockTime(23, 0, 0)

            TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
            TriggerServerEvent("XZCore:Server:SetMetaData", "currentapartment", CurrentApartment)
        end
        if new ~= nil then
            if new then
                TriggerEvent('xz-interior:client:SetNewState', true)
            else
                TriggerEvent('xz-interior:client:SetNewState', false)
            end
        else
            TriggerEvent('xz-interior:client:SetNewState', false)
        end
    end, apartmentId)
end

function LeaveApartment(house)
    --TriggerEvent('instances:client:LeaveInstance')
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_open", 0.1)
    openHouseAnim()
    TriggerServerEvent("xz-apartments:returnBucket")
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do
        Citizen.Wait(10)
    end
    exports['xz-interior']:DespawnInterior(houseObj, function()
        TriggerEvent('xz-weathersync:client:EnableSync')
        SetEntityCoords(PlayerPedId(), Apartments.Locations[house].coords.enter.x, Apartments.Locations[house].coords.enter.y,Apartments.Locations[house].coords.enter.z)
        SetEntityHeading(PlayerPedId(), Apartments.Locations[house].coords.enter.w)
        Citizen.Wait(1000)
        TriggerServerEvent("apartments:server:RemoveObject", CurrentApartment, house)
        TriggerServerEvent('xz-apartments:server:SetInsideMeta', CurrentApartment, false)
        CurrentApartment = nil
        InApartment = false
        CurrentOffset = 0
        DoScreenFadeIn(1000)
        TriggerServerEvent("InteractSound_SV:PlayOnSource", "houses_door_close", 0.1)
        TriggerServerEvent("XZCore:Server:SetMetaData", "currentapartment", nil)
    end)
end

function SetClosestApartment()
    local pos = GetEntityCoords(PlayerPedId())
    local current = nil
    local dist = nil

    for id, house in pairs(Apartments.Locations) do
        local distcheck = #(pos - vector3(Apartments.Locations[id].coords.enter.x, Apartments.Locations[id].coords.enter.y, Apartments.Locations[id].coords.enter.z))
        if current ~= nil then
            if distcheck < dist then
                current = id
                dist = distcheck
            end
        else
            dist = distcheck
            current = id
        end
    end
    if current ~= ClosestHouse and isLoggedIn and not InApartment then
        ClosestHouse = current
        XZCore.Functions.TriggerCallback('apartments:IsOwner', function(result)
            IsOwned = result
        end, ClosestHouse)
    end
end

function openHouseAnim()
    loadAnimDict("anim@heists@keycard@") 
    TaskPlayAnim( PlayerPedId(), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Citizen.Wait(400)
    ClearPedTasks(PlayerPedId())
end

function MenuOwners()
    ped = PlayerPedId();
    MenuTitle = "Owners"
    ClearMenu()
    Menu.addButton("Ring the doorbell", "OwnerList", nil)
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

function OwnerList()
    XZCore.Functions.TriggerCallback('apartments:GetAvailableApartments', function(apartments)
        ped = PlayerPedId();
        MenuTitle = "Rang the door at: "
        ClearMenu()

        if apartments == nil then
            XZCore.Functions.Notify("There is nobody home..", "error", 3500)
            closeMenuFull()
        else
            for k, v in pairs(apartments) do
                Menu.addButton(v, "RingDoor", k) 
            end
        end
        Menu.addButton("Back", "MenuOwners",nil)
    end, ClosestHouse)
end

function RingDoor(apartmentId)
    rangDoorbell = ClosestHouse
    TriggerServerEvent("InteractSound_SV:PlayOnSource", "doorbell", 0.1)
    TriggerServerEvent("apartments:server:RingDoor", apartmentId, ClosestHouse)
end

function MenuOutfits()
    ped = PlayerPedId();
    MenuTitle = "Outfits"
    ClearMenu()
    Menu.addButton("My Outfits", "OutfitsLijst", nil)
    Menu.addButton("Close Menu", "closeMenuFull", nil) 
end

function changeOutfit()
	Wait(200)
    loadAnimDict("clothingshirt")    	
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "try_shirt_positive_d", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
	Wait(3100)
	TaskPlayAnim(PlayerPedId(), "clothingshirt", "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
end

function OutfitsLijst()
    XZCore.Functions.TriggerCallback('apartments:GetOutfits', function(outfits)
        ped = PlayerPedId();
        MenuTitle = "My Outfits :"
        ClearMenu()

        if outfits == nil then
            XZCore.Functions.Notify("You didnt save any outfits...", "error", 3500)
            closeMenuFull()
        else
            for k, v in pairs(outfits) do
                Menu.addButton(outfits[k].outfitname, "optionMenu", outfits[k]) 
            end
        end
        Menu.addButton("Back", "MenuOutfits",nil)
    end)
end

function optionMenu(outfitData)
    ped = PlayerPedId();
    MenuTitle = "What now?"
    ClearMenu()

    Menu.addButton("Choose Outfit", "selectOutfit", outfitData) 
    Menu.addButton("Delete Outfit", "removeOutfit", outfitData) 
    Menu.addButton("Back", "OutfitsLijst",nil)
end

function selectOutfit(oData)
    TriggerServerEvent('clothes:selectOutfit', oData.model, oData.skin)
    XZCore.Functions.Notify(oData.outfitname.." chosen", "success", 2500)
    closeMenuFull()
    changeOutfit()
end

function removeOutfit(oData)
    TriggerServerEvent('clothes:removeOutfit', oData.outfitname)
    XZCore.Functions.Notify(oData.outfitname.." has been deleted", "success", 2500)
    closeMenuFull()
end

function closeMenuFull()
    Menu.hidden = true
    currentGarage = nil
    ClearMenu()
end

function ClearMenu()
	--Menu = {}
	Menu.GUI = {}
	Menu.buttonCount = 0
	Menu.selection = 0
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function DrawText3Ds(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    if onScreen then
      SetTextScale(0.30, 0.30)
      SetTextFont(4)
      SetTextProportional(1)
      SetTextColour(255, 255, 255, 215)
      SetTextEntry("STRING")
      SetTextCentre(1)
      AddTextComponentString(text)
      DrawText(_x,_y)
      local factor = (string.len(text)) / 370
      DrawRect(_x,_y+0.0120, factor, 0.026, 41, 11, 41, 68)
    end
end

