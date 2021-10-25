local Action          = require "necro.game.system.Action"
local Event           = require "necro.event.Event"
local ItemBan         = require "necro.game.item.ItemBan"
local LevelExit       = require "necro.game.tile.LevelExit"
local SettingsStorage = require "necro.config.SettingsStorage"

local CRSettings = require "CharRules.CRSettings"

local CSILoaded = pcall(require, "ControlledStartingInventory.CSISettings")

------------
-- EVENTS --
--#region---

Event.entitySchemaLoadEntity.add("charRulesComponents", {order="overrides"}, function(ev)
  local isAdvanced = SettingsStorage.get("config.showAdvanced")
  local entity = ev.entity

  if not entity.playableCharacter then return end

  --#region HEALTH SETTINGS--
  local useHealthSettings = CRSettings.get("generic.health.enable")
  if useHealthSettings then
    local healthAmount = CRSettings.get("generic.health.amount")
    local healthMax, healthCursed, healthLimit
    if isAdvanced then
      healthMax = CRSettings.get("generic.health.max")
      healthCursed = CRSettings.get("generic.health.cursed")
      healthLimit = CRSettings.get("generic.health.limit")
    else
      healthMax = healthAmount
      healthCursed = 0
      if healthAmount > 1 then
        healthLimit = 20
      else
        healthLimit = 1
      end
    end

    local cmpHealth = entity.health or {}
    cmpHealth.health = healthAmount
    cmpHealth.maxHealth = healthMax
    entity.health = cmpHealth

    local cmpCursed = entity.cursedHealth or {}
    cmpCursed.health = healthCursed
    entity.cursedHealth = cmpCursed

    local cmpLimit = entity.healthLimit or {}
    cmpLimit.limit = healthLimit
    entity.healthLimit = cmpLimit
  end
  --#endregion
end)