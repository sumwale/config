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
  image = icons.volume,
  widget = wibox.widget.imagebox
}

icon.enabled = true

icon:connect_signal(
  'button::release',
  function()
    spawn.easy_async('pactl set-sink-mute @DEFAULT_SINK@ toggle', function()
      icon.enabled = not icon.enabled
      if icon.enabled then
        icon.image = icons.volume
      else
        icon.image = icons.volume_muted
      end
    end)
  end
)

slider:connect_signal(
  'property::value',
  function()
    spawn.easy_async('pactl set-sink-volume @DEFAULT_SINK@ ' .. slider.value .. '%',
    function() end)
  end
)

watch(
  'sh -c "amixer -D pulse get Master | tail -1"',
  3,
  function(_, stdout)
    -- don't exceed 100 which will actually avoid calling the setter above since previous
    -- value will be the same as current (i.e. 100) hence volume can be increased
    -- beyond 100 by other means like command-line/GUI or keyboard shortcut
    local volume = math.min(tonumber(string.match(stdout, '(%d+)%%')), 100)
    local mute = string.match(stdout, '%[(%l+)%]')
    slider:set_value(volume)
    if mute == 'on' then
      icon.image = icons.volume
      icon.enabled = true
    else
      icon.image = icons.volume_muted
      icon.enabled = false
    end

    collectgarbage('collect')
  end
)

local button = mat_icon_button(icon)

local volume_setting =
  wibox.widget {
  button,
  slider,
  widget = mat_list_item
}

return volume_setting
