local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')

local dpi = require('beautiful').xresources.apply_dpi

-- Clock / Calendar 24h format
local textclock = wibox.widget.textclock('<span font="Fira Code bold 9">%H:%M</span>')

local month_calendar = awful.widget.calendar_popup.month({
screen = s,
start_sunday = false,
week_numbers = true
})
month_calendar:attach(textclock)
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
      width = dpi(44),
      x = s.geometry.width - dpi(92),
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
