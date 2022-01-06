--#region Imports
local Damage          = require "necro.game.system.Damage"
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

--#endregion

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
  return isAdvanced() or isAmplified()
end

--#endregion Enablers

-------------
-- ACTIONS --
--#region----

local function actionReset()
  print(Settings.Visibility)
  local keys = SettingsStorage.listKeys("mod.CharRules", Settings.Layer.REMOTE_OVERRIDE)
  for _, key in ipairs(keys) do
    SettingsStorage.set(key, nil, Settings.Layer.REMOTE_PENDING)
  end
end

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

Advanced = PowerSettings.entitySchema.bool {
  id="advanced",
  name="Advanced mode",
  desc="Should this mod show advanced settings?",
  order=0
}

Characters = PowerSettings.group {
  id="characters",
  name="Character-specific rules",
  desc="The rules that specific characters bring to the table.",
  order=1
}

--#region CHARACTER SETTINGS--
CharactersHeader = PowerSettings.entitySchema.label {
  id="characters.header",
  name="Jump between sections with left/right on section headers!",
  order=-1
}

CharactersAria = PowerSettings.entitySchema.action {
  id="characters.aria",
  name="\3*cc5Aria's rules\3r",
  order=0,
  leftAction=charJump("tempo", "bard"),
  rightAction=charJump("dorian")
}

CharactersMissedbeat = PowerSettings.entitySchema.enum {
  id="characters.missedBeat",
  name="Damage on missed beat",
  desc="Whether or not players should take damage on a missed beat.",
  order=1,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersMissedbeatdamage = PowerSettings.entitySchema.number {
  id="characters.missedBeatDamage",
  name="Amount of damage",
  desc="The amount of damage on a missed beat.",
  order=2,
  visibleIf=isAdvanced,
  default=0,
  minimum=0,
  maximum=50,
  format=healthFormat
}

CharactersMissedbeattype = PowerSettings.entitySchema.bitflag {
  id="characters.missedBeatType",
  name="Type of damage",
  desc="The type of damage on a missed beat.",
  order=3,
  visibleIf=isAdvanced,
  default=Damage.Type.SELF_DAMAGE,
  flags=Damage.Flag,
  presets=Damage.Type
}

CharactersBypasssarcophagus = PowerSettings.entitySchema.enum {
  id="characters.bypassSarcophagus",
  name="Bypass sarcophagus",
  desc="Whether or not stairs should be locked until a sarcophagus is destroyed",
  order=4,
  visibleIf=isAdvanced,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersDorian = PowerSettings.entitySchema.action {
  id="characters.dorian",
  name="\3*cc5Dorian's rules\3r",
  order=5,
  leftAction=charJump("aria"),
  rightAction=charJump("eli")
}

CharactersCursedboots = PowerSettings.entitySchema.enum {
  id="characters.cursedBoots",
  name="Boots of painful leaping",
  desc="Should boots of leaping or lunging cause damage when disabled while moving",
  order=6,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersCursedbootslabel = PowerSettings.entitySchema.label {
  id="characters.cursedBootsLabel",
  name="To actually apply the boots, go to Inventory.",
  order=7
}

CharactersCursedbootsdamage = PowerSettings.entitySchema.number {
  id="characters.cursedBootsDamage",
  name="Amount of damage",
  desc="The amount of damage from cursed boots.",
  order=8,
  visibleIf=isAdvanced,
  default=0,
  minimum=0,
  maximum=50,
  format=healthFormat
}

CharactersCursedbootstype = PowerSettings.entitySchema.bitflag {
  id="characters.cursedBootsType",
  name="Type of damage",
  desc="The type of damage from cursed boots.",
  order=9,
  visibleIf=isAdvanced,
  default=Damage.Type.BLOOD,
  flags=Damage.Flag,
  presets=Damage.Type
}

CharactersEli = PowerSettings.entitySchema.action {
  id="characters.eli",
  name="\3*cc5Eli's rules\3r",
  order=10,
  leftAction=charJump("dorian"),
  rightAction=charJump("monk")
}

CharactersElibombs = PowerSettings.entitySchema.label {
  id="characters.eliBombs",
  name="For infinite bombs, go to Inventory.",
  order=11
}

CharactersEliwalls = PowerSettings.entitySchema.enum {
  id="characters.eliWalls",
  name="Empty shop walls",
  desc="Should shop walls be devoid of gold?",
  order=12,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersMonk = PowerSettings.entitySchema.action {
  id="characters.monk",
  name="\3*cc5Monk's rules\3r",
  order=13,
  leftAction=charJump("eli"),
  rightAction=charJump("dove")
}

CharactersPoverty = PowerSettings.entitySchema.enum {
  id="characters.poverty",
  name="Vow of poverty",
  desc="Die on picking up gold",
  order=14,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersShoplifter = PowerSettings.entitySchema.enum {
  id="characters.shoplifter",
  name="Free items from shops",
  desc="Character receives one free item per shop",
  order=15,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersDescentcollect = PowerSettings.entitySchema.enum {
  id="characters.descentCollect",
  name="Collect gold on stairs",
  desc="When descending the stairs, pickup all dropped gold",
  order=16,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersEnemygold = PowerSettings.entitySchema.enum {
  id="characters.enemyGold",
  name="All enemies drop gold",
  desc="All enemies drop at least one gold when killed",
  order=17,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersDove = PowerSettings.entitySchema.action {
  id="characters.dove",
  name="\3*cc5Dove's rules\3r",
  order=18,
  leftAction=charJump("monk"),
  rightAction=charJump("bolt")
}

CharactersDovelabel = PowerSettings.entitySchema.label {
  id="characters.doveLabel",
  name="For the flower, go to Inventory.",
  order=19
}

CharactersTeleportingbombs = PowerSettings.entitySchema.enum {
  id="characters.teleportingBombs",
  name="Teleporting bombs",
  desc="When enemies are hit by bombs, they're teleported instead of damaged.",
  order=20,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersBypassminiboss = PowerSettings.entitySchema.enum {
  id="characters.bypassMiniboss",
  name="Bypass miniboss",
  desc="Should minibosses be bypassed for the stairs lock?",
  order=21,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersBolt = PowerSettings.entitySchema.action {
  id="characters.bolt",
  name="\3*cc5Bolt's rules\3r",
  order=22,
  leftAction=charJump("dove"),
  rightAction=charJump("bard")
}

CharactersDoubletime = PowerSettings.entitySchema.enum {
  id="characters.doubleTime",
  name="Double tempo",
  desc="Should characters play at double tempo",
  order=23,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT,
  visibleIf=function() return not isAdvanced() end
}

CharactersCustomtempo = PowerSettings.entitySchema.number {
  id="characters.customTempo",
  name="Tempo multiplier",
  desc="Should characters play at a custom tempo",
  order=24,
  default=0,
  minimum=0,
  maximum=20,
  format=numberFormat(0),
  visibleIf=isAdvanced
}

CharactersBard = PowerSettings.entitySchema.action {
  id="characters.bard",
  name="\3*cc5Bard's rules\3r",
  order=25,
  leftAction=charJump("bolt"),
  rightAction=charJump("mary", "aria")
}

CharactersNobeats = PowerSettings.entitySchema.enum {
  id="characters.noBeats",
  name="Ignore rhythm",
  desc="Characters ignore the rhythm of the music.",
  order=26,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT
}

CharactersMary = PowerSettings.entitySchema.action {
  id="characters.mary",
  name="\3*cc5Mary's rules\3r",
  order=27,
  leftAction=charJump("bard"),
  rightAction=charJump("tempo"),
  visibleIf=isAmplified
}

CharactersMarv = PowerSettings.entitySchema.enum {
  id="characters.marv",
  name="Protect a sheep",
  desc="A sheep follows you that must be kept alive",
  order=28,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT,
  visibleIf=isAmplified
}

CharactersTempo = PowerSettings.entitySchema.action {
  id="characters.tempo",
  name="\3*cc5Tempo's rules\3r",
  order=29,
  leftAction=charJump("mary"),
  rightAction=charJump("aria"),
  visibleIf=isAmplified
}

CharactersDamageup = PowerSettings.entitySchema.enum {
  id="characters.damageUp",
  name="Increase damage",
  desc="Should your attack damage be increased",
  order=30,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT,
  visibleIf=isAmplified
}

CharactersDamageupamount = PowerSettings.entitySchema.number {
  id="characters.damageUpAmount",
  name="Damage increase amount",
  desc="How much should your attack damage be increased",
  order=31,
  default=0,
  minimum=0,
  maximum=999,
  editAsString=true,
  visibleIf=isAdvancedAndAmplified,
  format=numberFormat(0)
}

CharactersKilltimer = PowerSettings.entitySchema.enum {
  id="characters.killTimer",
  name="Kill timer",
  desc="Must kill every few beats or you take damage",
  order=32,
  enum=CREnum.Tristate,
  default=CREnum.Tristate.DEFAULT,
  visibleIf=isAmplified
}

CharactersKilltimerdamage = PowerSettings.entitySchema.number {
  id="characters.killTimerDamage",
  name="Amount of damage",
  desc="The amount of damage from the kill timer.",
  order=33,
  visibleIf=isAdvancedAndAmplified,
  default=0,
  minimum=0,
  maximum=999,
  format=healthFormat
}

CharactersKilltimertype = PowerSettings.entitySchema.bitflag {
  id="characters.killTimerType",
  name="Type of damage",
  desc="The type of damage from the kill timer.",
  order=34,
  visibleIf=isAdvancedAndAmplified,
  default=Damage.Type.SUICIDE,
  flags=Damage.Flag,
  presets=Damage.Type
}
--#endregion

Inventory = PowerSettings.group {
  id="inventory",
  name="Inventory",
  desc="Rules about the inventory.",
  order=2
}

--#region INVENTORY SETTINGS--

--#endregion

--#endregion

return {
  get = function(setting)
    return PowerSettings.get("mod.CharRules." .. setting)
  end
}