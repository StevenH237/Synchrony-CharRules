--#region Imports
local Enum            = require "system.utils.Enum"
local Menu            = require "necro.menu.Menu"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local NixLib = require "NixLib.NixLib"

local CSILoaded, CSISettings = pcall(require, "ControlledStartingInventory.CSISettings")
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

local function listFormat(str)
  if str == "" then return "(Default)" end
  if str == " " then return "(Empty)" end
  return str
end

local function itemsFormat(str)
  if CSILoaded then return "(Disabled by CSI)" end
  return listFormat(str)
end

local function dictFormat(str)
  if str == "" then return "(Default)" end
  if str == " " then return "(Empty)" end
  return str
end

local function tristateFormat(val)
  if val == -1 then return "No"
  elseif val == 0 then return "(Default)"
  elseif val == 1 then return "Yes"
  else return "" end
end

local function quadstateFormat(val)
  if val == -1 then return "No"
  elseif val == 0 then return "(Default)"
  elseif val == 1 then return "Yes"
  elseif val == 2 then return "Permanent"
  else return "" end
end

local function songEndFormat(val)
  if val == 0 then return "(Default)"
  elseif val == 1 then return "Kill players"
  elseif val == 2 then return "Proceed to next floor"
  elseif val == 3 then return "Loop song"
  else return "" end
end

--#endregion

--------------
-- ENABLERS --
--#region-----

local function startingInventoryEnabler() return not CSILoaded end

local function invincibilityEnabler()
  return not SettingsStorage.get("mod.CharRules.health.invincibility.general", Settings.Layer.REMOTE_PENDING) == 2
end

--#endregion

-----------
-- ENUMS --
--#region--

local enumTristate = Enum.sequence {
  NO=-1,
  DEFAULT=0,
  YES=1
}

local enumQuadstate = Enum.sequence {
  NO=-1,
  DEFAULT=0,
  YES=1,
  PERMANENT=2
}

local enumSongEnd = Enum.sequence {
  DEFAULT=0,
  DEATH=1,
  DESCEND=2
}

--#endregion Enums

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

--#endregion

--------------
-- SETTINGS --
--#region-----

--#region Health settings

Health = Settings.group {
  name="Health options",
  desc="Options influencing starting and maximum health",
  id="health",
  order=1
}

HealthStart = Settings.entitySchema.number {
  name="Starting health",
  desc="The starting health of the player.",
  id="health.start",
  order=1,
  minimum=0,
  default=0,
  format=healthFormat,
  editAsString=true
}

HealthStartMax = Settings.entitySchema.number {
  name="Starting max health",
  desc="The starting heart containers of the player.",
  id="health.startMax",
  order=2,
  minimum=0,
  default=0,
  format=healthFormat,
  editAsString=true
}

HealthStartCursed = Settings.entitySchema.number {
  name="Starting cursed health",
  desc="The starting cursed heart containers of the player.",
  id="health.startCursed",
  order=3,
  minimum=0,
  default=0,
  format=healthFormat,
  editAsString=true
}

HealthLimit = Settings.entitySchema.number {
  name="Max health limit",
  desc="The maximum heart containers of the player.",
  id="health.limit",
  order=4,
  minimum=0,
  default=0,
  format=healthFormat,
  editAsString=true
}

HealthInvincibility = Settings.group {
  name="Invincibility options",
  desc="Options about invincibility.",
  id="health.invincibility",
  order=5
}

HealthInvincibilityGeneral = Settings.entitySchema.enum {
  name="Enabled",
  desc="Whether invincibility is enabled during gameplay.",
  id="health.invincibility.general",
  order=1,
  enum=enumQuadstate,
  format=quadstateFormat,
  default=0
}

HealthInvincibilityOnHit = Settings.entitySchema.number {
  name="On hit",
  desc="How many beats you're invincible after being hit.",
  id="health.invincibility.onHit",
  order=2,
  default=-1,
  minimum=-1,
  format=numberFormat(-1, 0, 0),
  editAsString=true
}

HealthInvincibilityOnLevelStart = Settings.entitySchema.number {
  name="On level start",
  desc="How many beats you're invincible after the level starts.",
  id="health.invincibility.onLevelStart",
  order=3,
  default=-1,
  minimum=-1,
  format=numberFormat(-1, 0, 0)
}

--#endregion health settings
--#region Inventory settings

Inv = Settings.group {
  name="Inventory options",
  desc="Settings that affect the inventory",
  id="inv",
  order=2
}

InvStart = Settings.entitySchema.string {
  name="Starting inventory",
  desc="Space-separated items for the starting inventory. See docs for default item IDs.",
  id="inv.start",
  order=1,
  default="",
  format=itemsFormat,
  enableIf=startingInventoryEnabler
}

InvBans = Settings.entitySchema.string {
  name="Banned components",
  desc="Space-separated item component bans. See docs for default bans. Use : for defa",
  id="inv.bans",
  order=2,
  default="",
  format=dictFormat
}

InvCursed = Settings.entitySchema.string {
  name="Cursed slots",
  desc="Space-separated list of slots to curse. See docs for slot names and defaults.",
  id="inv.cursed",
  order=3,
  default="",
  format=dictFormat
}

--#endregion Inventory settings
--#region Rhythm options

Rhythm = Settings.group {
  name="Rhythm settings",
  desc="Settings that affect turns and rhythm.",
  id="rhythm",
  order=3
}

RhythmFixed = Settings.entitySchema.enum {
  name="Fixed-beat mode",
  desc="Turn on fixed-beat mode (i.e. Bard gameplay)",
  id="rhythm.fixed",
  order=1,
  enum=enumTristate,
  format=tristateFormat,
  default=enumTristate.DEFAULT
}

RhythmMultiplier = Settings.entitySchema.number {
  name="Beat multiplier",
  desc="Subdivides the beat (i.e. Bolt gameplay = 2)",
  id="rhythm.multiplier",
  order=2,
  minimum=0,
  default=0,
  format=numberFormat(0),
  editAsString=true
}

RhythmSongEnd = Settings.entitySchema.enum {
  name="On song end",
  desc="Provide the action for the end of the song",
  id="rhythm.songEnd",
  order=3,
  enum=enumSongEnd,
  default=0,
  format=songEndFormat,
  editAsString=true
}

--#endregion Rhythm options
--#region Groove chain options

Groove = Settings.group {
  name="Groove chain settings",
  desc="Settings that affect groove chains (coin multipliers)",
  id="groove",
  order=4
}

GrooveLevel = Settings.group {
  name="Groove chain level settings",
  desc="Settings that affect groove chain levels",
  id="groove.level",
  order=1
}

GrooveLevelFirst = Settings.entitySchema.number {
  name="Kills for first level",
  desc="How many kills does it take to go from 1x to 2x",
  id="groove.level.first",
  order=1,
  minimum=0,
  default=0,
  format=numberFormat(0),
  editAsString=true
}

GrooveLevelEach = Settings.entitySchema.number {
  name="Kills for later levels",
  desc="How many kills does it take to level up after 2x",
  id="groove.level.each",
  order=2,
  minimum=0,
  default=0,
  format=numberFormat(0),
  editAsString=true
}

GrooveLevelTotal = Settings.entitySchema.number {
  name="Available levels",
  desc="How many levels are there",
  id="groove.level.total",
  order=3,
  minimum=0,
  default=0,
  format=numberFormat(0),
  editAsString=true
}

GrooveDrop = Settings.group {
  name="Drop damage penalty settings",
  desc="Take damage when dropping the groove chain",
  id="groove.drop",
  order=2
}

GrooveDropActive = Settings.entitySchema.enum {
  name="Active",
  desc="Whether or not multiplier drop damage is active",
  id="groove.drop.active",
  order=1,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

GrooveDropDamage = Settings.entitySchema.number {
  name="Damage amount",
  desc="How much damage dropping the multiplier should do.",
  id="groove.drop.damage",
  order=2,
  minimum=0,
  format=numberFormat(0),
  editAsString=true
}

--#endregion
--#region Gold options

Gold = Settings.group {
  name="Gold settings",
  desc="Options that deal with gold",
  id="gold",
  order=5
}

GoldStart = Settings.entitySchema.number {
  name="Starting gold",
  desc="How much gold do characters start with?",
  id="gold.start",
  order=1,
  minimum=-1,
  default=-1,
  format=numberFormat(-1),
  editAsString=true
}

GoldKill = Settings.entitySchema.enum {
  name="Gold kills on pickup",
  desc="If enabled, gold kills the player when picked up.",
  id="gold.kill",
  order=2,
  enum=enumTristate,
  default=0,
  format=tristateFormat
}

GoldMinimum = Settings.entitySchema.number {
  name="Minimum gold drops",
  desc="The lowest amount of gold that is killed by anything dropped.",
  id="gold.minimum",
  order=3,
  minimum=-1,
  default=-1,
  format=numberFormat(-1),
  editAsString=true
}

GoldFree = Settings.entitySchema.enum {
  name="Free items from shops",
  desc="If set, players can take one item from shops for free.",
  id="gold.free",
  order=4,
  enum=enumTristate,
  default=0,
  format=tristateFormat
}

--#endregion Settings
--#region Damage countdown options

Countdown = Settings.group {
  name="Damage countdown",
  desc="Damage every x beats unless you kill or pick up items",
  id="countdown",
  order=6
}

CountdownActive = Settings.entitySchema.enum {
  name="Active",
  desc="Whether or not the countdown timer is active",
  id="countdown.active",
  order=1,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

CountdownDamage = Settings.entitySchema.number {
  name="Damage amount",
  desc="How much damage the damage multiplier should do.",
  id="countdown.damage",
  order=2,
  minimum=0,
  default=0,
  format=numberFormat(0),
  editAsString=true
}

CountdownTimer = Settings.entitySchema.number {
  name="Countdown time",
  desc="How many beats should be in the countdown timer.",
  id="countdown.timer",
  order=3,
  minimum=0,
  default=0,
  format=numberFormat(0),
  editAsString=true
}

--#endregion
--#region Offense settings

Damage = Settings.group {
  name="Damage options",
  desc="Options affecting damage dealt",
  id="damage",
  order=7
}

DamageIncrease = Settings.entitySchema.number {
  name="Damage increase",
  desc="Increases damage dealt",
  id="damage.increase",
  order=1,
  minimum=-1,
  default=-1,
  format=numberFormat(-1, 0, -1),
  editAsString=true
}

--#endregion
--#region Allowed actions

Allowed = Settings.group {
  name="Allowed actions",
  desc="Which actions are allowed or not within gameplay",
  id="allowed",
  order=8
}

--#region Allowed directions

AllowedDirections = Settings.group {
  name="Movement directions",
  desc="Which movement directions are allowed or not within gameplay",
  id="allowed.directions",
  order=1
}

AllowedDirectionsNorth = Settings.entitySchema.enum {
  name="North",
  desc="Movement to the north (up), including attacking",
  id="allowed.directions.north",
  order=1,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedDirectionsEast = Settings.entitySchema.enum {
  name="East",
  desc="Movement to the east (right), including attacking",
  id="allowed.directions.east",
  order=2,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedDirectionsSouth = Settings.entitySchema.enum {
  name="South",
  desc="Movement to the south (down), including attacking",
  id="allowed.directions.south",
  order=3,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedDirectionsWest = Settings.entitySchema.enum {
  name="West",
  desc="Movement to the west (left), including attacking",
  id="allowed.directions.west",
  order=4,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedDirectionsNortheast = Settings.entitySchema.enum {
  name="Northeast",
  desc="Movement to the northeast (up-right), including attacking",
  id="allowed.directions.northeast",
  order=5,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedDirectionsSoutheast = Settings.entitySchema.enum {
  name="Southeast",
  desc="Movement to the southeast (down-right), including attacking",
  id="allowed.directions.southeast",
  order=6,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedDirectionsSouthwest = Settings.entitySchema.enum {
  name="Southwest",
  desc="Movement to the southwest (down-left), including attacking",
  id="allowed.directions.southwest",
  order=7,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedDirectionsNorthwest = Settings.entitySchema.enum {
  name="Northwest",
  desc="Movement to the northwest (up-left), including attacking",
  id="allowed.directions.northwest",
  order=8,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

--#endregion

AllowedItem1 = Settings.entitySchema.enum {
  name="Item 1",
  desc="The use of the main item",
  id="allowed.item1",
  order=2,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedItem2 = Settings.entitySchema.enum {
  name="Item 2 / Switch",
  desc="The use of the secondary item, or functions such as the holster's switch",
  id="allowed.item2",
  order=3,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedBomb = Settings.entitySchema.enum {
  name="Bomb",
  desc="The use of bombs",
  id="allowed.bomb",
  order=4,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedThrow = Settings.entitySchema.enum {
  name="Throw / Toggle",
  desc="The use of throwing weapons or toggling toggleable items",
  id="allowed.throw",
  order=5,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedSpell1 = Settings.entitySchema.enum {
  name="Spell 1",
  desc="The use of the first spell",
  id="allowed.spell1",
  order=6,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

AllowedSpell2 = Settings.entitySchema.enum {
  name="Spell 2",
  desc="The use of the second spell",
  id="allowed.spell2",
  order=7,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

--#endregion
--#region Misc settings

Misc = Settings.group {
  name="Misc settings",
  desc="Other settings I couldn't really categorize together",
  id="misc",
  order=9
}

--#region Exit settings

MiscExit = Settings.group {
  name="Level exit settings",
  desc="Settings controlling exit unlocks",
  id="misc.exits",
  order=1
}

MiscExitMiniboss = Settings.entitySchema.enum {
  name="Require miniboss",
  desc="Whether the miniboss must be defeated before the exit stairs unlock",
  id="misc.exits.miniboss",
  order=1,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

MiscExitSarcophagus = Settings.entitySchema.enum {
  name="Require sarcophagus",
  desc="Whether the sarcophagus must be defeated before the exit stairs unlock",
  id="misc.exits.sarcophagus",
  order=2,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

--#endregion

MiscUntoggled = Settings.entitySchema.enum {
  name="Damage on untoggled movement",
  desc="Whether to take damage when moving with an item toggled on",
  id="misc.untoggled",
  order=2,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

MiscLamb = Settings.entitySchema.enum {
  name="Lamb follower",
  desc="Mary's lamb follower that must be protected",
  id="misc.lamb",
  order=3,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

--#region Vision options

MiscVision = Settings.group {
  name="Vision options",
  desc="Options affecting vision",
  id="misc.vision",
  order=4
}

MiscVisionAll = Settings.entitySchema.enum {
  name="All tile vision",
  desc="Grant map-like vision",
  id="misc.vision.all",
  order=1,
  enum=enumTristate,
  format=tristateFormat,
  default=0
}

--#region Component-based vision

MiscVisionComponent = Settings.group {
  name="Component-based vision",
  desc="Vision based on components",
  id="misc.vision.component",
  order=2
}

MiscVisionComponentUse = Settings.entitySchema.bool {
  name="Use these settings",
  desc="Whether or not to enable the settings on this page",
  id="misc.vision.component.use",
  order=1,
  default=false
}

MiscVisionComponentMonocle = Settings.entitySchema.bool {
  name="Monocle sight",
  desc="See items that are visible by monocle",
  id="misc.vision.component.monocle",
  order=2,
  default=false
}

MiscVisionComponentTelepathy = Settings.entitySchema.bool {
  name="Telepathy sight",
  desc="See enemies that are visible by telepathy",
  id="misc.vision.component.telepathy",
  order=3,
  default=false
}

MiscVisionComponentTrapsight = Settings.entitySchema.bool {
  name="Trapsight",
  desc="See traps that are visible by trapsight",
  id="misc.vision.component.trapsight",
  order=4,
  default=false
}

MiscVisionComponentCustom = Settings.entitySchema.string {
  name="Other components",
  desc="Define your own components to force vision on here",
  id="misc.vision.component.custom",
  order=5,
  default="",
  format=listFormat
}

--#endregion

MiscVisionObjectLimit = Settings.entitySchema.number {
  name="Limit object vision range",
  desc="Limits your vision of objects to the given number of tiles",
  id="misc.vision.objectLimit",
  order=3,
  minimum=0,
  default=0,
  step=0.5,
  format=numberFormat(0)
}

MiscVisionTileLimit = Settings.entitySchema.number {
  name="Limit tile vision range",
  desc="Limits your vision to the given number of tiles",
  id="misc.vision.tileLimit",
  order=4,
  minimum=0,
  default=0,
  step=0.5,
  format=numberFormat(0)
}

--#endregion
--#endregion

ResetButton = Settings.entitySchema.action {
  name="Reset mod settings",
  desc="Resets ALL mod settings to defaults",
  id="reset",
  order=9999,
  action=actionReset
}

------------------
-- RETURN TABLE --
--#region---------

return {
  get = function(entry)
    return SettingsStorage.get("mod.CharRules." .. entry)
  end,
  getList = function(entry)
    local str = SettingsStorage.get("mod.CharRules." .. entry)
    if str == "" then return nil end
    if str == " " then return {} end
    return NixLib.splitToList(str)
  end,
  getSet = function(entry)
    local str = SettingsStorage.get("mod.CharRules." .. entry)
    if str == "" then return nil end
    if str == " " then return {} end
    return NixLib.splitToSet(str)
  end,
  getAllowedActions = function()
    return {
      AllowedDirectionsEast,
      AllowedDirectionsNortheast,
      AllowedDirectionsNorth,
      AllowedDirectionsNorthwest,
      AllowedDirectionsWest,
      AllowedDirectionsSouthwest,
      AllowedDirectionsSouth,
      AllowedDirectionsSoutheast,
      AllowedItem1,
      AllowedItem2,
      AllowedBomb,
      AllowedThrow,
      AllowedSpell1,
      AllowedSpell2
    }
  end
}

--#endregion Return