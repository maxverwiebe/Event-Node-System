local theme = {
    bg = Color(27,27,27, 250),
    bgSec = Color(39,39,39,203),
    navButton = Color(34,34,34),
    navButtonH = Color(39,39,39),
    primary = Color(21,180,29),
    grey = Color(168,168,168)
}

EventAutomation = EventAutomation or {}
EventAutomation.MainPages = EventAutomation.MainPages or {}

concommand.Add("nodemap", function()
    EventAutomation:MainMenu()
end, true)

function EventAutomation:MainMenu()
    local width = ScrW() * .8
    local height = ScrH() * .7

    self.MainFrame = vgui.Create("DFrame")
    self.MainFrame:SetTitle("")
    self.MainFrame:SetSize(width, height)
    self.MainFrame:MakePopup()
    self.MainFrame:Center()
    self.MainFrame:SetDraggable(false)
    self.MainFrame:ShowCloseButton(false)
    self.MainFrame:SetAlpha(0)
    self.MainFrame:AlphaTo(255, .1)
    self.MainFrame.Paint = function(me,w,h)
        local x, y = me:LocalToScreen()

        BSHADOWS.BeginShadow()
        draw.RoundedBox(20, x, y, w, h, theme.bg)
        BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)

        local x1 = draw.SimpleText("E", "EventAutomation.Title", w * .02, h * .015, theme.primary, TEXT_ALIGN_LEFT)
        local x2 = draw.SimpleText("VENT", "EventAutomation.Title", w * .02 + x1, h * .015, theme.grey, TEXT_ALIGN_LEFT)
        local x3 = draw.SimpleText("A", "EventAutomation.Title", w * .027 + x2 + x1, h * .015, theme.primary, TEXT_ALIGN_LEFT)
        local x4 = draw.SimpleText("UTOMATION", "EventAutomation.Title", w * .025 + x3 + x2 + x3, h * .015, theme.grey, TEXT_ALIGN_LEFT)

        draw.RoundedBox(0, w * .33, h * .0525, w * .59, h * .002, theme.grey)
    end

    self.CloseButton = vgui.Create("SummeLibrary.CloseButton", self.MainFrame)
    self.CloseButton:SetPos(width * .945, height * .04)
    self.CloseButton:SetSize(height * .05, height * .05)
    self.CloseButton:SetUp(function()
        self.MainFrame:Remove()
    end)

    self.MainPanel = vgui.Create("DPanel", self.MainFrame)
    self.MainPanel:SetPos(width * .2, height * .13)
    self.MainPanel:SetSize(width * .78, height * .83)
    function self.MainPanel:Paint(w, h) 
    end

    self.NavBarLEFT = vgui.Create("DScrollPanel", self.MainFrame)
    self.NavBarLEFT:SetPos(width * .01, height * .2)
    self.NavBarLEFT:SetSize(width * .18, height * .7)
    function self.NavBarLEFT:Paint(w, h) 
    end

    local activeButton = ""

    local function GenerateButton(data)
        self.Button = vgui.Create("DButton", self.NavBarLEFT)
        self.Button:Dock(TOP)
        self.Button:DockMargin(0, 0, 0, ScrH() * .01)
        self.Button:SetSize(0, ScrH() * .04)
        self.Button:SetText("")
        self.Button.BackgroundCol = Color(221, 221, 221)
        self.Button.BarStatus = 0
        self.Button.ButtonText = data.name
    
        function self.Button:IsActive()
            if activeButton == self.ButtonText then
                return true
            end
    
            return false
        end
    
        function self.Button:DoClick()
            activeButton = self.ButtonText

            EventAutomation.MainPanel:Clear()

            if data.frame then
                data.frame(EventAutomation.MainPanel)
            end
        end
    
        function self.Button:Paint(w, h)
            local bgCol = Color(223, 223, 223)
        
            if self:IsHovered() and not self:IsActive() then
                bgCol = Color(170, 43, 43, 234)
                self.BarStatus = math.Clamp(self.BarStatus + (FrameTime() * 7), 0, 1)
            else
                self.BarStatus = math.Clamp(self.BarStatus - (FrameTime() * 7), 0, 1)
            end
    
            if self:IsActive() then
                draw.RoundedBox(10, 0, 0, w, h, theme.bgSec)
            end
    
            self.BackgroundCol = SummeLibrary:LerpColor(FrameTime() * 12, self.BackgroundCol, bgCol)
    
            surface.SetDrawColor(Color(255,255,255))
            SummeLibrary:DrawImgur(w * .05 + w * .1 * self.BarStatus, h * .15, h * .7, h * .7, data.icon)
    
            local textX = draw.SimpleText(self.ButtonText, "EventAutomation.NavBarText", w * .2 + w * .1 * self.BarStatus, h * .25, self.BackgroundCol, TEXT_ALIGN_LEFT)

            if data.badge then
                surface.SetFont("EventAutomation.NavBarNotify")
                local textWidth = surface.GetTextSize(data.badge.text)

                draw.RoundedBox(5, w * .24 + textX + (w * .1 * self.BarStatus), h * .25, w * .05 + textWidth, h * .4, data.badge.color)
                draw.SimpleText(data.badge.text, "EventAutomation.NavBarNotify", w * .262 + textX + (w * .1 * self.BarStatus), h * .25, color_white, TEXT_ALIGN_LEFT)
            end
        end
    end

    local function GenerateAllButtons()
        for key, data in pairs(EventAutomation.MainPages) do
            GenerateButton(data)
        end 
    end

    self.SearchBarLEFT = vgui.Create("SummeLibrary.TextEntry", self.MainFrame)
    self.SearchBarLEFT:SetPos(width * .015, height * .12)
    self.SearchBarLEFT:SetSize(width * .16, height * .06)
    self.SearchBarLEFT:SetPlaceholder("Search settings")
    self.SearchBarLEFT:SetBarColor(SummeLibrary:GetColor("greyLight"))

    function self.SearchBarLEFT:OnChange()
        local text = self:GetText()
        EventAutomation.NavBarLEFT:Clear()

        if text == "" then
            GenerateAllButtons()
            return
        end

        for k, v in pairs(EventAutomation.MainPages) do
            for _, tag in pairs(v.tags) do
                if string.find(tag, text, 1, false) then
                    GenerateButton(v)
                end
            end
        end
    end

    GenerateAllButtons()
end

function EventAutomation:AddMainPage(key, data)
    EventAutomation.MainPages[key] = data
end

EventAutomation:AddMainPage("ACTIVE_COLLECTIONS", {
    name = "Active Collections",
    icon = "YsXrQ8z",
    frame = function(mainPanel)
        local width, height = mainPanel:GetSize()

        local data

        net.Start("EventAutomation.RequestCollections")
        net.SendToServer()

        local content = vgui.Create("DPanel", mainPanel)
        content:Dock(FILL)
        function content:Paint(w, h)
            draw.DrawText("Active Collections", "SummeLibrary.PageTitle", w * .01, h * .01, color_white, TEXT_ALIGN_LEFT)
        end

        local main = vgui.Create("DScrollPanel", content)
        main:Dock(FILL)
        main:DockMargin(0, height * .1, 0, 0)
        function main:Paint(w, h)
            --draw.RoundedBox(20, 0, 0, w, h, theme.navButton)
        end
    
        local sbar = main:GetVBar()
        function sbar:Paint(w, h)
        end
        function sbar.btnUp:Paint(w, h)
        end
        function sbar.btnDown:Paint(w, h)
        end
        function sbar.btnGrip:Paint(w, h)
        end
    
        sbar.LerpTarget = 0
    
        function sbar:AddScroll(dlta)
            local OldScroll = self.LerpTarget or self:GetScroll()
            dlta = dlta * 75
            self.LerpTarget = math.Clamp(self.LerpTarget + dlta, -self.btnGrip:GetTall(), self.CanvasSize + self.btnGrip:GetTall())
    
            return OldScroll ~= self:GetScroll()
        end
    
        sbar.Think = function(s)
            local frac = FrameTime() * 5
            if (math.abs(s.LerpTarget - s:GetScroll()) <= (s.CanvasSize / 10)) then
                frac = FrameTime() * 2
            end
            local newpos = Lerp(frac, s:GetScroll(), s.LerpTarget)
            s:SetScroll(math.Clamp(newpos, 0, s.CanvasSize))
            if (s.LerpTarget < 0 and s:GetScroll() <= 0) then
                s.LerpTarget = 0
            elseif (s.LerpTarget > s.CanvasSize and s:GetScroll() >= s.CanvasSize) then
                s.LerpTarget = s.CanvasSize
            end
        end
        
        net.Receive("EventAutomation.RequestCollections", function()
            data = net.ReadTable()

            local statusColors = {
                ["idle"] = Color(255,89,0),
                ["running"] = Color(78,255,78),
                ["timeout"] = Color(255,125,125),
            }

            for key, value in SortedPairs(data) do

                local nodesCount =  value.progress.."/".. #value.nodes

                local steamName = "n/A"
                steamworks.RequestPlayerInfo(value.lastRunPlayer or "n/A", function(name)
                    steamName = name
                end)

                PrintTable(value.nodes)

                local runtime = EventAutomation.CalculateRuntime(value.nodes, value.progress)
                local runtimeDef = EventAutomation.CalculateRuntime(value.nodes, 0)
                local timeleft = (value.lastRun or 1000) + runtime
                local timeleftDef = (value.lastRun or 1000) + runtimeDef

                print("Estimated runtime: ".. EventAutomation.CalculateRuntime(value.nodes, 0).. "s")

                local pnl = vgui.Create("DPanel", main)
                pnl:SetSize(width * .65, height * .15)
                pnl:Dock(TOP)
                pnl:DockMargin(width * 0.002, height * 0.02, width * 0.002, 0)
                function pnl:Paint(w, h)
                    draw.RoundedBox(8, 0, 0, w, h, theme.bgSec)

                    draw.SimpleText("#"..value.id, "SummeLibrary.HotkeyMenu", w * .02, h * .1, color_white, TEXT_ALIGN_LEFT)

                    draw.SimpleText("Status:", "EventAutomation.AddonsText", w * .02, h * .4, color_white, TEXT_ALIGN_LEFT)
                    draw.SimpleText(value.status, "EventAutomation.AddonsText", w * .07, h * .4, statusColors[value.status], TEXT_ALIGN_LEFT)

                    --if value.status == "running" then
                        draw.SimpleText(nodesCount, "EventAutomation.AddonsText", w * .5, h * .7, color_white, TEXT_ALIGN_LEFT)
                    --end

                    local lastRun = value.lastRun or 10000

                    local time = (lastRun - CurTime())

                    local lastExecuted = "Last executed ".. math.Round(-time, 0).. "s ago by ".. steamName.. "."

                    draw.SimpleText(lastExecuted, "EventAutomation.AddonsText", w * .02, h * .7, color_white, TEXT_ALIGN_LEFT)

                    draw.SimpleText(math.Round((timeleft - CurTime()), 0), "EventAutomation.AddonsText", w * .7, h * .7, color_white, TEXT_ALIGN_LEFT)
                    draw.RoundedBox(20, w * .5, h * .85, w * .3, h * .1, Color(44,44,44))
                end

                local toolbar = vgui.Create("DPanel", pnl)
                toolbar:SetSize(width * .15, height * .05)
                toolbar:SetPos(width * .85, height * .1)
                function toolbar:Paint(w, h)
                end

                local startButton = vgui.Create("DButton", toolbar)
                startButton:Dock(RIGHT)
                startButton:SetSize(ScrW() * .02, 0)
                startButton:DockMargin(0, 0, 0 ,0)
                startButton:SetText("")
                startButton.BGColor = Color(255,255,255)
                startButton.HoverColor = Color(255,255,255)
                function startButton:Paint(w, h)
                    local bgCol = Color(95, 93, 93)
        
                    if self:IsHovered() then
                        bgCol = self.HoverColor
                    end
                    
                    self.BGColor = SummeLibrary:LerpColor(FrameTime() * 12, self.BGColor, bgCol)

                    surface.SetDrawColor(self.BGColor)
                    SummeLibrary:DrawImgur(w * .5 - (h * .7/2), h * .5 - (h * .7/2), h * .7, h *.7, "pMdgC0f")
                end
                function startButton:DoClick()
                    net.Start("EventAutomation.RequestResumeCollection")
                    net.WriteString(value.id)
                    net.SendToServer()

                    value.lastRun = CurTime()
                    value.status = "running"

                    timer.Simple(runtime, function()
                        if pnl and IsValid(pnl) then
                            value.status = "idle"
                        end
                    end)
                end

                local deleteButton = vgui.Create("DButton", toolbar)
                deleteButton:Dock(RIGHT)
                deleteButton:SetSize(ScrW() * .02, 0)
                deleteButton:DockMargin(0, 0, 0 ,0)
                deleteButton:SetText("")
                deleteButton.BGColor = Color(255,255,255)
                deleteButton.HoverColor = Color(255,255,255)
                function deleteButton:Paint(w, h)
                    local bgCol = Color(95, 93, 93)
        
                    if self:IsHovered() then
                        bgCol = self.HoverColor
                    end
                    
                    self.BGColor = SummeLibrary:LerpColor(FrameTime() * 12, self.BGColor, bgCol)

                    surface.SetDrawColor(self.BGColor)
                    SummeLibrary:DrawImgur(w * .5 - (h * .7/2), h * .5 - (h * .7/2), h * .7, h *.7, "TP09rnG")
                end
                function deleteButton:DoClick()
                    local contextMenu = DermaMenu(deleteButton)
                    contextMenu:AddOption("No, don't delete it", function()
                        --
                    end)
                    contextMenu:AddOption("Yes, delete it", function()
                        net.Start("EventAutomation.DeleteCollection")
                        net.WriteString(value.id)
                        net.SendToServer()

                        local posX, posY = pnl:GetPos()

                        pnl:MoveTo(posX + 500, posY, .3)

                        pnl:AlphaTo(0, .3, 0, function()
                            pnl:Remove()
                        end)
                    end)

                    contextMenu:Open()
                end

                local editNodemap = vgui.Create("DButton", toolbar)
                editNodemap:Dock(RIGHT)
                editNodemap:SetSize(ScrW() * .02, 0)
                editNodemap:DockMargin(0, 0, 0 ,0)
                editNodemap:SetText("")
                editNodemap.BGColor = Color(255,255,255)
                editNodemap.HoverColor = Color(255,255,255)
                function editNodemap:Paint(w, h)
                    local bgCol = Color(95, 93, 93)
        
                    if self:IsHovered() then
                        bgCol = self.HoverColor
                    end
                    
                    self.BGColor = SummeLibrary:LerpColor(FrameTime() * 12, self.BGColor, bgCol)

                    surface.SetDrawColor(self.BGColor)
                    SummeLibrary:DrawImgur(w * .5 - (h * .7/2), h * .5 - (h * .7/2), h * .7, h *.7, "HdejK3I")
                end
                function editNodemap:DoClick()
                    net.Start("EventAutomation.GetCollectionNodemap")
                    net.WriteString(value.id)
                    net.SendToServer()
                end
            end
        end)
    end,
    tags = {},
})

-----------


EventAutomation:AddMainPage("RUN_NODES", {
    name = "Run Nodes Manually",
    icon = "gxNwCzX",
    badge = {
        text = 3,
        color = Color(77,127,255),
    },
    frame = function(mainPanel)
        local width, height = mainPanel:GetSize()

        local content = vgui.Create("DPanel", mainPanel)
        content:Dock(FILL)
        function content:Paint(w, h)
            draw.DrawText("Run Nodes Manually", "SummeLibrary.PageTitle", w * .01, h * .01, color_white, TEXT_ALIGN_LEFT)
        end

        local searchBar = vgui.Create("SummeLibrary.TextEntry", content)
        searchBar:SetPos(width * .02, height * .1)
        searchBar:SetSize(width * .3, height * .06)
        searchBar:SetPlaceholder("Search node")
        searchBar:SetBarColor(SummeLibrary:GetColor("greyLight"))

        local main = vgui.Create("DScrollPanel", content)
        main:SetPos(width * .02, height * .2)
        main:SetSize(width, height * .8)
        function main:Paint(w, h)
            --draw.RoundedBox(20, 0, 0, w, h, theme.navButton)
        end
    
        local sbar = main:GetVBar()
        function sbar:Paint(w, h)
        end
        function sbar.btnUp:Paint(w, h)
        end
        function sbar.btnDown:Paint(w, h)
        end
        function sbar.btnGrip:Paint(w, h)
        end
    
        sbar.LerpTarget = 0
    
        function sbar:AddScroll(dlta)
            local OldScroll = self.LerpTarget or self:GetScroll()
            dlta = dlta * 75
            self.LerpTarget = math.Clamp(self.LerpTarget + dlta, -self.btnGrip:GetTall(), self.CanvasSize + self.btnGrip:GetTall())
    
            return OldScroll ~= self:GetScroll()
        end
    
        sbar.Think = function(s)
            local frac = FrameTime() * 5
            if (math.abs(s.LerpTarget - s:GetScroll()) <= (s.CanvasSize / 10)) then
                frac = FrameTime() * 2
            end
            local newpos = Lerp(frac, s:GetScroll(), s.LerpTarget)
            s:SetScroll(math.Clamp(newpos, 0, s.CanvasSize))
            if (s.LerpTarget < 0 and s:GetScroll() <= 0) then
                s.LerpTarget = 0
            elseif (s.LerpTarget > s.CanvasSize and s:GetScroll() >= s.CanvasSize) then
                s.LerpTarget = s.CanvasSize
            end
        end

        local grid
        grid = vgui.Create("DGrid", main)
        grid:Dock(FILL)
        grid:SetCols(7)
        grid:SetColWide(width * .14)
        grid:SetRowHeight(height * .15)

        local function CreateNodeButton(nodeID)
            local node = EventAutomation:GetOption(nodeID)
            if not node then return end

            local btn = vgui.Create("DButton")
            btn:SetSize(width * .13, height * .13)
            btn:SetText("")

            function btn:Paint(w, h)
                draw.RoundedBox(5, 0, 0, w, h, Color(43,43,43))
                draw.RoundedBox(5, 0, 0, w, h * .2, node.color)

                draw.SimpleText(node.name, "EventAutomation.Node", w * .5, h * .4, color_white, TEXT_ALIGN_CENTER)
            end

            grid:AddItem(btn)
        end

        local function GenerateAllButtons()
            for k, v in pairs(EventAutomation.Options) do
                CreateNodeButton(k)
            end
        end

        function searchBar:OnChange()
            local text = string.lower(self:GetText())
            
            for _, v in ipairs( grid:GetChildren() ) do
                grid:RemoveItem(v)
                v:Remove()
            end

            if text == "" then
                print("DD")
                GenerateAllButtons()
                return
            else
                for k, v in pairs(EventAutomation.Options) do
                    if string.find(string.lower(v.name), text, 0, false) then

                        CreateNodeButton(k)
                        print(v.name)
                    end
                end
            end
        end

        GenerateAllButtons()
    end,
    tags = {},
})

EventAutomation:AddMainPage("IMPORT_COLLECTION", {
    name = "Import Collection",
    icon = "tkF6fEs",
    frame = function(mainPanel)
        local width, height = mainPanel:GetSize()

        local content = vgui.Create("DPanel", mainPanel)
        content:Dock(FILL)
        function content:Paint(w, h)
            draw.DrawText("Import Collection", "EventAutomation.PageTitle", w * .01, h * .01, color_white, TEXT_ALIGN_LEFT)

            local text = "Magna id do eiusmod consequat labore laboris culpa sit non laboris amet eiusmod sint. Ex adipisicing cupidatat pariatur in incididunt quis aliquip duis duis ipsum. Minim excepteur reprehenderit exercitation magna elit aute eiusmod cupidatat non."
            text = SummeLibrary:WrapText(text, "EventAutomation.PageDesc", w * .9)

            draw.DrawText(text, "EventAutomation.PageDesc", w * .01, h * .07, color_white, TEXT_ALIGN_LEFT)
        end

        local fileviewerBackground = vgui.Create("DPanel", content)
        fileviewerBackground:Dock(FILL)
        fileviewerBackground:DockMargin(width * .01, height * .15, width * .01, 0)
        function fileviewerBackground:Paint(w, h)
            draw.RoundedBox(5, 0, 0, w, h * 1, Color(30,30,30))
            draw.DrawText("garrysmod/data/summes_eventautomation/nodemaps", "EventAutomation.FileExplorerTitle", w * .01, h * .01, color_white, TEXT_ALIGN_LEFT)
        end

        local fileList = vgui.Create("DScrollPanel", fileviewerBackground)
        fileList:Dock(FILL)
        fileList:DockMargin(width * .01, height * .07, width * .01, height * .02)

        local files = {}
        local directories = {}

        files, directories = file.Find("summes_eventautomation/nodemaps/*.json", "DATA")
        for k, v in pairs(files) do
            local btn = vgui.Create("DButton", fileList)
            btn:SetText("")
            btn:Dock(TOP)
            btn:SetSize(0, height * .065)
            btn:DockMargin(0, 0, 0, height * .005)
            btn.BackgroundCol = Color(221, 221, 221)
            
            local time = os.date("%d.%m.%Y", file.Time("summes_eventautomation/nodemaps/"..v, "DATA"))

            function btn:Paint(w, h)
                local bgCol = Color(223, 223, 223)
        
                if self:IsHovered() then
                    bgCol = Color(170, 43, 43, 234)
                end
        
                self.BackgroundCol = SummeLibrary:LerpColor(FrameTime() * 12, self.BackgroundCol, bgCol)

                draw.RoundedBox(5, 0, 0, w, h * 1, Color(40,40,40))
                surface.SetDrawColor(color_white)
                SummeLibrary:DrawImgur(w * .01, h * .2, h * .6, h * .6, "RltzRUf")
                draw.DrawText(v, "EventAutomation.FileExplorerFileName", w * .04, h * .2, self.BackgroundCol, TEXT_ALIGN_LEFT)
                draw.DrawText(time, "EventAutomation.FileExplorerFileName", w * .98, h * .2, self.BackgroundCol, TEXT_ALIGN_RIGHT)
            end

            function btn:DoRightClick()
                local contextMenu = DermaMenu(btn)
                --function contextMenu:Paint(width, height) end
    
                local optionPanel = contextMenu:AddOption("Open Nodemap", function()
                    EventAutomation:NodeMap({
                        importedFrom = "summes_eventautomation/nodemaps/"..v,
                    })
                    EventAutomation.NodeMapPnl:ImportNodeMap("summes_eventautomation/nodemaps/"..v)
                end)
    
                local optionPanel = contextMenu:AddOption("Remove File", function()
                    EventAutomation:CreateBoolModal("Are you sure?", "Do you really want to delete the file "..v.."?", function()
                        self:Remove()
                        file.Delete("summes_eventautomation/nodemaps/"..v)
                    end)
                end)
    
                contextMenu:Open()
            end
        end
    end,
})

EventAutomation:AddMainPage("CREATE_COLLECTION", {
    name = "Create Collection",
    icon = "mo1cj9S",
    frame = function(mainPanel)
        EventAutomation.MainFrame:Remove()
        EventAutomation:NodeMap()
    end,
})