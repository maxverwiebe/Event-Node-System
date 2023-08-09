TOOL.Category = "EventAutomation"
TOOL.Name = "Position Copier"
TOOL.Command = nil
TOOL.ConfigName = nil
 
if CLIENT then
    language.Add("Tool.eventautomation_pos.name", "EVENTAUTOMATION")
    language.Add("Tool.eventautomation_pos.desc", "Make an entity permanent, which reappears on the map after every server restart and map change.")
    language.Add("Tool.eventautomation_pos.0", "Left click: Make entity permanent | Right click: Remove permanent status | Reload: Open perma prop information")
    language.Add("eventautomation_pos", "Left click: Make entity permanent | Right click: Remove permanent status | Reload: Open perma prop information")

end

function TOOL:LeftClick(trace)
    if not IsFirstTimePredicted() then return false end

    if CLIENT then
        local hitPos = trace.HitPos

        print(trace.HitPos)
    end

    return true
end
 
function TOOL:RightClick(trace)
    if not IsFirstTimePredicted() then return false end

    if CLIENT then
        
        if not IsValid(EventAutomation.OptionMenuPnl) or not IsValid(EventAutomation.NodeMapPnl) then return end

        if EventAutomation.SetTask == "POSITION" then
            local hitPos = trace.HitPos

            EventAutomation.PosClipboard = hitPos
    
            EventAutomation.OptionMenuPnl:SetMouseInputEnabled(true)
            EventAutomation.OptionMenuPnl:SetKeyBoardInputEnabled(true)
            EventAutomation.OptionMenuPnl:AlphaTo(255, .5, 0)
            EventAutomation.NodeMapPnl:SetMouseInputEnabled(true)
            EventAutomation.NodeMapPnl:SetKeyBoardInputEnabled(true)
            EventAutomation.NodeMapPnl:AlphaTo(255, .5, 0)
    
            EventAutomation.OptionMenuPnl:Return()
            
            return true
        end

        if EventAutomation.SetTask == "ENTITY" then
            local hitEnt = trace.Entity

            print(tostring(hitEnt))

            --net.Start("EventAutomation.GetMapCreationID")
            --net.WriteEntity(hitEnt)
            --net.SendToServer()

            EventAutomation.PosClipboard = hitEnt:EntIndex()

            EventAutomation.OptionMenuPnl:SetMouseInputEnabled(true)
            EventAutomation.OptionMenuPnl:SetKeyBoardInputEnabled(true)
            EventAutomation.OptionMenuPnl:AlphaTo(255, .5, 0)
            EventAutomation.NodeMapPnl:SetMouseInputEnabled(true)
            EventAutomation.NodeMapPnl:SetKeyBoardInputEnabled(true)
            EventAutomation.NodeMapPnl:AlphaTo(255, .5, 0)
    
            EventAutomation.OptionMenuPnl:Return()
        end
    end

    if EventAutomation.SetTask == "PLAYER_VECTOR_ANGLE" then
        local pos, ang = LocalPlayer():GetPos(), LocalPlayer():GetAngles()

        --net.Start("EventAutomation.GetMapCreationID")
        --net.WriteEntity(hitEnt)
        --net.SendToServer()

        EventAutomation.PosClipboard = vectorAngleToString(pos, ang)

        EventAutomation.OptionMenuPnl:SetMouseInputEnabled(true)
        EventAutomation.OptionMenuPnl:SetKeyBoardInputEnabled(true)
        EventAutomation.OptionMenuPnl:AlphaTo(255, .5, 0)
        EventAutomation.NodeMapPnl:SetMouseInputEnabled(true)
        EventAutomation.NodeMapPnl:SetKeyBoardInputEnabled(true)
        EventAutomation.NodeMapPnl:AlphaTo(255, .5, 0)

        EventAutomation.OptionMenuPnl:Return()
    end

    return true
end

if CLIENT then
    net.Receive("EventAutomation.GetMapCreationID", function()
        local id = net.ReadString()
        EventAutomation.PosClipboard = id

        print(id)
        EventAutomation.OptionMenuPnl:SetMouseInputEnabled(true)
        EventAutomation.OptionMenuPnl:SetKeyBoardInputEnabled(true)
        EventAutomation.OptionMenuPnl:AlphaTo(255, .5, 0)
        EventAutomation.NodeMapPnl:SetMouseInputEnabled(true)
        EventAutomation.NodeMapPnl:SetKeyBoardInputEnabled(true)
        EventAutomation.NodeMapPnl:AlphaTo(255, .5, 0)

        EventAutomation.OptionMenuPnl:Return()
    end)

    SummeLibrary:CreateFont("EventAutomation.TaskHUD", ScrH() * .05, 500, false)
    SummeLibrary:CreateFont("EventAutomation.TaskHUDS", ScrH() * .03, 500, false)
    function TOOL:DrawHUD()
        draw.SimpleText(EventAutomation.SetTask or "NOTHING", "EventAutomation.TaskHUD", ScrW() * .5, ScrH() * .8, Color(255,255,0), TEXT_ALIGN_CENTER)
        draw.SimpleText("PRESS 'RELOAD' (R) TO RETURN", "EventAutomation.TaskHUDS", ScrW() * .5, ScrH() * .85, Color(204,0,255), TEXT_ALIGN_CENTER)
    end

    function TOOL:Think()
        if gui.IsGameUIVisible() and input.IsKeyDown(KEY_R) then
            EventAutomation.OptionMenuPnl:SetMouseInputEnabled(true)
            EventAutomation.OptionMenuPnl:SetKeyBoardInputEnabled(true)
            EventAutomation.OptionMenuPnl:AlphaTo(255, .5, 0)
            EventAutomation.NodeMapPnl:SetMouseInputEnabled(true)
            EventAutomation.NodeMapPnl:SetKeyBoardInputEnabled(true)
            EventAutomation.NodeMapPnl:AlphaTo(255, .5, 0)

            EventAutomation.OptionMenuPnl:Return()
        end
    end
end