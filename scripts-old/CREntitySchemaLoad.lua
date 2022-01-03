local Action    = require "necro.game.system.Action"
local Event     = require "necro.event.Event"
local ItemBan   = require "necro.game.item.ItemBan"
local LevelExit = require "necro.game.tile.LevelExit"

local CRSettings          = require "CharRules.CRSettings"
local CRInventoryModifier = require "CharRules.CRInventoryModifier"

local CSILoaded, CSISettings = pcall(require, "ControlledStartingInventory.CSISettings")

------------
-- TABLES --
--#region---

local invStartMode,  invStartAdd,  invStartRemove,
       invBansMode,   invBansAdd,   invBansRemove,
     invCursedMode, invCursedAdd, invCursedRemove
local visibleComponents, monocleMode,
      telepathyMode, trapsightMode

--#endregion

------------
-- EVENTS --
--#region---

Event.entitySchemaGenerate.add("charRulesFunctions", {order="components", sequence=-1}, function ()
  invStartMode, invStartAdd, invStartRemove = CRInventoryModifier.inventoryList(CRSettings.get("inv.start"))
  invBansMode, invBansAdd, invBansRemove = CRInventoryModifier.inventoryList(CRSettings.get("inv.bans"))
  invCursedMode, invCursedAdd, invCursedRemove = CRInventoryModifier.inventoryList(CRSettings.get("inv.cursed"))

  local bansAddSet
  local bansRemoveSet

  if invBansAdd then
    bansAddSet = {}
    for i, v in ipairs(invBansAdd) do
      local k, v2 = string.match(v, "^([^:]+):(.+)$")
      if k then bansAddSet[k] = tonumber(v2)
      else bansAddSet[v] = ItemBan.Flag.GENERATE_ITEM_POOL + ItemBan.Flag.GENERATE_LEVEL + ItemBan.Flag.GENERATE_TRANSACTION + ItemBan.Flag.GENERATE_SHRINE_POOL + ItemBan.Flag.PICKUP end
    end
  end

  if invBansRemove then
    bansRemoveSet = {}
    for i, v in ipairs(invBansRemove) do
      local k, v2 = string.match(v, "^([^:]+):(.+)$")
      if k then bansAddSet[k] = tonumber(v2)
      else bansAddSet[v] = bit.bnot(0) end
    end
  end

  invBansAdd = bansAddSet
  invBansRemove = bansRemoveSet

  -- The components people have selected to make visible
  visibleComponents = CRSettings.getList("misc.vision.component.custom")
  monocleMode = CRSettings.get("misc.vision.component.monocle")
  telepathyMode = CRSettings.get("misc.vision.component.telepathy")
  trapsightMode = CRSettings.get("misc.vision.component.trapsight")
end)

Event.entitySchemaLoadEntity.add("charRulesComponents", {order="overrides"}, function(ev)
  local entity = ev.entity

  --#region NOT SETTINGS --
  -- These things aren't settings, they're component adds to make other settings work better
  if entity.visibleByMonocle and monocleMode then
    entity.CharRules_visibleCustom = {}
  end

  if entity.visibleByTelepathy and telepathyMode then
    entity.CharRules_visibleCustom = {}
  end

  if entity.trap and trapsightMode then
    entity.CharRules_visibleCustom = {}
  end

  if visibleComponents ~= nil then    
    for i, v in ipairs(visibleComponents) do
      if entity[v] then
        entity.CharRules_visibleCustom = {}
      end
    end
  end
  --#endregion

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

  if invStartMode then
    local initInv = entity.initialInventory or {}
    if invStartMode == "replace" then initInv.items = invStartAdd
    else
      local newList = {}

      -- Remove stuff from the removed list
      for i, v in ipairs(initInv.items) do
        for i2, v2 in ipairs(invStartRemove) do
          if v2:sub(-1) == "*" then
            -- If it ends in asterisk, treat it as a prefix
            if v:sub(1, v2:len()-1) == v2:sub(1, -2) then goto invStartContinue end
          else
            -- Otherwise treat it as an exact ID
            if v == v2 then goto invStartContinue end
          end
        end

        table.insert(newList, v)

        ::invStartContinue::
      end

      for i, v in ipairs(invStartAdd) do
        -- Add stuff from the additions list
        table.insert(newList, v)
      end

      initInv.items = newList
    end
    entity.initialInventory = initInv
  end

  if invBansMode then
    local bans = entity.inventoryBannedItems or {}
    
    if invBansMode == "replace" then bans.components = invBansAdd
    else
      bans.components = bans.components or {}

      -- Remove stuff from the removed list
      for k, v in pairs(bans.components) do
        if invBansRemove[k] then
          bans.components[k] = bit.band(bans.components[k], bit.bnot(invBansRemove[k]))
        end
      end

      -- Add stuff from the added list
      for k, v in pairs(invBansAdd) do
        if bans.components[k] then
          bans.components[k] = bit.bor(bans.components[k], v)
        else
          bans.components[k] = v
        end
      end
    end

    entity.inventoryBannedItems = bans
  end

  if invCursedMode then
    local curses = entity.inventoryCursedSlots or {}
    
    if invCursedMode == "replace" then curses.slots = invCursedAdd
    else
      curses.slots = curses.slots or {}

      -- Remove stuff from the removed list
      for i, v in ipairs(invCursedRemove) do
        curses.slots[v] = false
      end

      for i, v in ipairs(invCursedAdd) do
        curses.slots[v] = true
      end
    end

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
    local goldRingBan = invBansComp.itemAutoCollectCurrencyOnMove or 0

    if goldKill == 1 then
      currencyBan = bit.bor(currencyBan, ItemBan.Flag.PICKUP_DEATH)
      goldRingBan = bit.bor(goldRingBan, ItemBan.Flag.GENERATE_ITEM_POOL + ItemBan.Flag.GENERATE_LEVEL + ItemBan.Flag.GENERATE_TRANSACTION)
    else
      currencyBan = bit.band(currencyBan, bit.bnot(ItemBan.Flag.PICKUP_DEATH))
      goldRingBan = bit.band(goldRingBan, bit.bnot(ItemBan.Flag.GENERATE_ITEM_POOL + ItemBan.Flag.GENERATE_LEVEL + ItemBan.Flag.GENERATE_TRANSACTION))
    end

    if currencyBan == 0 then currencyBan = nil end
    invBansComp.itemCurrency = currencyBan
    invBansComp.itemAutoCollectCurrencyOnMove = goldRingBan
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
  --#region DAMAGE SETTINGS --

  local damageIncrease = CRSettings.get("damage.increase")

  if damageIncrease == 0 then
    entity.damageIncrease = false
  elseif damageIncrease > 1 then
    local inc = entity.damageIncrease or {}
    inc.damage = damageIncrease
    entity.damageIncrease = inc
  end

  --#endregion
  --#region ALLOWED ACTIONS --

  do
    local dirs = CRSettings.getAllowedActions()
    local filter = entity.actionFilter or {}
    local ignored = filter.ignoreActions or {
      [Action.Direction.UP_RIGHT]=true,
      [Action.Direction.UP_LEFT]=true,
      [Action.Direction.DOWN_LEFT]=true,
      [Action.Direction.DOWN_RIGHT]=true
    }

    for i = 1, 14 do
      if dirs[i] == -1 then
        ignored[i] = true
      elseif dirs[i] == 1 then
        ignored[i] = false
      end
    end

    filter.ignoreActions = ignored
    entity.actionFilter = filter
  end

  --#endregion
  --#region MISC SETTINGS --
  --#region Exit settings

  do
    local miniboss = CRSettings.get("misc.exits.miniboss")
    local sarcophagus = CRSettings.get("misc.exits.sarcophagus")

    local exitStairLock = entity.bypassStairLock or {level=0}
    local exitLevel = exitStairLock.level or 2

    if miniboss == -1 then
      exitLevel = bit.bor(exitLevel, LevelExit.StairLock.MINIBOSS)
    elseif miniboss == 1 then
      exitLevel = bit.band(exitLevel, bit.bnot(LevelExit.StairLock.MINIBOSS))
    end

    if sarcophagus == -1 then
      exitLevel = bit.bor(exitLevel, LevelExit.StairLock.SARCOPHAGUS)
    elseif sarcophagus == 1 then
      exitLevel = bit.band(exitLevel, bit.bnot(LevelExit.StairLock.SARCOPHAGUS))
    end

    exitStairLock.level = exitLevel
    entity.bypassStairLock = exitStairLock
  end

  --#endregion

  do
    local untoggled = CRSettings.get("misc.untoggled")

    if untoggled == -1 then
      entity.takeDamageOnUntoggledMovement = false
    elseif untoggled == 1 then
      entity.takeDamageOnUntoggledMovement = {}
    end

    local lamb = CRSettings.get("misc.lamb")

    if lamb == -1 then
      entity.characterWithFollower = false
    elseif lamb == 1 then
      entity.characterWithFollower = {followerType="Marv"}
    end
  end

  --#region Vision settings

  do
    local visionAll = CRSettings.get("misc.vision.all")

    if visionAll == -1 then
      entity.forceAllTileVision = false
    elseif visionAll == 1 then
      entity.forceAllTileVision = {}
    end

    local useComponents = CRSettings.get("misc.vision.component.use")

    if useComponents then
      entity.forceObjectVision = {component="CharRules_visibleCustom"}
      entity.minimapVision = {component="CharRules_visibleCustom"}
      entity.forceNonSilhouetteVision = {component="CharRules_visibleCustom"}
    end

    local objectLimit = CRSettings.get("misc.vision.objectLimit")

    if objectLimit > 0 then
      local limiter = entity.limitObjectVisionRadius or {}
      limiter.radius = objectLimit
      entity.limitObjectVisionRadius = limiter
    end

    local tileLimit = CRSettings.get("misc.vision.tileLimit")

    if tileLimit > 0 then
      local limiter = entity.limitTileVisionRadius or {}
      limiter.radius = tileLimit
      entity.limitTileVisionRadius = limiter
    end
  end

  --#endregion
  
  --#endregion
end)

--#endregion