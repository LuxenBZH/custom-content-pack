Ext.Require("Shared/Helpers.lua")


Ext.Events.SessionLoaded:Subscribe(function(e)
    local firstAid = Ext.GetStat("Target_FirstAid")
    firstAid.CleanseStatuses = firstAid.CleanseStatuses..";LX_TRAUMA"
    local cleanseWounds = Ext.GetStat("Target_CleanseWounds")
    cleanseWounds.CleanseStatuses = firstAid.CleanseStatuses..";LX_TRAUMA"
    local massCleanseWounds = Ext.GetStat("Shout_MassCleanseWounds")
    massCleanseWounds.CleanseStatuses = firstAid.CleanseStatuses..";LX_TRAUMA"
end)