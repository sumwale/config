local wibox = require('wibox')
local mat_list_item = require('widget.material.list-item')
local mat_slider = require('widget.material.slider')
local mat_icon = require('widget.material.icon')
local clickable_container = require('widget.material.clickable-container')
local icons = require('theme.icons')
local watch = require('awful.widget.watch')
local dpi = require('beautiful').xresources.apply_dpi
local spawn = require('awful.spawn')

local slider =
  wibox.widget {
  read_only = false,
  widget = mat_slider
}

slider:connect_signal(
  'property::value',
  function()
    spawn.easy_async('xbacklight -set ' .. math.max(slider.value, 5), function() end)
  end
)

watch(
  'xbacklight -get',
  3,
  function(widget, stdout, stderr, exitreason, exitcode)
    local brightness = string.match(stdout, '(%d+)')

    slider:set_value(tonumber(brightness))
    collectgarbage('collect')
  end
)

local brightness_setting =
  wibox.widget {
  wibox.widget {
    icon = icons.brightness,
    size = dpi(24),
    widget = mat_icon
  },
  slider,
  widget = mat_list_item
}

return brightness_setting
