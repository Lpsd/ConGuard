local function create(dimension, settings)
    local instance = ConGuard:new(dimension, settings)

    if (not instance) then
        return false
    end

    if (ConGuardInstances[dimension]) and (instanceof(ConGuardInstances[dimension], Class, true)) then
        ConGuardInstances[dimension]:delete()
        ConGuardInstances[dimension] = nil
    end

    ConGuardInstances[dimension] = instance
    return instance
end

function onSyncAll(items)
    for i, item in ipairs(items) do
        create(item.dimension, item.settings)
    end
end

function onCreated(dimension, settings)
    create(dimension, settings)
end

function onDestroyed(dimension)
    if (not ConGuardInstances[dimension]) or (not instanceof(ConGuardInstances[dimension], Class, true)) then
        return false
    end

    ConGuardInstances[dimension]:destroy()
    ConGuardInstances[dimension] = nil
end

function onSettingChange(dimension, setting, value)
    if (not ConGuardInstances[dimension]) or (not instanceof(ConGuardInstances[dimension], Class, true)) then
        return false
    end

    ConGuardInstances[dimension]:setSetting(setting, value)
end