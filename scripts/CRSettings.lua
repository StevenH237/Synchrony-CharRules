--#region Imports
local Damage          = require "necro.game.system.Damage"
local Entities        = require "system.game.Entities"
local GameDLC         = require "necro.game.data.resource.GameDLC"
local ItemBan         = require "necro.game.item.ItemBan"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local PowerSettings = require "PowerSettings.PowerSettings"

local CREnum = require "CharRules.CREnum"

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
    if val == def then return "(Default)" end
    if val == dis then return "(Disabled)" end
    val = val + off
    return tostring(val)
  end
end

local function healthFormat(amt)
  if amt == 0 then return "(Default)" end
  if amt <= 2 then return amt .. " (" .. (amt / 2) .. " heart)" end
  return amt .. " (" .. (amt / 2) .. " hearts)"
end

local function zeroableHealthFormat(amt)
  if amt == 0 then return "(None)" end
  if amt <= 2 then return amt .. " (" .. (amt / 2) .. " heart)" end
  return amt .. " (" .. (amt / 2) .. " hearts)"
end

local function healthAmountFormat(value)
  if value == -1 then return "(Default)"
  elseif value == 0 then return "Half a heart"
  elseif value == 1 then return "1 heart"
  else return value .. " hearts" end
end

--#endregion Formatters

--------------
-- ENABLERS --
--#region-----

local function isAdvanced()
  return PowerSettings.get("mod.CharRules.advanced")
end

local function isAmplified()
  return GameDLC.isAmplifiedLoaded()
end

local function isAdvancedAndAmplified()
  return isAdvanced() and isAmplified()
end

--#endregion Enablers

-------------
-- ACTIONS --
--#region----

local function charJump(char, noDLC)
  if noDLC and not isAmplified() then
    return function() Menu.selectByID("mod.CharRules.characters." .. noDLC) end
  end
  return function() Menu.selectByID("mod.CharRules.characters." .. char) end
end

--#endregion

--------------
-- SETTINGS --
--#region-----

RandomSeed = PowerSettings.entitySchema.number {
  id = "random",
  name = "Random seed",
  desc = "Seed for the randomizer. Always randomized when a run starts.",
  visibility = Settings.Visibility.HIDDEN
}

Advanced = PowerSettings.entitySchema.bool {
  id = "advanced",
  name = "Advanced mode",
  desc = "Should this mod show advanced settings?",
  order = 0
}

Characters = PowerSettings.group {
  id = "characters",
  name = "Character-specific rules",
  desc = "The rules that specific characters bring to the table.",
  order = 1
}

--#region CHARACTER SETTINGS--
Characters_Header = PowerSettings.entitySchema.label {
  id = "characters.header",
  name = "Jump between sections with left/right on section headers!",
  order = -1
}

Characters_Aria = PowerSettings.entitySchema.action {
  id = "characters.aria",
  name = "\3*cc5Aria's rules\3r",
  order = 0,
  leftAction = charJump("tempo", "bard"),
  rightAction = charJump("dorian")
}

Characters_MissedBeat = PowerSettings.entitySchema.enum {
  id = "characters.missedBeat",
  name = "Damage on missed beat",
  desc = "Whether or not players should take damage on a missed beat.",
  order = 1,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_MissedBeatDamage = PowerSettings.entitySchema.number {
  id = "characters.missedBeatDamage",
  name = "Amount of damage",
  desc = "The amount of damage on a missed beat.",
  order = 2,
  visibleIf = isAdvanced,
  default = 0,
  minimum = 0,
  maximum = 50,
  format = healthFormat
}

Characters_MissedBeatType = PowerSettings.entitySchema.bitflag {
  id = "characters.missedBeatType",
  name = "Type of damage",
  desc = "The type of damage on a missed beat.",
  order = 3,
  visibleIf = isAdvanced,
  default = Damage.Type.SELF_DAMAGE,
  flags = Damage.Flag,
  presets = Damage.Type
}

Characters_BypassSarcophagus = PowerSettings.entitySchema.enum {
  id = "characters.bypassSarcophagus",
  name = "Bypass sarcophagus",
  desc = "Whether or not stairs should be locked until a sarcophagus is destroyed",
  order = 4,
  visibleIf = isAdvanced,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_Dorian = PowerSettings.entitySchema.action {
  id = "characters.dorian",
  name = "\3*cc5Dorian's rules\3r",
  order = 5,
  leftAction = charJump("aria"),
  rightAction = charJump("eli")
}

Characters_CursedBoots = PowerSettings.entitySchema.enum {
  id = "characters.cursedBoots",
  name = "Boots of painful leaping",
  desc = "Should boots of leaping or lunging cause damage when disabled while moving",
  order = 6,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_CursedBootsLabel = PowerSettings.entitySchema.label {
  id = "characters.cursedBootsLabel",
  name = "To actually apply the boots, go to Inventory.",
  order = 7
}

Characters_CursedBootsDamage = PowerSettings.entitySchema.number {
  id = "characters.cursedBootsDamage",
  name = "Amount of damage",
  desc = "The amount of damage from cursed boots.",
  order = 8,
  visibleIf = isAdvanced,
  default = 0,
  minimum = 0,
  maximum = 50,
  format = healthFormat
}

Characters_CursedBootsType = PowerSettings.entitySchema.bitflag {
  id = "characters.cursedBootsType",
  name = "Type of damage",
  desc = "The type of damage from cursed boots.",
  order = 9,
  visibleIf = isAdvanced,
  default = Damage.Type.BLOOD,
  flags = Damage.Flag,
  presets = Damage.Type
}

Characters_Eli = PowerSettings.entitySchema.action {
  id = "characters.eli",
  name = "\3*cc5Eli's rules\3r",
  order = 10,
  leftAction = charJump("dorian"),
  rightAction = charJump("monk")
}

Characters_EliBombs = PowerSettings.entitySchema.label {
  id = "characters.eliBombs",
  name = "For infinite bombs, go to Inventory.",
  order = 11
}

Characters_EliWalls = PowerSettings.entitySchema.enum {
  id = "characters.eliWalls",
  name = "Empty shop walls",
  desc = "Should shop walls be devoid of gold?",
  order = 12,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_Monk = PowerSettings.entitySchema.action {
  id = "characters.monk",
  name = "\3*cc5Monk's rules\3r",
  order = 13,
  leftAction = charJump("eli"),
  rightAction = charJump("dove")
}

Characters_Poverty = PowerSettings.entitySchema.enum {
  id = "characters.poverty",
  name = "Vow of poverty",
  desc = "Die on picking up gold",
  order = 14,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_Shoplifter = PowerSettings.entitySchema.enum {
  id = "characters.shoplifter",
  name = "Free items from shops",
  desc = "Character receives one free item per shop",
  order = 15,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_DescentCollect = PowerSettings.entitySchema.enum {
  id = "characters.descentCollect",
  name = "Collect gold on stairs",
  desc = "When descending the stairs, pickup all dropped gold",
  order = 16,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_EnemyGold = PowerSettings.entitySchema.enum {
  id = "characters.enemyGold",
  name = "All enemies drop gold",
  desc = "All enemies drop at least one gold when killed",
  order = 17,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_Dove = PowerSettings.entitySchema.action {
  id = "characters.dove",
  name = "\3*cc5Dove's rules\3r",
  order = 18,
  leftAction = charJump("monk"),
  rightAction = charJump("bolt")
}

Characters_DoveLabel = PowerSettings.entitySchema.label {
  id = "characters.doveLabel",
  name = "For the flower, go to Inventory.",
  order = 19
}

Characters_TeleportingBombs = PowerSettings.entitySchema.enum {
  id = "characters.teleportingBombs",
  name = "Teleporting bombs",
  desc = "When enemies are hit by bombs, they're teleported instead of damaged.",
  order = 20,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_BypassMiniboss = PowerSettings.entitySchema.enum {
  id = "characters.bypassMiniboss",
  name = "Bypass miniboss",
  desc = "Should minibosses be bypassed for the stairs lock?",
  order = 21,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_Bolt = PowerSettings.entitySchema.action {
  id = "characters.bolt",
  name = "\3*cc5Bolt's rules\3r",
  order = 22,
  leftAction = charJump("dove"),
  rightAction = charJump("bard")
}

Characters_DoubleTime = PowerSettings.entitySchema.enum {
  id = "characters.doubleTime",
  name = "Double tempo",
  desc = "Should characters play at double tempo",
  order = 23,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = function() return not isAdvanced() end
}

Characters_CustomTempo = PowerSettings.entitySchema.number {
  id = "characters.customTempo",
  name = "Tempo multiplier",
  desc = "Should characters play at a custom tempo",
  order = 24,
  default = 0,
  minimum = 0,
  maximum = 20,
  format = numberFormat(0),
  visibleIf = isAdvanced
}

Characters_Bard = PowerSettings.entitySchema.action {
  id = "characters.bard",
  name = "\3*cc5Bard's rules\3r",
  order = 25,
  leftAction = charJump("bolt"),
  rightAction = charJump("mary", "aria")
}

Characters_NoBeats = PowerSettings.entitySchema.enum {
  id = "characters.noBeats",
  name = "Ignore rhythm",
  desc = "Characters ignore the rhythm of the music.",
  order = 26,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Characters_Mary = PowerSettings.entitySchema.action {
  id = "characters.mary",
  name = "\3*cc5Mary's rules\3r",
  order = 27,
  leftAction = charJump("bard"),
  rightAction = charJump("tempo"),
  visibleIf = isAmplified
}

Characters_Marv = PowerSettings.entitySchema.enum {
  id = "characters.marv",
  name = "Protect a sheep",
  desc = "A sheep follows you that must be kept alive",
  order = 28,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAmplified
}

Characters_Tempo = PowerSettings.entitySchema.action {
  id = "characters.tempo",
  name = "\3*cc5Tempo's rules\3r",
  order = 29,
  leftAction = charJump("mary"),
  rightAction = charJump("aria"),
  visibleIf = isAmplified
}

Characters_DamageUp = PowerSettings.entitySchema.enum {
  id = "characters.damageUp",
  name = "Increase damage",
  desc = "Should your attack damage be increased",
  order = 30,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAmplified
}

Characters_DamageUpAmount = PowerSettings.entitySchema.number {
  id = "characters.damageUpAmount",
  name = "Damage increase amount",
  desc = "How much should your attack damage be increased",
  order = 31,
  default = 0,
  minimum = 0,
  maximum = 999,
  editAsString = true,
  visibleIf = isAdvancedAndAmplified,
  format = numberFormat(0)
}

Characters_KillTimer = PowerSettings.entitySchema.enum {
  id = "characters.killTimer",
  name = "Kill timer",
  desc = "Must kill every few beats or you take damage",
  order = 32,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT,
  visibleIf = isAmplified
}

Characters_KillTimerDamage = PowerSettings.entitySchema.number {
  id = "characters.killTimerDamage",
  name = "Amount of damage",
  desc = "The amount of damage from the kill timer.",
  order = 33,
  visibleIf = isAdvancedAndAmplified,
  default = 0,
  minimum = 0,
  maximum = 999,
  format = healthFormat
}

Characters_KillTimerType = PowerSettings.entitySchema.bitflag {
  id = "characters.killTimerType",
  name = "Type of damage",
  desc = "The type of damage from the kill timer.",
  order = 34,
  visibleIf = isAdvancedAndAmplified,
  default = Damage.Type.SUICIDE,
  flags = Damage.Flag,
  presets = Damage.Type
}
--#endregion

Inventory = PowerSettings.group {
  id = "inventory",
  name = "Inventory",
  desc = "Rules about the inventory.",
  order = 2
}

--#region INVENTORY SETTINGS--
Inventory_Items = PowerSettings.group {
  id = "inventory.items",
  name = "Items",
  desc = "Set specific items here.",
  order = 0
}

--#region Items settings--
Inventory_Items_Clear = PowerSettings.entitySchema.bool {
  id = "inventory.items.clear",
  name = "Clear inventory",
  desc = "Clear inventory before giving new items",
  order = 0,
  default = false
}

Inventory_Items_Give = PowerSettings.entitySchema.list.entity {
  id = "inventory.items.give",
  name = "Give items",
  desc = "Add more items",
  order = 1,
  default = {},
  filter = "item",
  itemDefault = "MiscPotion"
}
--#endregion

Inventory_Bans = PowerSettings.group {
  id = "inventory.bans",
  name = "Bans",
  desc = "Set item bans here.",
  order = 1
}

--#region Item bans settings--

Inventory_Bans_CIRT = PowerSettings.entitySchema.enum {
  id = "inventory.bans.cirt",
  name = "Heart transplants",
  desc = "Items that ignore the rhythm temporarily on use",
  order = 0,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Bans_Healthlocked = PowerSettings.entitySchema.enum {
  id = "inventory.bans.healthlocked",
  name = "Health-increasing items",
  desc = "Items that increase health",
  order = 1,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Bans_NoDamage = PowerSettings.entitySchema.enum {
  id = "inventory.bans.noDamage",
  name = "Damage-increasing items",
  desc = "Items that increase damage output",
  order = 2,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Bans_Pacifist = PowerSettings.entitySchema.enum {
  id = "inventory.bans.pacifist",
  name = "Pacifism",
  desc = "Item bans due to pacifism",
  order = 3,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Bans_Poverty = PowerSettings.entitySchema.enum {
  id = "inventory.bans.poverty",
  name = "Gold-collecting items",
  desc = "Items that collect gold",
  order = 4,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Bans_Weaponlocked = PowerSettings.entitySchema.enum {
  id = "inventory.bans.weaponlocked",
  name = "Weapons",
  desc = "Other weapons",
  order = 5,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Bans_GrooveChainImmunity = PowerSettings.entitySchema.enum {
  id = "inventory.bans.grooveChainImmunity",
  name = "Groove chain immunity",
  desc = "Items that ignore missed beats while held",
  order = 6,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

--#endregion

Inventory_Curses = PowerSettings.group {
  id = "inventory.curses",
  name = "Cursed inventory slots",
  desc = "Curse slots.",
  order = 2
}

--#region Inventory curses settings--

Inventory_Curses_Action = PowerSettings.entitySchema.enum {
  id = "inventory.curses.action",
  name = "Consumable item",
  desc = "Curse the consumable item slot",
  order = 0,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Curses_Shovel = PowerSettings.entitySchema.enum {
  id = "inventory.curses.shovel",
  name = "Shovel",
  desc = "Curse the shovel slot",
  order = 1,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Curses_Weapon = PowerSettings.entitySchema.enum {
  id = "inventory.curses.weapon",
  name = "Weapon",
  desc = "Curse the weapon slot",
  order = 2,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Curses_Body = PowerSettings.entitySchema.enum {
  id = "inventory.curses.body",
  name = "Body (armor)",
  desc = "Curse the body slot",
  order = 3,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Curses_Head = PowerSettings.entitySchema.enum {
  id = "inventory.curses.head",
  name = "Head",
  desc = "Curse the head slot",
  order = 4,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Curses_Feet = PowerSettings.entitySchema.enum {
  id = "inventory.curses.feet",
  name = "Feet",
  desc = "Curse the feet slot",
  order = 5,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Curses_Torch = PowerSettings.entitySchema.enum {
  id = "inventory.curses.torch",
  name = "Torch",
  desc = "Curse the torch item slot",
  order = 6,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Curses_Ring = PowerSettings.entitySchema.enum {
  id = "inventory.curses.ring",
  name = "Ring",
  desc = "Curse the ring slot",
  order = 7,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Curses_Misc = PowerSettings.entitySchema.enum {
  id = "inventory.curses.misc",
  name = "Charms",
  desc = "Curse the charms slot",
  order = 8,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}

Inventory_Curses_Spell = PowerSettings.entitySchema.enum {
  id = "inventory.curses.spell",
  name = "Spell",
  desc = "Curse the spell slot",
  order = 9,
  enum = CREnum.Quatristate,
  default = CREnum.Quatristate.DEFAULT
}


--#endregion

--#endregion

Health = PowerSettings.group {
  id = "health",
  name = "Health settings",
  desc = "Rules relating to health.",
  order = 4
}

--#region HEALTH SETTINGS

Health_Amount = PowerSettings.entitySchema.number {
  id = "health.amount",
  name = "Amount of health",
  desc = "The total amount of health to use.",
  order = 0,
  visibleIf = function() return not isAdvanced() end,
  minimum = -1,
  maximum = 10,
  default = -1,
  format = healthAmountFormat
}

Health_Use = PowerSettings.entitySchema.bool {
  id = "health.use",
  name = "Use these settings",
  desc = "Whether or not the below settings should apply.",
  order = 1,
  visibleIf = isAdvanced,
  default = false
}

Health_Hearts = PowerSettings.entitySchema.number {
  id = "health.hearts",
  name = "Starting health",
  desc = "The number of half-hearts to start with.",
  order = 2,
  minimum = 1,
  default = 6,
  upperBound = "mod.CharRules.health.containers",
  format = healthFormat,
  visibleIf = isAdvanced
}

Health_Containers = PowerSettings.entitySchema.number {
  id = "health.containers",
  name = "Health containers",
  desc = "The number of half-heart containers to start with.",
  order = 3,
  lowerBound = "mod.CharRules.health.hearts",
  default = 6,
  upperBound = function()
    return get("health.limit") - get("health.cursed")
  end,
  format = healthFormat,
  visibleIf = isAdvanced
}

Health_Cursed = PowerSettings.entitySchema.number {
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
  visibleIf = isAdvancedAndAmplified
}

Health_Limit = PowerSettings.entitySchema.number {
  id = "health.limit",
  name = "Health limit",
  desc = "The number of half-hearts the player may ever hold.",
  order = 5,
  lowerBound = function()
    return get("health.containers") + get("health.cursed")
  end,
  default = 20,
  maximum = 30,
  format = healthFormat,
  visibleIf = isAdvanced
}

--#endregion

Other = PowerSettings.group {
  id = "other",
  name = "Other",
  desc = "Other stuff",
  order = 5
}

Other_MapGen = PowerSettings.entitySchema.bitflag {
  id = "other.mapGen",
  name = "Map gen for",
  desc = "Whose map gen should be used?",
  order = 0,
  visibleIf = isAdvanced,
  default = CREnum.MapGen.DEFAULT,
  flags = CREnum.MapGen,
  presets = CREnum.MapGenPresets
}

--#endregion

return {
  get = get
}
