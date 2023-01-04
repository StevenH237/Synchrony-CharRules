--#region Imports
local Boss            = require "necro.game.level.Boss"
local Damage          = require "necro.game.system.Damage"
local Entities        = require "system.game.Entities"
local GameDLC         = require "necro.game.data.resource.GameDLC"
local ItemBan         = require "necro.game.item.ItemBan"
local Menu            = require "necro.menu.Menu"
local Progression     = require "necro.game.system.Progression"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local Text = require "CharRules.i18n.Text"

local PowerSettings = require "PowerSettings.PowerSettings"

local CREnum = require "CharRules.Enum"

local NixLib = require "NixLib.NixLib"

local CSILoaded = pcall(require, "ControlledStartingInventory.CSISettings")
--#endregion Imports

---------------
-- FUNCTIONS --
--#region------

local function get(setting)
  return PowerSettings.get("mod.CharRules." .. setting)
end

--#endregion

----------------
-- FORMATTERS --
--#region-------

--NOTE: THIS RETURNS A FUNCTION, CALL IT IN YOUR SETTINGS DEF WITH THE DEFAULT VALUE
--For example, "numberFormat(0)" returns a format function that says "(Default)" for zero.
local function numberFormat(def, off, dis)
  off = off or 0
  dis = dis or nil

  return function(val)
    if val == def then return Text.Formats.Default end
    if val == dis then return Text.Formats.Disabled end
    val = val + off
    return tostring(val)
  end
end

local function healthFormat(amt)
  if amt == 0 then return Text.Formats.Default end
  if amt == 1 then return Text.Formats.Hearts05 end
  if amt == 2 then return Text.Formats.Hearts1 end
  if amt == 3 then return Text.Formats.Hearts15 end
  if amt == 4 then return Text.Formats.Hearts2 end
  if amt == 5 then return Text.Formats.Hearts25 end
  return Text.Formats.HeartsPlus(amt, amt / 2)
end

local function zeroableHealthFormat(amt)
  if amt == 0 then return Text.Formats.None end
  return healthFormat(amt)
end

--#endregion Formatters

--------------
-- ENABLERS --
--#region-----

-- NOTE: ALL FUNCTIONS IN THIS SECTION RETURN FUNCTIONS
-- USE visibleIf=funcName(param) IN THE SETTINGS CALL

local function both(a, b)
  return function()
    return a() and b()
  end
end

local function either(a, b)
  return function()
    return a() or b()
  end
end

local function anti(a)
  return function()
    return not a()
  end
end

local function isAdvanced(exp)
  if exp == nil then exp = true end

  return function()
    return PowerSettings.get("config.showAdvanced") == exp
  end
end

local function isAmplified(exp)
  if exp == nil then exp = true end

  return function()
    return GameDLC.isAmplifiedLoaded() == exp
  end
end

local function isSynchrony(exp)
  if exp == nil then exp = true end

  return function()
    return GameDLC.isSynchronyLoaded()
  end
end

local function isCharacterUnlocked(character)
  return function()
    return Progression.isUnlocked(Progression.UnlockType.PLAYABLE_CHARACTER, character) or get("characters.showAll")
  end
end

local function anyCharacterLocked()
  return function()
    for _, char in ipairs({ "Aria", "Dorian", "Eli", "Monk", "Dove", "Bolt", "Bard" }) do
      if Progression.isLocked(Progression.UnlockType.PLAYABLE_CHARACTER, char) then
        return true
      end
    end

    if isAmplified() then
      for _, char in ipairs({ "Diamond", "Mary", "Tempo" }) do
        if Progression.isLocked(Progression.UnlockType.PLAYABLE_CHARACTER, char) then
          return true
        end
      end
    end
  end
end

--#endregion Enablers

-------------
-- ACTIONS --
--#region----

--#endregion

--------------
-- SETTINGS --
--#region-----

PowerSettings.autoRegister()

PowerSettings.entitySchema.number {
  id = "random",
  name = "Random seed",
  desc = "Seed for the randomizer. Always randomized when a run starts.",
  visibility = Settings.Visibility.HIDDEN
}

PowerSettings.group {
  id = "characters",
  name = "Character-specific rules",
  desc = "The rules that specific characters bring to the table.",
  order = 1
}

--#region CHARACTER SETTINGS--
PowerSettings.entitySchema.label {
  id = "characters.header",
  name = "Jump between sections with left/right on section headers!",
  order = 0
}

PowerSettings.entitySchema.bool {
  id = "characters.showAll",
  name = "Show all characters",
  desc = "Show rules for all characters, even those not yet unlocked.",
  order = 1,
  visibleIf = anyCharacterLocked()
}

PowerSettings.shared.header {
  id = "characters.aria",
  name = "Aria's rules",
  order = 10,
  visibleIf = isCharacterUnlocked("Aria")
}

PowerSettings.entitySchema.enum {
  id = "characters.missedBeat",
  name = "Damage on missed beat",
  desc = "Whether or not players should take damage on a missed beat.",
  order = 11,
  visibleIf = isCharacterUnlocked("Aria"),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.number {
  id = "characters.missedBeatDamage",
  name = "Amount of damage",
  desc = "The amount of damage on a missed beat.",
  order = 12,
  visibleIf = both(isAdvanced(), isCharacterUnlocked("Aria")),
  default = 0,
  minimum = 0,
  maximum = 50,
  format = healthFormat
}

PowerSettings.entitySchema.bitflag {
  id = "characters.missedBeatType",
  name = "Type of damage",
  desc = "The type of damage on a missed beat.",
  order = 13,
  visibleIf = both(isAdvanced(), isCharacterUnlocked("Aria")),
  default = Damage.Type.SELF_DAMAGE,
  flags = Damage.Flag,
  presets = Damage.Type
}

PowerSettings.entitySchema.enum {
  id = "characters.bypassSarcophagus",
  name = "Bypass sarcophagus",
  desc = "Whether or not stairs should be locked until a sarcophagus is destroyed",
  order = 14,
  visibleIf = both(isAdvanced(), isCharacterUnlocked("Aria")),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.shared.header {
  id = "characters.dorian",
  name = "Dorian's rules",
  order = 20,
  visibleIf = isCharacterUnlocked("Dorian")
}

PowerSettings.entitySchema.enum {
  id = "characters.cursedBoots",
  name = "Boots of painful leaping",
  desc = "Should boots of leaping or lunging cause damage when disabled while moving",
  order = 21,
  visibleIf = isCharacterUnlocked("Dorian"),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.label {
  id = "characters.cursedBootsLabel",
  name = "To actually apply the boots, go to Inventory.",
  order = 22,
  visibleIf = isCharacterUnlocked("Dorian")
}

PowerSettings.entitySchema.number {
  id = "characters.cursedBootsDamage",
  name = "Amount of damage",
  desc = "The amount of damage from cursed boots.",
  order = 23,
  visibleIf = both(isAdvanced(), isCharacterUnlocked("Dorian")),
  default = 0,
  minimum = 0,
  maximum = 50,
  format = healthFormat
}

PowerSettings.entitySchema.bitflag {
  id = "characters.cursedBootsType",
  name = "Type of damage",
  desc = "The type of damage from cursed boots.",
  order = 24,
  visibleIf = both(isAdvanced(), isCharacterUnlocked("Dorian")),
  default = Damage.Type.BLOOD,
  flags = Damage.Flag,
  presets = Damage.Type
}

PowerSettings.shared.header {
  id = "characters.eli",
  name = "Eli's rules",
  order = 30,
  visibleIf = isCharacterUnlocked("Eli")
}

PowerSettings.entitySchema.label {
  id = "characters.eliBombs",
  name = "For infinite bombs, go to Inventory.",
  order = 31,
  visibleIf = isCharacterUnlocked("Eli")
}

PowerSettings.entitySchema.enum {
  id = "characters.eliWalls",
  name = "Empty shop walls",
  desc = "Should shop walls be devoid of gold?",
  order = 32,
  visibleIf = isCharacterUnlocked("Eli"),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.shared.header {
  id = "characters.monk",
  name = "Monk's rules",
  order = 40,
  visibleIf = isCharacterUnlocked("Monk")
}

PowerSettings.entitySchema.enum {
  id = "characters.poverty",
  name = "Vow of poverty",
  desc = "Die on picking up gold",
  order = 41,
  visibleIf = isCharacterUnlocked("Monk"),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "characters.shoplifter",
  name = "Free items from shops",
  desc = "Character receives one free item per shop",
  order = 42,
  visibleIf = isCharacterUnlocked("Monk"),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "characters.descentCollect",
  name = "Collect gold on stairs",
  desc = "When descending the stairs, pickup all dropped gold",
  order = 43,
  visibleIf = isCharacterUnlocked("Monk"),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "characters.enemyGold",
  name = "All enemies drop gold",
  desc = "All enemies drop at least one gold when killed",
  order = 44,
  visibleIf = isCharacterUnlocked("Monk"),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.shared.header {
  id = "characters.dove",
  name = "Dove's rules",
  order = 50,
  visibleIf = isCharacterUnlocked("Dove")
}

PowerSettings.entitySchema.label {
  id = "characters.doveLabel",
  name = "For the flower, go to Inventory.",
  order = 51,
  visibleIf = isCharacterUnlocked("Dove")
}

PowerSettings.entitySchema.enum {
  id = "characters.teleportingBombs",
  name = "Teleporting bombs",
  desc = "When enemies are hit by bombs, they're teleported instead of damaged.",
  order = 52,
  visibleIf = isCharacterUnlocked("Dove"),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "characters.bypassMiniboss",
  name = "Bypass miniboss",
  desc = "Should minibosses be bypassed for the stairs lock?",
  order = 53,
  visibleIf = isCharacterUnlocked("Dove"),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.shared.header {
  id = "characters.bolt",
  name = "Bolt's rules",
  order = 60,
  visibleIf = isCharacterUnlocked("Bolt")
}

PowerSettings.entitySchema.number {
  id = "characters.customTempo",
  name = "Tempo multiplier",
  desc = "Should characters play at a custom tempo",
  order = 62,
  default = 0,
  minimum = 0,
  maximum = 20,
  format = numberFormat(0),
  visibleIf = isCharacterUnlocked("Bolt")
}

PowerSettings.shared.header {
  id = "characters.bard",
  name = "Bard's rules",
  order = 70
}

PowerSettings.entitySchema.enum {
  id = "characters.noBeats",
  name = "Ignore rhythm",
  desc = "Characters ignore the rhythm of the music.",
  order = 71,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.shared.header {
  id = "characters.reaper",
  name = "Reaper's rules",
  order = 80
}

PowerSettings.entitySchema.enum {
  id = "characters.spawnSouls",
  name = "Spawn souls on kills",
  desc = "Should souls spawn from killed enemies?",
  order = 81,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.shared.header {
  id = "characters.diamond",
  name = "Diamond's rules",
  order = 90,
  visibleIf = both(isAmplified(), isCharacterUnlocked("Diamond"))
}

PowerSettings.shared.label {
  id = "characters.diamondLabel",
  name = "Movement directions are under the \"Unspecific rules\" category!",
  order = 91,
  visibleIf = both(isAmplified(), isCharacterUnlocked("Diamond"))
}

PowerSettings.shared.header {
  id = "characters.mary",
  name = "Mary's rules",
  order = 100,
  visibleIf = isAmplified()
}

PowerSettings.entitySchema.enum {
  id = "characters.marv",
  name = "Protect a sheep",
  desc = "A sheep follows you that must be kept alive",
  order = 101,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAmplified(),
  ignoredIf = isAmplified(false)
}

PowerSettings.shared.header {
  id = "characters.tempo",
  name = "Tempo's rules",
  order = 110,
  visibleIf = isAmplified()
}

PowerSettings.entitySchema.enum {
  id = "characters.damageUp",
  name = "Increase damage",
  desc = "Should your attack damage be increased",
  order = 111,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAmplified(),
  ignoredIf = isAmplified(false)
}

PowerSettings.entitySchema.number {
  id = "characters.damageUpAmount",
  name = "Damage increase amount",
  desc = "How much should your attack damage be increased",
  order = 112,
  default = 0,
  minimum = 0,
  maximum = 999,
  editAsString = true,
  visibleIf = both(isAdvanced(), isAmplified()),
  ignoredIf = isAmplified(false),
  format = numberFormat(0)
}

PowerSettings.entitySchema.enum {
  id = "characters.killTimer",
  name = "Kill timer",
  desc = "Must kill every few beats or you take damage",
  order = 113,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAmplified(),
  ignoredIf = isAmplified(false)
}

PowerSettings.entitySchema.number {
  id = "characters.killTimerDamage",
  name = "Amount of damage",
  desc = "The amount of damage from the kill timer.",
  order = 114,
  visibleIf = both(isAdvanced(), isAmplified()),
  ignoredIf = isAmplified(false),
  default = 0,
  minimum = 0,
  maximum = 999,
  format = healthFormat
}

PowerSettings.entitySchema.bitflag {
  id = "characters.killTimerType",
  name = "Type of damage",
  desc = "The type of damage from the kill timer.",
  order = 115,
  visibleIf = both(isAdvanced(), isAmplified()),
  ignoredIf = isAmplified(false),
  default = Damage.Type.SUICIDE,
  flags = Damage.Flag,
  presets = Damage.Type
}
--#endregion

PowerSettings.group {
  id = "unspecific",
  name = "Unspecific rules",
  desc = "Other rules that don't apply to specific characters",
  order = 1.5,
  visibleIf = isAdvanced(),
}

--#region UNSPECIFIC RULES--

PowerSettings.entitySchema.enum {
  id = "unspecific.actions",
  name = "Allowed actions",
  desc = "Which actions can the player take?",
  order = 0,
  visibleIf = isAdvanced(),
  enum = CREnum.ActionSets,
  default = CREnum.ActionSets.DEFAULT
}

--#endregion

PowerSettings.group {
  id = "inventory",
  name = "Inventory",
  desc = "Rules about the inventory.",
  order = 2
}

--#region INVENTORY SETTINGS--
PowerSettings.group {
  id = "inventory.items",
  name = "Items",
  desc = "Set specific items here.",
  order = 0
}

--#region Items settings--
PowerSettings.entitySchema.bool {
  id = "inventory.items.clear",
  name = "Clear inventory",
  desc = "Clear inventory before giving new items",
  order = 0,
  default = false
}

PowerSettings.entitySchema.list.entity {
  id = "inventory.items.give",
  name = "Give items",
  desc = "Add more items",
  order = 1,
  default = {},
  filter = "item",
  itemDefault = "MiscPotion"
}
--#endregion

PowerSettings.group {
  id = "inventory.bans",
  name = "Bans",
  desc = "Set item bans here.",
  order = 1
}

--#region Item bans settings--

PowerSettings.entitySchema.enum {
  id = "inventory.bans.cirt",
  name = "Heart transplants",
  desc = "Items that ignore the rhythm temporarily on use",
  order = 0,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.bans.healthlocked",
  name = "Health-increasing items",
  desc = "Items that increase health",
  order = 1,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.bans.noDamage",
  name = "Damage-increasing items",
  desc = "Items that increase damage output",
  order = 2,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.bans.pacifist",
  name = "Pacifism",
  desc = "Item bans due to pacifism",
  order = 3,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.bans.poverty",
  name = "Gold-collecting items",
  desc = "Items that collect gold",
  order = 4,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.bans.weaponlocked",
  name = "Weapons",
  desc = "Other weapons",
  order = 5,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.bans.grooveChainImmunity",
  name = "Groove chain immunity",
  desc = "Items that ignore missed beats while held",
  order = 6,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

--#endregion

PowerSettings.group {
  id = "inventory.curses",
  name = "Cursed inventory slots",
  desc = "Curse slots.",
  order = 2,
  visibleIf = isAdvanced()
}

--#region Inventory curses settings--

PowerSettings.entitySchema.enum {
  id = "inventory.curses.action",
  name = "Consumable item",
  desc = "Curse the consumable item slot",
  order = 0,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.shovel",
  name = "Shovel",
  desc = "Curse the shovel slot",
  order = 1,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.weapon",
  name = "Weapon",
  desc = "Curse the weapon slot",
  order = 2,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.body",
  name = "Body (armor)",
  desc = "Curse the body slot",
  order = 3,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.head",
  name = "Head",
  desc = "Curse the head slot",
  order = 4,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.feet",
  name = "Feet",
  desc = "Curse the feet slot",
  order = 5,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.torch",
  name = "Torch",
  desc = "Curse the torch item slot",
  order = 6,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.ring",
  name = "Ring",
  desc = "Curse the ring slot",
  order = 7,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.misc",
  name = "Charms",
  desc = "Curse the charms slot",
  order = 8,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.spell",
  name = "Spell",
  desc = "Curse the spell slot",
  order = 9,
  visibleIf = isAdvanced(),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

PowerSettings.entitySchema.enum {
  id = "inventory.curses.shield",
  name = "Shield",
  desc = "Curse the shield slot",
  order = 10,
  visibleIf = both(isAdvanced(), isSynchrony()),
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}
--#endregion

--#endregion

PowerSettings.group {
  id = "health",
  name = "Health settings",
  desc = "Rules relating to health.",
  order = 4
}

--#region HEALTH SETTINGS

PowerSettings.entitySchema.bool {
  id = "health.use",
  name = "Use these settings",
  desc = "Whether or not the below settings should apply.",
  order = 1,
  default = false
}

PowerSettings.entitySchema.number {
  id = "health.hearts",
  name = "Starting health",
  desc = "The number of half-hearts to start with.",
  order = 2,
  minimum = 1,
  default = 6,
  upperBound = "mod.CharRules.health.containers",
  format = healthFormat
}

PowerSettings.entitySchema.number {
  id = "health.containers",
  name = "Health containers",
  desc = "The number of half-heart containers to start with.",
  order = 3,
  lowerBound = "mod.CharRules.health.hearts",
  default = 6,
  upperBound = function()
    return get("health.limit") - get("health.cursed")
  end,
  format = healthFormat
}

PowerSettings.entitySchema.number {
  id = "health.cursed",
  name = "Cursed health",
  desc = "The number of half-cursed hearts to start with.",
  order = 4,
  minimum = 0,
  default = 0,
  upperBound = function()
    return get("health.limit") - get("health.containers")
  end,
  format = zeroableHealthFormat,
  visibleIf = both(isAmplified(), isAdvanced())
}

PowerSettings.entitySchema.number {
  id = "health.limit",
  name = "Health limit",
  desc = "The number of half-hearts the player may ever hold.",
  order = 5,
  lowerBound = function()
    return get("health.containers") + get("health.cursed")
  end,
  default = 20,
  maximum = 30,
  format = healthFormat
}

--#endregion

PowerSettings.group {
  id = "mapGen",
  name = "Map generation settings",
  desc = "Settings that affect map generation",
  order = 5,
  visibleIf = isAdvanced()
}

--#region Map gen settings

PowerSettings.entitySchema.enum {
  id = "mapGen.bossSarcophagus",
  name = "Sarcophagus in every room",
  desc = "Whether an invulnerable sarcophagus should be placed in (almost) every room.",
  order = 0,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibility = Settings.Visibility.HIDDEN, -- not working, hiding for now
  visibleIf = isAdvanced()
}

PowerSettings.entitySchema.enum {
  id = "mapGen.innatePeace",
  name = "Innate peace",
  desc = "Reduces the enemies in each floor",
  order = 1,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibility = Settings.Visibility.HIDDEN, -- not working, hiding for now
  visibleIf = isAdvanced()
}

PowerSettings.entitySchema.enum {
  id = "mapGen.noGoldInVaults",
  name = "Skip gold in vaults",
  desc = "Whether or not gold in vaults and walls should be skipped.",
  order = 2,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAdvanced()
}

PowerSettings.entitySchema.enum {
  id = "mapGen.reverseZoneOrder",
  name = "Reverse zone order",
  desc = "Whether or not the zone order should be reversed.",
  order = 3,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAdvanced()
}

PowerSettings.entitySchema.enum {
  id = "mapGen.skipBosses",
  name = "Skip boss fights",
  desc = "Whether or not boss fights should be skipped.",
  order = 4,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAdvanced()
}

PowerSettings.entitySchema.enum {
  id = "mapGen.smallerShops",
  name = "Smaller shops",
  desc = "Remove an item from the shops.",
  order = 5,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAdvanced()
}

PowerSettings.entitySchema.enum {
  id = "mapGen.storyBosses",
  name = "Use story bosses",
  desc = "Whether or not to face story bosses in the run.",
  order = 6,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibility = Settings.Visibility.HIDDEN, -- this one's deprecated
  visibleIf = isAdvanced(),
  refreshOnChange = true
}

PowerSettings.entitySchema.list.enum {
  id = "mapGen.storyBossList",
  name = "List of bosses",
  desc = "Which story bosses should be faced at the end?",
  order = 7,
  enum = Boss.Type,
  default = { Boss.Type.NECRODANCER },
  itemDefault = Boss.Type.NECRODANCER,
  visibility = Settings.Visibility.HIDDEN, -- not working, hiding for now
  visibleIf = both(isAdvanced(), function() return get("mapGen.storyBosses") == CREnum.Quatristate.RANDOM or
        get("mapGen.storyBosses") == CREnum.Quatristate.YES
  end)
}

--#endregion

PowerSettings.group {
  id = "tweaks",
  name = "Tweaks",
  desc = "Various tweaks that aren't exactly rules but might be helpful.",
  order = 6,
  visibleIf = isAdvanced()
}

--#region Tweaks

PowerSettings.shared.bool {
  id = "tweaks.goldenLute",
  name = "Golden lute damages golden lute",
  desc = "Should the Golden Lute (boss) take damage from the Golden Lute (weapon)?",
  order = 1,
  default = false,
  visibleIf = isAdvanced()
}

--#endregion

--#endregion

return {
  get = get
}
