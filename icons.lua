local icons = {
  apple = '',
  cpu = ' ',
  ram = ' ',
  clipboard = '',
  brew = '󰏗 ',
  brew_check = '',

  switch = {
    on = '󱨥',
    off = '󱨦',
  },
  volume = {
    _100 = '󰕾',
    _66 = '󰖀',
    _33 = '󰕿',
    _10 = '󰕿',
    _0 = '󰖁',
  },
  battery = {
    -- Normal (discharging)
    _100 = '󰁹',
    _90 = '󰂂',
    _80 = '󰂁',
    _70 = '󰂀',
    _60 = '󰁿',
    _50 = '󰁾',
    _40 = '󰁽',
    _30 = '󰁼',
    _20 = '󰁻',
    _10 = '󰁺',

    -- Charging (same glyph, different key)
    charging_100 = '󰂅',
    charging_90 = '󰂋',
    charging_80 = '󰂊',
    charging_70 = '󰢞',
    charging_60 = '󰂉',
    charging_50 = '󰢝',
    charging_40 = '󰂈',
    charging_30 = '󰂇',
    charging_20 = '󰂆',
    charging_10 = '󰢜',

    -- Text mode charging symbol
    charging_symbol = '󱐋',
  },
  wifi = {
    upload = '',
    download = '',
    off = '󰖪',
    connected = '󰖩',
    disconnected = '󰖪', -- Same as off when disconnected
    router = '󰩠',
  },
  stats_toggle = {
    show = '',
    hide = '',
  },
  music = {
    anchor = '󰎇',
    shuffle = '',
    prev = '󰒮',
    play = '',
    pause = '',
    next = '󰒭',
    repeat_icon = '',
  },
}

return icons
