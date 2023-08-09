EventAutomation:RegisterNewOption("util_timer")
    :SetName("Wait")
    :SetColor(Color(161,255,147))
    :SetCategory("Util")
    :AddAttribute("number", "SECONDS", 30, false)
    :SetServerCallback(function(attributes)

    end)
    :SetClientCallback(function(attributes)
        -- client side code here
    end)
