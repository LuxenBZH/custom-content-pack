Ext.Require("Shared/_InitShared.lua")

Ext.RegisterListener("SessionLoaded", function()
    Ext.Print(Ext.GetStat("LX_Guardian_Armor").MaxSummons)
    Ext.GetStat("LX_Guardian_Armor").MaxSummons = 10
end)

if Mods.LeaderLib then
    Mods.LeaderLib.Import(Mods.LuxensGameplayExpansion)
end
