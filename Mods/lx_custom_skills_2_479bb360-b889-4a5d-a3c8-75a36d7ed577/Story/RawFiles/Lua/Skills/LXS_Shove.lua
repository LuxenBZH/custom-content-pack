-- Shove
local rip = {}


local function KillFromFallOutsideMap(timer)
    if timer ~= "LXS_RipFall" then return end
    for i,char in pairs(rip) do
        CharacterDie(char, 0, "Physical")
        rip[i] = nil
    end
end

Ext.RegisterOsirisListener("TimerFinished", 1, "before", KillFromFallOutsideMap)

local function CreateHeightMap(target, distance, vector)
    local heightMap = {}
    local targetPos = Ext.GetCharacter(target).WorldPos
    if targetPos == nil then targetPos = Ext.GetItem(target).WorldPos end
    for x=0,40,1 do
        local newX = targetPos[1]+vector[1] * (x/distance)
        local newZ = targetPos[3]+vector[3] * (x/distance)
        if Ext.GetAiGrid():GetCellInfo(newX, newZ) == nil then return heightMap end
        heightMap[x+1] = Ext.GetAiGrid():GetCellInfo(newX, newZ).Height
        Ext.Print(heightMap[x+1])
    end
    return heightMap
end

local function GetFirstCliffEnd(heightmap)
    local pos
    local previous = heightmap[1]
    local slope = false
    for x=2,#heightmap,1 do
        if previous + 2 >= heightmap[x] and previous - 2 <= heightmap[x] then
            slope = false
        elseif heightmap[x] > previous + 2 then
            slope = false
            pos = x
            return
        else
            slope = true
        end
        if slope then
            pos = x
        end
        if not slope and pos ~= nil then return pos end
        previous = heightmap[x]
    end
    return pos
end

local function ShoveCharacter(target, instigator)
    local casterPos = Ext.GetCharacter(instigator).WorldPos
    local targetPos = Ext.GetCharacter(target).WorldPos
    if targetPos == nil then targetPos = Ext.GetItem(target).WorldPos end
    local vector = {}
    local distance = GetDistanceTo(target, instigator)
    -- local multiplier = 4/distance
    for i=1,3,1 do
        vector[i] = (targetPos[i] - casterPos[i])
    end
    local heightmap = CreateHeightMap(target, distance, vector)
    local cliffEnd = GetFirstCliffEnd(heightmap)
    -- Ext.ExecuteSkillPropertiesOnTarget("Projectile_LX_Shove_"..f, targets[target], target, Ext.GetCharacter(instigator).WorldPos, "Target", false)
    local newX = targetPos[1]+vector[1] * (4/distance)
    local newZ = targetPos[3]+vector[3] * (4/distance)
    local newY = heightmap[4]
    -- Ext.Print(, Ext.GetAiGrid():GetCellInfo(newX, newZ).Height, targetPos[2])
    -- if FindValidPosition(newX, newY, newZ, 0.1, target) ~= nil then
    --     local forcePush = NRD_CreateGameObjectMove(target, newX, newY-3, newZ, "Projectile_LX_Shove_6", targets[target])
    -- end
    --"4895f079-2b4d-4df7-b528-235f3b9db17c"
    --"5b229b34-16e4-4f4e-bd77-910fa9af26dd"
    
    local dummy = CreateItemTemplateAtPosition("4895f079-2b4d-4df7-b528-235f3b9db17c", casterPos[1]+vector[1]*(6/distance), casterPos[2]+1, casterPos[3]+vector[3]*(6/distance))
    -- local dummyOrigin = CreateItemTemplateAtPosition("5b229b34-16e4-4f4e-bd77-910fa9af26dd", targetPos[1], targetPos[2]+1.2, targetPos[3])
    -- local dummyTarget = CreateItemTemplateAtPosition("5b229b34-16e4-4f4e-bd77-910fa9af26dd", targetPos[1]+vector[1]*(2/distance), targetPos[2]-1, targetPos[3]+vector[3]*(2/distance))
    local sightCheck = HasLineOfSight(instigator, dummy)
    Ext.Print("Cliff end:",cliffEnd)
    if cliffEnd == nil then cliffEnd = 0 end
    if FindValidPosition(newX, newY, newZ, 0.1, target) ~= nil and heightmap[cliffEnd] ~= nil and (cliffEnd > 4 or targetPos[2] - heightmap[cliffEnd] < 5) then
        Ext.Print("--- Condition 1")
        Ext.ExecuteSkillPropertiesOnTarget("Projectile_LX_Shove_4", instigator, target, Ext.GetCharacter(instigator).WorldPos, "Target", false)
        return
    elseif cliffEnd ~= 0 and sightCheck == 1 then
        Ext.Print("--- Condition 2")
        local shift = Ext.Round((targetPos[2]-heightmap[cliffEnd+3])/2.5)
        if shift < 0 then shift = 0 end
        --Verify if the shift isn't pushing on another cliff
        for i=1,shift,1 do
            shift = i
            if heightmap[cliffEnd+i] > heightmap[cliffEnd]+1 then
                break
            end
        end
        Ext.Print("Shift :",shift)
        newX = targetPos[1]+vector[1] * (cliffEnd+shift/distance)
        newZ = targetPos[3]+vector[3] * (cliffEnd+shift/distance)
        newY = heightmap[cliffEnd+shift]
        local valid = true
        -- Find a valid position in priority
        if FindValidPosition(newX, newY, newZ, 0.1, target) == nil then
            valid = false
            for i=cliffEnd+shift,cliffEnd+shift+20,1 do
                Ext.Print(i)
                if heightmap[i] > heightmap[cliffEnd+shift] + 1 then
                    Ext.Print("Hit another cliff")
                    break
                end
                newX = targetPos[1] + vector[1] * (i/distance)
                newZ = targetPos[3] + vector[3] * (i/distance)
                newY = heightmap[i] 
                if FindValidPosition(newX, newY, newZ, 0.1, target) ~= nil then 
                    valid = true
                    Ext.Print("Valid position")
                    break
                end
            end
        end
        -- If there is absolutely no valid position, then set a fixed position in red AI grid
        if not valid then
            newX = targetPos[1]+vector[1] * (cliffEnd+4/distance)
            newZ = targetPos[3]+vector[3] * (cliffEnd+4/distance)
            newY = heightmap[cliffEnd+4]
            if targetPos[2] - 10 < newY then
                Ext.ExecuteSkillPropertiesOnTarget("Projectile_LX_Shove_6", instigator, target, Ext.GetCharacter(instigator).WorldPos, "Target", false)
                return
            end
        end
        Ext.Print(valid)

        local forcePush = NRD_CreateGameObjectMove(target, newX, newY, newZ, "Projectile_LX_Shove_6", instigator)
        if not valid then
            table.insert(rip, target)
            TimerLaunch("LXS_RipFall", 2000)
        end
    else
        Ext.Print("--- Condition 3")
        Ext.ExecuteSkillPropertiesOnTarget("Projectile_LX_Shove_4", instigator, target, Ext.GetCharacter(instigator).WorldPos, "Target", false)
        -- NRD_ProjectilePrepareLaunch()
        -- NRD_ProjectileSetString("SkillId", "ProjectileStrike_Stormbolt_Fire")
        -- NRD_ProjectileSetVector3("SourcePosition", newX, newY, newZ)
        -- NRD_ProjectileSetVector3("TargetPosition", newX, newY, newZ)
        -- NRD_ProjectileLaunch()
    end
end

local function RegisterShoveUse(target, instigator, damage, handle)
    local skillID = NRD_StatusGetString(target, handle, "SkillId")
    skillID = string.gsub(skillID, "%_%-1", "")
    if skillID ~= "Target_LX_Kick" then return end
    -- if ObjectIsCharacter(target) == 1 then
        ShoveCharacter(target, instigator)
    -- end
    -- TimerLaunch("LXS_ShoveCheck", 50)
end

Ext.RegisterOsirisListener("NRD_OnHit", 4, "before", RegisterShoveUse)