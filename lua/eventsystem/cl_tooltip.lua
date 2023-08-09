local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() * .13, ScrH() * .03)
    self:Center()
	self:SetDrawOnTop(true)

	self.text = "0"

	self._h = ScrH() * .03
end

function PANEL:Paint(w, h)
	if not IsValid(self.TargetPanel) then return end
	local tpData = self.TargetPanel.tpData

    draw.RoundedBox(5, 0, 0, w, h, Color(43,43,43))

	draw.DrawText(tpData.name, "EventAutomation.NodeTooltipHeader", w * .5, self._h * .08, tpData.color, TEXT_ALIGN_CENTER)

    local text = SummeLibrary:WrapText(self.text, "EventAutomation.NodeTooltip", w * .9)

    draw.DrawText(text, "EventAutomation.NodeTooltip", w * .5, self._h * .7, color_white, TEXT_ALIGN_CENTER)
end

function PANEL:SetText(text)
	self.text = text

	local w, h = self:GetSize()

	local text = SummeLibrary:WrapText(self.text, "EventAutomation.NodeTooltip", w * .9)
    draw.DrawText(text, "EventAutomation.NodeTooltip", w * .5, h * .28, color_white, TEXT_ALIGN_CENTER)
	surface.SetFont("EventAutomation.NodeTooltip")

	local tsizeX, tsizeY = surface.GetTextSize(text)

	self:SetSize(w, self._h + tsizeY)
end

function PANEL:Close()
	self:Remove()
end

local tooltip_delay = CreateClientConVar( "tooltip_delay", "0.5", true, false )

function PANEL:PositionTooltip()

	if ( !IsValid( self.TargetPanel ) ) then
		self:Close()
		return
	end

	self:InvalidateLayout( true )

	local x, y = input.GetCursorPos()
	local w, h = self:GetSize()

	local lx, ly = self.TargetPanel:LocalToScreen( 0, 0 )

	y = y - 50

	y = math.min( y, ly - h * 1.5 )
	if ( y < 2 ) then y = 2 end

	-- Fixes being able to be drawn off screen
	self:SetPos( math.Clamp( x - w * 0.5, 0, ScrW() - self:GetWide() ), math.Clamp( y, 0, ScrH() - (self:GetTall() * .1) ) )

end

function PANEL:OpenForPanel( panel )

	self.TargetPanel = panel
	self:PositionTooltip()

	-- Use the parent panel's skin
	self:SetSkin( panel:GetSkin().Name )

	if ( tooltip_delay:GetFloat() > 0 ) then

		self:SetVisible( false )
		timer.Simple( tooltip_delay:GetFloat(), function()

			if ( !IsValid( self ) ) then return end
			if ( !IsValid( panel ) ) then return end

			self:PositionTooltip()
			self:SetVisible( true )

		end )
	end

end

vgui.Register("Summe.Tooltip", PANEL, "Panel")