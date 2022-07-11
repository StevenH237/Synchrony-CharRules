local Enum    = require "system.utils.Enum"
local ItemBan = require "necro.game.item.ItemBan"

local module = {}

-----------
-- ENUMS --
--#region--

module.Inventory = Enum.sequence {
  DISABLE = 0,
  ADD = 1,
  REPLACE = 2
}

module.Tristate = Enum.sequence {
  NO = -1,
  DEFAULT = 0,
  YES = 1
}

module.Quatristate = Enum.sequence {
  NO = -1,
  DEFAULT = 0,
  YES = 1,
  RANDOM = 2
}

do
  local gen = ItemBan.Type.GENERATION
  local genAll = ItemBan.Type.GENERATION_ALL
  local lock = ItemBan.Type.LOCK
  local full = ItemBan.Type.FULL
  local death = ItemBan.Flag.PICKUP_DEATH
  local fullDeath = bit.band(bit.bor(full, death), bit.bnot(ItemBan.Flag.PICKUP))

  module.ItemBan = {
    NONE = 0,
    GENERATION = gen,
    GENERATION_ALL = genAll,
    LOCK = lock,
    FULL = full,
    PICKUP_DEATH = death,
    FULL_DEADLY = fullDeath,
    prettyNames = {
      [0] = "No bans",
      [gen] = "Don't generate except shrines",
      [genAll] = "Don't generate ever",
      [lock] = "Don't pickup or drop",
      [full] = "Don't pickup, drop, or generate",
      [death] = "Kill player on pickup",
      [fullDeath] = "Don't drop or generate, kill on pickup"
    }
  }
end

module.CharacterBitmask = {
  CADENCE = 1,
  MELODY = 2,
  ARIA = 4,
  DORIAN = 8,
  ELI = 16,
  MONK = 32,
  DOVE = 64,
  CODA = 128,
  BOLT = 256,
  BARD = 512,
  NOCTURNA = 1024,
  DIAMOND = 2048,
  MARY = 4096,
  TEMPO = 8192,
  -- REAPER=16384
}

--#endregion Enums

return module
