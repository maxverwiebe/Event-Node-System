local theme = {
    bg = Color(27,27,27,250),
    bgSec = Color(48,48,48,203),
    navButton = Color(34,34,34),
    navButtonH = Color(39,39,39),
    primary = Color(21,180,29),
    grey = Color(168,168,168)
}


function EventAutomation:CreateNodeMap()
    local width = ScrW() * .5
    local height = ScrH() * .7

    self.CreateFrame = vgui.Create("DFrame")
    self.CreateFrame:SetTitle("")
    self.CreateFrame:SetSize(width, height)
    self.CreateFrame:MakePopup()
    self.CreateFrame:Center()
    self.CreateFrame:SetDraggable(false)
    self.CreateFrame:ShowCloseButton(false)
    self.CreateFrame:SetAlpha(0)
    self.CreateFrame:AlphaTo(255, .1)
    self.CreateFrame.Paint = function(me,w,h)
        local x, y = me:LocalToScreen()

        BSHADOWS.BeginShadow()
        draw.RoundedBox(20, x, y, w, h, theme.bg)
        BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)

        local x1 = draw.SimpleText("E", "EventAutomation.Title", w * .018, h * .015, theme.primary, TEXT_ALIGN_LEFT)
        local x2 = draw.SimpleText("VENT", "EventAutomation.Title", w * .02 + x1, h * .015, theme.grey, TEXT_ALIGN_LEFT)
        local x3 = draw.SimpleText("A", "EventAutomation.Title", w * .03 + x2 + x1, h * .015, theme.primary, TEXT_ALIGN_LEFT)
        local x4 = draw.SimpleText("UTOMATION", "EventAutomation.Title", w * .025 + x3 + x2 + x3, h * .015, theme.grey, TEXT_ALIGN_LEFT)

        draw.RoundedBox(0, w * .5, h * .0525, w * .4, h * .002, theme.grey)
    end

    self.CloseButton = vgui.Create("SummeLibrary.CloseButton", self.CreateFrame)
    self.CloseButton:SetPos(width * .93, height * .03)
    self.CloseButton:SetSize(height * .05, height * .05)
    self.CloseButton:SetUp(function()
        self.CreateFrame:Remove()
    end)

    self.TitleText = vgui.Create("SummeLibrary.TextEntry", self.CreateFrame)
    self.TitleText:SetPos(width * .5 - (width * .15), height * .3)
    self.TitleText:SetSize(width * .3, height * .05)

    self.CreateButton = vgui.Create("DButton", self.CreateFrame)
    self.CreateButton:SetPos(width * .5 - (width * .15), height * .5)
    self.CreateButton:SetSize(width * .3, height * .04)
    self.CreateButton:SetText("")
    self.CreateButton.PolationStatus = 0
    self.CreateButton.NormalColor = Color(158, 158, 158, 0)
    self.CreateButton.Status = false
    function self.CreateButton:Paint(w, h)
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

        draw.DrawText("Create Nodemap", "SL.TextEntry", w * .5, h * .15, SummeLibrary:GetColor("greyLight"), TEXT_ALIGN_CENTER)
    end
    function self.CreateButton:DoClick()
        EventAutomation:NodeMap()
        EventAutomation.NodeMapPnl.Title = EventAutomation.TitleText:GetText()

        EventAutomation.CreateFrame:Remove()
    end
end