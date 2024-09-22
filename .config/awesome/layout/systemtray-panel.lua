local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local systray = wibox.widget.systray()
systray:set_horizontal(false)
systray:set_base_size(24)

local TopPanel = function(s, offset)
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(150),
      width = dpi(24),
      x = s.geometry.x + dpi(4),
      y = s.geometry.y + s.geometry.height - dpi(251),
      stretch = false,
      bg = beautiful.primary.hue_900,
      fg = beautiful.fg_normal,
      opacity = 0.75,
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
      layout = wibox.layout.align.vertical,
	  wibox.container.margin(systray, dpi(3), dpi(3), dpi(3), dpi(3)),
	  nil,
	  require('widget.battery'),
  }

  return panel
end

return TopPanel
