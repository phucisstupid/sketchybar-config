local cal_date = SBAR.add('item', {
  position = 'right',
  padding_left = 2,
  width = 0,
  y_offset = 6,
})

local cal_time = SBAR.add('item', {
  position = 'right',
  padding_left = 2,
  y_offset = -6,
})

-- Double border for calendar using a single item bracket
local cal_bracket = SBAR.add('bracket', { cal_date.name, cal_time.name }, {
  update_freq = 60, -- Update once per minute (time only changes every minute)
})

local function update_calendar()
  cal_date:set({ label = { string = os.date('%b %d') } })
  cal_time:set({ label = { string = os.date('%H:%M') } })
end

cal_bracket:subscribe({ 'forced', 'routine', 'system_woke' }, function(env)
  update_calendar()
end)

local function click_event()
  SBAR.exec('open -a Calendar')
end

cal_date:subscribe('mouse.clicked', click_event)
cal_time:subscribe('mouse.clicked', click_event)
