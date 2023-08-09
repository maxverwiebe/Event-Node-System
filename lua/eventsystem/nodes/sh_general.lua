EventAutomation:RegisterNewOption("gravity")
    :SetName("Gravity")
    :SetColor(Color(193,255,253))
    :SetCategory("General")
    :SetDescription("Changes the gravity globally for players. Default = 600.")
    :AddAttribute("number", "VALUE", 600, false)
    :SetServerCallback(function(attributes)
        RunConsoleCommand("sv_gravity",attributes["VALUE"])
    end)
    :SetClientCallback(function(attributes)
        -- client side code here
    end)

EventAutomation:RegisterNewOption("flashlight")
    :SetName("Control Flashlight")
    :SetColor(Color(193,255,253))
    :SetCategory("General")
    :AddAttribute("bool", "ALLOW_FLASHLIGHT", true, true)
    :SetServerCallback(function(attributes)
        if attributes["ALLOW_FLASHLIGHT"] then
            hook.Remove("PlayerSwitchFlashlight", "EventAutomation.AllowFlashlight")
            return
        end

        hook.Add("PlayerSwitchFlashlight", "EventAutomation.AllowFlashlight", function( ply, enabled )
            if enabled then
                return false
            end
            return true
        end)

    end)
    :SetClientCallback(function(attributes)
        -- client side code here
    end)

if SummeLibrary.Addons["comlink"] then
    EventAutomation:RegisterNewOption("comlink")
        :SetName("Control Comlink")
        :SetColor(Color(193,255,253))
        :SetCategory("General")
        :AddAttribute("bool", "ALLOW_COMLINK", true, true)
        :SetServerCallback(function(attributes)
            Comlink:ChangeStatus(attributes["ALLOW_COMLINK"])
        end)
        :SetClientCallback(function(attributes)
            -- client side code here
        end)
end

EventAutomation:RegisterNewOption("mapchange")
    :SetName("Mapchange")
    :SetColor(Color(193,255,253))
    :SetCategory("General")
    :AddAttribute("dropdown", "MAP_NAME", "test", false, 1, {
        comboChoices = {"gm_flatgrass"}
    })
    :SetServerCallback(function(attributes)
        timer.Simple(3, function()
            RunConsoleCommand("changelevel", attributes["MAP_NAME"])
        end)
    end)
    :TriggerClientside(true)
    :SetClientCallback(function(attributes)
        chat.AddText(Color(255,0,0), "! ", color_white, "Changing map to ", Color(25,255,255), attributes["MAP_NAME"])
    end)