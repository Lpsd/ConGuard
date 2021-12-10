ConGuard = inherit(Class)

-- *********************************************

function ConGuard:constructor(dimension, settings)
    self.dimension = dimension
    self.settings = settings

    return self
end

-- *********************************************

function ConGuard:setSetting(setting, value)
    self.settings[setting] = value
    return true
end

function ConGuard:getSetting(setting)
    return self.settings[setting]
end
