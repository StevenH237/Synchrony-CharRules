local Action  = require "necro.game.system.Action"
local Enum    = require "system.utils.Enum"
local ItemBan = require "necro.game.item.ItemBan"

local Text = require "CharRules.i18n.Text"

local NLText = require "NixLib.i18n.Text"

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
  NO      = entry(-1, NLText.Disable),
  DEFAULT = entry(0, NLText.Default),
  YES     = entry(1, NLText.Enable)
}

module.Quatristate = Enum.sequence {
  NO      = entry(-1, NLText.Disable),
  DEFAULT = entry(0, NLText.Default),
  YES     = entry(1, NLText.Enable),
  RANDOM  = entry(2, NLText.Randomize)
}

do
  local gen = ItemBan.Type.GENERATION
  local genAll = ItemBan.Type.GENERATION_ALL
  local lock = ItemBan.Type.LOCK
  local full = ItemBan.Type.FULL
  local death = ItemBan.Flag.PICKUP_DEATH
  local fullDeath = bit.band(bit.bor(full, death), bit.bnot(ItemBan.Flag.PICKUP))

  module.ItemBan = Enum.sequence {
    NONE           = entry(0, Text.ItemBans.None),
    GENERATION     = entry(gen, Text.ItemBans.Generation),
    GENERATION_ALL = entry(genAll, Text.ItemBans.GenerationAll),
    LOCK           = entry(lock, Text.ItemBans.Lock),
    FULL           = entry(full, Text.ItemBans.Full),
    PICKUP_DEATH   = entry(death, Text.ItemBans.PickupDeath),
    FULL_DEADLY    = entry(fullDeath, Text.ItemBans.FullDeadly),
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
    CHAR_DEFAULT = entry(0, Text.ActionSets.CharDefault),

    STANDARD = entry(1, Text.ActionSets.Standard, {
      actionFilter = { ignoreActions = {
        [dir.UP_RIGHT] = true,
        [dir.UP_LEFT] = true,
        [dir.DOWN_LEFT] = true,
        [dir.DOWN_RIGHT] = true
      } },
      actionRemap = false
    }),

    -- Used by Diamond and Klarinetta.
    DIAMOND = entry(2, Text.ActionSets.Diamond, {
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

    DIAMOND_2 = entry(3, Text.ActionSets.Diamond2, {
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

    SKEW = entry(4, Text.ActionSets.Skew, {
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
