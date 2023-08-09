EventAutomation:RegisterNewOption("spawn_prop")
    :SetName("Spawn Prop")
    :SetColor(Color(204,204,204))
    :SetCategory("Entities")
    :AddAttribute("string", "MODEL_STRING", "models/props_c17/gravestone003a.mdl", true)
    :AddAttribute("vector", "POSITION_VECTOR", Vector(0, 0, 0), false)
    :AddAttribute("bool", "FREEZE", true, false)
    :SetServerCallback(function(attributes)
        local ent = ents.Create("prop_physics")
        ent:SetModel(attributes["MODEL_STRING"])
        ent:SetPos(attributes["POSITION_VECTOR"])
        ent:Spawn()

        if attributes["FREEZE"] == true then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
            end
        end
    end)
    :SetClientCallback(function(attributes)
        -- client side code here
        end)

EventAutomation:RegisterNewOption("remove_entity")
    :SetName("Remove Entity")
    :SetColor(Color(204,204,204))
    :SetCategory("Entities")
    :AddAttribute("entity", "ENTITY_ID", 0, true)
    :SetServerCallback(function(attributes)
        local id = tonumber(attributes["ENTITY_ID"])
        local ent = ents.GetByIndex(id)
        if not IsValid(ent) then return end

        SafeRemoveEntity(ent)
    end)
    :SetClientCallback(function(attributes)
        -- client side code here
        end)

local AllSents = scripted_ents.GetList()
local SpawnOptions = {}

for _, v in pairs( AllSents ) do
    if v and istable( v.t ) then
        if v.t.Spawnable then
            if v.t.Base and string.StartWith( v.t.Base:lower(), "lunasflightschool_basescript" ) then
                if v.t.Category and v.t.PrintName then
                    local nicename = v.t.Category.." - "..v.t.PrintName
                    if not table.HasValue( SpawnOptions, nicename ) then
                        SpawnOptions[nicename] = v.t.ClassName
                    end
                end
            end
        end
    end
end

EventAutomation:RegisterNewOption("spawn_lfs")
    :SetName("Spawn LFS")
    :SetColor(Color(204,204,204))
    :SetCategory("Entities")
    :AddAttribute("dropdown", "LFS_CLASS", "test", false, 1, {
        comboChoices = SpawnOptions
    })
    :AddAttribute("vector", "POSITION_VECTOR", Vector(0, 0, 0), false)
    :AddAttribute("bool", "ENABLE_AI", true, false)
    :SetServerCallback(function(attributes)
        local ent = ents.Create(attributes["LFS_CLASS"])
        if not IsValid(ent) then return end
        ent:SetPos(attributes["POSITION_VECTOR"] + Vector(0,0,70))
        ent:Spawn()

        if attributes["ENABLE_AI"] == true then
            ent:SetAI(true)
        end
    end)
    :SetClientCallback(function(attributes)
        -- client side code here
        end)

EventAutomation:RegisterNewOption("spawn_hyperspaced_ship")
    :SetName("Spawn Hyperspaced Ship")
    :SetColor(Color(204,204,204))
    :SetCategory("Entities")
    :AddAttribute("player_vector_angle", "Vec/Angle", "", false, 1)
    :TriggerClientside(true)
    :SetServerCallback(function(attributes)
        local pos, ang = stringToVectorAngle(attributes["Vec/Angle"])
        
        print(pos, ang)

        if not pos or not ang then print("error occured") return end

        ang.p = 0

        local ent = ents.Create("prop_physics")
        if not IsValid(ent) then return end
        ent:SetModel("models/salty/munificent-class.mdl")
        ent:SetPos(pos)
        ent:SetAngles(ang)
        ent:Spawn()

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
        end
    end)
    :SetClientCallback(function(attributes)
        util.ScreenShake(LocalPlayer():GetPos(), 10, 5, 3, 5000)
        surface.PlaySound("everfall/vehicles/shared/throttle_punch/throttlepunch_thrustersmallflamehigh_1.mp3")
    end)
