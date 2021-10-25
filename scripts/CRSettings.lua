--#region Imports
local Enum            = require "system.utils.Enum"
local Settings        = require "necro.config.Settings"
local SettingsStorage = require "necro.config.SettingsStorage"

local PowerSettings = require "PowerSettings.PowerSettings"

local NixLib = require "NixLib.NixLib"

local CSILoaded = pcall(require, "ControlledStartingInventory.CSISettings")
--#endregion Imports

----------------
-- FORMATTERS --
--#region-------

--#endregion

--------------
-- ENABLERS --
--#region-----

--#endregion

-----------
-- ENUMS --
--#region--

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

Generic = PowerSettings.group {
  id="generic",
  name="Generic rules",
  desc="The basic rules that don't particularly apply to a specific character.",
  order=0
}

GenericHealth = PowerSettings.group {
  id="generic.health",
  name="Health settings",
  desc="Settings affecting the player's health",
  order=0
}

GenericHealthEnable = PowerSettings.entitySchema.bool {
  id="generic.health.enable",
  name="Use these settings",
  desc="Enables the settings on this screen",
  order=0,
  default=false
}

GenericHealthAmount = PowerSettings.entitySchema.number {
  id="generic.health.amount",
  name="Starting health",
  desc="The health with which the player starts",
  order=1,
  default=6,
  minimum=1,
  upperBound=function()
    if SettingsStorage.get("config.showAdvanced") then
      return SettingsStorage.get("mod.CharRules.generic.health.max", Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue("mod.CharRules.generic.health.max")
    else
      return 20
    end
  end
}

GenericHealthMax = PowerSettings.entitySchema.number {
  id="generic.health.max",
  name="Starting health containers",
  desc="The heart containers with which the player starts",
  order=2,
  default=6,
  lowerBound="generic.health.amount",
  upperBound=function()
    local limit = SettingsStorage.get("mod.CharRules.generic.health.limit", Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue("mod.CharRules.generic.health.limit")
    local cursed = SettingsStorage.get("mod.CharRules.generic.health.cursed", Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue("mod.CharRules.generic.health.cursed")

    return limit - cursed
  end,
  visibility=Settings.Visibility.ADVANCED
}

GenericHealthCursed = PowerSettings.entitySchema.number {
  id="generic.health.cursed",
  name="Starting cursed health",
  desc="The cursed health with which the player starts",
  order=3,
  default=0,
  minimum=0,
  upperBound=function()
    local limit = SettingsStorage.get("mod.CharRules.generic.health.limit", Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue("mod.CharRules.generic.health.limit")
    local max = SettingsStorage.get("mod.CharRules.generic.health.max", Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue("mod.CharRules.generic.health.max")

    return limit - max
  end,
  visibility=Settings.Visibility.ADVANCED
}

GenericHealthLimit = PowerSettings.entitySchema.number {
  id="generic.health.limit",
  name="Maximum health containers",
  desc="The number of heart containers above which the player can have no more",
  default=20,
  order=4,
  lowerBound=function()
    local cursed = SettingsStorage.get("mod.CharRules.generic.health.cursed", Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue("mod.CharRules.generic.health.cursed")
    local max = SettingsStorage.get("mod.CharRules.generic.health.max", Settings.Layer.REMOTE_PENDING) or SettingsStorage.getDefaultValue("mod.CharRules.generic.health.max")

    return cursed + max
  end,
  maximum=20,
  visibility=Settings.Visibility.ADVANCED
}

--#endregion

return {
  get = function(entry)
    return SettingsStorage.get("mod.CharRules." .. entry)
  end
}