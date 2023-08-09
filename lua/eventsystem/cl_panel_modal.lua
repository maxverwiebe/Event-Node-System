SummeLibrary:CreateFont("EventAutomation.ModalTitle", ScrH() * .025, 700, false)
SummeLibrary:CreateFont("EventAutomation.ModalText", ScrH() * .02, 400, false)

function EventAutomation:CreateStringModal(title, description, success)
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

    function panel:Paint(w, h)
        local x, y = self:LocalToScreen()

        BSHADOWS.BeginShadow()
            draw.RoundedBox(12, x, y, w, h, Color(36,36,36))
        BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)

        draw.DrawText(title, "EventAutomation.ModalTitle", w * .5, h * .03, color_white, TEXT_ALIGN_CENTER)

        local text = description
        text = SummeLibrary:WrapText(text, "EventAutomation.ModalText", ScrW() * .21)

        draw.DrawText(text, "EventAutomation.ModalText", w * .05, h * .15, color_white, TEXT_ALIGN_LEFT)
    end

    local textInput = vgui.Create("SummeLibrary.TextEntry", panel)
    textInput:SetSize(ScrW() * .218, ScrH() * .03)
    textInput:SetPos(ScrW() * .01, ScrH() * .15)
    textInput:SetText("")

    local button = EventAutomation:CreateButton(panel)
    button:SetSize(ScrW() * .218, ScrH() * .03)
    button:SetPos(ScrW() * .01, ScrH() * .24)
    button:SetColor(Color(58,58,58))
    button:SetHoverColor(Color(1,36,0))
    button:SetText("Send")
    function button:DoClick()
        panel:Remove()
        success(textInput:GetText())
    end
end

function EventAutomation:CreateBoolModal(title, description, success)
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

    function panel:Paint(w, h)
        local x, y = self:LocalToScreen()

        BSHADOWS.BeginShadow()
            draw.RoundedBox(12, x, y, w, h, Color(36,36,36))
        BSHADOWS.EndShadow(1, 1, 2, 200, 0, 0)

        draw.DrawText(title, "EventAutomation.ModalTitle", w * .5, h * .03, color_white, TEXT_ALIGN_CENTER)

        local text = description
        text = SummeLibrary:WrapText(text, "EventAutomation.ModalText", ScrW() * .21)

        draw.DrawText(text, "EventAutomation.ModalText", w * .05, h * .15, color_white, TEXT_ALIGN_LEFT)
    end

    local acceptButton = EventAutomation:CreateButton(panel)
    acceptButton:SetSize(ScrW() * .218, ScrH() * .03)
    acceptButton:SetPos(ScrW() * .01, ScrH() * .2)
    acceptButton:SetColor(Color(50,50,50))
    acceptButton:SetHoverColor(Color(2,37,0))
    acceptButton:SetText("Continue")
    function acceptButton:DoClick()
        panel:Remove()
        success(true)
    end

    local declineButton = EventAutomation:CreateButton(panel)
    declineButton:SetSize(ScrW() * .218, ScrH() * .03)
    declineButton:SetPos(ScrW() * .01, ScrH() * .24)
    declineButton:SetColor(Color(50,50,50))
    declineButton:SetHoverColor(Color(37,0,0))
    declineButton:SetText("Cancel")
end