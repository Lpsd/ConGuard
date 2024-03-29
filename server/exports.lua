function cg_call(dimension, method, ...)
    dimension = tonumber(dimension)

    if (not ConGuardInstances[dimension]) then
        return false
    end

    if (not ConGuardInstances[dimension][method]) then
        return false
    end

    return ConGuardInstances[dimension][method](ConGuardInstances[dimension], ...)
end

-- *********************************************

function createConnectionGuard(dimension, settings)
    dimension = tonumber(dimension)

    if (not dimension) then
        return false
    end

    local instance = ConGuard:new(dimension, settings)
    return instance
end

function destroyConnectionGuard(dimension)
    return cg_call(dimension, "delete")
end

function setConnectionGuardEnabled(dimension, state)
    return cg_call(dimension, "setEnabled", state)
end

function setConnectionGuardSetting(dimension, setting, value)
    return cg_call(dimension, "setSetting", setting, value)
end

function getConnectionGuardSetting(dimension, setting)
    return cg_call(dimension, "getSetting", setting)
end
