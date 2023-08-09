local t

function vectorAngleToString(vec, ang)
    local x = math.Round(vec.x)
    local y = math.Round(vec.y)
    local z = math.Round(vec.z)
    local p = math.Round(ang.p)
    local y = math.Round(ang.y)
    local r = math.Round(ang.r)
    
    return "Vector(" .. x .. ", " .. y .. ", " .. z .. ") Angle(" .. p .. ", " .. y .. ", " .. r .. ")"
end

function stringToVectorAngle(str)
    local vecStart, vecEnd = string.find(str, "Vector%(")
    local vecStr = string.sub(str, vecEnd+1, string.find(str, "%)", vecEnd+1)-1)
    local x, y, z = string.match(vecStr, "(-?%d+), (-?%d+), (-?%d+)")
  
    local angStart, angEnd = string.find(str, "Angle%(")
    local angStr = string.sub(str, angEnd+1, string.find(str, "%)", angEnd+1)-1)
    local p, y, r = string.match(angStr, "(-?%d+), (-?%d+), (-?%d+)")
  
    return Vector(x, y, z), Angle(p, y, r)
end

function EventAutomation.CalculateRuntime(nodeTable, startKey)
    local runtime = 0
  
    for key, entry in ipairs(nodeTable) do
        if key >= startKey and entry.id == "util_timer" and entry.attributeData.SECONDS then
            runtime = runtime + tonumber(entry.attributeData.SECONDS)
        end
    end
    
    return runtime
end