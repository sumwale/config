local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')

local dpi = require('beautiful').xresources.apply_dpi

-- Clock 24h format
local textclock = wibox.widget.textclock('<span font="Fira Code bold 8">%H %M</span>', 10)

-- Popup showing 24h clock with seconds
local textclock_popup =
  awful.tooltip(
  {
    objects = {textclock},
    timer_function = function()
      return os.date('%H:%M:%S')
    end,
    timeout = 1,
    font = 'Fira Code 9',
    margin_leftright = dpi(6),
    margin_topbottom = dpi(6),
    mode = 'mouse',
    align = 'right'
  }
)

local clock_widget = wibox.container.margin(textclock, dpi(4), dpi(4), dpi(4), dpi(4))

local ClockPanel = function(s, offset)
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(37),
      width = dpi(24),
      x = s.geometry.x + dpi(4),
      y = s.geometry.y + s.geometry.height - dpi(69),
      stretch = false,
      bg = beautiful.primary.hue_500,
      fg = beautiful.fg_normal,
      struts = {
        left = dpi(24)
      }
    }
  )

  panel:struts(
    {
      left = dpi(0)
    }
  )

  panel:setup {
      layout = wibox.layout.fixed.vertical,
      clock_widget,
  }

  return panel
end

return ClockPanel
