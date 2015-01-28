#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=upload.ico
#AutoIt3Wrapper_Run_AU3Check=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

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
#include <Misc.au3>
#include "_ColorChooser.au3"
#include "_ColorPicker.au3"
#include "_FileDragDrop.au3"
#endRegion

Global $hImage, $hGraphic, $hGUI
$GIFTPATH 	= @HomeDrive & "\GifT\"
$INIPATH 	= $GIFTPATH & "settings.ini"
$SERVICE 	= IniRead($INIPATH, "settings", "service", "imgur")
$SHORTEN	= IniRead($INIPATH, "settings", "shorten", "waa.ai")

_Splash(-1)
#region Error Check
If _Singleton("GifT", 1) == 0 Then
	MsgBox(262144, "Error", "GifT is already running!")
	Exit
EndIf

If _dropboxCheck() == -1 Then
	MsgBox(0, "Revert", "Reverting to imgur service...")
	IniWrite($INIPATH, "settings", "service", "imgur")
	Exit
EndIf

$VERSION = 8
$NEWVERSION = Number(BinaryToString(InetRead("https://dl.dropboxusercontent.com/u/113843502/GifT/Version.txt")))
If $NEWVERSION > $VERSION Then
	$enable = MsgBox(262148, "Update", "New version of GifT available.  Would you like to download?")
	If $enable == 6 Then
		$enable = MsgBox(262148, "Update", "Would you like source files as well?")
		If $enable == 6 Then
			ShellExecute("https://dl.dropboxusercontent.com/u/113843502/GifT/GifT" & "v" & $NEWVERSION & ".rar", "", "", "open")
		Else
			ShellExecute("https://dl.dropboxusercontent.com/u/113843502/GifT/GifT.exe", "", "", "open")
		EndIf
		Exit
	EndIf
EndIf
#endregion Errors

#region Variables
_Files()

$CURL 		= $GIFTPATH & "curl.exe"

$PATH 		= IniRead($INIPATH, "settings", "droppath", @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
$DIR 		= IniRead($INIPATH, "settings", "savepath", $GIFTPATH)
$UID 		= IniRead($INIPATH, "settings", "uid", "0")
$PUSHKEY	= IniRead($INIPATH, "settings", "pushkey", "0")
$LINK 		= "https://dl.dropboxusercontent.com/u/" & $UID & "/"
$FPS 		= Round(100 / IniRead($INIPATH, "settings", "fps", "5")) * 10
$DARK 		= IniRead($INIPATH, "settings", "backop", "200")
$LIGHT 		= IniRead($INIPATH, "settings", "selop", "50")
$BGCOLOR 	= IniRead($INIPATH, "settings", "backcol", "0")
$SELCOLOR 	= IniRead($INIPATH, "settings", "selcol", "255")
$BOXCOLOR 	= IniRead($INIPATH, "settings", "boxcol", "65280")
$MOUSE 		= 1 == IniRead($INIPATH, "settings", "mouse", "1")
$RECKEY 	= StringReplace(IniRead($INIPATH, "settings", "recordkey", "+ ^ v"), " ", "")
$PICKEY 	= StringReplace(IniRead($INIPATH, "settings", "picturekey", "+ ^ 4"), " ", "")
$COMPKEY 	= StringReplace(IniRead($INIPATH, "settings", "completekey", "{F4}"), " ", "")
$CANCKEY 	= StringReplace(IniRead($INIPATH, "settings", "cancelkey", "{ESC}"), " ", "")

$FILENAME 	= "default" ;Will be changed Date_Time
$UPLOADURL 	= ""

$started 	= 0
$stop 		= 0
#endRegion

#region GUI stuff?
HotKeySet($RECKEY, "_Record")
HotKeySet($PICKEY, "_Picture")
Opt("TrayMenuMode", 3) ; Default tray menu items (Script Paused/Exit) will not be shown. and no checkmarks

$TSETTINGS = TrayCreateItem("Settings")
$TABOUT = TrayCreateItem("About")
TrayCreateItem("")
$TEXIT = TrayCreateItem("Exit")

TraySetState()

$WHOLE = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$UP = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$GIF = GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$SQUARE = GUICreateSquare(0, 0, 0, 0, $BOXCOLOR)

WinSetTrans($whole, "", 1)
GUISetCursor(3, 1, $whole)

GUISetState(@SW_SHOW, $up)
GUISetState(@SW_SHOW, $gif)
#endRegion

#region Settings Window
$SMAIN = GUICreate("GifT Settings", 386, 235, -1, -1, $WS_SYSMENU)
$STABS = GUICtrlCreateTab(7, 7, 367, 195)

GUICtrlCreateTabItem("General")
$SCOPY = GUICtrlCreateCheckbox(" Copy link to clipboard", 19, 100, 120, 20)
$SOPEN = GUICtrlCreateCheckbox(" Open link in browser", 19, 125, 115, 20)
$SDELETE = GUICtrlCreateCheckbox(" Delete local files after conversion", 19, 150, 175, 20)
$SSOUND = GUICtrlCreateCheckbox(" Play notification sound", 215, 100, 125, 20)
$SMOUSE = GUICtrlCreateCheckbox(" Capture screen with mouse", 215, 125, 150, 20)
$SSAVE = GUICtrlCreateCheckbox(" Save gif file locally", 215, 150, 110, 20)
$SUPDATE = GUICtrlCreateCheckbox(" Check for updates", 19, 175, 120, 20)

$SAPI = GUICtrlCreateInput(0, 100, 35, 260, 22)
$SUID = GUICtrlCreateInput(0, 100, 65, 65, 22, $ES_NUMBER)
$SFPS = GUICtrlCreateInput(5, 305, 65, 55, 22, $ES_NUMBER)
GUICtrlCreateLabel("Puush API Key:", 15, 39,90, 20)
GUICtrlCreateLabel("Dropbox UID:", 15, 69, 70, 20)
GUICtrlCreateLabel("Frames per Second:", 195, 69, 100, 20)

GUICtrlSetLimit($SFPS, 2)

GUICtrlCreateTabItem("Hotkeys")
$SRECORD = GUICtrlCreateButton("CTRL + SHIFT + V", 190, 40, 150, 26)
$SPICTURE = GUICtrlCreateButton("CTRL + SHIFT + 4", 190, 70, 150, 26)
$SCOMPLETE = GUICtrlCreateButton("F4", 190, 100, 150, 26)
$SCANCEL = GUICtrlCreateButton("ESC", 190, 130, 150, 26)

GUICtrlCreateLabel("Select Area for Recording:", 25, 45, 140, 20, $ES_RIGHT)
GUICtrlCreateLabel("Select Area for Picture:", 25, 75, 140, 20, $ES_RIGHT)
GUICtrlCreateLabel("Complete Recording:", 25, 105, 140, 20, $ES_RIGHT)
GUICtrlCreateLabel("Cancel Selection/Recording:", 25, 135, 140, 20, $ES_RIGHT)

GUICtrlCreateTabItem("Paths")
GUICtrlCreateGroup("Gif Save Path", 15, 35, 350, 50)
GUICtrlCreateGroup("Dropbox Path", 15, 90, 350, 50)
GUICtrlCreateGroup("わかりません", 15, 145, 350, 50)
$SSAVEPATH = GUICtrlCreateInput($GIFTPATH, 25, 54, 255, 22)
$SDROPPATH = GUICtrlCreateInput(@HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\", 25, 109, 255, 22)
$SSAVEBROWSE = GUICtrlCreateButton("Browse...", 288, 52, 70, 25)
$SDROPBROWSE = GUICtrlCreateButton("Browse...", 288, 107, 70, 25)

GUICtrlCreateTabItem("Colors")
$SBACKOP = GUICtrlCreateInput(200, 93, 54, 55, 22, $ES_NUMBER)
$SSELOP = GUICtrlCreateInput(50, 93, 109, 55, 22, $ES_NUMBER)
$SBOXOP = GUICtrlCreateInput(255, 93, 164, 55, 22, $ES_NUMBER)
$SBACKCOL = _GUIColorPicker_Create('', 235, 52, 48, 26, IniRead($INIPATH, "settings", "backcol", "0"), BitOR($CP_FLAG_CHOOSERBUTTON, $CP_FLAG_MAGNIFICATION, $CP_FLAG_ARROWSTYLE), 0, -1, -1, 0, 'Colors', 'Custom...', '_ColorChooserDialog')
$SSELCOL = _GUIColorPicker_Create('', 235, 107, 48, 26, IniRead($INIPATH, "settings", "selcol", "255"), BitOR($CP_FLAG_CHOOSERBUTTON, $CP_FLAG_MAGNIFICATION, $CP_FLAG_ARROWSTYLE), 0, -1, -1, 0, 'Colors', 'Custom...', '_ColorChooserDialog')
$SBOXCOL = _GUIColorPicker_Create('', 235, 162, 48, 26, IniRead($INIPATH, "settings", "boxcol", "65280"), BitOR($CP_FLAG_CHOOSERBUTTON, $CP_FLAG_MAGNIFICATION, $CP_FLAG_ARROWSTYLE), 0, -1, -1, 0, 'Colors', 'Custom...', '_ColorChooserDialog')

GUICtrlCreateGroup("Background", 15, 35, 350, 50)
GUICtrlCreateLabel("Opacity:", 25, 58, 65, 20)
GUICtrlCreateLabel("Color:", 185, 58, 60, 20)
GUICtrlCreateGroup("Select Rectangle", 15, 90, 350, 50)
GUICtrlCreateLabel("Opacity:", 25, 113, 75, 20)
GUICtrlCreateLabel("Color:", 185, 113, 60, 20)
GUICtrlCreateGroup("Recording Rectangle", 15, 145, 350, 50)
GUICtrlCreateLabel("Opacity:", 25, 168, 75, 20)
GUICtrlCreateLabel("Color:", 185, 168, 60, 20)

GUICtrlSetState($SBOXOP, $GUI_DISABLE)
GUICtrlSetLimit($SBACKOP, 3)
GUICtrlSetLimit($SSELOP, 3)

GUICtrlCreateTabItem("Services")
GUICtrlCreateGroup("URL Shorteners", 15, 35, 350, 50)
GUIStartGroup()
$SWAAAI = GUICtrlCreateRadio("waa.ai", 25, 55, 70, 20)
$SBITLY = GUICtrlCreateRadio("bit.ly", 135, 55, 70, 20)
$SNSHORT = GUICtrlCreateRadio("None", 245, 55, 70, 20)
GUICtrlCreateGroup("Image Hosters", 15, 90, 350, 50)
GUIStartGroup()
$SIMGUR = GUICtrlCreateRadio("imgur", 25, 110, 70, 20)
$SPUUSH = GUICtrlCreateRadio("puush", 135, 110, 70, 20)
$SDROPBOX = GUICtrlCreateRadio("dropbox", 245, 110, 70, 20)
GUICtrlCreateLabel("- Imgur has a file limit of 1MB", 15, 175, 200, 20)

$SHOTKEY = GUICreate("Set Hotkey", 250, 80, -1, -1, $WS_SYSMENU, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))

$SKEY1 = GUICtrlCreateCombo("NONE", 15, 17, 60, 20)
$SKEY2 = GUICtrlCreateCombo("NONE", 90, 17, 60, 20)
$SKEY3 = GUICtrlCreateCombo("0", 165, 17, 60, 20)
GUICtrlSetData($SKEY1, "ALT|CTRL|SHIFT|WIN", "NONE")
GUICtrlSetData($SKEY2, "ALT|CTRL|SHIFT|WIN", "NONE")
GUICtrlSetData($SKEY3, "1|2|3|4|5|6|7|8|9|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|ESC", "0")

#endregion Settings Window

#region Load information
_loadIni()
If Not FileExists($GIFTPATH & "settings.ini") Then
	_updateIni()
EndIf

_updateGUI()
_endSplash()
#endRegion

While 1 ;Program Loop
	$TMSG = TrayGetMsg()
	Select
		Case $TMSG = $TEXIT
			_Exit()

		Case $TMSG = $TABOUT
			MsgBox(64, "About: GifT", "GIF recorder and uploader via Imgur/Puush/Dropbox" & @LF & "with waa.ai/bit.ly as the URL shortener" & @LF & @LF & "Coded in Autoit")

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
			If _dropboxCheck() == -1 Then
				MsgBox(0, "Revert", "Reverting to imgur service...")
				IniWrite($INIPATH, "settings", "service", "imgur")
				Exit
			EndIf
			GUISetState(@SW_HIDE, $SMAIN)

		Case $SDROPBROWSE
			$temp = FileSelectFolder("Dropbox Upload Path...", "", 3, GUICtrlRead($SDROPPATH))
			If Not @error Then
				GUICtrlSetData($SDROPPATH, $temp & "\")
			EndIf

		Case $SSAVEBROWSE
			$temp = FileSelectFolder("Local Save Path...", "", 3, GUICtrlRead($SSAVEPATH))
			If Not @error Then
				GUICtrlSetData($SSAVEPATH, $temp & "\")
			EndIf

		Case $SRECORD
			GUISetState(@SW_HIDE, $SMAIN)
			GUICtrlSetData($SRECORD, _selectKey($SRECORD))

		Case $SPICTURE
			GUISetState(@SW_HIDE, $SMAIN)
			GUICtrlSetData($SPICTURE, _selectKey($SPICTURE))

		Case $SCOMPLETE
			GUISetState(@SW_HIDE, $SMAIN)
			GUICtrlSetData($SCOMPLETE, _selectKey($SCOMPLETE))

		Case $SCANCEL
			GUISetState(@SW_HIDE, $SMAIN)
			GUICtrlSetData($SCANCEL, _selectKey($SCANCEL))

		Case $SWAAAI, $SBITLY, $SNSHORT
			$SHORTEN = GUICtrlRead($MSG, 1)
			IniWrite($INIPATH, "settings", "shorten", $SHORTEN)

		Case $SIMGUR, $SPUUSH, $SDROPBOX
			$SERVICE = GUICtrlRead($MSG, 1)
			IniWrite($INIPATH, "settings", "service", $SERVICE)
	EndSwitch
	Sleep(5)
WEnd

Func _Capture($l, $t, $w, $h) ;Takes pictures of the desktop until stopped
	$started = 1
	$FILENAME = @YEAR & "-" & @MON & "-" & @MDAY & "_" & Mod(@HOUR, 12) & "." & @MIN & "." & @SEC
	DirCreate($dir & $FILENAME)
	Sleep(200)
	$time = timerInit()
	_ScreenCapture_Capture($dir & $FILENAME & "\" & $FILENAME & ".gif", $l, $t, $w, $h, $MOUSE)
	For $i = 1000 To 9999
		While TimerDiff($time) < $FPS
			Sleep(10)
		WEnd
		$time = timerInit()
		_ScreenCapture_Capture($dir & $FILENAME & "\~" & $i & ".gif", $l, $t, $w, $h, $MOUSE)
		If $started == 0 Then
			Return
		EndIf
	Next
EndFunc   ;==>_Capture

Func _takePicture($l, $t, $w, $h)
	$FILENAME = @YEAR & "-" & @MON & "-" & @MDAY & "_" & Mod(@HOUR, 12) & "." & @MIN & "." & @SEC
	_ScreenCapture_Capture($GIFTPATH & "Pictures\" & $FILENAME & ".png", $l, $t, $w, $h, $MOUSE)
	If $service = "dropbox" Then
		If _dropboxCheck() = -1 Then
			If GUICtrlRead($SDELETE) == 1 Then
				FileDelete($GIFTPATH & "Pictures\" & $FILENAME & ".png")
			EndIf
			Exit
		EndIf
		FileCopy($GIFTPATH & "Pictures\" & $FILENAME & ".png", $path & $FILENAME & ".png")
		$UPLOADURL = _shortURL($LINK & $FILENAME & ".png")
		While Not StringInStr(_GetTrayText("Dropbox"), "Up to date")
			Sleep(100)
		WEnd
	Else
		If $service = "imgur" Then
			$ERRCHECK = _imgurUpload($GIFTPATH & "Pictures\" & $FILENAME & ".png")
		ElseIf $service = "puush" Then
			$ERRCHECK = _puushUpload($GIFTPATH & "Pictures\" & $FILENAME & ".png", $PUSHKEY)
		EndIf
		If $ERRCHECK == -1 Then
			MsgBox(0, "Error", "There seems to have been an error with uploading")
			TrayTip("Upload Failed", "There was an error.", 5, 1)
			return
		EndIf
		$UPLOADURL = _shortURL($ERRCHECK)
	EndIf

	If GUICtrlRead($SDELETE) == 1 Then
		FileDelete($GIFTPATH & "Pictures\" & $FILENAME & ".png")
	EndIf

	If GUICtrlRead($SSOUND) == 1 Then
		SoundPlay($GIFTPATH & "beep.mp3")
	EndIf

	TrayTip("Upload Complete", $UPLOADURL, 5, 1)

	If GUICtrlRead($SCOPY) == 1 Then
		ClipPut($UPLOADURL)
	EndIf
	If GUICtrlRead($SOPEN) == 1 Then
		ShellExecute($UPLOADURL, "", "", "open")
	EndIf
EndFunc

Func _Select($action = "r") ;Selection process to determine what to record
	While 1
		If _IsPressed("1") Then
			If $action = "r" Then
				HotKeySet($COMPKEY, "_Stop")
				HotKeySet($CANCKEY, "_Cancel")
				HotKeySet($RECKEY)
				HotKeySet($PICKEY)
			EndIf
			$mp = MouseGetPos()
			WinSetTrans($gif, "", $LIGHT)
			While _IsPressed("01")
				$pos = MouseGetPos()
				$lefts = _Order($mp[0], $pos[0])
				$tops = _Order($mp[1], $pos[1])

				_GUISetHole($up, $lefts[0], $tops[0], $lefts[1] + 1, $tops[1] + 1)
				WinMove($gif, "", $lefts[0], $tops[0], $lefts[1] + 1, $tops[1] + 1)
				Sleep(50)
			WEnd

			GUISetState(@SW_HIDE, $whole)
			WinSetTrans($gif, "", 0)
			_GUISetHole($up, $lefts[0], $tops[0], $lefts[1] + 1, $tops[1] + 1)

			$square = SquareResize($lefts[0] - 3, $tops[0] - 3, $lefts[1] + 7, $tops[1] + 7, $square)
			GUISetState(@SW_SHOW, $square)

			Sleep(10)
			If $SERVICE <> "dropbox" Or $UID > 0 Then
				If $action = "r" Then
					_Capture($lefts[0], $tops[0], $lefts[1] + $lefts[0], $tops[1] + $tops[0])
				ElseIf $action = "p" Then
					WinMove($up, "", 0, 0, 0, 0)
					_GUISetHole($up, 0, 0, 0, 0)
					WinMove($gif, "", 0, 0, 0, 0)
					GUISetState(@SW_HIDE, $square)

					_takePicture($lefts[0], $tops[0], $lefts[1] + $lefts[0], $tops[1] + $tops[0])
				EndIf
			Else
				WinMove($up, "", 0, 0, 0, 0)
				_GUISetHole($up, 0, 0, 0, 0)
				WinMove($gif, "", 0, 0, 0, 0)
				GUISetState(@SW_HIDE, $square)
				MsgBox(0, "Error", "Unable to start capture due to UID value: " & $UID & @LF & "Please update your UID in the settings window")
			EndIf
			Return
		EndIf
		Sleep(25)
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

Func _Reset() ;Resets the screen
	GUISetState(@SW_SHOW, $whole)
	WinMove($up, "", 0, 0, @DesktopWidth, @DesktopHeight)
EndFunc   ;==>_Reset

Func _Record() ; Reset + Begin record
	_Reset()
	_Select("r")
EndFunc

Func _Picture() ; Reset + Take picture
	_Reset()
	_Select("p")
EndFunc

Func _Stop() ;Stops the current recording and completes final steps
	If $started == 1 Then
		$started = 0
		WinMove($up, "", 0, 0, 0, 0)
		_GUISetHole($up, 0, 0, 0, 0)
		WinMove($gif, "", 0, 0, 0, 0)
		GUISetState(@SW_HIDE, $square)
		HotKeySet($COMPKEY)
		HotKeySet($CANCKEY)
		$theFiles = _getFiles($dir & $FILENAME & "\")

		If $service = "dropbox" Then
			_convert($theFiles, $path, $FPS, $GIFTPATH & "Gif.exe")
			If _dropboxCheck() = -1 Then
				If GUICtrlRead($SDELETE) == 1 Then
					DirRemove($dir & $FILENAME, 1)
				EndIf
				If GUICtrlRead($SSAVE) == 1 Then
					FileCopy($path & $FILENAME & ".gif", $GIFTPATH & "Gifs\" & $FILENAME & ".gif", 8)
				EndIf
				Exit
			EndIf

			$UPLOADURL = _shortURL($LINK & $FILENAME & ".gif")
			If GUICtrlRead($SSAVE) == 1 Then
				FileCopy($path & $FILENAME & ".gif", $GIFTPATH & "Gifs\" & $FILENAME & ".gif", 8)
			EndIf
			If GUICtrlRead($SDELETE) == 1 Then
				DirRemove($dir & $FILENAME, 1)
			EndIf
			While Not StringInStr(_GetTrayText("Dropbox"), "Up to date")
				Sleep(500)
			WEnd
		Else
			_convert($theFiles, $GIFTPATH, $FPS, $GIFTPATH & "Gif.exe")
			If $service = "imgur" Then
				$ERRCHECK = _imgurUpload($GIFTPATH & $FILENAME & ".gif")
			ElseIf $service = "puush" Then
				$ERRCHECK = _puushUpload($GIFTPATH & $FILENAME & ".gif", $PUSHKEY)
			EndIf

			If $ERRCHECK == -1 Then
				MsgBox(0, "Error", "There seems to have been an error with uploading")
				TrayTip("Upload Failed", "There was an error.", 5, 1)
				HotKeySet($RECKEY, "_Record")
				HotKeySet($PICKEY, "_Picture")
				return
			EndIf
			$UPLOADURL = _shortURL($ERRCHECK)
			If GUICtrlRead($SSAVE) == 1 Then
				FileCopy($GIFTPATH & $FILENAME & ".gif", $GIFTPATH & "Gifs\" & $FILENAME & ".gif", 8)
			EndIf
			FileDelete($GIFTPATH & $FILENAME & ".gif")
			If GUICtrlRead($SDELETE) == 1 Then
				DirRemove($dir & $FILENAME, 1)
			EndIf
		EndIf

		If GUICtrlRead($SSOUND) == 1 Then
			SoundPlay($GIFTPATH & "beep.mp3")
		EndIf
		TrayTip("Upload Complete", $UPLOADURL, 5, 1)
		If GUICtrlRead($SCOPY) == 1 Then
			ClipPut($UPLOADURL)
		EndIf
		If GUICtrlRead($SOPEN) == 1 Then
			ShellExecute($UPLOADURL, "", "", "open")
		EndIf
		HotKeySet($RECKEY, "_Record")
		HotKeySet($PICKEY, "_Picture")
	EndIf
EndFunc   ;==>_Stop

Func _Cancel() ;Cancels the current recording and deletes files
	If $started == 1 Then
		WinMove($up, "", 0, 0, 0, 0)
		_GUISetHole($up, 0, 0, 0, 0)
		WinMove($gif, "", 0, 0, 0, 0)
		GUISetState(@SW_HIDE, $square)
		HotKeySet($COMPKEY)
		HotKeySet($CANCKEY)
		HotKeySet($RECKEY, "_Record")
		HotKeySet($PICKEY, "_Picture")
		DirRemove($dir & $FILENAME, 1)
		TrayTip("Recording Canceled", "The recording has been canceled, and the temporary files have been deleted.", 5, 1)
		$started = 0
	EndIf
EndFunc
#endregion Clear Functions

#region Helper Functions
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

Func _setKeys($button, $str) ;Sets hotkey buttons with key sequence string
	Dim $keys = StringSplit($str, " ")
	$ret = _convertHotkey($keys[1])
	If $keys[0] > 1 Then
		$ret &= " + " & _convertHotkey($keys[2])
	EndIf
	If $keys[0] > 2 Then
		$ret &= " + " & _convertHotkey($keys[3])
	EndIf
	GUICtrlSetData($button, $ret)
	return $ret
EndFunc

Func _selectKey($BUTTON) ;GUI for selecting hotkey
	$keys = StringSplit(GUICtrlRead($BUTTON), " + ", 1)
	GUISetState(@SW_SHOW, $SHOTKEY)
	GUICtrlSendMsg($SKEY3, 0x14D, 1, $keys[$keys[0]])
	If $keys[0] >= 2 Then
		GUICtrlSendMsg($SKEY2, 0x14D, 1, $keys[$keys[0] - 1])
		If $keys[0] >= 3 Then
			GUICtrlSendMsg($SKEY1, 0x14D, 1, $keys[$keys[0] - 2])
		Else
			GUICtrlSendMsg($SKEY1, 0x14D, 1, "NONE")
		EndIf
	Else
		GUICtrlSendMsg($SKEY1, 0x14D, 1, "NONE")
		GUICtrlSendMsg($SKEY2, 0x14D, 1, "NONE")
	EndIf

	While 1
		$MSG = GUIGetMsg()
		Switch $MSG

		Case $GUI_EVENT_CLOSE
			$str = ""
			If GUICtrlRead($SKEY1) <> "NONE" Then
				$str &= GUICtrlRead($SKEY1) & " + "
			EndIf
			If GUICtrlRead($SKEY2) <> "NONE" Then
				$str &= GUICtrlRead($SKEY2) & " + "
			EndIf
			$str &= GUICtrlRead($SKEY3)

			GUISetState(@SW_HIDE, $SHOTKEY)
			GUISetState(@SW_SHOW, $SMAIN)
			return $str
		EndSwitch
	WEnd
EndFunc   ;==>_selectKey

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

Func _imgurUpload($path, $key = "f77d0b8cd41eb62792be0bf303e649df")
	Local $stdoutr = "", $output = ""
	$run = $CURL & " -F image=@" & $path & " -F key=" & $key & " --retry 2 --location-trusted --url http://api.imgur.com/2/upload.xml"
	$PID = Run($run, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	While $output = ""
		$stdoutr = StdoutRead($PID)
		If Not @error And $stdoutr <> "" Then
			$output &= $stdoutr & @CRLF
		EndIf
	WEnd

	Local $piclink = StringRegExp($output, "http://i.imgur.com/[^<]*", 3)
	If Not @error Then
		return $piclink[0]
	Else
		Select
			Case StringInStr($output, "This method requires authentication")
				MsgBox(262144 + 4096 + 16, "Error", "Authentication is required !", 4)
			Case StringInStr($output, "No image data was sent")
				MsgBox(262144 + 4096 + 16, "Error", "No image data was sent !", 4)
			Case StringInStr($output, "Invalid API Key")
				MsgBox(262144 + 4096 + 16, "Error", "Invalid API Key !", 4)
			Case StringInStr($output, "No API key was sent,")
				MsgBox(262144 + 4096 + 16, "Error", "The file is too big to upload to imgur.  Please use dropbox or puush instead.", 4)
			Case Else
				MsgBox(0, "", $output)
				MsgBox(262144 + 4096 + 16, "Error", "Sorry, an error occured", 4)
		EndSelect
		return -1
	EndIf
EndFunc

Func _puushUpload($path, $key = "E66E58E82203C1184928C812C483B580")
	Local $stdoutr = "", $output = ""

	$run = $CURL & " -F k=" & $key & " -F z=poop -F f=@" & $path & " --retry 2 --location-trusted --url http://puush.me/api/up"
	$PID = Run($run, "", @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	While $output = ""
		$output = StdoutRead($PID)
		Sleep(20)
	WEnd
	Local $piclink = StringSplit($output, ",")
	If Not @error Then
		;MsgBox(0, "", $piclink[2])
		return $piclink[2]
	Else
		MsgBox(0, "", $output)
		MsgBox(262144 + 4096 + 16, "Error", "Sorry, an error occured", 4)
		return -1
	EndIf
EndFunc

Func _dropboxCheck()
	If $SERVICE = "dropbox" Then
		If Not FileExists(@HomeDrive & "\Users\" & @UserName & "\Dropbox\") Then
			$enable = MsgBox(262148, "Error", "You do not seem to have Dropbox installed.  Would you like to install?" & @LF & @LF & "Expected path: " & @HomeDrive & "\Users\" & @UserName & "\Dropbox\")
			If $enable == 6 Then
				ShellExecute("https://www.dropbox.com/downloading", "", "", "open")
				MsgBox(262144, "Notice", "Please try again once you have completed the install process.")
			EndIf
			return -1
		ElseIf Not FileExists(@HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\") Then
			$enable = MsgBox(262148, "Error", "A public Dropbox folder was not detected.  You will need one enabled in order to upload files. Would you like to enable it?" & @LF & @LF & "Expected path: " & @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
			If $enable == 6 Then
				ShellExecute("https://www.dropbox.com/enable_public_folder", "", "", "open")
				MsgBox(262144, "Notice", "You must run GifT again once you have created your public folder.")
			Else
				MsgBox(262144, "Notice", "If you already have a public Dropbox folder, please change its location to: " & @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
			EndIf
			return -1
		ElseIf Not ProcessExists("Dropbox.exe") Then
			MsgBox(262144, "Error", "Dropbox is not running.  You must run dropbox in order to upload files")
			return -1
		Else
			If _GetTrayText("Dropbox") == "" Then
				MsgBox(262144, "Error", "Unable to find Dropbox tray icon. Please set it to 'Show icon and notifications'" & @LF & @LF & @TAB & "Control Panel -> Notification Area Icons")
				return -1
			EndIf
		EndIf
	EndIf
	return 1
EndFunc
#endregion Helper Functions

#region Conversion Functions
Func _convert($file, $output, $delay = 200, $path = "C:\GifT\Gif.exe") ;Animates a list of .gif
	Run($path, "", @SW_HIDE)
	$hWnd = WinWait("Gif Creator", "")
	_FileDragDrop($hWnd, $file)
	ControlSetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]", $output)
	ControlSetText($hWnd, "", "[CLASS:Edit; INSTANCE:2]", $delay)
	ControlClick($hWnd, "", "[CLASS:Button; INSTANCE:1]")
EndFunc   ;==>_convert

Func _convertHotkey($key) ;converts hotkey from actual to string form
	If $key = "!" Then
		return "ALT"
	ElseIf $key = "+" Then
		return "CTRL"
	ElseIf $key = "^" Then
		return "SHIFT"
	ElseIf $key = "#" Then
		return "WIN"
	Else
		return StringUpper(StringReplace(StringReplace($key, "{", ""), "}", ""))
	EndIf
EndFunc

Func _shortURL($url, $user = "giftupload", $api = "R_026342ffc376b66dc50460a5634fe2ec") ;shortens URL
	If $SHORTEN = "waa.ai" Then
		Return BinaryToString(InetRead("http://api.waa.ai/?url=" & $url))
	ElseIf $SHORTEN = "bit.ly" Then
		Return BinaryToString(InetRead("http://api.bit.ly/v3/shorten?login=" & $user & "&apiKey=" & $api & "&longUrl=" & $url & "&format=txt"))
	Else
		return $url
	EndIf
EndFunc   ;==>_shortURL
#endregion

#region Updates
Func _loadIni() ;Loads .ini file and sets data to controls
	GUICtrlSetData($SDROPPATH, IniRead($INIPATH, "settings", "droppath", @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\"))
	GUICtrlSetData($SSAVEPATH, IniRead($INIPATH, "settings", "savepath", $GIFTPATH & "Local\"))
	GUICtrlSetData($SUID, IniRead($INIPATH, "settings", "uid", "0"))
	GUICtrlSetData($SAPI, IniRead($INIPATH, "settings", "pushkey", "0"))
	GUICtrlSetData($SFPS, IniRead($INIPATH, "settings", "fps", "5"))
	GUICtrlSetData($SBACKOP, IniRead($INIPATH, "settings", "backop", "200"))
	GUICtrlSetData($SSELOP, IniRead($INIPATH, "settings", "selop", "50"))

	GUICtrlSetState($SCOPY, IniRead($INIPATH, "settings", "copy", "1"))
	GUICtrlSetState($SOPEN, IniRead($INIPATH, "settings", "open", "4"))
	GUICtrlSetState($SDELETE, IniRead($INIPATH, "settings", "delete", "4"))
	GUICtrlSetState($SSOUND, IniRead($INIPATH, "settings", "sound", "1"))
	GUICtrlSetState($SMOUSE, IniRead($INIPATH, "settings", "mouse", "1"))
	GUICtrlSetState($SSAVE, IniRead($INIPATH, "settings", "save", "4"))

	_setKeys($SRECORD, IniRead($INIPATH, "settings", "recordkey", "+ ^ v"))
	_setKeys($SPICTURE, IniRead($INIPATH, "settings", "picturekey", "+ ^ 4"))
	_setKeys($SCOMPLETE, IniRead($INIPATH, "settings", "completekey", "{F4}"))
	_setKeys($SCANCEL, IniRead($INIPATH, "settings", "cancelkey", "{ESC}"))

	$temp = IniRead($INIPATH, "settings", "shorten", "waa.ai")
	If $temp = "bit.ly" Then
		GUICtrlSetState($SBITLY, $GUI_CHECKED)
	ElseIf $temp = "none" Then
		GUICtrlSetState($SNSHORT, $GUI_CHECKED)
	Else
		GUICtrlSetState($SWAAAI, $GUI_CHECKED)
	EndIf

	$temp = IniRead($INIPATH, "settings", "service", "imgur")
	If $temp = "dropbox" Then
		GUICtrlSetState($SDROPBOX, $GUI_CHECKED)
	ElseIf $temp = "puush" Then
		GUICtrlSetState($SPUUSH, $GUI_CHECKED)
	Else
		GUICtrlSetState($SIMGUR, $GUI_CHECKED)
	EndIf
EndFunc   ;==>_loadIni

Func _updateGUI() ;Sets the color and opacity of the GUIs
	GUISetBkColor($BGCOLOR, $up)
	GUISetBkColor($SELCOLOR, $gif)
	GUISetBkColor($BGCOLOR, $whole)

	WinSetTrans($up, "", $DARK)
	WinSetTrans($gif, "", 0)
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
		GUICtrlSetData($SSAVEPATH, $GIFTPATH)
	EndIf

	IniWrite($INIPATH, "settings", "droppath", GUICtrlRead($SDROPPATH))
	IniWrite($INIPATH, "settings", "savepath", GUICtrlRead($SSAVEPATH))
	IniWrite($INIPATH, "settings", "uid", GUICtrlRead($SUID))
	IniWrite($INIPATH, "settings", "pushkey", GUICtrlRead($SAPI))
	IniWrite($INIPATH, "settings", "fps", GUICtrlRead($SFPS))
	IniWrite($INIPATH, "settings", "backop", GUICtrlRead($SBACKOP))
	IniWrite($INIPATH, "settings", "selop", GUICtrlRead($SSELOP))
	IniWrite($INIPATH, "settings", "backcol", _GUIColorPicker_GetColor($SBACKCOL))
	IniWrite($INIPATH, "settings", "selcol", _GUIColorPicker_GetColor($SSELCOL))
	IniWrite($INIPATH, "settings", "boxcol", _GUIColorPicker_GetColor($SBOXCOL))

	IniWrite($INIPATH, "settings", "copy", GUICtrlRead($SCOPY))
	IniWrite($INIPATH, "settings", "open", GUICtrlRead($SOPEN))
	IniWrite($INIPATH, "settings", "delete", GUICtrlRead($SDELETE))
	IniWrite($INIPATH, "settings", "sound", GUICtrlRead($SSOUND))
	IniWrite($INIPATH, "settings", "mouse", GUICtrlRead($SMOUSE))
	IniWrite($INIPATH, "settings", "save", GUICtrlRead($SSAVE))

	_updateHotkey(StringSplit(GUICtrlRead($SRECORD), " + ", 1), "recordkey")
	_updateHotkey(StringSplit(GUICtrlRead($SPICTURE), " + ", 1), "picturekey")
	_updateHotkey(StringSplit(GUICtrlRead($SCOMPLETE), " + ", 1), "completekey")
	_updateHotkey(StringSplit(GUICtrlRead($SCANCEL), " + ", 1), "cancelkey")
EndFunc   ;==>_updateIni

Func _updateVar() ;Updates variable values based on .ini file
	$PATH 		= IniRead($INIPATH, "settings", "droppath", @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
	$DIR 		= IniRead($INIPATH, "settings", "savepath", $GIFTPATH)
	$UID 		= IniRead($INIPATH, "settings", "uid", "0")
	$PUSHKEY 	= IniRead($INIPATH, "settings", "pushkey", "0")
	$LINK 		= "https://dl.dropboxusercontent.com/u/" & $UID & "/"
	$FPS 		= Round(100 / IniRead($INIPATH, "settings", "fps", "5")) * 10
	$DARK 		= IniRead($INIPATH, "settings", "backop", "200")
	$LIGHT 		= IniRead($INIPATH, "settings", "selop", "50")
	$BGCOLOR 	= IniRead($INIPATH, "settings", "backcol", "0")
	$SELCOLOR 	= IniRead($INIPATH, "settings", "selcol", "255")
	$BOXCOLOR 	= IniRead($INIPATH, "settings", "boxcol", "65280")
	$MOUSE 		= 1 == IniRead($INIPATH, "settings", "mouse", "1")
	HotKeySet($RECKEY)
	$RECKEY 	= StringReplace(IniRead($INIPATH, "settings", "recordkey", "+ ^ v"), " ", "")
	HotKeySet($RECKEY, "_Record")
	HotKeySet($PICKEY)
	$PICKEY 	= StringReplace(IniRead($INIPATH, "settings", "picturekey", "+ ^ 4"), " ", "")
	HotKeySet($PICKEY, "_Picture")
	$COMPKEY 	= StringReplace(IniRead($INIPATH, "settings", "completekey", "{F4}"), " ", "")
	$CANCKEY 	= StringReplace(IniRead($INIPATH, "settings", "cancelkey", "{ESC}"), " ", "")
EndFunc   ;==>_updateVar

Func _updateHotkey($keys, $name) ;Whites new hotkeys to .ini file
	$str = ""
	For $i = 1 To $keys[0] Step 1
		If $keys[$i] = "ALT" Then
			$str &= "! "
		ElseIf $keys[$i] = "CTRL" Then
			$str &= "+ "
		ElseIf $keys[$i] = "SHIFT" Then
			$str &= "^ "
		ElseIf $keys[$i] = "WIN" Then
			$str &= "# "
		Else
			If StringLen($keys[$i]) == 1 Then
				$str &= StringLower($keys[$i])
			Else
				$str &= "{" & $keys[$i] & "}"
			EndIf
		EndIf
	Next
	IniWrite($INIPATH, "settings", $name, $str)
EndFunc
#endregion Updates

#region Splash Image
Func _Splash($d = -1) ;Begins the splash image
	_GDIPlus_Startup()
	; Load PNG image
	$hImage = _GDIPlus_ImageLoadFromFile($GIFTPATH & "GifT.png")
	$iWidth = _GDIPlus_ImageGetWidth($hImage)
	$iHeight = _GDIPlus_ImageGetHeight($hImage)

	; Create GUI
	$hGUI = GUICreate("", $iWidth, $iHeight, -1, -1, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TOPMOST + $WS_EX_TOOLWINDOW)
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
	DirCreate($GIFTPATH & "Gifs\")
	DirCreate($GIFTPATH & "Local\")
	DirCreate($GIFTPATH & "Pictures\")
	$check = FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\Gif.exe", $GIFTPATH & "Gif.exe")
	If $check == 0 Then
		FileCopy(@ScriptDir & "Gif.exe", $GIFTPATH & "Gif.exe")
	EndIf
	$check = FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\GifT.png", $GIFTPATH & "GifT.png")
	If $check == 0 Then
		FileCopy(@ScriptDir & "Gif.png", $GIFTPATH & "Gif.png")
	EndIf
	$check = FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\beep.mp3", $GIFTPATH & "beep.mp3")
	If $check == 0 Then
		FileCopy(@ScriptDir & "beep.mp3", $GIFTPATH & "beep.mp3")
	EndIf
	$check = FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\curl.exe", $GIFTPATH & "curl.exe")
	If $check == 0 Then
		FileCopy(@ScriptDir & "curl.exe", $GIFTPATH & "curl.exe")
	EndIf
EndFunc   ;==>_Files

#region Square GUI
Func _GUISetHole($hWin, $i_X, $i_Y, $i_SizeW, $i_SizeH) ;Creates a hole in the gui
	Local $aWinPos, $Outer_Rgn, $Inner_Rgn, $Wh, $Combined_Rgn
	Local Const $RGN_DIFF = 4
	$aWinPos = WinGetPos($hWin)

	$Outer_Rgn = DllCall("gdi32.dll", "long", "CreateRectRgn", "long", 0, "long", 0, "long", $aWinPos[2], "long", $aWinPos[3])
	$Inner_Rgn = DllCall("gdi32.dll", "long", "CreateRectRgn", "long", $i_X, "long", $i_Y, "long", $i_X + $i_SizeW, _
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
	Return GUICreateSquare($l, $t, $w, $h, $BOXCOLOR)
EndFunc   ;==>SquareResize
#endRegion