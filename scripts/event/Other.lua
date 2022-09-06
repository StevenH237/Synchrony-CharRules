local Damage   = require "necro.game.system.Damage"
local Event    = require "necro.event.Event"
local Player   = require "necro.game.character.Player"
local Entities = require "system.game.Entities"

local CRSettings = require "CharRules.Settings"

Event.objectTakeDamage.add("luteShieldBypass", { order = "shield", sequence = -1, filter = "luteHead" }, function(ev)
  if Damage.Flag.check(ev.type, Damage.Flag.GOLDEN_LUTE) and CRSettings.get("tweaks.goldenLute") then
    ev.type = Damage.Flag.mask(ev.type, Damage.Flag.STRENGTH_BASED)
  end
end)
