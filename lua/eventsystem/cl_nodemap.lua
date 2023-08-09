SummeLibrary:CreateFont("EventAutomation.Node", ScrH() * .015, 500, false)
SummeLibrary:CreateFont("EventAutomation.NodeID", ScrH() * .007, 500, false)

EventAutomation.CopiedAttributesClipboard = {id = "nil"}

local function formatTable(t)
    local str = "(" .. table.concat(t, ", ") .. ")"
    return str
end
  

local theme = {
    bg = Color(27,27,27,250),
    bgSec = Color(48,48,48,203),
    navButton = Color(34,34,34),
    navButtonH = Color(39,39,39),
    primary = Color(21,180,29),
    grey = Color(168,168,168),
    info = Color(252,255,47)
}

local function bezier(p0, p1, p2, p3, t)
	local e = p0 + t * (p1 - p0)
	local f = p1 + t * (p2 - p1)
	local g = p2 + t * (p3 - p2)

	local h = e + t * (f - e)
	local i = f + t * (g - f)

	local p = h + t * (i - h)

	return p
end

local function DrawBezier(startPos, endPos, color)
	local detail = 1
	local p2 = Vector(endPos.x,startPos.y,0)
	local p3 = Vector(startPos.x,endPos.y,0)

	for i = 1,detail do
		local sp = bezier(startPos, p2, p3, endPos, (i - 1) / detail)
		local ep = bezier(startPos, p2, p3, endPos, i / detail)
        surface.SetDrawColor(color)
		surface.DrawLine( sp.x, sp.y, ep.x, ep.y )
	end
end

local function DrawRoundedBezier(startPos, endPos, radius)
    local segments = 10 -- Anzahl der Teilsegmente
    local detail = 10 -- Anzahl der Schritte für die Kreisbogenapproximation
    local p2 = Vector(endPos.x, startPos.y, 0)
    local p3 = Vector(startPos.x, endPos.y, 0)

    for i = 1, segments do
        local t0 = (i - 1) / segments
        local t1 = i / segments

        -- Berechnung der Kontrollpunkte für das Quadrat
        local sqStart = bezier(startPos, p2, p3, endPos, t0)
        local sqEnd = bezier(startPos, p2, p3, endPos, t1)
        local sqDir = (sqEnd - sqStart):GetNormalized()
        local sqPerp = Vector(-sqDir.y, sqDir.x, 0)
        local sqTopLeft = sqStart + sqPerp * radius
        local sqTopRight = sqStart - sqPerp * radius
        local sqBottomLeft = sqEnd + sqPerp * radius
        local sqBottomRight = sqEnd - sqPerp * radius

        -- Zeichnen des Quadrats
        surface.DrawPoly({
            {x = sqTopLeft.x, y = sqTopLeft.y},
            {x = sqTopRight.x, y = sqTopRight.y},
            {x = sqBottomRight.x, y = sqBottomRight.y},
            {x = sqBottomLeft.x, y = sqBottomLeft.y}
        })

        -- Berechnung der Kontrollpunkte für den Kreisbogen
        local mid = (sqStart + sqEnd) / 2
        local circleCenter = mid + sqPerp * radius
        local startAngle = (sqStart - circleCenter):Angle().y - 90
        local endAngle = (sqEnd - circleCenter):Angle().y - 90

        -- Zeichnen des Kreisbogens
        for j = 1, detail do
            local angle = Lerp(j / detail, startAngle, endAngle)
            local pos = circleCenter + Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0) * radius
            surface.DrawTexturedRectRotated(pos.x, pos.y, radius * 2, radius * 2, angle)
        end

        -- Zeichnen der Verbindungslinie zum nächsten Kreisbogen
        if i < segments then
            local nextSqStart = bezier(startPos, p2, p3, endPos, t1)
            surface.DrawLine(sqEnd.x, sqEnd.y, nextSqStart.x, nextSqStart.y)
        end
    end
end


local function GetFileFriendyName(name)
    name = string.lower(name)
    name = string.Replace(name, " ", "_")

    return name
end

function EventAutomation:NodeMap(startUpData)
    if not startUpData then
        startUpData = {}
    end

    local zoom = startUpData.zoom or 1

    EventAutomation.NodeMapPnl = vgui.Create("DFrame")
    EventAutomation.NodeMapPnl:SetSize(ScrW() * .8, ScrH() * .85)
    EventAutomation.NodeMapPnl:ShowCloseButton(false)
    EventAutomation.NodeMapPnl:Center()
    EventAutomation.NodeMapPnl:MakePopup()
    EventAutomation.NodeMapPnl:SetTitle("")
    EventAutomation.NodeMapPnl:MoveTo(ScrW() * .01, ScrH() * .075, .3)
    EventAutomation.NodeMapPnl.Paint = function(me,w,h)
        local x, y = me:LocalToScreen()

        BSHADOWS.BeginShadow()
        draw.RoundedBox(20, x, y, w, h, theme.bg)
        BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)

        local x1 = draw.SimpleText("E", "EventAutomation.Title", w * .016, h * .015, theme.primary, TEXT_ALIGN_LEFT)
        local x2 = draw.SimpleText("VENT", "EventAutomation.Title", w * .017 + x1, h * .015, theme.grey, TEXT_ALIGN_LEFT)
        local x3 = draw.SimpleText("A", "EventAutomation.Title", w * .024 + x2 + x1, h * .015, theme.primary, TEXT_ALIGN_LEFT)
        local x4 = draw.SimpleText("UTOMATION", "EventAutomation.Title", w * .022 + x3 + x2 + x3, h * .015, theme.grey, TEXT_ALIGN_LEFT)

        if startUpData.collectionID then
            local x1 = draw.SimpleText("Downloaded from Server. (Nodemap ID: "..startUpData.collectionID..")", "EventAutomation.DownloadedDisclaimer", w * .016, h * .07, theme.info, TEXT_ALIGN_LEFT)
        elseif startUpData.importedFrom then
            local x1 = draw.SimpleText("Imported from local directory. ("..startUpData.importedFrom..")", "EventAutomation.DownloadedDisclaimer", w * .016, h * .07, theme.info, TEXT_ALIGN_LEFT)
        end

        draw.RoundedBox(0, w * .33, h * .045, w * .59, h * .002, theme.grey)
    end

    EventAutomation.CloseButton = vgui.Create("SummeLibrary.CloseButton", EventAutomation.NodeMapPnl)
    EventAutomation.CloseButton:SetPos(ScrW() * .76, ScrH() * .02)
    EventAutomation.CloseButton:SetSize(ScrH() * .035, ScrH() * .035)
    EventAutomation.CloseButton:SetUp(function()
        EventAutomation.NodeMapPnl:Remove()
    end)

    local btns = {}
    local btnOrder = {}

    local receiver = vgui.Create("DPanel", EventAutomation.NodeMapPnl)
    receiver:Dock(FILL)
    receiver:DockMargin(ScrW() * .0, ScrH() * .04, ScrW() * .0, ScrH() * .025)
    function receiver:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(177,177,177,0))

        for k, v in pairs(btns) do
            for k, v in SortedPairs(btnOrder) do

                if not v or not IsValid(v) then continue end
                local nextBtn = btnOrder[k + 1]
                if not nextBtn or not IsValid(nextBtn) then continue end

                surface.SetDrawColor(color_white)

                local pos1, pos2 = v:GetPos()
                local pos3, pos4 = nextBtn:GetPos()

                local size1, size2 = v:GetSize()
                local size3, size4 = nextBtn:GetSize()

                --surface.DrawLine(pos1 + size1/2, pos2 + size2/2, pos3 + size3/2, pos4 + size4/2)

                DrawBezier(Vector(pos1 + size1/2, pos2 + size2/2, 0), Vector(pos3 + size3/2, pos4 + size4/2, 0), Color(255,222,0))
                --DrawRoundedBezier(Vector(pos1 + size1/2, pos2 + size2/2, 0), Vector(pos3 + size3/2, pos4 + size4/2, 0), 3)
            end
        end
    end
    receiver:Receiver( 'name', function( receiver, tableOfDroppedPanels, isDropped, menuIndex, mouseX, mouseY ) 
        if isDropped then
            local sizeX, sizeY = tableOfDroppedPanels[1]:GetSize()
            local x = mouseX - (sizeX/2.5)
            local y = mouseY - (sizeY/2.8)

            tableOfDroppedPanels[1]:MoveTo(x, y, .1, 0, -1, function()
                tableOfDroppedPanels[1]:SaveDefaultPos()
            end)

        end
    end,
    {})

    local nodeTitleFont = "EventAutomation.Node"

    local function OnMouseWheeled(self, delta)
        -- Erhält die aktuelle Größe des Panels
        local width, height = self:GetSize()
    
        -- Berechnet den Prozentsatz des Abstands zwischen den Elementen
        local spacingPercentage = 0.1 -- anpassen, je nachdem wie groß der Abstand zwischen den Elementen sein soll
        local spacing = width * spacingPercentage
    
        -- Ändert die Größe aller Elemente des Panels
        for _, child in ipairs(self:GetChildren()) do
            local defW, defH = ScrW() * .07, ScrH() * .05
            local child_width, child_height = child:GetSize()
    
            local new_width = math.Clamp(child_width - (delta * 0.1 * child_width), defW * .4, defW)
            local new_height = math.Clamp(child_height - (delta * 0.1 * child_height), defH * .4, defH)
    
            zoom = math.Clamp(delta * 0.1, 0, 2)
            zoom = new_width / defW
    
            --local x, y = child.defaultPosX or 50, child.defaultPosY or 50
            local x, y = child.defaultPosX or 50, child.defaultPosY or 50
            local x_, y_ = child:GetPos()



            -- Skaliert die Position des Elements basierend auf dem Zoomfaktor
            --child:SetPos(receiver:LocalToScreen(x * zoom), receiver:LocalToScreen(y * zoom))
            child:SetPos((x * zoom), (y * zoom))
    
            -- Skaliert die Größe des Elements basierend auf dem Zoomfaktor
            child:SetSize(new_width, new_height)

            if zoom >= 1 then
                nodeTitleFont = "EventAutomation.Node1"
            elseif zoom >= 0.7 then
                nodeTitleFont = "EventAutomation.Node0.7"
            elseif zoom >= 0.5 then
                nodeTitleFont = "EventAutomation.Node0.5"
            elseif zoom <= 0.3 then
                nodeTitleFont = "EventAutomation.Node0.3"
            end

        end
    end

    receiver.OnMouseWheeled = OnMouseWheeled
    
    local awaitConenctionBy = false

    function EventAutomation.NodeMapPnl:CreateButton(nodeID)
        local option = EventAutomation:GetOption(nodeID)
        if not option then return end

        local btn = vgui.Create("DButton", receiver)
        btn:Droppable( 'name' )
        btn:SetText("")
        btn:SetSize(ScrW() * .07 * zoom, ScrH() * .05 * zoom)
        btn.optionID = nodeID
        btn.attributeData = {}
        btn.defaultPosX, btn.defaultPosY = 0, 0

        btn:SetPos(ScrW() * .65, ScrH() * .9)
        btn:MoveTo(0, 0, .3, 0, -1)

        function btn:Highlight()
            local sizeX, sizeY = self:GetSize()

            self:AlphaTo(100, .5, 0, function()
                self:AlphaTo(255, .5, 0)
            end)
        end

        function btn:SaveDefaultPos()
            self.defaultPosX, self.defaultPosY = self:GetPos()
            self.defaultPosX, self.defaultPosY = self.defaultPosX * 1/zoom, self.defaultPosY * 1/zoom
            --self.defaultPosX, self.defaultPosY = self:GetPos()
        end

        for k, v in pairs(option.attributes) do
            btn.attributeData[k] = v.default
        end

        if option.id == "util_timer" then
            btn:SetSize(ScrW() * .07, ScrH() * .05)
        end

        function btn:Paint(w, h)
            draw.RoundedBox(5, 0, 0, w, h, Color(43,43,43))
            draw.RoundedBox(5, 0, 0, w, h * .2, option.color)
            draw.RoundedBox(5, 0, h * .18, w, h * .05, ColorAlpha(option.color, 50))

            if awaitConenctionBy == self then
                draw.RoundedBox(5, 0, h * .97, w, h * .03, Color(255,217,3))
            end

            --draw.SimpleText(math.Round((self.defaultPosX or 50) * zoom, 1) .. " | ".. math.Round((self.defaultPosY or 50) * zoom, 1), "EventAutomation.Node", w * .5, h * .2, Color(217,255,0), TEXT_ALIGN_CENTER)

            draw.SimpleText(option.name, nodeTitleFont, w * .5, h * .4, color_white, TEXT_ALIGN_CENTER)
            draw.SimpleText(self.id or "/", "EventAutomation.NodeID", w * .5, h * .8, color_white, TEXT_ALIGN_CENTER)

            if option.adminOnly then
                surface.SetDrawColor(Color(255,123,0))
                SummeLibrary:DrawImgur(w * .87, h * .65, h * .3, h * .3, "p0vOzEf")
            end
        end

        function btn:DoClick()
            if not awaitConenctionBy then
                awaitConenctionBy = self

                if not table.HasValue(btnOrder, self) then
                    self.id = table.insert(btnOrder, self)
                end
            else
                --awaitConenctionBy.nextBtn = btn

                if not table.HasValue(btnOrder, btn) then
                    self.id = table.insert(btnOrder, btn)
                end

                awaitConenctionBy = false
            end
        end

        function btn:DoRightClick()
            local contextMenu = DermaMenu(btn)
            function contextMenu:Paint(w, h)
                local x, y = self:LocalToScreen()

                BSHADOWS.BeginShadow()
                draw.RoundedBox(10, x, y, w, h, theme.bg)
                BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)
                --draw.RoundedBox(6, 0, 0, width, height, Color(48,48,48))
            end
            --function contextMenu:Paint(width, height) end

            local optionPanel = contextMenu:AddOption("Delete Node", function()
                btns[self] = nil
                btnOrder[self.id or 999999] = nil

                self:Remove()
            end)

            if self.id then
                local optionPanel = contextMenu:AddOption("Delete Connection", function()
                    if self.id then
                        btnOrder[self.id] = nil
                        self.id = nil
                    end
                end)
            end

            local optionPanel = contextMenu:AddOption("Edit Attributes", function()
                EventAutomation:OptionMenu(self.optionID, self, EventAutomation.NodeMapPnl)
            end)

            local optionPanel = contextMenu:AddOption("Copy Attributes", function()
                EventAutomation.CopiedAttributesClipboard = {
                    id = option.id,
                    attributeData = self.attributeData,
                }
            end)

            if EventAutomation.CopiedAttributesClipboard.id == option.id then
                local optionPanel = contextMenu:AddOption("Paste Attributes", function()
                    self.attributeData = EventAutomation.CopiedAttributesClipboard.attributeData
                end)
            end

            local optionPanel = contextMenu:AddOption("Duplicate Node", function()
                local newBtn = EventAutomation.NodeMapPnl:CreateButton(self.optionID)
                newBtn.attributeData = self.attributeData

                local posX, posY = gui.MouseX(), gui.MouseY()
                posX, posY = receiver:ScreenToLocal(posX, posY)

                newBtn:SetPos(posX, posY)
                timer.Simple(0, function()
                    newBtn:Highlight()
                end)
            end)

            contextMenu:Open()
        end

        btn.tpData = {
            color = option.color,
            category = option.category,
            name = option.name,
        }

        btn:SetTooltipPanelOverride("Summe.Tooltip")
        btn:SetTooltip(option.desc)

        table.insert(btns, btn)

        return btn
    end


    function EventAutomation.NodeMapPnl:ImportNodeMap(fileName)
        local data = file.Read(fileName, DATA)
        data = util.JSONToTable(data)

        for k, v in pairs(btns) do
            btns[k] = nil
            btnOrder[v.id or 999999] = nil

            v:Remove()
        end

        zoom = data.zoom or 1

        for k, v in SortedPairs(data.buttons) do
            local btn = EventAutomation.NodeMapPnl:CreateButton(v.id)
            btn:MoveTo(v.posX * ScrW(), v.posY * ScrH(), .3, .1, -1, function()
                btn:SaveDefaultPos()
            end)
            btn.id = table.insert(btnOrder, btn)
            btn.attributeData = v.attributeData
        end
    end

    local toolbar = vgui.Create("DPanel", EventAutomation.NodeMapPnl)
    toolbar:SetPos(ScrW() * .003, ScrH() * .82)
    toolbar:SetSize(ScrW() * .7945, ScrH() * .03)
    function toolbar:Paint(w, h)
        draw.RoundedBox(10, 0, 0, w, h, Color(50,50,50))
    end

    local function GetNodeCategories()
        local _ = {}

        for k, v in pairs(EventAutomation.Options) do
            if v.category then
                _[v.category] = true
            end
        end

        return _
    end

    local function GetExportReadyData()
        local data = {}
        data.buttons = {}

            for k, v in SortedPairs(btnOrder) do
                local posX, posY = v:GetPos()

                posX = posX / ScrW()
                posY = posY / ScrH()

                data.buttons[k] = {
                    id = v.optionID,
                    posX = posX,
                    posY = posY,
                    attributeData = v.attributeData,
                }
            end
        
        data.zoom = zoom

        return data
    end

    local createButton = EventAutomation:CreateButton(toolbar)
    createButton:Dock(LEFT)
    createButton:SetSize(ScrW() * .05, 0)
    createButton:DockMargin(0, 0, 0 ,0)
    createButton:SetColor(Color(50,50,50))
    createButton:SetHoverColor(Color(56,56,56))
    createButton:SetIcon("3rwEu6S")
    function createButton:DoClick()
        local Menu = DermaMenu()
        function Menu:Paint(w, h)
            local x, y = self:LocalToScreen()

            BSHADOWS.BeginShadow()
            draw.RoundedBox(10, x, y, w, h, theme.bg)
            BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)
            --draw.RoundedBox(6, 0, 0, width, height, Color(48,48,48))
        end

        for cat, v in pairs(GetNodeCategories()) do
            local Child, Parent = Menu:AddSubMenu(cat)
            Parent:SetIcon( "icon16/arrow_refresh.png" )
            function Child:Paint(w, h)
                local x, y = self:LocalToScreen()

                BSHADOWS.BeginShadow()
                draw.RoundedBox(10, x, y, w, h, theme.bg)
                BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)
                --draw.RoundedBox(6, 0, 0, width, height, Color(48,48,48))
            end

            for k, v in pairs(EventAutomation.Options) do
                if v.category != cat then continue end
                Child:AddOption(v.name, function()
                    EventAutomation.NodeMapPnl:CreateButton(v.id)
                end):SetIcon( "icon16/group.png")
            end
        end

        -- Open the menu
        Menu:Open()
    end

    local exportButton = EventAutomation:CreateButton(toolbar)
    exportButton:Dock(RIGHT)
    exportButton:SetSize(ScrW() * .03, 0)
    exportButton:DockMargin(0, 0, 0 ,0)
    exportButton:SetColor(Color(50,50,50))
    exportButton:SetHoverColor(Color(56,56,56))
    exportButton:SetIcon("01vxrN4")
    function exportButton:DoClick()
        local data = GetExportReadyData()
        EventAutomation:CreateStringModal("Export Nodemap", "Please enter a name, as which the file should be saved. The name will be converted into a file friendly one.", function(text)
            local fileName = GetFileFriendyName(text.."_"..game.GetMap())

            file.CreateDir("summes_eventautomation")
            file.CreateDir("summes_eventautomation/nodemaps")
            file.Write("summes_eventautomation/nodemaps/"..fileName..".json", util.TableToJSON(data))

            SummeLibrary:Notify("success", "Nodemap exported", "The nodemap has been exported to garrysmod/data/summes_eventautomation/nodemaps/"..fileName..".json")
        end)
    end

    if not startUpData.collectionID then
        local runButton = EventAutomation:CreateButton(toolbar)
        runButton:Dock(RIGHT)
        runButton:SetSize(ScrW() * .03, 0)
        runButton:DockMargin(0, 0, 0 ,0)
        runButton:SetColor(Color(50,50,50))
        runButton:SetHoverColor(Color(56,56,56))
        runButton:SetIcon("Nwmes1A")
        function runButton:DoClick()

            local panel = vgui.Create("DFrame")
            panel:SetSize(ScrW() * .24, ScrH() * .3)
            panel:ShowCloseButton(false)
            panel:Center()
            panel:MakePopup()
            panel:SetTitle("")
            panel:SetBackgroundBlur(false)
            panel:DoModal()

            local close = vgui.Create("SummeLibrary.CloseButton", panel)
            close:SetPos(ScrW() * .22, ScrH() * .01)
            close:SetSize(ScrH() * .025, ScrH() * .025)
            close:SetUp(function()
                panel:Remove()
            end)

            local restricedNotes = {}

            for k, v in SortedPairs(btnOrder) do
                if LocalPlayer():IsAdmin() then continue end

                if not EventAutomation.Options[v.optionID] then continue end // would be unfortunate lol

                if EventAutomation.Options[v.optionID].adminOnly then
                    table.insert(restricedNotes, EventAutomation.Options[v.optionID].name)
                end
            end

            local restricedNotesString = formatTable(restricedNotes)

            function panel:Paint(w, h)
                local x, y = self:LocalToScreen()

                BSHADOWS.BeginShadow()
                    draw.RoundedBox(12, x, y, w, h, Color(36,36,36))
                BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)

                draw.DrawText("Send this nodemap to the server?", "EventAutomation.ModalTitle", w * .5, h * .03, color_white, TEXT_ALIGN_CENTER)

                local text = "In order to execute this nodemap, you have to create a collection for it at first."
                text = SummeLibrary:WrapText(text, "EventAutomation.ModalText", ScrW() * .21)

                draw.DrawText(text, "EventAutomation.ModalText", w * .05, h * .15, color_white, TEXT_ALIGN_LEFT)

                if #restricedNotes > 0 then
                    draw.DrawText("Admin restriced notes are getting skipped! ".. restricedNotesString, "EventAutomation.NodeTooltip", w * .05, h * .73, Color(255,144,144), TEXT_ALIGN_LEFT)
                end
            end

            local textInput = vgui.Create("SummeLibrary.TextEntry", panel)
            textInput:SetSize(ScrW() * .218, ScrH() * .03)
            textInput:SetPos(ScrW() * .01, ScrH() * .1)
            textInput:SetText("")

            local deleteAfterRunInstantly

            local runInstantly = vgui.Create("DButton", panel)
            runInstantly:SetPos(ScrW() * .01, ScrH() * .145)
            runInstantly:SetSize(ScrW() * .15, ScrH() * .03)
            runInstantly:SetText("")
            runInstantly.PolationStatus = 0
            runInstantly.NormalColor = Color(158, 158, 158, 0)
            runInstantly.Status = false
            function runInstantly:Paint(w, h)
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
                SummeLibrary:DrawImgur(w * .02, h * .1, h * .8, h * .8, runInstantly.Status and "ExHkfJq" or "aVmdI7R")

                draw.DrawText("Run instantly ", "SL.TextEntry", w * .2, h * .15, SummeLibrary:GetColor("greyLight"), TEXT_ALIGN_LEFT)
            end
            function runInstantly:Toggle()
                if self.Status then
                    self.Status = false
                    deleteAfterRunInstantly:SetVisible(false)
                else
                    self.Status = true
                    deleteAfterRunInstantly:SetVisible(true)
                end
            end
            function runInstantly:DoClick()
                self:Toggle()
            end

            deleteAfterRunInstantly = vgui.Create("DButton", panel)
            deleteAfterRunInstantly:SetPos(ScrW() * .01, ScrH() * .18)
            deleteAfterRunInstantly:SetSize(ScrW() * .15, ScrH() * .03)
            deleteAfterRunInstantly:SetText("")
            deleteAfterRunInstantly.PolationStatus = 0
            deleteAfterRunInstantly.NormalColor = Color(158, 158, 158, 0)
            deleteAfterRunInstantly.Status = false
            deleteAfterRunInstantly:SetVisible(false)
            function deleteAfterRunInstantly:Paint(w, h)
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
                SummeLibrary:DrawImgur(w * .02, h * .1, h * .8, h * .8, deleteAfterRunInstantly.Status and "ExHkfJq" or "aVmdI7R")

                draw.DrawText("Delete after finishing ", "SL.TextEntry", w * .2, h * .15, SummeLibrary:GetColor("greyLight"), TEXT_ALIGN_LEFT)
            end
            function deleteAfterRunInstantly:Toggle()
                if self.Status then
                    self.Status = false
                else
                    self.Status = true
                end
            end
            function deleteAfterRunInstantly:DoClick()
                self:Toggle()
            end

            local button = EventAutomation:CreateButton(panel)
            button:SetSize(ScrW() * .218, ScrH() * .03)
            button:SetPos(ScrW() * .01, ScrH() * .24)
            button:SetText("Send")
            button:SetColor(Color(58,58,58))
            button:SetHoverColor(Color(1,36,0))
            function button:DoClick()
                panel:Remove()
                
                local name = textInput:GetText()

                local btns = {}

                for k, v in SortedPairs(btnOrder) do
                    btns[k] = {
                        id = v.optionID,
                        attributeData = v.attributeData or {},
                    }
                end

                local data = GetExportReadyData()

                net.Start("EventAutomation.StartCollection")
                net.WriteTable(btns)
                net.WriteString(util.TableToJSON(data))
                net.WriteString(name)
                net.WriteBool(runInstantly.Status)
                if runInstantly.Status then
                    net.WriteBool(deleteAfterRunInstantly.Status)
                end
                net.SendToServer()
            end
            
            return false

            --[[EventAutomation:CreateBoolModal("Execute this nodemap?", "Do you really want to send this nodemap to the server and execute it?", function()
                local _ = {}

                for k, v in SortedPairs(btnOrder) do
                    _[k] = {
                        id = v.optionID,
                        attributeData = v.attributeData or {},
                    }
                end

                local data = GetExportReadyData()

                net.Start("EventAutomation.StartCollection")
                net.WriteTable(_)
                net.WriteString(util.TableToJSON(data))
                net.SendToServer()

                PrintTable(_)
            end)]]--
        end
    else
        local sendToServerButton = EventAutomation:CreateButton(toolbar)
        sendToServerButton:Dock(RIGHT)
        sendToServerButton:SetSize(ScrW() * .03, 0)
        sendToServerButton:DockMargin(0, 0, 0 ,0)
        sendToServerButton:SetColor(Color(50,50,50))
        sendToServerButton:SetHoverColor(Color(56,56,56))
        sendToServerButton:SetIcon("xAosZz5")
        function sendToServerButton:DoClick()
            EventAutomation:CreateBoolModal("Update this collection?", "Do you really want to send this nodemap to the server and update the collection with it?", function()
                local _ = {}

                for k, v in SortedPairs(btnOrder) do
                    _[k] = {
                        id = v.optionID,
                        attributeData = v.attributeData or {},
                    }
                end

                local data = GetExportReadyData()

                net.Start("EventAutomation.UpdateCollectionsNodemap")
                net.WriteString(startUpData.collectionID)
                net.WriteTable(_)
                net.WriteString(util.TableToJSON(data))
                net.SendToServer()
            end)
        end
    end

    if startUpData.importedFrom then
        local saveButton = EventAutomation:CreateButton(toolbar)
        saveButton:Dock(RIGHT)
        saveButton:SetSize(ScrW() * .03, 0)
        saveButton:DockMargin(0, 0, 0 ,0)
        saveButton:SetColor(Color(50,50,50))
        saveButton:SetHoverColor(Color(56,56,56))
        saveButton:SetIcon("ObNhnFS")
        function saveButton:DoClick()
            local data = GetExportReadyData()

            file.CreateDir("summes_eventautomation")
            file.CreateDir("summes_eventautomation/nodemaps")
            file.Write(startUpData.importedFrom, util.TableToJSON(data))
            SummeLibrary:Notify("success", "Nodemap updated", "The nodemap has been updated ("..startUpData.importedFrom..")")
        end
    end
end