local Action          = require "necro.game.system.Action"
local Event           = require "necro.event.Event"
local ItemBan         = require "necro.game.item.ItemBan"
local LevelExit       = require "necro.game.tile.LevelExit"
local SettingsStorage = require "necro.config.SettingsStorage"

local CRSettings = require "CharRules.Settings"
local CREnum     = require "CharRules.Enum"

local CSILoaded = pcall(require, "ControlledStartingInventory.CSISettings")

------------
-- EVENTS --
--#region---

Event.entitySchemaLoadEntity.add("charRulesComponents", { order = "overrides" }, function(ev)
  local isAdvanced = SettingsStorage.get("config.showAdvanced")
  local entity = ev.entity
  local useItemBans = CRSettings.get("generic.inventory.bans.enable")

  --#region
  -- Custom item bans
  if useItemBans then
    local customItems = CRSettings.get("generic.inventory.bans.custom.items")

    for i, v in ipairs(customItems) do
      if v == entity.name then
        entity.CharRules_banCustom = {}
        break
      end
    end
  end
  --#endregion

  if not entity.playableCharacter then return end

  --#region INVENTORY SETTINGS--
  local useInventorySettings = CRSettings.get("generic.inventory.enable")
  if useInventorySettings == CREnum.Inventory.REPLACE then
    entity.initialInventory = entity.initialInventory or {}
    entity.initialInventory.items = CRSettings.get("generic.inventory.items")
  elseif useInventorySettings == CREnum.Inventory.ADD then
    entity.initialInventory = entity.initialInventory or {}
    entity.initialInventory.items = entity.initialInventory.items or {}
    for i, v in ipairs(CRSettings.get("generic.inventory.items")) do
      table.insert(entity.initialInventory.items, v)
    end
  end

  --#region ITEM BAN SETTINGS--
  entity.inventoryBannedItems = entity.inventoryBannedItems or { components = {} }
  if useItemBans then
    entity.inventoryBannedItems.components = {}
    entity.inventoryBannedItems.components.item = CRSettings.get("generic.inventory.bans.item")
    entity.inventoryBannedItems.components.consumableHeal = CRSettings.get("generic.inventory.bans.consumableHeal")
    entity.inventoryBannedItems.components.itemActivable = CRSettings.get("generic.inventory.bans.itemActivable")
    entity.inventoryBannedItems.components.itemArmor = CRSettings.get("generic.inventory.bans.itemArmor")
    entity.inventoryBannedItems.components.itemBanHealthlocked = CRSettings.get("generic.inventory.bans.itemBanHealthlocked")
    entity.inventoryBannedItems.components.itemBanNoDamage = CRSettings.get("generic.inventory.bans.itemBanNoDamage")
    entity.inventoryBannedItems.components.itemBanPacifist = CRSettings.get("generic.inventory.bans.itemBanPacifist")
    entity.inventoryBannedItems.components.itemBanPoverty = CRSettings.get("generic.inventory.bans.itemBanPoverty")
    entity.inventoryBannedItems.components.itemBanWeaponlocked = CRSettings.get("generic.inventory.bans.itemBanWeaponlocked")
    entity.inventoryBannedItems.components.itemMoveAmplifier = CRSettings.get("generic.inventory.bans.itemMoveAmplifier")
    entity.inventoryBannedItems.components.itemPurchasePriceMultiplier = CRSettings.get("generic.inventory.bans.itemPurchasePriceMultiplier")
    if isAdvanced then
      entity.inventoryBannedItems.components.CharRules_banCustom = CRSettings.get("generic.inventory.bans.custom.flags")
      for i, v in ipairs(CRSettings.get("generic.inventory.bans.custom.components")) do
        entity.inventoryBannedItems.components[v] = CRSettings.get("generic.inventory.bans.custom.flags")
      end
    end
  end

  local goldKills = CRSettings.get("character.monk.goldKills")
  if goldKills == CREnum.Tristate.NO then
    entity.inventoryBannedItems.components.itemCurrency = nil
  elseif goldKills == CREnum.Tristate.YES then
    entity.inventoryBannedItems.components.itemCurrency = ItemBan.Flag.PICKUP_DEATH
  end

  --#endregion
  --#endregion

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

    entity.health = entity.health or {}
    entity.health.health = healthAmount
    entity.health.maxHealth = healthMax

    entity.cursedHealth = entity.cursedHealth or {}
    entity.cursedHealth.health = healthCursed

    entity.healthLimit = entity.healthLimit or {}
    entity.healthLimit.limit = healthLimit
  end
  --#endregion

  --#region ARIA SETTINGS--
  local useMissedBeat = CRSettings.get("character.aria.missedBeat")
  if useMissedBeat == CREnum.Tristate.NO then
    entity.grooveChainInflictDamageOnDrop = entity.grooveChainInflictDamageOnDrop or {}
    entity.grooveChainInflictDamageOnDrop.active = false
  elseif useMissedBeat == CREnum.Tristate.YES then
    entity.grooveChainInflictDamageOnDrop = entity.grooveChainInflictDamageOnDrop or {}
    entity.grooveChainInflictDamageOnDrop.active = true
    if isAdvanced then
      entity.grooveChainInflictDamageOnDrop.damage = CRSettings.get("character.aria.damage")
      entity.grooveChainInflictDamageOnDrop.type = CRSettings.get("character.aria.damageType")
    end
  end

  local sarcStairLock = CRSettings.get("character.aria.bypassStairLock")
  entity.bypassStairLock = entity.bypassStairLock or { level = 0 }
  if sarcStairLock == CREnum.Tristate.NO and entity.bypassStairLock then
    entity.bypassStairLock.level = bit.band(entity.bypassStairLock.level, bit.bnot(LevelExit.StairLock.SARCOPHAGUS))
  elseif sarcStairLock == CREnum.Tristate.YES then
    entity.bypassStairLock.level = bit.bor(entity.bypassStairLock.level, LevelExit.StairLock.SARCOPHAGUS)
  end
  --#endregion

  --#region DORIAN SETTINGS--
  local useCursedBoots = CRSettings.get("character.dorian.cursed")
  if useCursedBoots == CREnum.Tristate.NO then
    entity.takeDamageOnUntoggledMovement = false
  elseif useCursedBoots == CREnum.Tristate.YES then
    entity.takeDamageOnUntoggledMovement = entity.takeDamageOnUntoggledMovement or {}
    if isAdvanced then
      entity.takeDamageOnUntoggledMovement.damage = CRSettings.get("character.dorian.customize.damage")
      entity.takeDamageOnUntoggledMovement.type = CRSettings.get("character.dorian.customize.type")
    end
  end
  --#endregion

  --#region ELI SETTINGS--
  local getWallGold = CRSettings.get("character.eli.wallGold")
  if getWallGold == CREnum.Tristate.NO then
    entity.wallDropSuppressor = {}
  elseif getWallGold == CREnum.Tristate.YES then
    entity.wallDropSuppressor = false
  end
  --#endregion

  --#region MONK SETTINGS--
  local shoplifter = CRSettings.get("character.monk.shoplifter")
  if shoplifter == CREnum.Tristate.NO then
    entity.shoplifter = false
  elseif shoplifter == CREnum.Tristate.YES then
    entity.shoplifter = entity.shoplifter or {}
  end

  local goldHater = CRSettings.get("character.monk.goldHater")
  if goldHater == CREnum.Tristate.NO then
    entity.goldHater = false
  elseif goldHater == CREnum.Tristate.YES then
    entity.goldHater = entity.goldHater or {}
  end

  local descentCollectCurrency = CRSettings.get("character.monk.descentCollect")
  if descentCollectCurrency == CREnum.Tristate.NO then
    entity.descentCollectCurrency = false
  elseif descentCollectCurrency == CREnum.Tristate.YES then
    entity.descentCollectCurrency = entity.descentCollectCurrency or {}
  end

  local enemyDrops = CRSettings.get("character.monk.enemyDrops")
  if enemyDrops == CREnum.Tristate.NO then
    entity.minimumCurrencyDrop = false
  elseif enemyDrops == CREnum.Tristate.YES then
    entity.minimumCurrencyDrop = entity.minimumCurrencyDrop or {}
    if isAdvanced then
      entity.minimumCurrencyDrop.minimum = CRSettings.get("character.monk.minimumGold")
    end
  end
  --#endregion

  --#region DOVE SETTINGS--
  local songEndSuicide = CRSettings.get("character.dove.songEndCast")
  if songEndSuicide == CREnum.Tristate.NO then
    entity.songEndCast = { spell = "SpellcastSongEnd" }
  elseif songEndSuicide == CREnum.Tristate.YES then
    entity.songEndCast = { spell = "SpellcastSuicide" }
  end

  local teleportingBombs = CRSettings.get("character.dove.teleportingBombs")
  if teleportingBombs == CREnum.Tristate.NO then
    entity.teleportingBombs = false
  elseif teleportingBombs == CREnum.Tristate.YES then
    entity.teleportingBombs = entity.teleportingBombs or {}
  end

  local bossStairLock = CRSettings.get("character.dove.miniboss")
  if bossStairLock == CREnum.Tristate.NO and entity.bypassStairLock then
    entity.bypassStairLock.level = bit.band(entity.bypassStairLock.level, bit.bnot(LevelExit.StairLock.MINIBOSS))
  elseif bossStairLock == CREnum.Tristate.YES then
    entity.bypassStairLock.level = bit.bor(entity.bypassStairLock.level, LevelExit.StairLock.MINIBOSS)
  end
  --#endregion
end)
