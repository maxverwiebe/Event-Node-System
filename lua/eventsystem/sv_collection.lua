EventAutomation.CollectionMeta = EventAutomation.CollectionMeta or {}
EventAutomation.CollectionMeta.__index = EventAutomation.CollectionMeta or {}

EventAutomation.Collections = EventAutomation.Collections or {}

local function RandomVariable(length)
	local res = ""
	for i = 1, length do
		res = res .. string.char(math.random(97, 122))
	end
	return string.upper(res)
end

local function GetFileFriendyName(name)
    name = string.lower(name)
    name = string.Replace(name, " ", "_")

    return name
end

function EventAutomation:RegisterCollection(name)
    local id = GetFileFriendyName(name).."_"..RandomVariable(7)
    EventAutomation.Collections[id] = {
        id = "",
        nodes = {},
        status = "idle",
        lastRun = 0,
        progress = 0,
    }

    EventAutomation.Collections[id].id = id

    setmetatable(EventAutomation.Collections[id], EventAutomation.CollectionMeta)

    SummeLibrary:Success("eventsystem", "Created collection "..id)

    return EventAutomation.Collections[id]
end

function EventAutomation.CollectionMeta:SetStatus(statusString)
    self.status = statusString

    return self
end

function EventAutomation.CollectionMeta:SetNodemap(json)
    print(json)
    self.nodemap = json

    return self
end

function EventAutomation.CollectionMeta:GetNodemap()
    PrintTable(self)
    return self.nodemap
end

function EventAutomation.CollectionMeta:AddNodes(nodeTable)
    self.nodes = nodeTable

    return self
end

function EventAutomation.CollectionMeta:Delete()
    EventAutomation.Collections[self.id] = nil
end

function EventAutomation.CollectionMeta:Wait(seconds)
    SummeLibrary:Success("eventsystem", "Waiting "..seconds.." seconds")

    timer.Simple(seconds, function()
        coroutine.resume(self._co)
    end)

    return self
end

function EventAutomation.CollectionMeta:SetProgress(progress)
    self.progress = progress

    return self
end

function EventAutomation.CollectionMeta:Run(callback)
    SummeLibrary:Success("eventsystem", "Running Collection ".. self.id)

    self.lastRun = CurTime()

    self._co = coroutine.create(function()
        self:SetStatus("running")

        local running = true

        timer.Simple(40, function()
            if (not self._co and running) then
                print("ERROR")
                self:SetStatus("timeout")
                timeouted = true
            end
        end)

        for k, v in SortedPairs(self.nodes) do
            self.activeNode = k
            local node = EventAutomation:GetOption(v.id)
            if not node then continue end

            self:SetProgress(k)

            if node.id == "util_timer" then
                SummeLibrary:Success("eventsystem", "Waiting "..v.attributeData["SECONDS"].." seconds")

                local co = coroutine.running() -- Coroutine-Referenz abrufen
                timer.Simple(v.attributeData["SECONDS"], function()
                    coroutine.resume(co) -- Übergeben Sie die Coroutine-Referenz als Argument
                end)
                coroutine.yield()
                continue
            else
                node:Execute(v.attributeData)
            end
        end

        self:SetProgress(0)
        self:SetStatus("idle")
        running = false
        --SummeLibrary:Success("eventsystem", "Destroying collection "..self.id)
        --EventAutomation.Collections[self.id] = nil
        --self = nil

        SummeLibrary:Success("eventsystem", "Finished")

        if callback and isfunction(callback) then callback() end
    end)

    coroutine.resume(self._co)
end

util.AddNetworkString("EventAutomation.RequestResumeCollection")

net.Receive("EventAutomation.RequestResumeCollection", function(len, ply)
    local id = net.ReadString()

    EventAutomation.Collections[id]:Run()
    EventAutomation.Collections[id].lastRunPlayer = ply:SteamID64()
end)