if not PersistentVars then
    PersistentVars = {}
end

Ext.Require("Shared/_InitShared.lua")

if Mods.LeaderLib then
    Mods.LeaderLib.Import(Mods.LuxensGameplayExpansion)
end
