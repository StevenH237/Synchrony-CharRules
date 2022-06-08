local Event           = require "necro.event.Event"
local SettingsStorage = require "necro.config.SettingsStorage"

Event.runSettingsInit.add("initializeRandomizerSeed", { order = "randomizer", sequence = 1 }, function(ev)
  ev.settings["mod.CharRules.random"] = ev.seed or 0
end)
