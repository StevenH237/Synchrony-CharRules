local Event   = require "necro.event.Event"
local ItemBan = require "necro.game.item.ItemBan"

local CRSettings = require "CharRules.CRSettings"

local CSILoaded, CSISettings = pcall(require, "ControlledStartingInventory.CSISettings")

------------
-- TABLES --
--#region---

local invStartTable, invBansTable, invCursedTable

--#endregion

------------
-- EVENTS --
--#region---

Event.entitySchemaGenerate.add("charRulesFunctions", {order="components", sequence=-1}, function ()
  invStartTable = CRSettings.getList("inv.start")
  invBansTable = CRSettings.getSet("inv.bans")
  invCursedTable = CRSettings.getSet("inv.cursed")

  if invBansTable then for k, v in pairs(invBansTable) do
    if v == true then invBansTable[k] = ItemBan.Flag.GENERATE_ITEM_POOL + ItemBan.Flag.GENERATE_LEVEL + ItemBan.Flag.GENERATE_TRANSACTION end
  end end
end)

Event.entitySchemaLoadEntity.add("charRulesComponents", {order="overrides"}, function(ev)
  local entity = ev.entity

  if not entity.playableCharacter then return end

  --#region HEALTH SETTINGS --

  local startHealth = CRSettings.get("health.start")
  local startMax = CRSettings.get("health.startMax")
  local startCursed = CRSettings.get("health.startCursed")
  local healthLimit = CRSettings.get("health.limit")

  if startHealth > 0 or startMax > 0 then
    local cmpHealth = entity.health or {}

    if startHealth > 0 then cmpHealth.health = startHealth end
    if startMax > 0 then cmpHealth.maxHealth = startMax end

    entity.health = cmpHealth
  end

  if startCursed > 0 then
    local cmpCursed = entity.cursedHealth or {}
    cmpCursed.health = startCursed
    entity.cursedHealth = cmpCursed
  end

  if healthLimit > 0 then
    local cmpLimit = entity.healthLimit or {}
    cmpLimit.limit = healthLimit
    entity.healthLimit = cmpLimit
  end

  --#region └─ INVINCIBILITY SETTINGS --

  local invEnable = CRSettings.get("health.invincibility.general")
  local invOnHit = CRSettings.get("health.invincibility.onHit")
  local invOnStart = CRSettings.get("health.invincibility.onLevelStart")

  if invEnable == -1 then
    entity.invincibility = false
    entity.invincibilityOnHit = false
    entity.invincibilityOnLevelStart = false
  else
    if invEnable > 0 then
      local inv = entity.invincibility or {}
      if invEnable == 2 then inv.permanent = true end
      entity.invincibility = inv
    end

    if invOnHit == 0 then
      entity.invincibilityOnHit = false
    elseif invOnHit > 0 then
      local invHit = entity.invincibilityOnHit or {}
      invHit.turns = invOnHit
      entity.invincibilityOnHit = invHit
    end

    if invOnStart == 0 then
      entity.invincibilityOnLevelStart = false
    elseif invOnStart > 0 then
      local invStart = entity.invincibilityOnLevelStart or {}
      invStart.turns = invOnStart
      entity.invincibilityOnLevelStart = invStart
    end
  end

  --#endregion
  --#endregion
  --#region INVENTORY SETTINGS --

  if invStartTable and not CSILoaded then
    local initInv = entity.initialInventory or {}
    initInv.items = invStartTable
    entity.initialInventory = initInv
  end

  if invBansTable then
    local bans = entity.inventoryBannedItems or {}
    bans.components = invBansTable
    entity.inventoryBannedItems = bans
  end

  if invCursedTable then
    local curses = entity.inventoryCursedSlots or {}
    curses.slots = invCursedTable
    entity.inventoryCursedSlots = curses
  end

  --#endregion
  --#region RHYTHM SETTINGS --

  local fixedBeat = CRSettings.get("rhythm.fixed")
  local multiplier = CRSettings.get("rhythm.multiplier")
  local songEnd = CRSettings.get("rhythm.songEnd")

  if fixedBeat == -1 then
    entity.rhythmIgnoredTemporarily = entity.rhythmIgnoredTemporarily or {}
    entity.rhythmIgnored = false
  elseif fixedBeat == 1 then
    entity.rhythmIgnored = entity.rhythmIgnored or {}
    entity.rhythmIgnoredTemporarily = false
  end

  if multiplier > 0 then
    local subdiv = entity.rhythmSubdivision or {}
    subdiv.factor = multiplier
    entity.rhythmSubdivision = subdiv
  end

  if songEnd == 2 then
    local cast = entity.songEndCast or {}
    cast.spell = "SpellcastSongEnd"
    entity.songEndCast = cast
  elseif songEnd == 1 then
    local cast = entity.songEndCast or {}
    cast.spell = "SpellcastSuicide"
    entity.songEndCast = cast
  end

  --#endregion
  --#region GROOVE SETTINGS --
  --#region ├─ GROOVE LEVELS --

  local grooveLevelFirst = CRSettings.get("groove.level.first")
  local grooveLevelEach = CRSettings.get("groove.level.each")
  local grooveLevelTotal = CRSettings.get("groove.level.total")

  if grooveLevelFirst > 0 or grooveLevelEach > 0 or grooveLevelTotal > 0 then
    local groove = entity.grooveChain or {}

    if grooveLevelFirst > 0 then groove.killsForInitMultiplier = grooveLevelFirst end
    if grooveLevelEach > 0 then groove.killsPerMultiplier = grooveLevelEach end
    if grooveLevelTotal > 0 then groove.maximumMultiplier = grooveLevelTotal end

    entity.grooveChain = groove
  end

  --#endregion
  --#region └─ GROOVE DROP --

  local dropActive = CRSettings.get("groove.drop.active")
  local dropDamage = CRSettings.get("groove.drop.damage")

  if dropActive ~= 0 or dropDamage ~= 0 then
    local drop = entity.grooveChainInflictDamageOnDrop or {}

    if dropActive == 1 then
      drop.active = true
    elseif dropActive == -1 then
      drop.active = false
    end

    if dropDamage ~= 0 then drop.damage = dropDamage end

    entity.grooveChainInflictDamageOnDrop = drop
  end

  --#endregion
  --#endregion
  --#region GOLD SETTINGS --

  local goldStart = CRSettings.get("gold.start")
  local goldKill = CRSettings.get("gold.kill")
  local goldMinimum = CRSettings.get("gold.minimum")
  local goldFree = CRSettings.get("gold.free")

  if goldStart >= 0 then
    local gold = entity.goldCounter or {}
    gold.amount = goldStart
    entity.goldCounter = gold
  end

  if goldKill ~= 0 then
    entity.goldHater = (goldKill == 1) and {}

    local invBans = entity.inventoryBannedItems or {}
    local invBansComp = invBans.components or {}
    local currencyBan = invBansComp.itemCurrency or 0

    if goldKill == 1 then currencyBan = bit.bor(currencyBan, ItemBan.Flag.PICKUP_DEATH)
    else currencyBan = bit.band(currencyBan, bit.bnot(ItemBan.Flag.PICKUP_DEATH)) end

    if currencyBan == 0 then currencyBan = nil end
    invBansComp.itemCurrency = currencyBan
    invBans.components = invBansComp
    entity.inventoryBannedItems = invBans
  end

  if goldMinimum >= 0 then
    local min = entity.minimumCurrencyDrop or {}
    min.minimum = goldMinimum
    entity.minimumCurrencyDrop = min
  end

  if goldFree == -1 then
    entity.shoplifter = false
  elseif goldFree == 1 then
    entity.shoplifter = {}
  end

  --#endregion
  --#region COUNTDOWN SETTINGS --

  local countdownActive = CRSettings.get("countdown.active")
  local countdownDamage = CRSettings.get("countdown.damage")
  local countdownTimer = CRSettings.get("countdown.timer")

  if countdownActive == 1 then
    local countdown = entity.damageCountdown or {}

    if countdownDamage ~= 0 then countdown.damage = countdownDamage end
    if countdownTimer ~= 0 then countdown.countdownReset = countdownTimer end

    entity.damageCountdown = countdown

    -- defining it like this to not override other-mod flyaway texts
    local countdownFlyaways = entity.damageCountdownFlyaways or {}
    local countdownTexts = countdownFlyaways.texts or {}
    for i = 0, 5 do countdownTexts[i+1] = tostring(i) end
    for i = 10, 50, 10 do countdownTexts[i+1] = tostring(i) end
    countdownFlyaways.texts = countdownTexts
    entity.damageCountdownFlyaways = countdownFlyaways
  elseif countdownActive == -1 then
    entity.damageCountdown = false
  end

  --#endregion
end)

--#endregion