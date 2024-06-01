local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local clickable_container = require('widget.material.clickable-container')

local dpi = require('beautiful').xresources.apply_dpi

local LayoutBox = function(s)
  local layoutBox = clickable_container(awful.widget.layoutbox(s))
  layoutBox:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        3,
        function()
          awful.layout.inc(-1)
        end
      ),
      awful.button(
        {},
        4,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        5,
        function()
          awful.layout.inc(-1)
        end
      )
    )
  )
  return layoutBox
end

local ModePanel = function(s, offset)
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = dpi(24),
      width = dpi(24),
      x = s.geometry.x + dpi(4),
      y = s.geometry.y + s.geometry.height - dpi(28),
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
    {
      layout = wibox.layout.fixed.vertical,
      LayoutBox(s)
    },
    nil,
    nil
  }

  return panel
end

return ModePanel
