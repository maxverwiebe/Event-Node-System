local function GetFileFriendyName(name)
    name = string.lower(name)
    name = string.Replace(name, " ", "_")

    return name
end

net.Receive("EventAutomation.Nodes.SendMessage", function()
    local prefixColor = net.ReadColor()
    local prefix = net.ReadString()
    local msgColor = net.ReadColor()
    local msg = net.ReadString()

    print(prefixColor)

    chat.AddText(prefixColor, prefix, Color(90,90,90)," » ", msgColor, msg)
end)

net.Receive("EventAutomation.OptionStarted.TriggerClient", function()
    local nodeID = net.ReadString()
    local attributeData = net.ReadTable()

    local node = EventAutomation:GetOption(nodeID)
    if not node then return end

    node:Execute(attributeData)
end)

net.Receive("EventAutomation.GetCollectionNodeMap", function(len, ply)
    local id = net.ReadString()
    local nodemap = net.ReadString()
    local filename = GetFileFriendyName(id)

    file.CreateDir("summes_eventautomation")
    file.CreateDir("summes_eventautomation/nodemaps")
    file.CreateDir("summes_eventautomation/nodemaps/temp")
    file.Write("summes_eventautomation/nodemaps/temp/"..filename..".json", nodemap)

    SummeLibrary:Notify("success", "Nodemap downloaded", "The nodemap has been downloaded to garrysmod/data/summes_eventautomation/nodemaps/temp/"..filename..".json")

    EventAutomation:NodeMap({
        collectionID = id,
    })
    EventAutomation.NodeMapPnl:ImportNodeMap("summes_eventautomation/nodemaps/temp/"..filename..".json")
end)