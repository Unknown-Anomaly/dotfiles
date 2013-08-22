{-# LANGUAGE
     DeriveDataTypeable,
     FlexibleContexts,
     FlexibleInstances,
     MultiParamTypeClasses,
     NoMonomorphismRestriction,
     PatternGuards,
     ScopedTypeVariables,
     TypeSynonymInstances,
     UndecidableInstances
     #-}
{-# OPTIONS_GHC -W -fwarn-unused-imports -fno-warn-missing-signatures #-}

import qualified Data.Map as M
import qualified XMonad.StackSet as W   -- Window cycling with Alt+Tab
import System.IO
import System.Exit
import XMonad
import XMonad.Actions.CycleWS           -- Workspace cycling
import XMonad.Actions.GridSelect        -- Display open windows in 2D grid
import XMonad.Actions.PhysicalScreens   -- Manipulate screens ordered by location instead of ID
import XMonad.Actions.UpdatePointer     -- Change pointer to follow whichever window focus changes to
import XMonad.Hooks.DynamicLog          -- Call loghook with every internal state update
import XMonad.Hooks.FadeInactive        -- Make inactive windows translucent
import XMonad.Hooks.ManageDocks         -- Tools to automatically manage dock programs, such as xmobar and dzen
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Layout.IndependentScreens -- Simulate independent sets of workspaces on each screen
import XMonad.Layout.Fullscreen
import XMonad.Layout.NoBorders          -- Make a given layout display without borders
import XMonad.Layout.Spiral
import XMonad.Layout.Tabbed
import XMonad.Util.Run(spawnPipe)       -- Run commands as external processes
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Util.WorkspaceCompare
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

myManageHook = composeAll [
    className =? "google-chrome"  --> doShift "0_2:web",
    className =? "firefox"        --> doShift "0_2:web",
    resource  =? "desktop_window" --> doIgnore,
    className =? "steam" 	  --> doFloat,
    className =? "Gimp" 	  --> doFloat,
    resource  =? "gpicview" 	  --> doFloat,
    className =? "urxvt" 	  --> doShift "0_1:term",
    className =? "skype"          --> doShift "0_3:im:",
    isFullscreen --> (doF W.focusDown <+> doFullFloat)
    ]

myLayout = avoidStruts (
    Tall 1 (3/100) (1/2) |||
    Mirror (Tall 1 (3/100) (1/2)) |||
    tabbed shrinkText tabConfig |||
    Full |||
    spiral (6/7)) |||
    noBorders (fullscreenFull Full)

myNormalBorderColor  = "#grey"
myFocusedBorderColor = "#red"

tabConfig = defaultTheme {
    activeBorderColor   = "#red",
    activeTextColor     = "#CEFFAC",
    activeColor         = "#000000",
    inactiveBorderColor = "grey",
    inactiveTextColor   = "#EEEEEE",
    inactiveColor       = "#000000"
}

xmobarTitleColor = "#FFB6B0"
xmobarCurrentWorkspaceColor = "#CEFFAC"
myBorderWidth = 2

myTerminal = "urxvt"

myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount where fadeAmount = 0.92

myWorkspaces = withScreens 1 [ "1:term", "2:web", "3:im", "4:media", "5", "6", "7", "8", "9" ]

myKeys conf@(XConfig {XMonad.modMask = modM}) = M.fromList $
    -- Enable grid select with Mod+<Grave> -- the backtick
    [
    ((modM, xK_grave), goToSelected $ gsconfig1),
    -- Use scrot for printscreen snapshot of desktop and single window
    ((0, xK_Print), spawn "scrot"),
    ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s"),
    -- Lock screen with xscreensaver with Mod+<Shift>+L
    ((modM .|. shiftMask, xK_l), spawn "xscreensaver-command -lock"),
    -- Use Mod+<Right/Left> arrow keys to move workspaces
    ((modM, xK_Left), prevWS),
    ((modM, xK_Right), nextWS),
    -- Also use Mod+<Shift>+<Right/Left> to move windows to workspace to left/right
    ((modM .|. shiftMask, xK_Left), shiftToPrev),
    ((modM .|. shiftMask, xK_Right), shiftToNext),

    -- == Program hooks == --
    -- Run terminal
    ((modM .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf),
    -- Launch program with yeganesh
    ((modM, xK_p), spawn "exe=`dmenu_path_c | yeganesh` && eval \"exec $exe\""),

    -- == Use of audio media buttons to control sound == --
    -- Volume down
    ((0, 0x1008FF11), spawn "amixer set Master 1-"),
    -- Volume up
    ((0, 0x1008FF13), spawn "amixer set Master 1+"),
    -- Volume mute toggle
    ((0, 0x1008FF12), spawn "amixer set Master toggle"),

    -- == Mimic Alt-Tab focus switching behavior == --
    -- modM-tab | modM-shift-tab
    ((modM, xK_Tab), windows W.swapDown),
    ((modM .|. shiftMask, xK_Tab), windows W.swapUp),
    -- == Default xmonad controls == --
    -- modM-j / modM-k
    ((modM, xK_j), windows W.focusDown),
    ((modM, xK_k), windows W.focusUp),
    -- Swap the focused window with the next/prev window
    ((modM .|. shiftMask, xK_j), windows W.swapDown),
    ((modM .|. shiftMask, xK_k), windows W.swapUp),
    -- modM-shift-q, Quit
    ((modM .|. shiftMask, xK_q), io (exitWith ExitSuccess)),
    -- modM-q, restart
    ((modM, xK_q), restart "xmonad" True),
    -- modM-shift-c, kill focused window
    ((modM .|. shiftMask, xK_c), kill),
    -- modM-space, Change layout
    ((modM, xK_space), sendMessage NextLayout),
    -- modM-shift-space, Reset layout
    ((modM .|. shiftMask, xK_space), setLayout $ XMonad.layoutHook conf ),
    -- modM-n, resize viewed windows to 'correct' size
    ((modM, xK_n), refresh)
    ]
    ++
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    [((m .|. modM, k), windows $ onCurrentScreen f i)
	| (i, k) <- zip (workspaces' conf) [xK_1 .. xK_9],
	  (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    ++
    [((modM .|. mask, key), f sc)
     | (key, sc) <- zip [xK_w, xK_e, xK_s, xK_d] [0..],
	(f, mask) <- [(viewScreen, 0), (sendToScreen, shiftMask)]]


myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

myMouseBindings (XConfig {XMonad.modMask = modMask}) = M.fromList $ []

gsconfig1 = defaultGSConfig { gs_cellheight = 45, gs_cellwidth = 250 }

-- Perform action every time xmonad is started or is restarted
myStartupHook = return ()


main = do
    --trayerKill <- spawnPipe "pkill trayer"
    xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmobarrc"
    trayerProc <- spawnPipe "pkill trayer; trayer --edge top --align right --SetDockType true --SetPartialStrut true --widthtype percent --width 10 --heighttype pixel --height 18 --transparent true --alpha 0 --tint 0x000000 --padding 0"
    xmonad $ defaults {
        logHook = myLogHook <+> dynamicLogWithPP xmobarPP {
            ppOutput = hPutStrLn xmproc,
            ppTitle = xmobarColor "green" "" . shorten 100,
            ppCurrent = xmobarColor xmobarCurrentWorkspaceColor "",
            ppSort = getSortByTag,
            ppSep = "   "
            },
        manageHook = manageDocks <+> myManageHook,
        startupHook = setWMName "xmonad"
    }


defaults = defaultConfig {
    modMask             = mod4Mask,
    terminal            = myTerminal,
    workspaces          = myWorkspaces,
    focusFollowsMouse   = myFocusFollowsMouse,
    borderWidth         = myBorderWidth,
    normalBorderColor   = myNormalBorderColor,
    focusedBorderColor  = myFocusedBorderColor,

    keys                = myKeys,
    mouseBindings       = myMouseBindings,

    layoutHook          = smartBorders $ myLayout,
    manageHook          = myManageHook,
    startupHook         = myStartupHook
}
