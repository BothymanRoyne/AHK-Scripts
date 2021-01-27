;# WinKey
;! Alt
;^ Ctrl
;+ Shift


#Persistent			; This keeps the script running permanently.
#SingleInstance		; Only allows one instance of the script to run.

; Resize action window horizontally
#^+D::
Send , !{space}
WinWait , ahk_class #32768 ,, 1 ; Waits 1s for menu to exist
If !ErrorLevel ; ErrorLevel is 0 if menu exists
    Send , s{right}
Return

#^+A::
Send , !{space}
WinWait , ahk_class #32768 ,, 1 ; Waits 1s for menu to exist
If !ErrorLevel ; ErrorLevel is 0 if menu exists
    Send , s{left}
Return

; Resize active window vertically
#^+W::
Send , !{space}
WinWait , ahk_class #32768 ,, 1 ; Waits 1s for menu to exist
If !ErrorLevel ; ErrorLevel is 0 if menu exists
    Send , s{up}
Return

#^+S::
Send , !{space}
WinWait , ahk_class #32768 ,, 1 ; Waits 1s for menu to exist
If !ErrorLevel ; ErrorLevel is 0 if menu exists
    Send , s{down}
Return

; Minimize active window
#v::WinMinimize, A

; Close active window
#c::
WinGetTitle, Title, A
PostMessage, 0x112, 0xF060,,, %Title%
return

; Open Volume Mixer
#+z::
    Run sndvol
    return

; Open Sound options
#z::
    cmd=c:\windows\system32\control.exe mmsys.cpl sounds,,2
    Run, %cmd%
    return

; Restart explorer.exe
#f::
    process, close, explorer.exe
    Run, explorer.exe

; Open C: directory
;#w::
;    Run, explorer.exe C:\

; Spotify controls
; ctrl + shift + mouse button backward = previous 
^+XButton1::Media_Prev


; ctrl + shift + mouse button forward = next 
^+XButton2::Media_Next


; ctrl + shift + middle button = pause
^+MButton::Media_Play_Pause

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Win+A to change Audio Playback Device
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
#a::
	toggle:=!toggle ; This toggles the variable between true/false
	if toggle
	{
		Run nircmd setdefaultsounddevice "Speakers"
		soundToggleBox("Speakers")
	}
	else
	{
		Run nircmd setdefaultsounddevice "Headphones"
		soundToggleBox("Headphones")
	}
Return

; Display sound toggle GUI
soundToggleBox(Device)
{
	IfWinExist, soundToggleWin
	{
		Gui, destroy
	}
	
	Gui, +ToolWindow -Caption +0x400000 +alwaysontop
	Gui, Add, text, x35 y8, Default sound: %Device%
	SysGet, screenx, 0
	SysGet, screeny, 1
	xpos:=screenx-275
	ypos:=screeny-100
	Gui, Show, NoActivate x%xpos% y%ypos% h30 w200, soundToggleWin
	
	SetTimer,soundToggleClose, 2000
}
soundToggleClose:
    SetTimer,soundToggleClose, off
    Gui, destroy
Return

;; Open terminal in current Explorer window folder
#If WinActive("ahk_class CabinetWClass") ; explorer

	^+t::
	WinGetTitle, ActiveTitle, A
	If InStr(ActiveTitle, "\")  ; If the full path is displayed in the title bar (Folder Options)
		Fullpath := ActiveTitle
	else
	If InStr(ActiveTitle, ":") ; If the title displayed is something like "DriveName (C:)"
	{
		Fullpath := SubStr(ActiveTitle, -2)
		Fullpath := SubStr(Fullpath, 1, -1)
	}
	else    ; If the full path is NOT displayed in the title bar 
	; https://autohotkey.com/boards/viewtopic.php?p=28751#p28751
	for window in ComObjCreate("Shell.Application").Windows
	{
		try Fullpath := window.Document.Folder.Self.Path
		SplitPath, Fullpath, title
		If (title = ActiveTitle)
			break
	}
	Run, mintty.exe, %Fullpath%
	return 

#If



#SingleInstance Force

;#SC029
#^+3::
MMPrimDPI := 1.0 ;DPI Scale of the primary monitor (divided by 100).
MMSecDPI := 1.5  ;DPI Scale of the secondary monitor (divided by 100).
SysGet, MMCount, MonitorCount
SysGet, MMPrimary, MonitorPrimary
SysGet, MMPrimLRTB, Monitor, MMPrimary
WinGetPos, MMWinGetX, MMWinGetY, MMWinGetWidth, MMWinGetHeight, A
MMWinGetXMiddle := MMWinGetX + (MMWinGetWidth / 2)
MMDPISub := Abs(MMPrimDPI - MMSecDPI) + 1
;Second mon is off, window is lost, bring to primary
if ( (MMCount = 1) and !((MMWinGetXMiddle > MMPrimLRTBLeft + 20) and (MMWinGetXMiddle < MMPrimLRTBRight - 20) and (MMWinGetY > MMPrimLRTBTop + 20) and (MMWinGetY < MMPrimLRTBBottom - 20)) ){
    if ((MMPrimDPI - MMSecDPI) >= 0)
        MMWHRatio := 1 / MMDPISub
    Else
        MMWHRatio := MMDPISub
    MMWinMoveWidth := MMWinGetWidth * MMWHRatio
    MMWinMoveHeight := MMWinGetHeight * MMWHRatio
    WinMove, A,, 0, 0, MMWinMoveWidth, MMWinMoveHeight
    WinMove, A,, 0, 0, MMWinMoveWidth, MMWinMoveHeight ;Fail safe
    return
}
if (MMPrimary = 1)
    SysGet, MMSecLRTB, Monitor, 2
Else
    SysGet, MMSecLRTB, Monitor, 1
MMSecW := MMSecLRTBRight - MMSecLRTBLeft
MMSecH := MMSecLRTBBottom - MMSecLRTBTop
;Primary to secondary
if ( (MMWinGetXMiddle > MMPrimLRTBLeft - 20) and (MMWinGetXMiddle < MMPrimLRTBRight + 20) and (MMWinGetY > MMPrimLRTBTop - 20) and (MMWinGetY < MMPrimLRTBBottom + 20) ){
    if ( (MMSecW) and (MMSecH) ){ ;Checks if sec mon exists. Could have used MMCount instead: if (MMCount >= 2){}
        if ((MMSecDPI - MMPrimDPI) >= 0){
            MMWidthRatio := (MMSecW / A_ScreenWidth) / MMDPISub
            MMHeightRatio := (MMSecH / A_ScreenHeight) / MMDPISub
        }
        Else {
            MMWidthRatio := (MMSecW / A_ScreenWidth) * MMDPISub
            MMHeightRatio := (MMSecH / A_ScreenHeight) * MMDPISub            
        }
        MMWinMoveX := (MMWinGetX * MMWidthRatio) + MMSecLRTBLeft
        MMWinMoveY := (MMWinGetY * MMHeightRatio) + MMSecLRTBTop
        if (MMSecLRTBBottom - MMWinMoveY < 82) ;Check if window is going under taskbar and fixes it.
            MMWinMoveY -= 82
        MMWinMoveWidth := MMWinGetWidth * MMWidthRatio
        MMWinMoveHeight := MMWinGetHeight * MMHeightRatio
        WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
        WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
    }
} ;Secondary to primary
Else if ( (MMWinGetXMiddle > MMSecLRTBLeft - 20) and (MMWinGetXMiddle < MMSecLRTBRight + 20) and (MMWinGetY > MMSecLRTBTop - 20) and (MMWinGetY < MMSecLRTBBottom + 20) ){
    if ( (MMSecW) and (MMSecH) ){
        if ((MMPrimDPI - MMSecDPI) >= 0){
            MMWidthRatio := (A_ScreenWidth / MMSecW) / MMDPISub
            MMHeightRatio := (A_ScreenHeight / MMSecH) / MMDPISub
        }
        Else{
            MMWidthRatio := (A_ScreenWidth / MMSecW) * MMDPISub
            MMHeightRatio := (A_ScreenHeight / MMSecH) * MMDPISub
        }
        MMWinMoveX := (MMWinGetX - MMSecLRTBLeft) * MMWidthRatio
        MMWinMoveY := (MMWinGetY - MMSecLRTBTop) * MMHeightRatio
        if (MMPrimLRTBBottom - MMWinMoveY < 82)
            MMWinMoveY -= 82
        MMWinMoveWidth := MMWinGetWidth * MMWidthRatio
        MMWinMoveHeight := MMWinGetHeight * MMHeightRatio
        WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
        WinMove, A,, MMWinMoveX, MMWinMoveY, MMWinMoveWidth, MMWinMoveHeight
    }
} ;If window is out of current monitors' boundaries or if script fails
Else{
    MsgBox, 4, MM, % "Current window is in " MMWinGetX " " MMWinGetY "`nDo you want to move it to 0,0?"
    IfMsgBox Yes
    WinMove, A,, 0, 0
}
return