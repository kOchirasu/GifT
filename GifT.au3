#AutoIt3Wrapper_Icon=upload.ico

#region Include Files
#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#include <GuiToolBar.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <File.au3>
#include <IE.au3>
#include <Misc.au3>
#include "_ColorChooser.au3"
#include "_ColorPicker.au3"
#include "_FileDragDrop.au3"
#endRegion

#region Error Check
If _Singleton("GifT", 1) == 0 Then
	MsgBox(0, "Error", "GifT is already running!")
	Exit
ElseIf Not FileExists(@HomeDrive & "\Users\" & @UserName & "\Dropbox\") Then
	$enable = MsgBox(0, "Error", "You do not seem to have Dropbox installed.  Would you like to install?" & @LF & @LF & "Expected path: " & @HomeDrive & "\Users\" & @UserName & "\Dropbox\")
	If $enable = 6 Then
		ShellExecute("https://www.dropbox.com/downloading", "", "", "open")
		MsgBox(0, "Notice", "Please try again once you have completed the install process.")
	EndIf
	Exit
ElseIf Not FileExists(@HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\") Then
	$enable = MsgBox(4, "Error", "A public Dropbox folder was not detected.  You will need one enabled in order to upload files. Would you like to enable it?" & @LF & @LF & "Expected path: " & @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
	If $enable = 6 Then
		ShellExecute("https://www.dropbox.com/enable_public_folder", "", "", "open")
		MsgBox(0, "Notice", "You must run GifT again once you have created your public folder.")
	Else
		MsgBox(0, "Notice", "If you already have a public Dropbox folder, please change its location to: " & @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
	EndIf
	_Exit()
EndIf
#endregion Errors

#region Variables
Global $hImage, $hGraphic, $hGUI
_Files()
_Splash(-1)

$INIPATH = @HomeDrive & "\GifT\settings.ini"
$UID = 0
$FPS = 5
$LINK = "https://dl.dropboxusercontent.com/u/" & $UID & "/"
$FILENAME = "default" ;Will be changed Date_Time
$path = @HomeDrive & "\Users\Computer\Dropbox\Public\" ;doesnt work
$dir = @HomeDrive & "\GifT\"
$DARK = 200
$LIGHT = 50
$BGCOLOR = 0x000000
$SELCOLOR = 0x0000FF
$MOUSE = True
$UPLOADURL = ""

$started = 0
$stop = 0
#endRegion

#region GUI stuff?
HotKeySet("^+v", "_Reset")
Opt("TrayMenuMode", 3) ; Default tray menu items (Script Paused/Exit) will not be shown. and no checkmarks

$TSETTINGS = TrayCreateItem("Settings")
$TABOUT = TrayCreateItem("About")
TrayCreateItem("")
$TEXIT = TrayCreateItem("Exit")

TraySetState()

$WHOLE = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$UP = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$LEFT = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$RIGHT = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$DOWN = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$GIF = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$SQUARE = GUICreateSquare(0, 0, 0, 0, 0x00FF00)

WinSetTrans($whole, "", 1)
GUISetCursor(3, 1, $whole)

GUISetState(@SW_SHOW, $up)
GUISetState(@SW_SHOW, $left)
GUISetState(@SW_SHOW, $right)
GUISetState(@SW_SHOW, $down)
GUISetState(@SW_SHOW, $gif)
#endRegion

#region Settings Window
$SMAIN 			= GUICreate("Settings", 400, 235, -1, -1, $WS_SYSMENU)
$SDROPPATH 		= GUICtrlCreateInput(@HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\", 5, 10, 300, 22)
$SSAVEPATH 		= GUICtrlCreateInput(@HomeDrive & "\GifT\", 5, 38, 300, 22)
$SDROPBROWSE 	= GUICtrlCreateButton("Browse...", 315, 8, 70, 25)
$SSAVEBROWSE 	= GUICtrlCreateButton("Browse...", 315, 36, 70, 25)

$SUID 			= GUICtrlCreateInput(113843502, 40, 68, 65, 22, $ES_NUMBER)
$SFPS 			= GUICtrlCreateInput(5, 40, 98, 65, 22, $ES_NUMBER)
$SBACKOP 		= GUICtrlCreateInput(200, 195, 68, 65, 22, $ES_NUMBER)
$SSELOP 		= GUICtrlCreateInput(50, 195, 98, 65, 22, $ES_NUMBER)
$SBACKCOL 		= _GUIColorPicker_Create('', 335, 66, 48, 26, IniRead($INIPATH, "settings", "backcol", "0"), BitOR($CP_FLAG_CHOOSERBUTTON, $CP_FLAG_MAGNIFICATION, $CP_FLAG_ARROWSTYLE), 0, -1, -1, 0, 'Colors', 'Custom...', '_ColorChooserDialog')
$SSELCOL 		= _GUIColorPicker_Create('', 335, 96, 48, 26, IniRead($INIPATH, "settings", "selcol", "255"), BitOR($CP_FLAG_CHOOSERBUTTON, $CP_FLAG_MAGNIFICATION, $CP_FLAG_ARROWSTYLE), 0, -1, -1, 0, 'Colors', 'Custom...', '_ColorChooserDialog')

$SCOPY 			= GUICtrlCreateCheckbox(" Copy link to clipboard", 9, 130, 120, 20)
$SOPEN 			= GUICtrlCreateCheckbox(" Open link in browser", 9, 155, 115, 20)
$SDELETE 		= GUICtrlCreateCheckbox(" Delete local files after conversion", 9, 180, 175, 20)
$SSOUND			= GUICtrlCreateCheckbox(" Play notification sound", 210, 130, 125, 20)
$SMOUSE			= GUICtrlCreateCheckbox(" Capture screen with mouse", 210, 155, 150, 20)
$SSAVE 			= GUICtrlCreateCheckbox(" Save gif file locally", 210, 180, 110, 20)

_loadIni()

GUICtrlCreateLabel("UID:", 11, 72, 25, 20)
GUICtrlCreateLabel("FPS:", 11, 102, 25, 20)
GUICtrlCreateLabel("BG Opacity:", 117, 72, 65, 20)
GUICtrlCreateLabel("Select Opacity:", 117, 102, 75, 20)
GUICtrlCreateLabel("BG Color:", 270, 72, 60, 20)
GUICtrlCreateLabel("Select Color:", 270, 102, 60, 20)

GUICtrlSetLimit($SBACKOP, 3)
GUICtrlSetLimit($SSELOP, 3)
GUICtrlSetLimit($SFPS, 2)
#endregion Settings Window

#region Load information
If Not FileExists(@HomeDrive & "\GifT\settings.ini") Then
	_updateIni()
EndIf

_updateVar()
_updateGUI()
Sleep(500)
_endSplash()
#endRegion

While 1 ;Program Loop
	$TMSG = TrayGetMsg()
	Select
		Case $TMSG = $TEXIT
			_Exit()

		Case $TMSG = $TABOUT
			MsgBox(64, "About: GifT", "GIF recorder and uploader via Dropbox.com" & @LF & "with bitly.com as the URL shortener" & @LF & @LF & "Coded in Autoit")

		Case $TMSG = $TSETTINGS
			;Open Settings Window
			GUISetState(@SW_SHOW, $SMAIN)
	EndSelect

	$MSG = GUIGetMsg()
	Switch $MSG
		Case $GUI_EVENT_CLOSE
			_updateIni()
			_updateVar()
			_updateGUI()
			GUISetState(@SW_HIDE, $SMAIN)

		Case $SDROPBROWSE ;
			$temp = FileSelectFolder("Dropbox Upload Path...", "", 3, GUICtrlRead($SDROPPATH))
			If Not @error Then
				GUICtrlSetData($SDROPPATH, $temp & "\")
			EndIf

		Case $SSAVEBROWSE
			$temp = FileSelectFolder("Local Save Path...", "", 3, GUICtrlRead($SSAVEPATH))
			If Not @error Then
				GUICtrlSetData($SSAVEPATH, $temp & "\")
			EndIf
	EndSwitch
WEnd

Func _Capture($l, $t, $w, $h) ;Takes pictures of the desktop until stopped
	$started = 1
	$FILENAME = @YEAR & "-" & @MON & "-" & @MDAY & "_" & Mod(@HOUR, 12) & "." & @MIN & "." & @SEC
	DirCreate($dir & $FILENAME)
	Sleep(200)
	$time = timerInit()
	_ScreenCapture_Capture($dir & $FILENAME & "\" & $FILENAME & ".gif", $l, $t, $w + $l, $h + $t, $MOUSE)
	For $i = 1000 To 9999
		While TimerDiff($time) < $FPS
			Sleep(10)
		WEnd
		$time = timerInit()
		_ScreenCapture_Capture($dir & $FILENAME & "\~" & $i & ".gif", $l, $t, $w + $l, $h + $t, $MOUSE)
		If $started == 0 Then
			Return
		EndIf
	Next
EndFunc   ;==>_Capture

Func _Select() ;Selection process to determine what to record
	While 1
		If _IsPressed("1") Then
			HotKeySet("{F4}", "_Stop")
			HotKeySet("{ESC}", "_Cancel")
			$mp = MouseGetPos()
			WinSetTrans($gif, "", $LIGHT)
			While _IsPressed("01")
				$pos = MouseGetPos()
				$lefts = _Order($mp[0], $pos[0])
				$tops = _Order($mp[1], $pos[1])
				_Update($lefts[0], $tops[0], $lefts[1], $tops[1])
				WinMove($gif, "", $lefts[0], $tops[0], $lefts[1] + 1, $tops[1] + 1)
			WEnd
			GUISetState(@SW_HIDE, $whole)
			WinSetTrans($gif, "", Ceiling($LIGHT / 255))
			_Update($lefts[0], $tops[0], $lefts[1], $tops[1])

			$square = SquareResize($lefts[0] - 3, $tops[0] - 3, $lefts[1] + 7, $tops[1] + 7, $square)
			GUISetState(@SW_SHOW, $square)

			Sleep(10)
			If $UID > 0 Then
				_Capture($lefts[0], $tops[0], $lefts[1], $tops[1])
			Else
				WinMove($up, "", 0, 0, 0, 0)
				WinMove($left, "", 0, 0, 0, 0)
				WinMove($right, "", 0, 0, 0, 0)
				WinMove($down, "", 0, 0, 0, 0)
				WinMove($gif, "", 0, 0, 0, 0)
				GUISetState(@SW_HIDE, $square)
				MsgBox(0, "Error", "Unable to start capture due to UID value: " & $UID & @LF & "Please update your UID in the settings window")
			EndIf
			Return
		EndIf
	WEnd
EndFunc   ;==>_Select

#region Clear Functions

Func _Exit() ;Exits the program
	_Stop()
	$quit = MsgBox(4, "Are you sure?", "Are you sure you want to quit?")
	If $quit == 6 Then
		_Splash(2000)
		Exit
	EndIf
EndFunc   ;==>_Exit

Func _Reset() ;Sets up for screen recording and begins _Select()
	GUISetState(@SW_SHOW, $whole)
	_Update(0, @DesktopHeight, 0, 0)
	_Select()
EndFunc   ;==>_Reset

Func _Stop() ;Stops the current recording and completes final steps
	If $started == 1 Then
		WinMove($up, "", 0, 0, 0, 0)
		WinMove($left, "", 0, 0, 0, 0)
		WinMove($right, "", 0, 0, 0, 0)
		WinMove($down, "", 0, 0, 0, 0)
		WinMove($gif, "", 0, 0, 0, 0)
		GUISetState(@SW_HIDE, $square)
		HotKeySet("{F4}")
		HotKeySet("{ESC}")
		$theFiles = _getFiles($dir & $FILENAME & "\")

		_convert($theFiles, $path, $FPS, @HomeDrive & "\GifT\Gif.exe")
		$UPLOADURL = _shortURL($LINK & $FILENAME & ".gif")
		While Not StringInStr(_GetTrayText("Dropbox"), "Up to date")
			Sleep(500)
		WEnd
		If IniRead($INIPATH, "settings", "sound", "1") == 1 Then
			SoundPlay(@HomeDrive & "\GifT\beep.mp3")
		EndIf
		TrayTip("Upload Complete", $UPLOADURL, 5, 1)
		If IniRead($INIPATH, "settings", "copy", "1") == 1 Then
			ClipPut($UPLOADURL)
		EndIf
		If IniRead($INIPATH, "settings", "open", "4") == 1 Then
			ShellExecute($UPLOADURL, "", "", "open")
		EndIf
		If IniRead($INIPATH, "settings", "delete", "4") == 1 Then
			DirRemove($dir & $FILENAME, 1)
		EndIf
		If IniRead($INIPATH, "settings", "save", "4") == 1 Then
			FileCopy($path & $FILENAME & ".gif", @HomeDrive & "\GifT\Gifs\" & $FILENAME & ".gif", 8)
		EndIf
		$started = 0
	EndIf
EndFunc   ;==>_Stop

Func _Cancel() ;Cancels the current recording and deletes files
	If $started == 1 Then
		WinMove($up, "", 0, 0, 0, 0)
		WinMove($left, "", 0, 0, 0, 0)
		WinMove($right, "", 0, 0, 0, 0)
		WinMove($down, "", 0, 0, 0, 0)
		WinMove($gif, "", 0, 0, 0, 0)
		GUISetState(@SW_HIDE, $square)
		HotKeySet("{F4}")
		HotKeySet("{ESC}")

		DirRemove($dir & $FILENAME, 1)
		TrayTip("Recording Canceled", "The recording has been canceled, and the temporary files have been deleted.", 5, 1)
		$started = 0
	EndIf
EndFunc
#endregion Clear Functions

#region Helper Functions
Func _convert($file, $output, $delay = 200, $path = "C:\GifT\Gif.exe") ;Animates a list of .gif
	Run($path, "", @SW_HIDE)
	$hWnd = WinWait("Gif Creator", "")
	_FileDragDrop($hWnd, $file)
	ControlSetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]", $output)
	ControlSetText($hWnd, "", "[CLASS:Edit; INSTANCE:2]", $delay)
	Sleep(1000)
	ControlClick($hWnd, "", "[CLASS:Button; INSTANCE:1]")
EndFunc   ;==>_convert

Func _getFiles($dir) ;Gets list of files from $dir
	Local $ret = ""
	Local $FileList = _FileListToArray($dir, "*.gif", 1)
	If @error = 1 Then
		MsgBox(0, "", "No Folders Found.")
		Exit
	EndIf
	If @error = 4 Then
		MsgBox(0, "", "No Files Found.")
		Exit
	EndIf
	For $i = 1 To $FileList[0] Step 1
		$ret &= $dir & $FileList[$i] & "|"
	Next
	Return $ret
EndFunc   ;==>_getFiles

Func _GetTrayText($sToolTipTitle) ;Gets text of tray tip
	; Find systray handle
	Local $hSysTray_Handle = ControlGetHandle("[Class:Shell_TrayWnd]", "", "[Class:ToolbarWindow32;Instance:1]")
	If @error Then
		MsgBox(16, "Error", "System tray not found")
		Exit
	EndIf

	; Get systray item count
	Local $iSystray_ButCount = _GUICtrlToolbar_ButtonCount($hSysTray_Handle)
	If $iSystray_ButCount = 0 Then
		MsgBox(16, "Error", "No items found in system tray")
		Exit
	EndIf

	; Look for wanted tooltip
	Local $iSystray_ButtonNumber
	For $iSystray_ButtonNumber = 0 To $iSystray_ButCount - 1
		Local $sText = _GUICtrlToolbar_GetButtonText($hSysTray_Handle, $iSystray_ButtonNumber)
		If StringInStr($sText, $sToolTipTitle) = 1 Then Return $sText
	Next

	Return SetError(1, 0, "")
EndFunc   ;==>_GetTrayText

Func _Order($a, $b) ;Orders $a and $b from least to greatest
	Dim $res[2]
	If $a < $b Then
		$res[0] = $a
		$res[1] = $b - $a
	Else
		$res[0] = $b
		$res[1] = $a - $b
	EndIf
	Return $res
EndFunc   ;==>_Order

Func _shortURL($url, $user = "giftupload", $api = "R_026342ffc376b66dc50460a5634fe2ec") ;shortens URL bit.ly
	Return BinaryToString(InetRead("http://api.bit.ly/v3/shorten?login=" & $user & "&apiKey=" & $api & "&longUrl=" & $url & "&format=txt"))
EndFunc   ;==>_shortURL
#endregion Helper Functions

#region Updates
Func _loadIni() ;Loads ini file and sets data to controls
	GUICtrlSetData($SDROPPATH, IniRead($INIPATH, "settings", "droppath", @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\"))
	GUICtrlSetData($SSAVEPATH, IniRead($INIPATH, "settings", "savepath", @HomeDrive & "\GifT\Local\"))
	GUICtrlSetData($SUID, IniRead($INIPATH, "settings", "uid", "0"))
	GUICtrlSetData($SFPS, IniRead($INIPATH, "settings", "fps", "5"))
	GUICtrlSetData($SBACKOP, IniRead($INIPATH, "settings", "backop", "200"))
	GUICtrlSetData($SSELOP, IniRead($INIPATH, "settings", "selop", "50"))

	GUICtrlSetState($SCOPY, IniRead($INIPATH, "settings", "copy", "1"))
	GUICtrlSetState($SOPEN, IniRead($INIPATH, "settings", "open", "4"))
	GUICtrlSetState($SDELETE, IniRead($INIPATH, "settings", "delete", "4"))
	GUICtrlSetState($SSOUND, IniRead($INIPATH, "settings", "sound", "1"))
	GUICtrlSetState($SMOUSE, IniRead($INIPATH, "settings", "mouse", "1"))
	GUICtrlSetState($SSAVE, IniRead($INIPATH, "settings", "save", "4"))
EndFunc   ;==>_loadIni

Func _Update($l, $t, $w, $h) ;Updates the background gui to have a hole in the middle
	WinMove($up, "", 0, 0, @DesktopWidth, $t)
	WinMove($down, "", 0, $t + $h + 1, @DesktopWidth, @DesktopHeight - $h - $t)
	WinMove($left, "", 0, $t, $l, $h + 1)
	WinMove($right, "", $l + $w + 1, $t, @DesktopWidth - $l - $w, $h + 1)
EndFunc   ;==>_Update

Func _updateGUI() ;Sets the color and opacity of the GUIs
	GUISetBkColor($BGCOLOR, $up)
	GUISetBkColor($BGCOLOR, $left)
	GUISetBkColor($BGCOLOR, $right)
	GUISetBkColor($BGCOLOR, $down)
	GUISetBkColor($SELCOLOR, $gif)

	WinSetTrans($up, "", $DARK)
	WinSetTrans($left, "", $DARK)
	WinSetTrans($right, "", $DARK)
	WinSetTrans($down, "", $DARK)
	WinSetTrans($gif, "", Ceiling($LIGHT / 255))
EndFunc   ;==>_updateGUI

Func _updateIni() ;Writes new values to .ini file
	If GUICtrlRead($SBACKOP) > 255 Then
		GUICtrlSetData($SBACKOP, 255)
	EndIf
	If GUICtrlRead($SBACKOP) < 0 Then
		GUICtrlSetData($SBACKOP, 0)
	EndIf
	If GUICtrlRead($SSELOP) > 255 Then
		GUICtrlSetData($SSELOP, 255)
	EndIf
	If GUICtrlRead($SSELOP) < 0 Then
		GUICtrlSetData($SSELOP, 0)
	EndIf
	If GUICtrlRead($SFPS) > 20 Then
		GUICtrlSetData($SFPS, 20)
	EndIf
	If GUICtrlRead($SFPS) < 1 Then
		GUICtrlSetData($SFPS, 1)
	EndIf
	If Not FileExists(GUICtrlRead($SDROPPATH)) Then
		GUICtrlSetData($SDROPPATH, @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
	EndIf
	If Not FileExists(GUICtrlRead($SSAVEPATH)) Then
		GUICtrlSetData($SSAVEPATH, @HomeDrive & "\GifT\")
	EndIf

	IniWrite($INIPATH, "settings", "droppath", GUICtrlRead($SDROPPATH))
	IniWrite($INIPATH, "settings", "savepath", GUICtrlRead($SSAVEPATH))
	IniWrite($INIPATH, "settings", "uid", GUICtrlRead($SUID))
	IniWrite($INIPATH, "settings", "fps", GUICtrlRead($SFPS))
	IniWrite($INIPATH, "settings", "backop", GUICtrlRead($SBACKOP))
	IniWrite($INIPATH, "settings", "selop", GUICtrlRead($SSELOP))
	IniWrite($INIPATH, "settings", "backcol", _GUIColorPicker_GetColor($SBACKCOL))
	IniWrite($INIPATH, "settings", "selcol", _GUIColorPicker_GetColor($SSELCOL))

	IniWrite($INIPATH, "settings", "copy", GUICtrlRead($SCOPY))
	IniWrite($INIPATH, "settings", "open", GUICtrlRead($SOPEN))
	IniWrite($INIPATH, "settings", "delete", GUICtrlRead($SDELETE))
	IniWrite($INIPATH, "settings", "sound", GUICtrlRead($SSOUND))
	IniWrite($INIPATH, "settings", "mouse", GUICtrlRead($SMOUSE))
	IniWrite($INIPATH, "settings", "save", GUICtrlRead($SSAVE))
EndFunc   ;==>_updateIni

Func _updateVar() ;Updates variable values based on ini file
	$path = IniRead($INIPATH, "settings", "droppath", @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
	$dir = IniRead($INIPATH, "settings", "savepath", @HomeDrive & "\GifT\")
	$UID = IniRead($INIPATH, "settings", "uid", "0")
	$LINK = "https://dl.dropboxusercontent.com/u/" & $UID & "/"
	$FPS = Round(100 / IniRead($INIPATH, "settings", "fps", "5")) * 10
	$DARK = IniRead($INIPATH, "settings", "backop", "200")
	$LIGHT = IniRead($INIPATH, "settings", "selop", "50")
	$BGCOLOR = IniRead($INIPATH, "settings", "backcol", "0")
	$SELCOLOR = IniRead($INIPATH, "settings", "selcol", "255")
	$MOUSE = 1 == IniRead($INIPATH, "settings", "mouse", "1")
EndFunc   ;==>_updateVar
#endregion Updates

#region Splash Image
Func _Splash($d = -1) ;Begins the splash image
	_GDIPlus_Startup()
	; Load PNG image
	$hImage = _GDIPlus_ImageLoadFromFile(@HomeDrive & "\GifT\GifT.png")
	$iWidth = _GDIPlus_ImageGetWidth($hImage)
	$iHeight = _GDIPlus_ImageGetHeight($hImage)

	; Create GUI
	$hGUI = GUICreate("Show PNG", $iWidth, $iHeight, -1, -1, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TOPMOST)
	$hGUI_child = GUICreate("", $iWidth, $iHeight, 0, 0, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TOPMOST + $WS_EX_MDICHILD, $hGUI)
	GUISetBkColor(0xFFFFFF, $hGUI_child)
	GUISetState(@SW_SHOW, $hGUI)
	GUISetState(@SW_SHOW, $hGUI_child)
	SetTransparentBitmap($hGUI, $hImage)
	_WinAPI_SetLayeredWindowAttributes($hGUI_child, 0xFFFFFF, 0xff)

	$hGraphic = _GDIPlus_GraphicsCreateFromHWND($hGUI_child)
	_GDIPlus_GraphicsSetSmoothingMode($hGraphic, 2)
	If $d <> -1 Then
		Sleep($d)
		_endSplash()
	EndIf
EndFunc   ;==>_Splash

Func _endSplash() ;Ends the splash image
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_Shutdown()
	GUIDelete($hGUI)
EndFunc   ;==>_endSplash

Func SetTransparentBitmap($hGUI, $hImage, $iOpacity = 0xFF) ;Used for transparency (.png)
	Local $hScrDC, $hMemDC, $hBitmap, $hOld, $pSize, $tSize, $pSource, $tSource, $pBlend, $tBlend
	$hScrDC = _WinAPI_GetDC(0)
	$hMemDC = _WinAPI_CreateCompatibleDC($hScrDC)
	$hBitmap = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImage)
	$hOld = _WinAPI_SelectObject($hMemDC, $hBitmap)
	$tSize = DllStructCreate($tagSIZE)
	$pSize = DllStructGetPtr($tSize)
	DllStructSetData($tSize, "X", _GDIPlus_ImageGetWidth($hImage))
	DllStructSetData($tSize, "Y", _GDIPlus_ImageGetHeight($hImage))
	$tSource = DllStructCreate($tagPOINT)
	$pSource = DllStructGetPtr($tSource)
	$tBlend = DllStructCreate($tagBLENDFUNCTION)
	$pBlend = DllStructGetPtr($tBlend)
	DllStructSetData($tBlend, "Alpha", $iOpacity)
	DllStructSetData($tBlend, "Format", 1)
	_WinAPI_UpdateLayeredWindow($hGUI, $hGUI, 0, $pSize, $hMemDC, $pSource, 0, $pBlend, $ULW_ALPHA)
	_WinAPI_ReleaseDC(0, $hScrDC)
	_WinAPI_SelectObject($hMemDC, $hOld)
	_WinAPI_DeleteObject($hBitmap)
	_WinAPI_DeleteDC($hMemDC)
EndFunc   ;==>SetTransparentBitmap
#endregion Splash Image

Func _Files() ;Additional files that are needed to run the program
	DirCreate(@HomeDrive & "\GifT\Gifs\")
	DirCreate(@HomeDrive & "\GifT\Local\")
	$check = FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\Gif.exe", @HomeDrive & "\GifT\Gif.exe")
	If $check == 0 Then
		FileCopy(@ScriptDir & "Gif.exe", @HomeDrive & "\GifT\Gif.exe")
	EndIf
	$check = FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\GifT.png", @HomeDrive & "\GifT\GifT.png")
	If $check == 0 Then
		FileCopy(@ScriptDir & "Gif.png", @HomeDrive & "\GifT\Gif.png")
	EndIf
	$check = FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\beep.mp3", @HomeDrive & "\GifT\beep.mp3")
	If $check == 0 Then
		FileCopy(@ScriptDir & "beep.mp3", @HomeDrive & "\GifT\beep.mp3")
	EndIf
EndFunc   ;==>_Files

#region Square GUI
Func _GUISetHole($hWin, $i_X, $i_Y, $i_SizeW, $i_SizeH) ;Creates a hole in the gui
	Local $aWinPos, $Outer_Rgn, $Inner_Rgn, $Wh, $Combined_Rgn
	Local Const $RGN_DIFF = 4
	$aWinPos = WinGetPos($hWin)

	$Outer_Rgn = DllCall("gdi32.dll", "long", "CreateRectRgn", "long", 0, "long", 0, "long", $aWinPos[2], "long", $aWinPos[3])
	$Inner_Rgn = DllCall("gdi32.dll", "long", "CreateRectRgn", "long", $i_Y, "long", $i_Y, "long", $i_Y + $i_SizeW, _
			"long", $i_Y + $i_SizeH)
	$Combined_Rgn = DllCall("gdi32.dll", "long", "CreateRectRgn", "long", 0, "long", 0, "long", 0, "long", 0)
	DllCall("gdi32.dll", "long", "CombineRgn", "long", $Combined_Rgn[0], "long", $Outer_Rgn[0], "long", $Inner_Rgn[0], _
			"int", $RGN_DIFF)
	DllCall("user32.dll", "long", "SetWindowRgn", "hwnd", $hWin, "long", $Combined_Rgn[0], "int", 1)
EndFunc   ;==>_GUISetHole

Func GUICreateSquare($i_X = -1, $i_Y = -1, $i_W = -1, $i_H = -1, $sColor = 0x00FF00) ;Creates a square GUI with a hole
	Local $hSquare_GUI = GUICreate("", $i_W, $i_H, $i_X, $i_Y, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
	GUISetBkColor($sColor)
	_GUISetHole($hSquare_GUI, 3, 3, $i_W - 6, $i_H - 6)
	Return $hSquare_GUI
EndFunc   ;==>GUICreateSquare

Func SquareResize($l, $t, $w, $h, $square) ;Deletes and remakes a square GUI
	GUIDelete($square)
	Return GUICreateSquare($l, $t, $w, $h, 0x00FF00)
EndFunc   ;==>SquareResize
#endRegion