local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local apps = require('configuration.apps')

local dpi = require('beautiful').xresources.apply_dpi

local left_panel_grabber

function left_panel_grabber_stop()
  if left_panel_grabber then
    awful.keygrabber.stop(left_panel_grabber)
  end
end

local left_panel = function(screen)
  local panel_content_width = dpi(400)

  local panel =
    wibox {
    screen = screen,
    width = 1,
    height = 1,
    x = screen.geometry.x,
    y = screen.geometry.y + dpi(30),
    visible = false,
    ontop = false,
    bg = beautiful.primary.hue_900,
    fg = beautiful.fg_normal
  }

  panel.opened = false

  panel:struts(
    {
      left = dpi(0)
    }
  )

  local backdrop =
    wibox {
    ontop = true,
    screen = screen,
    bg = '#00000000',
    type = 'dock',
    x = screen.geometry.x,
    y = screen.geometry.y,
    width = screen.geometry.width,
    height = screen.geometry.height
  }

  function panel:run_rofi()
    _G.awesome.spawn(
      apps.default.rofi,
      false,
      false,
      false,
      false,
      function()
        panel:toggle()
      end
    )
  end

  local open_panel = function()
    panel.width = panel_content_width
    panel.height = screen.geometry.height - dpi(30)
    backdrop.visible = true
    panel.visible = true
    panel.ontop = true
    panel:get_children_by_id('panel_content')[1].visible = true
    panel:emit_signal('opened')

    left_panel_grabber = awful.keygrabber.run(
      function(_, key, event)
        if event == 'release' then
          return
        end

        if key == 'Escape' or key == 'm' then
          panel:toggle()
        elseif key == 's' or key == 'r' or key == 'f' or key == 'a' then
          left_panel_grabber_stop()
          panel:run_rofi()
        elseif key == 'e' or key == 'q' or key == 'x' then
          panel:toggle()
          _G.exit_screen_show()
        end
      end
    )

  end

  local close_panel = function()
    left_panel_grabber_stop()
    panel.width = 1
    panel.height = 1
    backdrop.visible = false
    panel.visible = false
    panel.ontop = false
    panel:get_children_by_id('panel_content')[1].visible = false
    panel:emit_signal('closed')
  end

  function panel:toggle()
    self.opened = not self.opened
    if self.opened then
      open_panel()
    else
      close_panel()
    end
  end

  backdrop:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          panel:toggle()
        end
      )
    )
  )

  panel:setup {
    layout = wibox.layout.align.vertical,
    nil,
    {
      id = 'panel_content',
      bg = beautiful.primary.hue_900,
      widget = wibox.container.background,
      visible = false,
      forced_width = panel_content_width,
      {
        require('layout.left-panel.dashboard')(screen, panel),
        layout = wibox.layout.stack
      }
    }
  }
  return panel
end

return left_panel
