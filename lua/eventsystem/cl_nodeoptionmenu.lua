local passiveFrames = {}
local isPassive = false
EventAutomation.SetTask = false

function EventAutomation:TurnPassive()
    EventAutomation.OptionMenuPnl:SetMouseInputEnabled(false)
    EventAutomation.OptionMenuPnl:SetKeyBoardInputEnabled(false)
    EventAutomation.OptionMenuPnl:AlphaTo(0, .5, 0)
    EventAutomation.NodeMapPnl:SetMouseInputEnabled(false)
    EventAutomation.NodeMapPnl:SetKeyBoardInputEnabled(false)
    EventAutomation.NodeMapPnl:AlphaTo(0, .5, 0)

    RunConsoleCommand("use", "gmod_tool")

    spawnmenu.ActivateTool("eventautomation_pos")
end

local theme = {
    bg = Color(27,27,27,250),
    bgSec = Color(48,48,48,203),
    navButton = Color(34,34,34),
    navButtonH = Color(39,39,39),
    primary = Color(21,180,29),
    grey = Color(168,168,168)
}

SummeLibrary:CreateFont("EventAutomation.NodeMenuTitle", ScrH()/35, 700, false)
SummeLibrary:CreateFont("EventAutomation.NodeMenuAttTitle", ScrH()/50, 700, false)

function EventAutomation:OptionMenu(id, btn)
    local option = EventAutomation:GetOption(id)
    if not option then print("Option Not Found") return end

    if IsValid(EventAutomation.OptionMenuPnl) then EventAutomation.OptionMenuPnl:Remove() end

    local existingAttData = false

    if btn and IsValid(btn) and btn.attributeData then
        existingAttData = btn.attributeData
    end

    EventAutomation.OptionMenuPnl = vgui.Create("DFrame")
    EventAutomation.OptionMenuPnl:SetSize(ScrW() * .18, ScrH() * .6)
    EventAutomation.OptionMenuPnl:ShowCloseButton(false)
    EventAutomation.OptionMenuPnl:Center()
    EventAutomation.OptionMenuPnl:MakePopup()
    EventAutomation.OptionMenuPnl:SetTitle("")
    EventAutomation.OptionMenuPnl:SetBackgroundBlur(false)
    EventAutomation.OptionMenuPnl:MoveTo(ScrW() * .815, ScrH() * .075, .3)
    EventAutomation.OptionMenuPnl.Paint = function(me,w,h)
        local x, y = me:LocalToScreen()

        BSHADOWS.BeginShadow()
        draw.RoundedBox(20, x, y, w, h, theme.bg)
        BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)

        local x1 = draw.SimpleText("NODE CONFIGURATION", "EventAutomation.NodeMenuTitle", w * .035, h * .015, theme.primary, TEXT_ALIGN_LEFT)

        --draw.RoundedBox(0, w * .33, h * .045, w * .59, h * .002, theme.grey)
    end

    EventAutomation.CloseButton = vgui.Create("SummeLibrary.CloseButton", EventAutomation.OptionMenuPnl)
    EventAutomation.CloseButton:SetPos(ScrW() * .16, ScrH() * .01)
    EventAutomation.CloseButton:SetSize(ScrH() * .025, ScrH() * .025)
    EventAutomation.CloseButton:SetUp(function()
        EventAutomation.OptionMenuPnl:Remove()
    end)

    local scroll = vgui.Create("DScrollPanel", EventAutomation.OptionMenuPnl)
    scroll:DockMargin(ScrW() * .0035, ScrW() * .005, ScrW() * .0035, 0)
    scroll:Dock(FILL)
    local sbar = scroll:GetVBar()
    function sbar:Paint(w, h)
        --draw.RoundedBox(5, 0, 0, w * .8, h, Color(0, 0, 0, 100))
    end
    function sbar.btnUp:Paint(w, h)
        --draw.RoundedBox(0, 0, 0, w * .5, h, Color(36, 173, 216))
    end
    function sbar.btnDown:Paint(w, h)
        --draw.RoundedBox(0, 0, 0, w * .5, h, Color(36, 173, 216))
    end
    function sbar.btnGrip:Paint(w, h)
        draw.RoundedBox(5, w * .1, 0, w * .5, h, Color(189, 189, 189))
    end

    local valueEntry = {}

    function EventAutomation.OptionMenuPnl:Return()
        EventAutomation.SetTask = false
        valueEntry[EventAutomation.AttClipboard]:SetText(tostring(EventAutomation.PosClipboard))
    end

    for k, attribute in SortedPairsByMemberValue(option.attributes, "sort") do
        local titleExt = ""
        if attribute.required then
            titleExt = " *"
        end

        local DLabel = vgui.Create("DLabel", scroll)
        DLabel:Dock(TOP)
        DLabel:DockMargin(0, ScrH() * .01, 0, 0)
        DLabel:SetText(k..titleExt)
        DLabel:SetFont("EventAutomation.NodeMenuAttTitle")

        local validDatatype = false

        if attribute.type == "vector" then
            local pnl = vgui.Create("DPanel", scroll)
            pnl:Dock(TOP)
            pnl:SetDrawBackground(false)

            valueEntry[k] = vgui.Create("DTextEntry", pnl)
            valueEntry[k]:Dock(FILL)
            valueEntry[k]:SetText(tostring(attribute.default))
            valueEntry[k].isRequired = attribute.required
            validDatatype = true

            local selectVecBtn = EventAutomation:CreateButton(pnl)
            selectVecBtn:Dock(RIGHT)
            selectVecBtn:SetSize(ScrW() * .03, 0)
            selectVecBtn:SetText("* * *")
            function selectVecBtn:DoClick()
                --local plyPos = LocalPlayer():GetPos() + Vector(0, 0, 80)
                --valueEntry[k]:SetText(tostring(plyPos))

                EventAutomation.AttClipboard = k
                EventAutomation.SetTask = "POSITION"

                EventAutomation:TurnPassive(scroll)
            end

            if existingAttData and existingAttData[k] then
                valueEntry[k]:SetText(tostring(existingAttData[k]))
            end
        end

        if attribute.type == "entity" then
            local pnl = vgui.Create("DPanel", scroll)
            pnl:Dock(TOP)

            valueEntry[k] = vgui.Create("DTextEntry", pnl)
            valueEntry[k]:Dock(FILL)
            valueEntry[k]:SetText(tostring(attribute.default))
            valueEntry[k].isRequired = attribute.required
            validDatatype = true

            local selectVecBtn = EventAutomation:CreateButton(pnl)
            selectVecBtn:Dock(RIGHT)
            selectVecBtn:SetSize(ScrW() * .03, 0)
            selectVecBtn:SetText("* * *")
            function selectVecBtn:DoClick()
                --local plyPos = LocalPlayer():GetPos() + Vector(0, 0, 80)
                --valueEntry[k]:SetText(tostring(plyPos))

                EventAutomation.AttClipboard = k
                EventAutomation.SetTask = "ENTITY"

                EventAutomation:TurnPassive(scroll)
            end

            if existingAttData and existingAttData[k] then
                valueEntry[k]:SetText(tostring(existingAttData[k]))
            end
        end

        if attribute.type == "player_vector_angle" then
            local pnl = vgui.Create("DPanel", scroll)
            pnl:Dock(TOP)
            pnl:SetDrawBackground(false)

            valueEntry[k] = vgui.Create("DTextEntry", pnl)
            valueEntry[k]:Dock(FILL)
            valueEntry[k]:SetText(tostring(attribute.default))
            valueEntry[k].isRequired = attribute.required
            validDatatype = true

            local selectVecBtn = EventAutomation:CreateButton(pnl)
            selectVecBtn:Dock(RIGHT)
            selectVecBtn:SetSize(ScrW() * .03, 0)
            selectVecBtn:SetText("* * *")
            function selectVecBtn:DoClick()
                --local plyPos = LocalPlayer():GetPos() + Vector(0, 0, 80)
                --valueEntry[k]:SetText(tostring(plyPos))

                EventAutomation.AttClipboard = k
                EventAutomation.SetTask = "PLAYER_VECTOR_ANGLE"

                EventAutomation:TurnPassive(scroll)
            end

            print(existingAttData[k])

            if existingAttData and existingAttData[k] then
                valueEntry[k]:SetText(tostring(existingAttData[k]))
            end
        end

        if attribute.type == "string" then
            valueEntry[k] = vgui.Create("SummeLibrary.TextEntry", scroll)
            valueEntry[k]:Dock(TOP)
            valueEntry[k]:SetText(attribute.default)
            valueEntry[k].isRequired = attribute.required
            validDatatype = true

            if existingAttData and existingAttData[k] then
                valueEntry[k]:SetText(existingAttData[k])
            end
        end

        if attribute.type == "dropdown" then
            valueEntry[k] = vgui.Create("DComboBox", scroll)
            valueEntry[k]:Dock(TOP)
            valueEntry[k]:SetValue(attribute.default)
            valueEntry[k].isRequired = attribute.required
            validDatatype = true

            for _, v in pairs(attribute.data.comboChoices) do
                valueEntry[k]:AddChoice(v)
            end

            if existingAttData and existingAttData[k] then
                valueEntry[k]:SetValue(existingAttData[k])
            end
        end

        if attribute.type == "number" then
            valueEntry[k] = vgui.Create("DNumberWang", scroll)
            valueEntry[k]:Dock(TOP)
            valueEntry[k]:SetMin(-100000)
            valueEntry[k]:SetMax(100000)
            valueEntry[k]:SetValue(attribute.default)
            valueEntry[k].isRequired = attribute.required
            validDatatype = true

            if existingAttData and existingAttData[k] then
                valueEntry[k]:SetValue(existingAttData[k])
            end
        end

        if attribute.type == "color" then
            valueEntry[k] = vgui.Create("DColorMixer", scroll)
            valueEntry[k]:Dock(TOP)
            valueEntry[k]:SetPalette(true)
            valueEntry[k]:SetWangs(true)
            valueEntry[k]:SetColor(attribute.default)
            valueEntry[k].isRequired = attribute.required
            validDatatype = true
            valueEntry[k]:SetSize(0, ScrH() * .15)

            if existingAttData and existingAttData[k] then
                valueEntry[k]:SetColor(existingAttData[k])
            end
        end

        if attribute.type == "bool" then
            --[[valueEntry[k] = vgui.Create("DComboBox", scroll)
            valueEntry[k]:Dock(TOP)
            valueEntry[k]:SetValue(tostring(attribute.default))
            valueEntry[k]:AddChoice("true")
            valueEntry[k]:AddChoice("false")
            valueEntry[k].isRequired = attribute.required
            validDatatype = true

            if existingAttData and existingAttData[k] then
                valueEntry[k]:SetValue(tostring(existingAttData[k]))
            end]]--

            valueEntry[k] = vgui.Create("DButton", scroll)
            valueEntry[k]:Dock(TOP)
            valueEntry[k]:SetSize(ScrW() * .1, ScrH() * .03)
            valueEntry[k]:SetText("")
            valueEntry[k].PolationStatus = 0
            valueEntry[k].NormalColor = Color(158, 158, 158, 0)
            valueEntry[k].Status = false
            validDatatype = true
            valueEntry[k].Paint = function(self, w, h)
                local bgCol = Color(158, 158, 158, 0)
                if self:IsHovered() then
                    bgCol = Color(160, 160, 160, 40)
                    self.PolationStatus = math.Clamp(self.PolationStatus + 10 * FrameTime(), 0, 1)
                else
                    self.PolationStatus = math.Clamp(self.PolationStatus - 10 * FrameTime(), 0, 1)
                end

                self.NormalColor = SummeLibrary:LerpColor(FrameTime() * 12, self.NormalColor, bgCol)

                draw.RoundedBox(8, 0, 0, w, h, self.NormalColor)

                surface.SetDrawColor(color_white)
                SummeLibrary:DrawImgur(w * .02, h * .1, h * .8, h * .8, valueEntry[k].Status and "ExHkfJq" or "aVmdI7R")

                draw.DrawText("Yes", "SL.TextEntry", w * .2, h * .15, SummeLibrary:GetColor("greyLight"), TEXT_ALIGN_LEFT)
            end
            valueEntry[k].Toggle = function(self)
                if self.Status then
                    self.Status = false
                else
                    self.Status = true
                end
            end
            valueEntry[k].DoClick = function(self)
                self:Toggle()
            end
            valueEntry[k].GetValue = function(self)
                return tobool(self.Status)
            end

            if existingAttData and existingAttData[k] then
                valueEntry[k].Status = existingAttData[k]
            end
        end


        if not validDatatype then
            valueEntry[k] = vgui.Create("DTextEntry", scroll)
            valueEntry[k]:Dock(TOP)
            valueEntry[k]:SetText("ERROR:   TYPE ".. attribute.type.. " NOT VALID!")
            valueEntry[k]:SetEditable(false)
            valueEntry[k]:SetTextColor(Color(255,0,0))
        end

        valueEntry[k].key = k
        --valueEntry[k]:DockMargin(0, 0, 0, ScrH() * .013)
    end

    local executeButton = EventAutomation:CreateButton(EventAutomation.OptionMenuPnl)
    executeButton:SetSize(ScrW() * .1, ScrH() * .03)
    executeButton:SetText("Apply attributes")
    executeButton:SetColor(Color(58,58,58))
    executeButton:SetHoverColor(Color(1,36,0))
    executeButton:Dock(BOTTOM)
    function executeButton:DoClick()
        local data = {}

        for k, v in SortedPairs(valueEntry) do
            local attribute = option:GetAttribute(v.key)
            local type = attribute.type

            if type == "string" then
                data[v.key] = v:GetText()
            elseif type == "entity" then
                data[v.key] = v:GetText()
            elseif type == "player_vector_angle" then
                data[v.key] = v:GetText()
            elseif type == "number" then
                data[v.key] = v:GetValue()
            elseif type == "bool" then
                data[v.key] = tobool(v:GetValue())
            elseif type == "dropdown" then
                data[v.key] = tostring(v:GetValue())
            elseif type == "color" then
                data[v.key] = v:GetColor()
            elseif type == "vector" then
                data[v.key] = util.StringToType(v:GetText(), "Vector")
            else
                data[v.key] = attribute.default
            end
        end

        if btn and IsValid(btn) then
            btn.attributeData = data
            btn:Highlight()

            EventAutomation.OptionMenuPnl:Remove()
        end

        --net.Start("EventAutomation.StartOption")
        --net.WriteString(id)
        --net.WriteTable(data)
        --net.SendToServer()
    end
end