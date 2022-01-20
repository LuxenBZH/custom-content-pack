if Mods.LeaderLib then
    RegisterSkillListener("Shout_LX_GuardianArmorSplit", function(skill, char, state, data)
        if state == "CAST" then
            local character = Ext.GetCharacter(char)
            local pos = character.WorldPos
            local currentFaction = GetFaction(char)
            local head = CharacterCreateAtPosition(pos[1], pos[2], pos[3], "a173cf17-ec1a-426f-a954-906fc87fe51e", 0)
            local sword = CharacterCreateAtPosition(pos[1], pos[2], pos[3], "af2af46a-6a2f-4703-931e-8b005fb9df8f", 1)
            local arms = CharacterCreateAtPosition(pos[1], pos[2], pos[3], "d6c59f92-19eb-4bd6-93d1-ef71efff1652", 1)
            local feet = CharacterCreateAtPosition(pos[1], pos[2], pos[3], "dc239310-a06c-4b77-9b71-6b141afb6387", 1)
            CharacterLevelUpTo(head, character.Stats.Level)
            ItemLevelUpTo(CharacterGetEquippedWeapon(head), character.Stats.Level)
            CharacterLevelUpTo(sword, character.Stats.Level)
            ItemLevelUpTo(CharacterGetEquippedWeapon(sword), character.Stats.Level)
            CharacterLevelUpTo(arms, character.Stats.Level)
            ItemLevelUpTo(CharacterGetEquippedWeapon(arms), character.Stats.Level)
            CharacterLevelUpTo(feet, character.Stats.Level)
            ItemLevelUpTo(CharacterGetEquippedWeapon(feet), character.Stats.Level)
            SetFaction(head, currentFaction)
            SetFaction(sword, currentFaction)
            SetFaction(arms, currentFaction)
            SetFaction(feet, currentFaction)
            ApplyStatus(char, "DEACTIVATED", -1, 1)
            MoveAllItemsTo(char, head, 0, 0, 1)
            -- SetOnStage(char, 0)
        end
    end)
end