DEBUG = true
ConGuardInstances = {}

function init()
    if (SERVER) then
        addEvent("onPlayerNetworkTimeout", true)
        addEvent("onPlayerNetworkInterruptionLimitReached", true)

        addEventHandler(
            "onPlayerResourceStart",
            root,
            function(resource)
                if (getResourceRootElement(resource) == resourceRoot) then
                    addPlayer(source)
                end
            end
        )
        addEventHandler("onPlayerLeave", root, removePlayer)

        local import = importDefaultSettings()

        if (import ~= true) then
            iprintd("[ConGuard] Failed to launch", import)
            return cancelEvent()
        end

        iprintd("[ConGuard] Launched successfully...")
    end

    if (CLIENT) then
        addEvent("onConGuardCreated", true)
        addEvent("onConGuardDestroyed", true)
        addEvent("onConGuardSettingChange", true)
        addEvent("onConGuardSyncAll", true)

        addEvent("onClientPlayerConnectionStatus", true)
        addEventHandler("onClientPlayerConnectionStatus", resourceRoot, setPlayerConnectionStatus)

        addEventHandler("onConGuardCreated", resourceRoot, onCreated)
        addEventHandler("onConGuardDestroyed", resourceRoot, onDestroyed)
        addEventHandler("onConGuardSettingChange", resourceRoot, onSettingChange)
        addEventHandler("onConGuardSyncAll", resourceRoot, onSyncAll)

        addEventHandler("onClientElementStreamIn", root, registerStreamedInPlayer)
        addEventHandler("onClientElementStreamOut", root, unregisterStreamedInPlayer)

        addEventHandler("onClientRender", root, renderLostConnectionImages)

        initializeStreamedInPlayers()
    end
end
addEventHandler(SERVER and "onResourceStart" or "onClientResourceStart", resourceRoot, init)
