local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')

local dpi = require('beautiful').xresources.apply_dpi

local icons = require('theme.icons')

local textclock = wibox.widget.textclock('<span font="Fira Code 9">%a, %b %e %Y</span>')

local month_calendar = awful.widget.calendar_popup.month({
  screen = s,
  start_sunday = false,
  week_numbers = true
})
month_calendar:attach(textclock)

local date_widget = wibox.container.margin(textclock, dpi(4), dpi(4), dpi(4), dpi(4))

local DatePanel = function(s, offset)
  local offsetx = 0
  if offset == true then
    offsetx = dpi(128)
    offsety = dpi(4)
  end
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(24),
      width = dpi(124),
      x = s.geometry.width - dpi(217),
      y = s.geometry.y  + offsety,
      stretch = false,
      bg = beautiful.primary.hue_900,
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
      date_widget,
  }

  return panel
end

return DatePanel
