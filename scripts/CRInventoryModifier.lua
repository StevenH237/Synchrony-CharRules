local module = {}

local NixLib = require("NixLib.NixLib")

-- Returns up to three values:
-- • The first value can either be nil or the strings "replace" or "add".
--   • If it's nil, the second and third values will also be nil.
--   • If it's "replace", the second value will be a table, which is the items
--     to replace the inventory with.
--   • If it's "add", the second value will be a table of items to add to the
--     inventory; then the third is a table of items to remove.
function module.inventoryList(str)
  if str == "" then return nil, nil, nil end
  if str == " " then return "replace", {}, nil end

  local list = NixLib.splitToList(str)

  if #list == 0 then return "replace", {}, nil end

  if list[1] == "+" or list[1] == "-" then
    local adding = true
    local addList = {}
    local remList = {}

    for i, v in ipairs(list) do
      if v == "+" then adding = true
      elseif v == "-" then adding = false
      else
        if adding then table.insert(addList, v)
        else table.insert(remList, v) end
      end
    end

    return "add", addList, remList
  else
    return "replace", list, nil
  end
end

return module