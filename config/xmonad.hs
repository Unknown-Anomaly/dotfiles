import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.EwmhDesktops
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.WindowProperties
import System.IO
import System.Exit
import XMonad.Actions.CycleWS
import XMonad.Config.Gnome

import XMonad.Layout.Combo
import XMonad.Layout.Fullscreen
import XMonad.Layout.Gaps
import XMonad.Layout.Grid
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Named
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.Reflect
import XMonad.Layout.Tabbed
import XMonad.Layout.TwoPane
import XMonad.Layout.WindowNavigation

import Control.Monad
import Data.Ratio
import qualified Data.Map as M
import qualified XMonad.StackSet as S
myBorderWidth = 2
myNormalBorderColor = "#202030"
myFocusedBorderColor = "#A0A0D0"

myWorkspaces = [ "1:main", "2:web", "3:term", "4:chat", "5:media", "6:mimize" ]

xmobarTitleColor = "#FFB6B0"
xmobarCurrentWorkspaceColor = "#CEFFAC"
borderWidth = 2
normalBorderColor  = "#grey"
focusedBorderColor = "#red"
myModMask = mod4Mask
altMask = mod1Mask


myLayout = avoidStruts (
    tabbed shrinkText tabConfig |||
    Tall 1 (3/100) (1/2) |||
    Mirror (Tall 1 (3/100) (1/2)) |||
    Full |||
    noBorders (fullscreenFull Full))

tabConfig = defaultTheme {
    activeBorderColor   = "#red",
    activeTextColor     = "#CEFFAC",
    activeColor         = "#000000",
    inactiveBorderColor = "grey",
    inactiveTextColor   = "#EEEEEE",
    inactiveColor       = "#000000"
}

myKeys conf = M.fromList $
    [ ((controlMask             , xK_Print   ), spawn "sleep 0.2; scrot -s")
    , ((myModMask .|. shiftMask , xK_l       ), spawn "xscreensaver-command -lock")
    , ((myModMask               , xK_Left    ), prevWS)
    , ((myModMask               , xK_Right   ), nextWS)
    , ((myModMask .|. shiftMask , xK_Left    ), shiftToPrev)
    , ((myModMask .|. shiftMask , xK_Right   ), shiftToNext)
    -- == Program hooks == --
    , ((myModMask .|. shiftMask , xK_Return  ), spawn $ XMonad.terminal conf)
    , ((myModMask               , xK_p       ), spawn "exe=`dmenu_path_c | yeganesh` && eval \"exec $exe\"")    -- Launch program with yeganesh
    -- == Use of audio media buttons to control sound == --
    , ((0, 0x1008FF11                        ), spawn "amixer set Master 1-")        -- Volume down
    , ((0, 0x1008FF13                        ), spawn "amixer set Master 1+")        -- Volume up
    , ((0, 0x1008FF12                        ), spawn "amixer set Master toggle")    -- Volume mute toggle
    -- == Mimic Alt-Tab focus switching behavior == --
    , ((myModMask               , xK_Tab     ), windows S.swapDown)                  -- modM-tab | modM-shift-tab
    , ((myModMask .|. shiftMask , xK_Tab     ), windows S.swapUp)
    -- == Default xmonad controls == --
    , ((myModMask               , xK_j       ), windows S.focusDown)                 -- modM-j | modM-k
    , ((myModMask               , xK_k       ), windows S.focusUp)
    -- Swap the focused window with the next/prev window
    , ((myModMask .|. shiftMask , xK_j       ), windows S.swapDown)                  -- modM-Shift-j / modM-Shift-k
    , ((myModMask .|. shiftMask , xK_k       ), windows S.swapUp)
    -- == Other functions == --
    , ((myModMask .|. shiftMask , xK_q       ), io (exitWith ExitSuccess))           -- modM-shift-q, Quit
    , ((myModMask               , xK_q       ), broadcastMessage ReleaseResources >> restart "xmonad" True)               -- modM-q, restart
    , ((myModMask .|. shiftMask , xK_c       ), kill)                                -- modM-shift-c, kill focused window
    , ((myModMask .|. shiftMask , xK_z       ), spawn "xscreensaver-command -lock" ) -- modM-shift-z, locks screen.
    , ((myModMask               , xK_space   ), sendMessage NextLayout)              -- modM-space, Change layout
    , ((myModMask               , xK_r       ), refresh)                             -- modM-r, resize viewed windows to 'correct' size

    ] ++
    [ ((myModMask, k), windows $ S.greedyView i)
        | (i, k) <- zip myWorkspaces workspaceKeys
    ] ++
    [ ((altMask, k), (windows $ S.shift i) >> (windows $ S.greedyView i))
        | (i, k) <- zip myWorkspaces workspaceKeys
    ]
    where workspaceKeys = [xK_1 .. xK_9]

main = do
    xmproc <- spawnPipe "xmobar"
    xmonad $ defaultConfig
        { manageHook = ( isFullscreen --> doFullFloat ) <+> manageDocks <+> manageHook defaultConfig
        -- manageHook = manageDocks <+> manageHook defaultConfig
        , layoutHook = smartBorders $ myLayout
        , logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "green" "" . shorten 75
                        , ppLayout = const ""
                        , ppSep = " "
                        }
        , terminal = "urxvt"
        , workspaces = myWorkspaces
        , keys = myKeys
        }
