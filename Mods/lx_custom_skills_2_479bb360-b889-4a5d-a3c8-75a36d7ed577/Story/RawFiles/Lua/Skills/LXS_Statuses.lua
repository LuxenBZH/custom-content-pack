---- Neurotoxin
--- @param character string GUID
--- @param status string Status Name
--- @param causee string GUID
Ext.RegisterOsirisListener("CharacterStatusRemoved", 3, "before", function(character, status, causee)
    if status == "LX_NEUROTOXIN" then
        if Ext.GetCharacter(character).Stats.CurrentMagicArmor < 1 then
            ApplyStatus(character, "LX_NEUROTOXIN_APPLY", 6.0, 1)
            ApplyStatus(character, "STUNNED", 6.0, 1)
        end
    end
    if status == "LX_MASSTELEPORT" then
        ApplyStatus(character, "DEACTIVATED", -1.0, 1)
        ApplyStatus(character, "SRP_VLOCK", -1.0, 1)
        PlayEffect(character, "RS3_FX_GP_Status_Windwalker_01_Reappear", "Dummy_BodyFX")
    end
end)

Ext.RegisterOsirisListener("ObjectTurnStarted", 1, "before", function(character)
    ClearTag(character, "LXS_BloodLustSatisfied")
end)