EventAutomation = {}

timer.Simple(0, function()
    SummeLibrary:Register({
        class = "eventsystem",
        name = "EventAutomation",
        color = Color(60,255,226),
        version = "Development",
    })
end)

hook.Add("EventAutomation.Registered", "34343", function()
    local rootDir = "eventsystem"

    local function AddFile(File, dir)
        local fileSide = string.lower(string.Left(File , 3))
    
        if SERVER and fileSide == "sv_" then
            include(dir..File)
        elseif fileSide == "sh_" then
            if SERVER then 
                AddCSLuaFile(dir..File)
            end
            include(dir..File)
        elseif fileSide == "cl_" then
            if SERVER then 
                AddCSLuaFile(dir..File)
            elseif CLIENT then
                include(dir..File)
            end
        end
    end
    
    local function IncludeDir(dir)
        dir = dir .. "/"
        local File, Directory = file.Find(dir.."*", "LUA")
    
        for k, v in ipairs(File) do
            if string.EndsWith(v, ".lua") then
                AddFile(v, dir)
            end
        end
        
        for k, v in ipairs(Directory) do
            IncludeDir(dir..v)
            print(v)
        end
    end

    IncludeDir(rootDir)
end)