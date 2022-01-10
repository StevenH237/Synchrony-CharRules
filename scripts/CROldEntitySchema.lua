local Event = require "necro.event.Event"

local module = {}

module.healthIncreasingItems = {}
module.itemSlots = {}

Event.ecsSchemaReloaded.add("preserveInfo", {order="deleteDeadEntities", sequence=-1}, function(ev)
  for i, v in ipairs(ev.entityTypes) do
    -- Sort items by slot:
    if v.itemSlot then
      module.itemSlots[v.name] = v.itemSlot.name
    end

    -- Max health-increasing items:
    if v.itemIncreaseMaxHealth then
      module.healthIncreasingItems[v.name] = v.itemIncreaseMaxHealth.maxHealth
    end
  end
end)

return module