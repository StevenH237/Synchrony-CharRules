local module = {}

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
end