local Damage   = require "necro.game.system.Damage"
local Event    = require "necro.event.Event"
local Player   = require "necro.game.character.Player"
local Entities = require "system.game.Entities"

local CRSettings = require "CharRules.Settings"

Event.objectTakeDamage.override("luteShield", 1, function(func, ev)
  if CRSettings.get("tweaks.goldenLute") then
    if not Damage.Flag.check(ev.type, Damage.Flag.GOLDEN_LUTE) then
      return func(ev)
    end
  else
    return func(ev)
  end
end)
