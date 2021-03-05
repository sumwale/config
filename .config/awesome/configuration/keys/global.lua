local awful = require('awful')
require('awful.autofocus')
local beautiful = require('beautiful')
local hotkeys_popup = require('awful.hotkeys_popup').widget

local modkey = require('configuration.keys.mod').modKey
local altkey = require('configuration.keys.mod').altKey
local apps = require('configuration.apps')
local switcher = require('awesome-switcher')

-- Key bindings
local globalKeys =
  awful.util.table.join(
  -- Hotkeys
  awful.key({modkey}, 'F1', hotkeys_popup.show_help, {description = 'Show help', group = 'awesome'}),
  awful.key({modkey, 'Control'}, 'r', _G.awesome.restart, {description = 'reload awesome', group = 'awesome'}),
  awful.key({modkey, 'Control'}, 'q', _G.awesome.quit, {description = 'quit awesome', group = 'awesome'}),
  -- Tag browsing
  awful.key({modkey}, 'w', awful.tag.viewprev, {description = 'view previous', group = 'tag'}),
  awful.key({modkey}, 's', awful.tag.viewnext, {description = 'view next', group = 'tag'}),
  awful.key({altkey, 'Control'}, 'Up', awful.tag.viewprev, {description = 'view previous', group = 'tag'}),
  awful.key({altkey, 'Control'}, 'Down', awful.tag.viewnext, {description = 'view next', group = 'tag'}),
  awful.key({modkey}, 'Escape', awful.tag.history.restore, {description = 'go back', group = 'tag'}),
  -- Default client focus
  awful.key(
    {modkey, 'Shift'},
    'd',
    function()
      awful.client.focus.byidx(1)
    end,
    {description = 'Focus next by index', group = 'client'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'a',
    function()
      awful.client.focus.byidx(-1)
    end,
    {description = 'Focus previous by index', group = 'client'}
  ),
  awful.key(
    {modkey},
    'd',
    function()
      local flag = false
      for _, c in ipairs(mouse.screen.selected_tag:clients()) do
                 if c.minimized == true then
                   flag = true
                 end
                 c.minimized = true
      end
      for _, c in ipairs(mouse.screen.selected_tag:clients()) do
                 if flag == true then
                   c.minimized = false
                 end
      end
    end,
    {description = 'minimize all clients', group = 'awesome'}
  ),
  awful.key(
    {modkey},
    'm',
    function()
      for s in screen do
        if s.left_panel then
          s.left_panel:toggle()
        end
      end
    end,
    {description = 'Main menu', group = 'awesome'}
  ),
  awful.key(
    {modkey},
    'r',
    function()
      awful.spawn(apps.default.rofi)
    end,
    {description = 'Run menu', group = 'awesome'}
  ),
  awful.key(
    {altkey},
    'space',
    function()
      awful.spawn('rofi -combi-modi window,drun,ssh -show combi -modi combi -display-combi ""')
    end,
    {description = 'Detailed run menu', group = 'awesome'}
  ),
  awful.key(
    {'Control', altkey},
    'Delete',
    function()
      awful.spawn('reboot')
    end,
    {description = 'Reboot Computer', group = 'awesome'}
  ),
  awful.key(
    {modkey, altkey},
    'Delete',
    function()
      awful.spawn('shutdown now')
    end,
    {description = 'Shutdown Computer', group = 'awesome'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'l',
    function()
      _G.exit_screen_show()
    end,
    {description = 'Log Out Screen', group = 'awesome'}
  ),
  awful.key({modkey}, 'u', awful.client.urgent.jumpto, {description = 'jump to urgent client', group = 'client'}),
  --[[awful.key(
    {altkey},
    'Tab',
    function()
      --awful.client.focus.history.previous()
      awful.client.focus.byidx(1)
      if _G.client.focus then
        _G.client.focus:raise()
      end
    end,
    {description = 'Switch to next window', group = 'client'}
  ),
  awful.key(
    {altkey, 'Shift'},
    'Tab',
    function()
      --awful.client.focus.history.previous()
      awful.client.focus.byidx(-1)
      if _G.client.focus then
        _G.client.focus:raise()
      end
    end,
    {description = 'Switch to previous window', group = 'client'}
  ),--]]
  awful.key(
    {altkey},
    'Tab',
    function()
      switcher.switch(1, altkey, 'Alt_L', 'Shift', 'Tab')
    end,
    {description = 'Switch to next window', group = 'client'}
  ),
  awful.key(
    {altkey, 'Shift'},
    'Tab',
    function()
      switcher.switch(-1, altkey, 'Alt_L', 'Shift', 'Tab')
    end,
    {description = 'Switch to previous window', group = 'client'}
  ),

  -- Programms
  awful.key(
    {modkey},
    'l',
    function()
      awful.spawn(apps.default.lock)
    end,
    {description = 'Lock the screen', group = 'awesome'}
  ),
  awful.key(
    {},
    'Print',
    function()
      awful.util.spawn_with_shell(apps.default.screenshot_save)
    end,
    {description = 'Take a screenshot of your active monitor and save to Pictures', group = 'screenshots'}
  ),
  awful.key(
    {altkey},
    'Print',
    function()
      awful.util.spawn_with_shell(apps.default.screenshot_save_win)
    end,
    {description = 'Take a screenshot of the active window and save to Pictures', group = 'screenshots'}
  ),
  awful.key(
    {'Control'},
    'Print',
    function()
      awful.util.spawn_with_shell(apps.default.screenshot_save_area)
    end,
    {description = 'Mark an area and save its screenshot to Pictures', group = 'screenshots'}
  ),
  awful.key(
    {'Shift'},
    'Print',
    function()
      awful.util.spawn_with_shell(apps.default.screenshot_clip)
    end,
    {description = 'Take a screenshot of your active monitor and save to clipboard', group = 'screenshots (clipboard)'}
  ),
  awful.key(
    {altkey, 'Shift'},
    'Print',
    function()
      awful.util.spawn_with_shell(apps.default.screenshot_clip_win)
    end,
    {description = 'Take a screenshot of the active window and save to clipboard', group = 'screenshots (clipboard)'}
  ),
  awful.key(
    {'Control', 'Shift'},
    'Print',
    function()
      awful.util.spawn_with_shell(apps.default.screenshot_clip_area)
    end,
    {description = 'Mark an area and save its screenshot to clipboard', group = 'screenshots (clipboard)'}
  ),
  awful.key(
    {modkey},
    'Print',
    function()
      awful.util.spawn_with_shell(apps.default.screenshot)
    end,
    {description = 'Open screenshot tool', group = 'screenshots'}
  ),
  awful.key(
    {modkey},
    'b',
    function()
      awful.util.spawn(apps.default.browser)
    end,
    {description = 'Open browser', group = 'launcher'}
  ),
  awful.key(
    {modkey},
    'e',
    function()
      awful.util.spawn(apps.default.mail)
    end,
    {description = 'Open email client', group = 'launcher'}
  ),
  awful.key(
    {modkey},
    'x',
    function()
      awful.spawn(apps.default.terminal)
    end,
    {description = 'Open a terminal', group = 'launcher'}
  ),
  -- Change layout
  awful.key(
    {altkey, 'Shift'},
    'Right',
    function()
      awful.tag.incmwfact(0.05)
    end,
    {description = 'Increase master width factor', group = 'layout'}
  ),
  awful.key(
    {altkey, 'Shift'},
    'Left',
    function()
      awful.tag.incmwfact(-0.05)
    end,
    {description = 'Decrease master width factor', group = 'layout'}
  ),
  awful.key(
    {altkey, 'Shift'},
    'Down',
    function()
      awful.client.incwfact(0.05)
    end,
    {description = 'Decrease master height factor', group = 'layout'}
  ),
  awful.key(
    {altkey, 'Shift'},
    'Up',
    function()
      awful.client.incwfact(-0.05)
    end,
    {description = 'Increase master height factor', group = 'layout'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'Left',
    function()
      awful.tag.incnmaster(1, nil, true)
    end,
    {description = 'Increase the number of master clients', group = 'layout'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'Right',
    function()
      awful.tag.incnmaster(-1, nil, true)
    end,
    {description = 'Decrease the number of master clients', group = 'layout'}
  ),
  awful.key(
    {modkey, 'Control'},
    'Left',
    function()
      awful.tag.incncol(1, nil, true)
    end,
    {description = 'Increase the number of columns', group = 'layout'}
  ),
  awful.key(
    {modkey, 'Control'},
    'Right',
    function()
      awful.tag.incncol(-1, nil, true)
    end,
    {description = 'Decrease the number of columns', group = 'layout'}
  ),
  awful.key(
    {modkey},
    'space',
    function()
      awful.layout.inc(1)
    end,
    {description = 'Select next', group = 'layout'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'space',
    function()
      awful.layout.inc(-1)
    end,
    {description = 'Select previous', group = 'layout'}
  ),
  awful.key(
    {modkey},
    'h',
    function()
      local c = _G.client.focus
      if c then
        c.minimized = true
      end
    end,
    {description = 'minimize client', group = 'client'}
  ),
  awful.key(
    {modkey},
    'g',
    function()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        _G.client.focus = c
        c:raise()
      end
    end,
    {description = 'restore minimized', group = 'client'}
  ),
  -- Dropdown application
  awful.key(
    {modkey},
    'z',
    function()
      _G.toggle_quake()
    end,
    {description = 'dropdown application', group = 'launcher'}
  ),
  -- Widgets popups
  --[[awful.key(
    {altkey},
    'h',
    function()
      if beautiful.fs then
        beautiful.fs.show(7)
      end
    end,
    {description = 'Show filesystem', group = 'widgets'}
  ),
  awful.key(
    {altkey},
    'w',
    function()
      if beautiful.weather then
        beautiful.weather.show(7)
      end
    end,
    {description = 'Show weather', group = 'widgets'}
  ),--]]
  -- Brightness
  awful.key(
    {},
    'XF86MonBrightnessUp',
    function()
      awful.spawn('xbacklight -inc 1')
    end,
    {description = '+1%', group = 'hotkeys'}
  ),
  awful.key(
    {},
    'XF86MonBrightnessDown',
    function()
      awful.spawn('xbacklight -dec 1')
    end,
    {description = '-1%', group = 'hotkeys'}
  ),
  -- ALSA volume control
  awful.key(
    {},
    'XF86AudioRaiseVolume',
    function()
      awful.spawn('amixer -q -D pulse sset Master 1%+')
    end,
    {description = 'volume up', group = 'hotkeys'}
  ),
  awful.key(
    {},
    'XF86AudioLowerVolume',
    function()
      awful.spawn('amixer -q -D pulse sset Master 1%-')
    end,
    {description = 'volume down', group = 'hotkeys'}
  ),
  awful.key(
    {},
    'XF86AudioMute',
    function()
      awful.spawn('amixer -q -D pulse set Master 1+ toggle')
    end,
    {description = 'toggle mute', group = 'hotkeys'}
  ),
  awful.key(
    {modkey, 'Shift'},
    'm',
    function()
      awful.spawn('amixer -q -D pulse set Capture 1+ toggle')
    end,
    {description = 'toggle microphone mute', group = 'hotkeys'}
  ),
  --[[awful.key(
    {},
    'XF86AudioNext',
    function()
      --
    end,
    {description = 'toggle mute', group = 'hotkeys'}
  ),
  awful.key(
    {},
    'XF86PowerDown',
    function()
      --
    end,
    {description = 'toggle mute', group = 'hotkeys'}
  ),
  awful.key(
    {},
    'XF86PowerOff',
    function()
      _G.exit_screen_show()
    end,
    {description = 'toggle mute', group = 'hotkeys'}
  ),--]]
  -- Screen management
  awful.key(
    {modkey},
    'o',
    awful.client.movetoscreen,
    {description = 'move window to next screen', group = 'client'}
  ),
  -- Open default program for tag
  awful.key(
    {modkey},
    't',
    function()
      awful.spawn(
          awful.screen.focused().selected_tag.defaultApp,
          {
            tag = _G.mouse.screen.selected_tag,
            placement = awful.placement.centered
          }
        )
    end,
    {description = 'Open default program for tag/workspace', group = 'tag'}
  ),
  -- Custom hotkeys
  -- type firefox master password
  awful.key(
    {'Control','Shift'},
    'F11',
    function()
      awful.util.spawn_with_shell('sleep 0.5; xdotool type `secret-tool lookup mozilla firefox-master`')
    end
  ),
  -- type thunderbird master password
  awful.key(
    {'Control','Shift'},
    'F12',
    function()
      awful.util.spawn_with_shell('sleep 0.5; xdotool type `secret-tool lookup mozilla thunderbird-master`')
    end
  ),
  -- File Manager
  awful.key(
    {modkey},
    'f',
    function()
      awful.util.spawn(apps.default.files)
    end,
    {description = 'filebrowser', group = 'launcher'}
  ),
  -- Software Manager
  awful.key(
    {modkey},
    'p',
    function()
      awful.util.spawn(apps.default.software)
    end,
    {description = 'software manager', group = 'launcher'}
  ),
  -- Raise conky
  awful.key(
    {modkey},
    'c',
    function()
      for _, c in ipairs(_G.client.get()) do
        if c.class == 'conky' then
          c:jump_to(false)
          break
        end
      end
    end,
    {description = 'raise conky', group = 'hotkeys'}
  )
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
  -- Hack to only show tags 1 and 9 in the shortcut window (mod+s)
  local descr_view, descr_toggle, descr_move, descr_toggle_focus
  if i == 1 or i == 9 then
    descr_view = {description = 'view tag #', group = 'tag'}
    descr_toggle = {description = 'toggle tag #', group = 'tag'}
    descr_move = {description = 'move focused client to tag #', group = 'tag'}
    descr_toggle_focus = {description = 'toggle focused client on tag #', group = 'tag'}
  end
  globalKeys =
    awful.util.table.join(
    globalKeys,
    -- View tag only.
    awful.key(
      {modkey},
      '#' .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          tag:view_only()
        end
      end,
      descr_view
    ),
    -- Toggle tag display.
    awful.key(
      {modkey, 'Control'},
      '#' .. i + 9,
      function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then
          awful.tag.viewtoggle(tag)
        end
      end,
      descr_toggle
    ),
    -- Move client to tag.
    awful.key(
      {modkey, 'Shift'},
      '#' .. i + 9,
      function()
        if _G.client.focus then
          local tag = _G.client.focus.screen.tags[i]
          if tag then
            _G.client.focus:move_to_tag(tag)
          end
        end
      end,
      descr_move
    ),
    -- Toggle tag on focused client.
    awful.key(
      {modkey, 'Control', 'Shift'},
      '#' .. i + 9,
      function()
        if _G.client.focus then
          local tag = _G.client.focus.screen.tags[i]
          if tag then
            _G.client.focus:toggle_tag(tag)
          end
        end
      end,
      descr_toggle_focus
    )
  )
end

return globalKeys
