local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')

local dpi = require('beautiful').xresources.apply_dpi

-- Clock 24h format
local textclock = wibox.widget.textclock('<span font="Fira Code bold 9">%H:%M</span>', 15)

-- Popup showing 24h clock with seconds
local textclock_popup =
  awful.tooltip(
  {
    objects = {textclock},
    timer_function = function()
      return os.date('%H:%M:%S')
    end,
    timeout = 1,
    font = 'Fira Code 9.5',
    margin_leftright = dpi(8),
    margin_topbottom = dpi(6),
    mode = 'mouse',
    align = 'left'
  }
)

local clock_widget = wibox.container.margin(textclock, dpi(4), dpi(4), dpi(4), dpi(4))

local ClockPanel = function(s, offset)
  if offset == true then
    offsety = dpi(4)
  end
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(24),
      width = dpi(48),
      x = s.geometry.width - dpi(96),
      y = s.geometry.y  + offsety,
      stretch = false,
      bg = beautiful.primary.hue_500,
      fg = beautiful.fg_normal,
      struts = {
        top = dpi(24)
      }
    }
  )

  panel:struts(
    {
      top = dpi(0)
    }
  )

  panel:setup {
      layout = wibox.layout.fixed.horizontal,
      clock_widget,
  }

  return panel
end

return ClockPanel
