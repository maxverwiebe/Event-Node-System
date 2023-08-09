EventAutomation.NodeMeta = EventAutomation.NodeMeta or {}
EventAutomation.NodeMeta.__index = EventAutomation.NodeMeta or {}

EventAutomation.Options = EventAutomation.Options or {}
EventAutomation.OptionCategories = EventAutomation.OptionCategories or {}

function EventAutomation:RegisterNewOption(id)
    EventAutomation.Options[id] = {id = id, name = "n/A", color = Color(103,103,103), attributes = {},}
    setmetatable(EventAutomation.Options[id], EventAutomation.NodeMeta)

    SummeLibrary:Success("eventsystem", "Created option node "..id)

    return EventAutomation.Options[id]
end

function EventAutomation:GetOption(id)
    return EventAutomation.Options[id] or false
end

function EventAutomation.NodeMeta:SetName(name)
    self.name = name

    self.desc = "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea"

    return self
end

function EventAutomation.NodeMeta:SetDescription(desc)
    self.desc = desc

    return self
end

function EventAutomation.NodeMeta:SetColor(color)
    self.color = color

    return self
end

function EventAutomation.NodeMeta:RestrictAdmin(value)
    self.adminOnly = value

    return self
end

function EventAutomation.NodeMeta:SetCategory(category)
    self.category = category

    EventAutomation.OptionCategories[category] = true

    return self
end

function EventAutomation.NodeMeta:AddAttribute(type, id, default, required, sort, data)
    local _ = {}
    _.type = type
    _.default = default
    _.required = required
    _.sort = sort or 1
    _.data = data

    self.attributes[id] = _

    return self
end

function EventAutomation.NodeMeta:GetAttribute(id)
    return self.attributes[id] or false
end

function EventAutomation.NodeMeta:SetServerCallback(func)
    self.SVCallback = func

    return self
end

function EventAutomation.NodeMeta:TriggerClientside(bool)
    self.sendToClient = bool

    return self
end

function EventAutomation.NodeMeta:SetClientCallback(func)
    self.CLCallback = func

    return self
end

function EventAutomation.NodeMeta:Execute(attributeData)
    SummeLibrary:Success("eventsystem", "Running option node "..self.id)

    if SERVER then
        self.SVCallback(attributeData)

        if self.sendToClient then
            net.Start("EventAutomation.OptionStarted.TriggerClient")
            net.WriteString(self.id)
            net.WriteTable(attributeData)
            net.Broadcast()
        end
        -- TELL EVERY CLIENT TO EXECUTE IT WIP TODO
        return
    end

    if CLIENT then
        self.CLCallback(attributeData)
        return
    end

    return self
end