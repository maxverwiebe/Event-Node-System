util.AddNetworkString("EventAutomation.StartOption")
util.AddNetworkString("EventAutomation.StartCollection")
util.AddNetworkString("EventAutomation.GetMapCreationID")
util.AddNetworkString("EventAutomation.RequestCollections")
util.AddNetworkString("EventAutomation.GetCollectionNodemap")
util.AddNetworkString("EventAutomation.UpdateCollectionsNodemap")
util.AddNetworkString("EventAutomation.DeleteCollection")


util.AddNetworkString("EventAutomation.OptionStarted.TriggerClient")
util.AddNetworkString("EventAutomation.Nodes.SendMessage")


net.Receive("EventAutomation.StartOption", function(ply)
    local optionID = net.ReadString()
    local attributeData = net.ReadTable() -- TODO CHANGE IN FUTURE

    EventAutomation:StartOption(optionID, attributeData)
end)

function EventAutomation:StartOption(optionID, attributeData)
    local option = EventAutomation:GetOption(optionID)
    if not option then return end

    option:Execute(attributeData)
end

--[[net.Receive("EventAutomation.StartCollection", function(ply)
    local data = net.ReadTable()

    PrintTable(data)

    local co

    local function Wait(seconds)
        SummeLibrary:Success("eventsystem", "Waiting "..seconds.." seconds")
        timer.Simple(seconds, function()
            coroutine.resume(co)
        end)
    end

    co = coroutine.create(function()
        for k, v in SortedPairs(data) do
            local node = EventAutomation:GetOption(v.id)
            if not node then return end

            if node.id == "util_timer" then
                Wait(v.attributeData["SECONDS"])
                coroutine.yield()
                continue
            else
                node:Execute(v.attributeData)
            end
        end
    end)

    coroutine.resume(co)
end)]]--

net.Receive("EventAutomation.StartCollection", function(len, ply)
    local nodeTable = net.ReadTable()
    local nodeMap = net.ReadString() -- WIP
    local name = net.ReadString()
    local execute = net.ReadBool()
    local deleteAfterExecution = net.ReadBool()

    local collection = EventAutomation:RegisterCollection(name)
    collection:AddNodes(nodeTable)
    collection:SetNodemap(nodeMap)
    if execute then
        collection:Run(function()
            if deleteAfterExecution then collection:Delete() end
        end)
        collection.lastRunPlayer = ply:SteamID64()
    end
end)

net.Receive("EventAutomation.GetCollectionNodeMap", function(len, ply)
    local id = net.ReadString()

    local nodemap = EventAutomation.Collections[id]:GetNodemap()

    net.Start("EventAutomation.GetCollectionNodeMap")
    net.WriteString(id)
    net.WriteString(nodemap)
    net.Send(ply)
end)

net.Receive("EventAutomation.GetMapCreationID", function(len, ply)
    local ent = net.ReadEntity()
    local id = ent:GetCreationID()

    print(id)

    net.Start("EventAutomation.GetMapCreationID")
    net.WriteString(id)
    net.Send(ply)
end)

net.Receive("EventAutomation.RequestCollections", function(len, ply)
    local collections = EventAutomation.Collections

    for k, v in pairs(collections) do
        v._co = nil
    end

    net.Start("EventAutomation.RequestCollections")
    net.WriteTable(collections)
    net.Send(ply)
end)

net.Receive("EventAutomation.UpdateCollectionsNodemap", function(len, ply)
    local id = net.ReadString()
    local btnOrder = net.ReadTable()
    local nodemap = net.ReadString()

    print(nodemap)

    EventAutomation.Collections[id]:AddNodes(btnOrder)
    EventAutomation.Collections[id]:SetNodemap(nodemap)

    SummeLibrary:Notify(ply, "success", "Collection updated", "The collection has been updated with the new nodemap!")
end)

net.Receive("EventAutomation.DeleteCollection", function(len, ply)
    local id = net.ReadString()

    EventAutomation.Collections[id]:Delete()
end)