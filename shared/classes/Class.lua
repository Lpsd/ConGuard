Class = {}

function Class:new(...)
    return new(self, ...)
end

function Class:delete(...)
    return delete(self, ...)
end

-- *********************************************

function Class:virtual_constructor()
    self.events = {}
end

function Class:virtual_destructor()
    self:unregisterEvents()
end

-- *********************************************

function Class:registerEvent(eventName, attachedTo, handlerFunction, getPropagated, priority)
    if (not eventName) or (not attachedTo) or (not handlerFunction) then
        return false
    end

    if (not self.events) then
        self.events = {}
    end

    getPropagated = (getPropagated == nil) and true or getPropagated
    priority = priority or "normal"

    addEventHandler(eventName, attachedTo, handlerFunction, getPropagated, priority)

    return table.insert(
        self.events,
        {
            eventName = eventName,
            attachedTo = attachedTo,
            handlerFunction = handlerFunction
        }
    )
end

-- *********************************************

function Class:unregisterEvent(eventName, attachedTo, handlerFunction)
    local removed = false
    for i, event in ipairs(self.events) do
        if
            (event.eventName == eventName) and (event.attachedTo == attachedTo) and
                (event.handlerFunction == handlerFunction)
         then
            removed = removeEventHandler(event.eventName, event.attachedTo, event.handlerFunction)
        end
    end
    return removed
end

function Class:unregisterEvents()
    if (not self.events) or (self.eventsUnregistered) then
        return false
    end

    for i, event in ipairs(self.events) do
        removeEventHandler(event.eventName, event.attachedTo, event.handlerFunction)
    end

    self.eventsUnregistered = true
end
