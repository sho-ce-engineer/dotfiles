-- ウィンドウ操作
function snapLeftHalf()
  local win = hs.window.focusedWindow()
  local screen = win:screen():frame()
  win:setFrame({x=screen.x, y=screen.y, w=screen.w/2, h=screen.h})
end

function snapRightHalf()
  local win = hs.window.focusedWindow()
  local screen = win:screen():frame()
  win:setFrame({x=screen.x + screen.w/2, y=screen.y, w=screen.w/2, h=screen.h})
end

function maximizeWindow()
  local win = hs.window.focusedWindow()
  win:setFrame(win:screen():frame())
end

function moveToNextScreen()
  local win = hs.window.focusedWindow()
  local nextScreen = win:screen():next()
  win:moveToScreen(nextScreen)
end

function snapCenterThird()
  local win = hs.window.focusedWindow()
  local screen = win:screen():frame()
  win:setFrame({x=screen.x + screen.w/3, y=screen.y, w=screen.w/3, h=screen.h})
end

function snapLeftThird()
  local win = hs.window.focusedWindow()
  local screen = win:screen():frame()
  win:setFrame({x=screen.x, y=screen.y, w=screen.w/3, h=screen.h})
end

function snapRightThird()
  local win = hs.window.focusedWindow()
  local screen = win:screen():frame()
  win:setFrame({x=screen.x + (screen.w/3)*2, y=screen.y, w=screen.w/3, h=screen.h})
end

function snapTopThird()
  local win = hs.window.focusedWindow()
  local screen = win:screen():frame()
  win:setFrame({x=screen.x, y=screen.y, w=screen.w, h=screen.h/3})
end

function snapMiddleThird()
  local win = hs.window.focusedWindow()
  local screen = win:screen():frame()
  win:setFrame({x=screen.x, y=screen.y + screen.h/3, w=screen.w, h=screen.h/3})
end

function snapBottomThird()
  local win = hs.window.focusedWindow()
  local screen = win:screen():frame()
  win:setFrame({x=screen.x, y=screen.y + (screen.h/3)*2, w=screen.w, h=screen.h/3})
end

function snapBottomTwoThirds()
  local win = hs.window.focusedWindow()
  local screen = win:screen():frame()
  win:setFrame({x=screen.x, y=screen.y + screen.h/3, w=screen.w, h=(screen.h/3)*2})
end

hs.hotkey.bind({"cmd", "alt"}, "Left", snapLeftHalf)
hs.hotkey.bind({"cmd", "alt"}, "Up", maximizeWindow)
hs.hotkey.bind({"cmd", "alt"}, "Down", snapCenterThird)
hs.hotkey.bind({"cmd", "alt"}, "Right", snapRightHalf)
hs.hotkey.bind({"cmd", "alt"}, "1", moveToNextScreen)
hs.hotkey.bind({"cmd", "alt"}, "pad1", snapLeftThird)
hs.hotkey.bind({"cmd", "alt"}, "pad2", snapCenterThird)
hs.hotkey.bind({"cmd", "alt"}, "pad3", snapRightThird)
hs.hotkey.bind({"cmd", "alt", "shift"}, "pad9", snapTopThird)
hs.hotkey.bind({"cmd", "alt", "shift"}, "pad6", snapMiddleThird)
hs.hotkey.bind({"cmd", "alt", "shift"}, "pad3", snapBottomThird)
hs.hotkey.bind({"cmd", "alt", "shift"}, "pad5", snapBottomTwoThirds)
