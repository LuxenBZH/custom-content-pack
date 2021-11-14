-- Duelist's Leadership
local duelistCooldown = {}

local function DuelistLeadership_ReduceCooldown(character, skill, skillType, skillElement)
    if skill ~= "Shout_LX_DuelistLeadership" then return end
    local char = Ext.GetCharacter(character)
    local skills = char.GetSkills(char)
    local elligible = {}
    for i,s in pairs(skills) do
        if s ~= "Shout_LX_DuelistLeadership" and NRD_StatGetInt(s, "ActionPoints") == 1 and NRD_SkillGetCooldown(character, s) > 0.0 then elligible[s] = NRD_SkillGetCooldown(character, s) end
    end
    for s,cooldown in pairs(elligible) do
        NRD_SkillSetCooldown(character, s, 0.0)
    end
    duelistCooldown[character] = elligible
    TimerLaunch("LXS_ReduceCooldownOne", 30)
end

Ext.RegisterOsirisListener("CharacterUsedSKill", 4, "before", DuelistLeadership_ReduceCooldown)

local function DuelistLeadership_ReduceCooldown2(timer)
    if timer ~= "LXS_ReduceCooldownOne" then return end
    for character, elligible in pairs(duelistCooldown) do
        for skill,cooldown in pairs(elligible) do
            NRD_SkillSetCooldown(character, skill, cooldown-6.0)
        end
        duelistCooldown[character] = nil
    end
end

Ext.RegisterOsirisListener("TimerFinished", 1, "before", DuelistLeadership_ReduceCooldown2)