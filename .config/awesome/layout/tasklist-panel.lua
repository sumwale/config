local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local TaskList = require('widget.task-list')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')
local mat_icon_button = require('widget.material.icon-button')
local mat_icon = require('widget.material.icon')

local dpi = beautiful.xresources.apply_dpi

local icons = require('theme.icons')

local add_button = mat_icon_button(mat_icon(icons.plus, dpi(24)))
add_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn(
          awful.screen.focused().selected_tag.defaultApp,
          {
            tag = _G.mouse.screen.selected_tag,
            placement = awful.placement.centered
          }
        )
      end
    )
  )
)

local TasklistPanel = function(s, offset)
  --local offsetx = 0
  --local offsety = 0
  local tasklist_height = dpi(300)
  local offsetx = dpi(4)
  local offsety = (s.geometry.height - tasklist_height - dpi(55)) / 2
  --if offset == true then
  --  offsetx = dpi(4)
    -- dpi(55) is the difference between upper one (tag-list + ...) and bottom one
    -- (system-tray + ...), so task-list is equidistant from the two
  --  offsety = (s.geometry.height - tasklist_height - dpi(55)) / 2
  --end
  local panel =
    wibox(
    {
      ontop = false,
      screen = s,
      height = tasklist_height,
      width = dpi(24),
      x = s.geometry.x + offsetx,
      y = s.geometry.y + offsety,
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
      left = dpi(32)
    }
  )

  panel:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.vertical,
      TaskList(s),
      --add_button
    },
    nil,
    nil
  }

  return panel
end

return TasklistPanel
