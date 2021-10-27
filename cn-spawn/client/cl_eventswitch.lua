function Login.playerLoaded() end

function Login.characterLoaded()
    print("characterLoaded")
    TriggerServerEvent('character:loadspawns')
    TriggerServerEvent('esx:onPlayerSpawn')
    TriggerEvent('esx:onPlayerSpawn')
    TriggerEvent('playerSpawned')
    TriggerEvent('esx:restoreLoadout')
end

function Login.characterSpawned()

    isNear = false
    
    if Spawn.isNew then
        Wait(1000)
        --Todo When New Spawn
        
    end
    SetPedMaxHealth(PlayerPedId(), 200)
    SetPlayerMaxArmour(PlayerId(), 60)
    
    runGameplay()
    Spawn.isNew = false
end
RegisterNetEvent("cn-spawn:characterSpawned");
AddEventHandler("cn-spawn:characterSpawned", Login.characterSpawned);
