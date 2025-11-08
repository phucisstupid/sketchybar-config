local function safe_require(path)
  local ok, err = pcall(require, path)
  if not ok then
    print('[Left Items] ⚠️ Failed to load ' .. path .. ': ' .. tostring(err))
  end
end

local function is_enabled(name)
  return MODULES[name] and MODULES[name].enable ~= false
end

if is_enabled('logo') then
  safe_require('items.left.logo')
end
if is_enabled('spaces') then
  safe_require('items.left.spaces')
end
if is_enabled('front_app') then
  safe_require('items.left.front_app')
end
if is_enabled('menus') then
  safe_require('items.left.menus')
end
