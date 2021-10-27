function ESX.SpawnManagerInitialize(self)
    Citizen.CreateThread(function()

        FreezeEntityPosition(PlayerPedId(), true)

        TransitionToBlurred(500)
        DoScreenFadeOut(500)

        ShutdownLoadingScreen()

        local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)

        SetCamRot(cam, 0.0, 0.0, -45.0, 2)
        SetCamCoord(cam, -682.0, -1092.0, 226.0)
        SetCamActive(cam, true)
        RenderScriptCams(true, false, 0, true, true)

        local ped = PlayerPedId()

        SetEntityCoordsNoOffset(ped, -682.0, -1092.0, 200.0, false, false, false, true)

        SetEntityVisible(ped, false)

        DoScreenFadeIn(500)

        while IsScreenFadingIn() do
            Citizen.Wait(0)
        end

        TriggerEvent("esx:spawnInitialized")
        TriggerServerEvent("esx:spawnInitialized")

    end)
end

function ESX.SpawnManagerInitialSpawn(self)
    Citizen.CreateThread(function()
        DisableAllControlActions(0)
        DoScreenFadeOut(10)

        while IsScreenFadingOut() do
            Citizen.Wait(0)
        end

        --Tells raid clothes to set ped to correct skin
        TriggerEvent("esx:initialSpawnModelLoaded")

        local ped = PlayerPedId()

        SetEntityVisible(ped, true)
        FreezeEntityPosition(PlayerPedId(), false)
        
        ClearPedTasksImmediately(ped)
        RemoveAllPedWeapons(ped)
        --ClearPlayerWantedLevel(PlayerId())

        EnableAllControlActions(0)
        TriggerEvent("character:finishedLoadingChar")
    end)
end

AddEventHandler("esx:firstSpawn", function()
    ESX:SpawnManagerInitialSpawn()

    Citizen.CreateThread(function()
        Citizen.Wait(600)
        FreezeEntityPosition(PlayerPedId(), false)
    end)
end)