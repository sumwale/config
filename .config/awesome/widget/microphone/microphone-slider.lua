local wibox = require('wibox')
local mat_list_item = require('widget.material.list-item')
local mat_slider = require('widget.material.slider')
local mat_icon_button = require('widget.material.icon-button')
local icons = require('theme.icons')
local watch = require('awful.widget.watch')
local spawn = require('awful.spawn')

local slider =
  wibox.widget {
  read_only = false,
  widget = mat_slider
}

local icon =
  wibox.widget {
  image = icons.microphone,
  widget = wibox.widget.imagebox
}

icon.enabled = true

icon:connect_signal(
  'button::release',
  function()
    spawn.easy_async('pactl set-source-mute @DEFAULT_SOURCE@ toggle', function()
      icon.enabled = not icon.enabled
      if icon.enabled then
        icon.image = icons.microphone
      else
        icon.image = icons.microphone_muted
      end
    end)
  end
)

slider:connect_signal(
  'property::value',
  function()
    spawn.easy_async('pactl set-source-volume @DEFAULT_SOURCE@ ' .. slider.value .. '%',
    function() end)
  end
)

watch(
  'sh -c "amixer -D pulse get Capture | tail -1"',
  3,
  function(_, stdout)
    local microphone_volume = tonumber(string.match(stdout, '(%d+)%%'))
    local mute = string.match(stdout, '%[(%l+)%]')
    slider:set_value(microphone_volume)
    if mute == 'on' then
      icon.image = icons.microphone
      icon.enabled = true
    else
      icon.image = icons.microphone_muted
      icon.enabled = false
    end

    collectgarbage('collect')
  end
)

local button = mat_icon_button(icon)

local microphone_setting =
  wibox.widget {
  button,
  slider,
  widget = mat_list_item
}

return microphone_setting
