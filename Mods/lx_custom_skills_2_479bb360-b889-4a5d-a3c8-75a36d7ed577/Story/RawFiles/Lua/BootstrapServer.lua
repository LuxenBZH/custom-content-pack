Ext.Require("BootstrapShared.lua")
Ext.Require("Server/_InitServer.lua")

Ext.RegisterOsirisListener("CharacterUsedItemTemplate", 3, "before", function(character, template, item)
    if template == "e985c83d-82d7-4af4-9575-68bcbb48e2f2" then
        ApplyStatus(character, "DEACTIVATED", -1.0, 1)
    end
end)
