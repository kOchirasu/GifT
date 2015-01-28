#AutoIt3Wrapper_icon = upload.ico

#include <GUIConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <StaticConstants.au3>
#include <EditConstants.au3>
#Include <GuiToolBar.au3>
#include <ScreenCapture.au3>
#include <GDIPlus.au3>
#include <File.au3>
#include <IE.au3>
#include <Misc.au3>
#include <WinAPI.au3>
#include <Memory.au3>
#Include "_ColorChooser.au3"
#Include "_ColorPicker.au3"

#Region Errors
If _Singleton("GifT", 1) == 0 Then
    MsgBox(0, "Error", "GifT is already running!")
    Exit
ElseIf Not FileExists(@HomeDrive & "\Users\" & @USERNAME & "\Dropbox\") Then
	MsgBox(0, "Error", "You do not seem to have Dropbox installed.  Please install and try again." & @LF & @LF & "Expected path: " & @HomeDrive & "\Users\" & @USERNAME & "\Dropbox\")
	Exit
ElseIf Not FileExists(@HomeDrive & "\Users\" & @USERNAME & "\Dropbox\Public\") Then
	$enable = MsgBox(4, "Error", "A public Dropbox folder was not detected.  You will need one enabled in order to upload files. Would you like to enable it?" & @LF & @LF & "Expected path: " & @HomeDrive & "\Users\" & @USERNAME & "\Dropbox\Public\")
	If $enable = 6 Then
		ShellExecute ("https://www.dropbox.com/enable_public_folder", ""  ,"", "open")
		MsgBox(0, "Notice", "You must run GifT again once you have created your public folder.")
	Else
		MsgBox(0, "Notice", "If you already have a public Dropbox folder, please change its location to: " & @HomeDrive & "\Users\" & @USERNAME & "\Dropbox\Public\")
	EndIf
	_Exit()
EndIf
#endRegion


Global $hImage, $hGraphic, $hGUI
_Files()
_Splash(-1)


$INIPATH = @HomeDrive & "\GifT\settings.ini"
$UID = 0
$FPS = 5
$LINK = "https://dl.dropboxusercontent.com/u/" & $UID & "/"
$FILENAME = "default" ;Will be changed Date_Time
$PATH = @HomeDrive & "\Users\Computer\Dropbox\Public\" ;doesnt work
$DIR = @HomeDrive & "\GifT\"
$DARK = 200
$LIGHT = 50
$BGCOLOR = 0x000000
$SELCOLOR = 0x0000FF
$MOUSE = TRUE
$UPLOADURL = ""

$started = 0
$stop = 0

HotKeySet("^+v", "_Reset")
Opt("TrayMenuMode", 3) ; Default tray menu items (Script Paused/Exit) will not be shown. and no checkmarks

$TSETTINGS 		= TrayCreateItem("Settings")
$TABOUT 		= TrayCreateItem("About")
TrayCreateItem("")
$TEXIT 			= TrayCreateItem("Exit")

TraySetState()

$up 			= GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOr($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$left 			= GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOr($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$right 			= GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOr($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$down 			= GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOr($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
$gif 			= GUICreate("", 0, 0, 0, 0, $WS_POPUP, BitOr($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))

GUISetState(@SW_SHOW, $up)
GUISetState(@SW_SHOW, $left)
GUISetState(@SW_SHOW, $right)
GUISetState(@SW_SHOW, $down)
GUISetState(@SW_SHOW, $gif)

#Region Settings Window
$SMAIN 			= GUICreate("Settings", 400, 235, -1, -1, $WS_SYSMENU)
$SDROPPATH 		= GUICtrlCreateInput(@HomeDrive & "\Users\" & @USERNAME & "\Dropbox\Public\", 5, 10, 300, 22)
$SSAVEPATH 		= GUICtrlCreateInput(@HomeDrive & "\GifT\", 5, 38, 300, 22)
$SDROPBROWSE	= GUICtrlCreateButton("Browse...", 315, 8, 70, 25)
$SSAVEBROWSE 	= GUICtrlCreateButton("Browse...", 315, 36, 70, 25)

$SUID 			= GUICtrlCreateInput(113843502, 40, 68, 65, 22, $ES_NUMBER)
$SFPS 			= GUICtrlCreateInput(5, 40, 98, 65, 22, $ES_NUMBER)
$SBACKOP 		= GUICtrlCreateInput(200, 195, 68, 65, 22, $ES_NUMBER)
$SSELOP 		= GUICtrlCreateInput(50, 195, 98, 65, 22, $ES_NUMBER)
$SBACKCOL 		= _GUIColorPicker_Create('', 335, 66, 48, 26, IniRead($INIPATH, "settings", "backcol", "0"), BitOR($CP_FLAG_CHOOSERBUTTON, $CP_FLAG_MAGNIFICATION, $CP_FLAG_ARROWSTYLE), 0, -1, -1, 0, 'Colors', 'Custom...', '_ColorChooserDialog')
$SSELCOL 		= _GUIColorPicker_Create('', 335, 96, 48, 26, IniRead($INIPATH, "settings", "selcol", "255"), BitOR($CP_FLAG_CHOOSERBUTTON, $CP_FLAG_MAGNIFICATION, $CP_FLAG_ARROWSTYLE), 0, -1, -1, 0, 'Colors', 'Custom...', '_ColorChooserDialog')

$SCOPY			= GUICtrlCreateCheckBox(" Copy link to clipboard", 9, 130, 120, 20)
$SOPEN 			= GUICtrlCreateCheckBox(" Open link in browser", 9, 155, 115, 20)
$SDELETE 		= GUICtrlCreateCheckBox(" Delete local files after conversion", 9, 180, 175, 20)
$SSOUND 		= GUICtrlCreateCheckBox(" Play notification sound", 210, 130, 125, 20)
$SMOUSE 		= GUICtrlCreateCheckBox(" Capture screen with mouse", 210, 155, 150, 20)
$SSAVE	 		= GUICtrlCreateCheckBox(" Save gif file locally", 210, 180, 110, 20)

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
#endRegion

If Not FileExists(@HomeDrive & "\GifT\settings.ini") Then
	_updateIni()
EndIf
_updateVar()
_updateGUI()
Sleep(500)
_endSplash()

While 1
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

Func _Select()
	While 1
		If _IsPressed("1") Then
			HotKeySet("{F4}", "_Stop")
			$mp = MouseGetPos()
			WinSetTrans($gif, "", $light)
			While _IsPressed("01")
				$pos = MouseGetPos()
				$lefts = _Order($mp[0], $pos[0])
				$tops = _Order($mp[1], $pos[1])
				_Update($lefts[0], $tops[0], $lefts[1], $tops[1])
				WinMove($gif, "", $lefts[0], $tops[0], $lefts[1], $tops[1])
			WEnd
			WinSetTrans($gif, "", 1)
			_Update($lefts[0], $tops[0], $lefts[1], $tops[1])
			Sleep(10)
			If $UID > 0 Then
				_Capture($lefts[0], $tops[0], $lefts[1], $tops[1])
			Else
				WinMove($up, "", 0, 0, 0, 0)
				WinMove($left, "", 0, 0, 0, 0)
				WinMove($right, "", 0, 0, 0, 0)
				WinMove($down, "", 0, 0, 0, 0)
				WinMove($gif, "", 0, 0, 0, 0)
				MsgBox(0, "Error", "Unable to start capture due to UID value: " & $UID & @LF & "Please update your UID in the settings window")
			EndIf
			return
		EndIf
    WEnd
EndFunc

Func _Capture($l, $t, $w, $h)
	$started = 1
	$filename = @YEAR & "-" & @MON & "-" & @MDAY & "_" & Mod(@HOUR, 12) & "." & @MIN & "." & @SEC
	;TrayTip("Recording Started", $filename, 5, 1)
	DirCreate($dir & $filename)
	Sleep(200)
	_ScreenCapture_Capture($dir & $filename & "\" & $filename & ".gif", $l, $t, $w + $l, $h + $t, $MOUSE)
	Sleep($FPS)
	For $i = 1000 To 9999
			_ScreenCapture_Capture($dir & $filename & "\~" & $i & ".gif", $l, $t, $w + $l, $h + $t, $MOUSE)
			Sleep($FPS)
		If $started == 0 Then
			return
		EndIf
	Next
EndFunc

#Region Clear Functions
Func _Reset()
	_Update(0, @DesktopHeight, 0, 0)
	_Select()
EndFunc

Func _Exit()
	_Stop()
	$quit = MsgBox(4, "Are you sure?", "Are you sure you want to quit?")
	If $quit == 6 Then
		_Splash(2000)
		Exit
	EndIf
EndFunc

Func _Stop()
	If $started == 1 Then
		WinMove($up, "", 0, 0, 0, 0)
		WinMove($left, "", 0, 0, 0, 0)
		WinMove($right, "", 0, 0, 0, 0)
		WinMove($down, "", 0, 0, 0, 0)
		WinMove($gif, "", 0, 0, 0, 0)
		HotKeySet("{F4}")
		$theFiles = _getFiles($dir & $filename & "\")

		_convert($theFiles, $PATH, $FPS, @HomeDrive & "\GifT\Gif.exe")
		$UPLOADURL = _shortURL($link & $filename & ".gif")
		While Not StringInStr(_GetTrayText("Dropbox"), "Up to date")
			Sleep(500)
		WEnd
		If IniRead($INIPATH, "settings", "sound", "1") == 1 Then
			SoundPlay(@HomeDrive & "\GifT\beep.mp3")
		EndIf
		TrayTip("Upload Complete", $UPLOADURL, 5 , 1)
		If IniRead($INIPATH, "settings", "copy", "1") == 1 Then
			ClipPut($UPLOADURL)
		EndIf
		If IniRead($INIPATH, "settings", "open", "4") == 1 Then
			ShellExecute ($UPLOADURL, ""  ,"", "open")
		EndIf
		If IniRead($INIPATH, "settings", "delete", "4") == 1 Then
			DirRemove($dir & $filename, 1)
		EndIf
		If IniRead($INIPATH, "settings", "save", "4") == 1 Then
			FileCopy($PATH & $filename & ".gif", @HomeDrive & "\GifT\Gifs\" & $filename & ".gif", 8)
		EndIf

		$started = 0
	EndIf
EndFunc
#endRegion

#Region Helper Functions
Func _convert($file, $output, $delay = 200, $path = "C:\GifT\Gif.exe")
	Run($path, "", @SW_HIDE)
	$hWnd = WinWait("Gif Creator", "")
	_FileDragDrop($hWnd,$file)
	ControlSetText($hWnd, "", "[CLASS:Edit; INSTANCE:1]", $output)
	ControlSetText($hWnd, "", "[CLASS:Edit; INSTANCE:2]", $delay)
	Sleep(1000)
	ControlClick($hWnd, "", "[CLASS:Button; INSTANCE:1]")
EndFunc

Func _shortURL($url, $user = "giftupload", $api = "R_026342ffc376b66dc50460a5634fe2ec")
	return BinaryToString(InetRead("http://api.bit.ly/v3/shorten?login=" & $user & "&apiKey=" & $api & "&longUrl=" & $url & "&format=txt"))
EndFunc

Func _Order($a, $b)
    Dim $res[2]
    If $a < $b Then
        $res[0] = $a
        $res[1] = $b - $a
    Else
        $res[0] = $b
        $res[1] = $a - $b
    EndIf
    Return $res
EndFunc  ;==>Order

Func _getFiles($dir)
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
	return $ret
EndFunc

Func _GetTrayText($sToolTipTitle)
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
EndFunc
#endRegion

#Region Updates
Func _Update($l, $t, $w, $h)
	WinMove($up, "", 0, 0, @DesktopWidth, $t)
	WinMove($down, "", 0, $t + $h + 1, @DesktopWidth, @DesktopHeight - $h - $t)
	WinMove($left, "", 0, $t, $l, $h + 1)
	WinMove($right, "", $l + $w + 1, $t, @DesktopWidth - $l - $w, $h + 1)
EndFunc

Func _updateGUI()
	GUISetBkColor($BGCOLOR, $up)
	GUISetBkColor($BGCOLOR, $left)
	GUISetBkColor($BGCOLOR, $right)
	GUISetBkColor($BGCOLOR, $down)
	GUISetBkColor($SELCOLOR, $gif)

	WinSetTrans($up, "", $dark)
	WinSetTrans($left, "", $dark)
	WinSetTrans($right, "", $dark)
	WinSetTrans($down, "", $dark)
	WinSetTrans($gif, "", 1)
EndFunc

Func _updateVar()
	$PATH = IniRead($INIPATH, "settings", "droppath", @HomeDrive & "\Users\" & @USERNAME & "\Dropbox\Public\")
	$DIR = IniRead($INIPATH, "settings", "savepath", @HomeDrive & "\GifT\")
	$UID = IniRead($INIPATH, "settings", "uid", "0")
	$LINK = "https://dl.dropboxusercontent.com/u/" & $UID & "/"
	$FPS = Round(100/IniRead($INIPATH, "settings", "fps", "5")) * 10
	$DARK = IniRead($INIPATH, "settings", "backop", "200")
	$LIGHT = IniRead($INIPATH, "settings", "selop", "50")
	$BGCOLOR = IniRead($INIPATH, "settings", "backcol", "0")
	$SELCOLOR = IniRead($INIPATH, "settings", "selcol", "255")
	$MOUSE = 1 == IniRead($INIPATH, "settings", "mouse", "1")
EndFunc

Func _loadIni()
	GUICtrlSetData($SDROPPATH, IniRead($INIPATH, "settings", "droppath", @HomeDrive & "\Users\" & @USERNAME & "\Dropbox\Public\"))
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
EndFunc

Func _updateIni()
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
		GUICtrlSetData($SDROPPATH, @HomeDrive & "\Users\" & @USERNAME & "\Dropbox\Public\")
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
EndFunc
#endregion

#Region Splash Image
Func _Splash($d = -1)
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
EndFunc

Func _endSplash()
	_GDIPlus_ImageDispose($hImage)
	_GDIPlus_GraphicsDispose($hGraphic)
	_GDIPlus_Shutdown()
	GUIDelete($hGUI)
EndFunc

Func SetTransparentBitmap($hGUI, $hImage, $iOpacity = 0xFF)
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
#endRegion

Func _Files()
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
EndFunc

#Region Included
Func _FileDragDrop($hWnd,$sFiles,$iXPos=0,$iYPos=0,$sSep='|',$bUnicode=True)
	Local Const $WM_DROPFILES=0x0233
#cs
	; DROPFILES structure: dword offset;int x,int y;BOOL fNC;BOOL fWide
	;	(offset is offset of start of file list, x,y point is location in window [client coords],
	;	  fNC = if dropped on non-client area [in which case point is in screen coords ], fWide= Unicode flag)
#ce
	Local Const $tagDROP_FILES = "dword offset;int px;int py;bool fNC;bool fWide"
;~ 	Parameter checks
	If Not IsHWnd($hWnd) Or Not IsString($sFiles) Or $sFiles='' Or $sSep='' Then Return SetError(1,0,False)
;~ 	Local vars
	Local $pDropFiles,$stDropFiles,$iExtra=0,$sType=';byte'
	Local $iStSize=DllStructGetSize(DllStructCreate($tagDROP_FILES)),$iStrLen=StringLen($sFiles)+2	; 2 for double-NULL term

	If $bUnicode Then
		$iExtra=$iStrLen	; Unicode = 2 bytes per character, so we need to add a 2nd $iStrLen to the allocation
		$bUnicode=-1
		$sType=';wchar'		; change type of data (note 'byte' is needed for ANSI/ASCII - not sure why, but it chokes otherwise)
	EndIf

;~ 	Allocate memory for the structure and strings, get a pointer to it
;~ 		0x40 = $GMEM_ZEROINIT (zero-initialize memory) 0 = $GMEM_FIXED (returns a pointer instead of a handle)
	$pDropFiles = _MemGlobalAlloc($iStSize + $iStrLen+$iExtra,0x40)
	If $pDropFiles=0 Then Return SetError(-1,0,False)

;~ 	Create the structure with strings appended
	$stDropFiles = DllStructCreate($tagDROP_FILES & $sType & " filelist[" & $iStrLen & "]", $pDropFiles)

	DllStructSetData($stDropFiles, "offset", $iStSize)	; Offset of file list

;~ 	X,Y Position, in client coords (makes a difference in some programs [Notepad++ for example - center of window is good])
	DllStructSetData($stDropFiles, "px", $iXPos)
	DllStructSetData($stDropFiles, "py", $iYPos)

	DllStructSetData($stDropFiles, "fWide", $bUnicode)	; TRUE = unicode
;~ 	DllStructSetData($stDropFiles, "fNC", 0)		; FALSE = in client area, TRUE = non-client (and x,y pos in screen coords)
	DllStructSetData($stDropFiles, "filelist", StringReplace($sFiles,$sSep,ChrW(0)))

	; Attempt to Post the Message to the window (SendMessage doesn't work here)
	If Not _WinAPI_PostMessage($hWnd, $WM_DROPFILES, $pDropFiles, 0) Then
;~ 		Failed to send message. We can free the memory in this case
		_MemGlobalFree($pDropFiles)
		Return SetError(16,0,False)
	EndIf
#cs
	; NOTE: We do *not* free the memory - this is handled by the program receiving the message (and by Windows)
	;	Technically if that program doesn't handle the message correctly, then we'll wind up with a memory leak
	;	However, since we can not be sure when/if the message was or will be received, we can't just discard the memory
	;	that will be used by Windows
;~ 	_MemGlobalFree($pDropFiles)
#ce
	Return True
EndFunc	;=> _FileDragDrop()
#endRegion