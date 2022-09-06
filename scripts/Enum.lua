local Action  = require "necro.game.system.Action"
local Enum    = require "system.utils.Enum"
local ItemBan = require "necro.game.item.ItemBan"

local module = {}

local function entry(num, name, data)
  data = data or {}
  data.name = name
  return Enum.entry(num, data)
end

-----------
-- ENUMS --
--#region--

module.Tristate = Enum.sequence {
  NO      = entry(-1, "Disable"),
  DEFAULT = entry(0, "Default"),
  YES     = entry(1, "Enable")
}

module.Quatristate = Enum.sequence {
  NO      = entry(-1, "Disable"),
  DEFAULT = entry(0, "Default"),
  YES     = entry(1, "Enable"),
  RANDOM  = entry(2, "Randomize")
}

do
  local gen = ItemBan.Type.GENERATION
  local genAll = ItemBan.Type.GENERATION_ALL
  local lock = ItemBan.Type.LOCK
  local full = ItemBan.Type.FULL
  local death = ItemBan.Flag.PICKUP_DEATH
  local fullDeath = bit.band(bit.bor(full, death), bit.bnot(ItemBan.Flag.PICKUP))

  module.ItemBan = Enum.sequence {
    NONE           = entry(0, "No bans"),
    GENERATION     = entry(gen, "Don't generate except shrines"),
    GENERATION_ALL = entry(genAll, "Don't generate at all"),
    LOCK           = entry(lock, "Don't pick up or drop"),
    FULL           = entry(full, "Don't pick up, drop, or generate"),
    PICKUP_DEATH   = entry(death, "Kill player on pickup"),
    FULL_DEADLY    = entry(fullDeath, "Don't drop or generate, kill on pickup"),
  }
end

module.CharacterBitmask = {
  CADENCE  = 1,
  MELODY   = 2,
  ARIA     = 4,
  DORIAN   = 8,
  ELI      = 16,
  MONK     = 32,
  DOVE     = 64,
  CODA     = 128,
  BOLT     = 256,
  BARD     = 512,
  NOCTURNA = 1024,
  DIAMOND  = 2048,
  MARY     = 4096,
  TEMPO    = 8192,
  -- REAPER=16384
}

do
  local dir = Action.Direction
  local spe = Action.Special

  local actionSets = {
    CHAR_DEFAULT = entry(0, "Character default"),

    STANDARD = entry(1, "Standard movement", {
      actionFilter = { ignoreActions = {
        [dir.UP_RIGHT] = true,
        [dir.UP_LEFT] = true,
        [dir.DOWN_LEFT] = true,
        [dir.DOWN_RIGHT] = true
      } },
      actionRemap = false
    }),

    -- Used by Diamond and Klarinetta.
    DIAMOND = entry(2, "Diamond movement (8-way + Item/bomb)", {
      actionFilter = { ignoreActions = {
        [spe.ITEM_2] = true,
        [spe.THROW] = true,
        [spe.SPELL_1] = true,
        [spe.SPELL_2] = true
      } },
      actionRemap = { map = {
        [spe.ITEM_1] = spe.ITEM_2,
        [spe.ITEM_2] = spe.ITEM_1,
        [spe.THROW] = spe.BOMB,
        [spe.BOMB] = spe.THROW
      } }
    }),

    DIAMOND_2 = entry(3, "8-way + spells", {
      actionFilter = { ignoreActions = {
        [spe.ITEM_2] = true,
        [spe.THROW] = true,
        [spe.ITEM_1] = true,
        [spe.BOMB] = true
      } },
      actionRemap = { map = {
        [spe.SPELL_1] = spe.ITEM_2,
        [spe.ITEM_2] = spe.SPELL_1,
        [spe.THROW] = spe.SPELL_2,
        [spe.SPELL_2] = spe.THROW
      } }
    }),

    SKEW = entry(4, "Skew (U-UR-D-DL)", {
      actionFilter = { ignoreActions = {
        [dir.LEFT] = true,
        [dir.UP_LEFT] = true,
        [dir.RIGHT] = true,
        [dir.DOWN_RIGHT] = true
      } },
      actionRemap = { map = {
        [dir.LEFT] = dir.DOWN_LEFT,
        [dir.DOWN_LEFT] = dir.LEFT,
        [dir.RIGHT] = dir.UP_RIGHT,
        [dir.UP_RIGHT] = dir.RIGHT
      } }
    })
  }

  module.ActionSets = Enum.sequence(actionSets)
end
--#endregion Enums

return module
