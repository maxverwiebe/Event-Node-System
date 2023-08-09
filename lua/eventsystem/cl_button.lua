local t

function EventAutomation:CreateButton(panel)
    local button = vgui.Create("DButton", panel)
    button:SetPos(0, 0)
    button:SetSize(0, 0)
    button:SetText("")
    button.BGColor = Color(255,255,255)
    button.HoverColor = Color(255,255,255)
    function button:Paint(w, h)
        local bgCol = self.BGColor_ or Color(223, 223, 223)
        
        if self:IsHovered() then
            bgCol = self.HoverColor
        end
        
        self.BGColor = SummeLibrary:LerpColor(FrameTime() * 12, self.BGColor, bgCol)

        local x, y = self:LocalToScreen()
        BSHADOWS.BeginShadow()
            draw.RoundedBox(10, x, y, w, h, self.BGColor)
        BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)

        if not self.IconImgur then
            draw.DrawText(self.Text or "n/A", "EventAutomation.PanelButton", w * .5, h * .25, color_white, TEXT_ALIGN_CENTER)
        else
            surface.SetDrawColor(color_white)
            SummeLibrary:DrawImgur(w * .5 - (h * .7/2), h * .5 - (h * .7/2), h * .7, h *.7, self.IconImgur)
        end
    end

    function button:SetColor(color)
        self.BGColor_ = color
        self.BGColor = color
    end

    function button:SetHoverColor(color)
        self.HoverColor = color
    end

    function button:SetText(text)
        self.Text = text
    end

    function button:SetIcon(imgurID)
        self.IconImgur = imgurID
    end

    return button
end