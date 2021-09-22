--#region Imports
local Enum            = require "system.utils.Enum"
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

  local list = NixLib.splitToList(str)
  if #list == 1 then return list[1] end
  if #list == 2 then return list[1] .. " & " .. list[2] end

  local item = table.remove(list)
  return table.concat(list, ", ") .. ", & " .. item
end

local function itemsFormat(str)
  if CSILoaded then return "(Disabled by CSI)" end
  return listFormat(str)
end

local function dictFormat(str)
  if str == "" then return "(Default)" end
  if str == " " then return "(Empty)" end

  local dict = NixLib.splitToSet(str)
  local out = ""

  for k, v in pairs(dict) do
    if v == true then out = out .. ", " .. k
    else out = out .. ", " .. k .. ": " .. v end
  end

  return out:sub(3)
end

local function tristateFormat(val)
  if val == -1 then return "No"
  elseif val == 0 then return "(Default)"
  elseif val == 1 then return "Yes"
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

-----------
-- ENUMS --
--#region--

local enumTristate = Enum.sequence {
  NO=-1,
  DEFAULT=0,
  YES=1
}

local enumSongEnd = Enum.sequence {
  DEFAULT=0,
  DEATH=1,
  DESCEND=2
}

--#endregion Enums

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

--#endregion health settings
--#region Inventory settings

Inv = Settings.group {
  name="Inventory settings",
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
  enableIf=function() return not CSILoaded end
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
  id="countdown"
}

GrooveDropActive = Settings.entitySchema.enum {
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
  format=numberFormat(0, -1),
  editAsString=true
}

--#endregion

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
  end
}

--#endregion Return