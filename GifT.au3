#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Includes\upload.ico
#AutoIt3Wrapper_Run_AU3Check=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <SliderConstants.au3>
#include <ComboConstants.au3>
#include <ScreenCapture.au3>
#include <GuiComboBox.au3>
#include <GDIPlus.au3>
#include <File.au3>
#include <Misc.au3>

#include <FTPEx.au3>
#include "Array.au3"

#include "Includes/_GifTConstants.au3"

Global $hImage, $hGraphic, $hGUI

$SHORTEN	= IniRead($INIPATH, "settings", "shorten", "none")
$SERVICE 	= IniRead($INIPATH, "settings", "service", "imgur")
$GIFTYPE 	= IniRead($INIPATH, "settings", "quantize", 0)
_Splash() ;Turn on splash image until loading is complete

#region Error Check
If _Singleton("GifT", 1) == 0 Then
	MsgBox($MB_TOPMOST, "Error", "GifT is already running!")
	Exit
EndIf

If _dropboxCheck() == -1 Then
	MsgBox($MB_OK, "Revert", "Reverting to imgur service...")
	_FileWriteLog($LOG, "Reverted to imgur service due to failed Dropbox check")
	IniWrite($INIPATH, "settings", "service", "imgur")
	Exit
EndIf

If Not FileExists($LOGPATH) Then
	_FileCreate($LOGPATH)
EndIf

$LOG = FileOpen($LOGPATH, 1)

If IniRead($INIPATH, "settings", "update", $GUI_CHECKED) = $GUI_CHECKED Then
	$NEWVERSION = Number(BinaryToString(InetRead("http://rasu.us/GifT/version.txt")))
	If $NEWVERSION > $VERSION Then
		If MsgBox($MB_TOPMOST + $MB_ICONQUESTION + $MB_YESNO, "Update", "New version of GifT available.  Would you like to download?" & @LF & @LF & "	Newest Version: " & $NEWVERSION) = $IDYES Then
			If MsgBox($MB_TOPMOST + $MB_ICONQUESTION + $MB_YESNO, "Update", "Would you like source files as well?") = $IDYES Then
				ShellExecute("http://rasu.us/GifT/GifTv" & $NEWVERSION & ".rar", "", "", "open")
			Else
				ShellExecute("http://rasu.us/GifT/GifT.exe", "", "", "open")
			EndIf
			_FileWriteLog($LOG, "Updated to version " & $NEWVERSION)
			Exit
		EndIf
	EndIf
EndIf
#endregion Errors

#region Variables
If _checkFiles() <> "" Then
	If MsgBox($MB_TOPMOST + $MB_ICONQUESTION + $MB_YESNO, "Missing Files!", "You are missing the following files:" & @LF & @LF & _checkFiles() & @LF & @LF & "Would you like to download the installer?") = $IDYES Then
		If @OSArch = "X32" Then
			ShellExecute("http://rasu.us/GifT/GifTInstaller_(x32).exe", "", "", "open")
		Else
			ShellExecute("http://rasu.us/GifT/GifTInstaller_(x64).exe", "", "", "open")
		EndIf
	EndIf
	Exit
EndIf

Global $PATH, $UID, $LINK, $PUSHKEY, $LIGHT, $SELCOLOR, $BOXCOLOR, $RECKEY, $PICKEY, $COMPKEY, $SERVER, $USER, $PASS

DirCreate($DIR)
$FILENAME 	= "00-00-00_00.00.00" ;Will be changed Date_Time
$UPLOADURL 	= ""
$DEVICELIST = _FFmpeg_DeviceList()
$PID 		= 0

_updateVar()
#endRegion

#region Tray Menu + GUI Stuff
Opt("TrayMenuMode", 3) ; Default tray menu items (Script Paused/Exit) will not be shown. and no checkmarks

$TSETTINGS 	= TrayCreateItem("Settings")
$TABOUT 	= TrayCreateItem("About")
TrayCreateItem("")
$TEXIT 		= TrayCreateItem("Exit")

TraySetState()
$SQUARE 	= GUICreateFrame(0, 0, 0, 0, $BOXCOLOR)
#endRegion

#region Settings Window
$SMAIN 		= GUICreate("GifT Settings", 386, 235, -1, -1, $WS_SYSMENU)
$STABS 		= GUICtrlCreateTab(7, 7, 367, 195)

#region Settings - General Tab
GUICtrlCreateTabItem("General")
$SVIDDEV	= GUICtrlCreateCombo($DEVICELIST[0][0] > 0 ? $DEVICELIST[0][1] : "No compatible Video devices", 90, 38, 190, 20, $CBS_DROPDOWNLIST )
$SAUDDEV	= GUICtrlCreateCombo($DEVICELIST[1][0] > 0 ? $DEVICELIST[1][1] : "No compatible Audio devices", 90, 69, 190, 20, $CBS_DROPDOWNLIST )
$SCOPY 		= GUICtrlCreateCheckbox(" Copy link to clipboard", 20, 98, 120, 20)
$SOPEN 		= GUICtrlCreateCheckbox(" Open link in browser", 20, 123, 115, 20)
$SSAVE 		= GUICtrlCreateCheckbox(" Save files locally", 20, 148, 110, 20)
$SDELETE 	= GUICtrlCreateCheckbox(" Delete files after conversion", 20, 173, 150, 20)
$SSOUND 	= GUICtrlCreateCheckbox(" Play notification sound", 195, 98, 125, 20)
$SMUTE 		= GUICtrlCreateCheckbox(" Mute audio device", 195, 123, 115, 20)
$SENCODE	= GUICtrlCreateCheckbox(" Realtime Encode (CPU Heavy)", 195, 148, 165, 20)
$SUPDATE 	= GUICtrlCreateCheckbox(" Check for updates", 195, 173, 120, 20)

$SADV		= GUICtrlCreateButton("Advanced...", 285, 36, 80, 56)

GUICtrlCreateLabel("Video Device:", 17, 42, 80, 20)
GUICtrlCreateLabel("Audio Device:", 17, 73, 80, 20)

If $DEVICELIST[0][0] > 1 Then
	$popDev = ""
	For $i = 2 To $DEVICELIST[0][0]
		$popDev &= $DEVICELIST[0][$i] & "|"
	Next
	;ConsoleWrite($popDev & @CRLF)
	GUICtrlSetData($SVIDDEV, $popDev, "No Video Devices")
EndIf

If $DEVICELIST[1][0] > 1 Then
	$popDev = ""
	For $i = 2 To $DEVICELIST[1][0]
		$popDev &= $DEVICELIST[1][$i] & "|"
	Next
	;ConsoleWrite($popDev & @CRLF)
	GUICtrlSetData($SAUDDEV, $popDev, $DEVICELIST[1][1])
EndIf
;_ArrayDisplay($DEVICELIST)
#endregion

#region Settings - Hotkeys Tab
GUICtrlCreateTabItem("Hotkeys")
$SRECORD 	= GUICtrlCreateButton("CTRL + SHIFT + R", 165, 40, 150, 26)
$SPICTURE 	= GUICtrlCreateButton("CTRL + SHIFT + E", 165, 70, 150, 26)
$SCOMPLETE 	= GUICtrlCreateButton("F4", 165, 100, 150, 26)

$SRECDF 	= GUICtrlCreateButton("q", 320, 40, 40, 26)
$SPICDF 	= GUICtrlCreateButton("q", 320, 70, 40, 26)
$SCOMPDF 	= GUICtrlCreateButton("q", 320, 100, 40, 26)

GUICtrlSetFont($SRECDF, 12, 400, 0, "Webdings")
GUICtrlSetFont($SPICDF, 12, 400, 0, "Webdings")
GUICtrlSetFont($SCOMPDF, 12, 400, 0, "Webdings")

GUICtrlCreateLabel("Select Area for Recording:", 25, 45, 125, 20, $ES_RIGHT)
GUICtrlCreateLabel("Select Area for Picture:", 25, 75, 125, 20, $ES_RIGHT)
GUICtrlCreateLabel("Complete Recording:", 25, 105, 125, 20, $ES_RIGHT)
#endregion

#region Settings - Paths Tab
GUICtrlCreateTabItem("Paths")
GUICtrlCreateGroup("File Save Path", 15, 35, 350, 50)
GUICtrlCreateGroup("Dropbox Path", 15, 90, 350, 50)

$SDIRPATH 		= GUICtrlCreateInput($DIR, 25, 54, 255, 22)
$SDROPPATH 		= GUICtrlCreateInput(@HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\", 25, 109, 255, 22)

$SDIRBROWSE 	= GUICtrlCreateButton("Browse...", 288, 52, 70, 25)
$SDROPBROWSE 	= GUICtrlCreateButton("Browse...", 288, 107, 70, 25)
#endregion

#region Settings - Info Tab
GUICtrlCreateTabItem("Info")
GUICtrlCreateGroup("FTP", 15, 35, 350, 50)
GUICtrlCreateGroup("Puush", 15, 90, 350, 50)
GUICtrlCreateGroup("Dropbox", 15, 145, 350, 50)
$SFTPSERVER	= GUICtrlCreateInput("", 25, 54, 120, 22)
$SFTPUSER	= GUICtrlCreateInput("", 155, 54, 100, 22)
$SFTPPASS	= GUICtrlCreateInput("", 265, 54, 85, 22)
$SAPI 		= GUICtrlCreateInput(0, 110, 109, 240, 22)
$SUID 		= GUICtrlCreateInput(0, 102, 164, 75, 22, $ES_NUMBER)

GUICtrlCreateLabel("Puush API Key:", 25, 113, 90, 20)
GUICtrlCreateLabel("Dropbox UID:", 25, 168, 259, 20)

GUICtrlSendMsg($SFTPPASS, $EM_SETPASSWORDCHAR, 9679, 0)
GUICtrlSendMsg($SAPI, $EM_SETPASSWORDCHAR, 9679, 0)
_GUICtrlEdit_SetCueBanner($SFTPSERVER, "FTP Server")
_GUICtrlEdit_SetCueBanner($SFTPUSER, "Username")
_GUICtrlEdit_SetCueBanner($SFTPPASS, "Password")
GUICtrlSetLimit($SAPI, 32)
#endregion


#region Settings - Services Tab
GUICtrlCreateTabItem("Services")
GUICtrlCreateGroup("URL Shorteners", 15, 35, 350, 50)
$SWAAAI 	= GUICtrlCreateRadio("waa.ai", 25, 55, 70, 20)
$SBITLY 	= GUICtrlCreateRadio("bit.ly", 135, 55, 70, 20)
$SNSHORT 	= GUICtrlCreateRadio("None", 245, 55, 70, 20)
GUICtrlCreateGroup("Image Hosters", 15, 90, 350, 80)
$SIMGUR 	= GUICtrlCreateRadio("Imgur", 25, 110, 70, 20)
$SFTP	 	= GUICtrlCreateRadio("FTP", 135, 110, 70, 20)
$SPUUSH 	= GUICtrlCreateRadio("Puush", 245, 110, 70, 20)
$SDROPBOX 	= GUICtrlCreateRadio("Dropbox", 25, 140, 70, 20)
$SNHOST	 	= GUICtrlCreateRadio("None", 135, 140, 70, 20)
GUICtrlCreateLabel("- Imgur has a file limit of 2MB", 15, 180, 200, 20)
#endregion

#region Settings - Colors Tab
GUICtrlCreateTabItem("Colors")
$SSELOP 	= GUICtrlCreateSlider(75, 55, 165, 26, BitOr($TBS_NOTICKS, $TBS_TOOLTIPS))
$SBOXOP 	= GUICtrlCreateSlider(75, 110, 165, 26, BitOr($TBS_NOTICKS, $TBS_TOOLTIPS))
$SSELCOL 	= _GUIColorPicker_Create('', 300, 50, 48, 26,IniRead($INIPATH, "settings", "selcol", 52479), BitOR($CP_FLAG_CHOOSERBUTTON, $CP_FLAG_MAGNIFICATION, $CP_FLAG_ARROWSTYLE), 0, -1, -1, 0, 'Colors', 'Custom...', '_ColorChooserDialog')
$SBOXCOL	= _GUIColorPicker_Create('', 300, 105, 48, 26, IniRead($INIPATH, "settings", "boxcol", 16711680), BitOR($CP_FLAG_CHOOSERBUTTON, $CP_FLAG_MAGNIFICATION, $CP_FLAG_ARROWSTYLE), 0, -1, -1, 0, 'Colors', 'Custom...', '_ColorChooserDialog')

GUICtrlSetBkColor($SSELOP, 0xFFFFFF)
GUICtrlSetBkColor($SBOXOP, 0xFFFFFF)
GUICtrlSetLimit($SSELOP, 255)
GUICtrlSetLimit($SBOXOP, 255)
GUICtrlSetData($SBOXOP, 255)

GUICtrlCreateGroup("Selection Box", 15, 35, 350, 50)
GUICtrlCreateLabel("Opacity:", 30, 56, 65, 20)
GUICtrlCreateLabel("Color:", 260, 56, 60, 20)
GUICtrlCreateGroup("Recording Box", 15, 90, 350, 50)
GUICtrlCreateLabel("Opacity:", 30, 111, 75, 20)
GUICtrlCreateLabel("Color:", 260, 111, 60, 20)

GUICtrlSetState($SBOXOP, $GUI_DISABLE)
#endregion

#region Settings - Misc. Tab
GUICtrlCreateTabItem("Misc.")
GUICtrlCreateGroup("Color Quantization", 15, 35, 350, 50)
$SCQXIAO 	= GUICtrlCreateRadio("Xiaolin Wu", 25, 55, 70, 20)
$SCQNEURAL 	= GUICtrlCreateRadio("Neural-Net", 135, 55, 70, 20)
$SCQNONE 	= GUICtrlCreateRadio("None", 245, 55, 70, 20)
GUICtrlCreateGroup("Older Versions", 15, 90, 350, 50)
GUICtrlCreateLabel("Version:", 25, 112, 50, 20)
GUICtrlCreateLabel("Current Version: v" & $VERSION, 250, 112, 120, 20)
$SVSELECT	= GUICtrlCreateInput($VERSION, 75, 110, 30, 20, $ES_NUMBER)
$SDLSOURCE	= GUICtrlCreateButton("Download Source", 130, 105, 100, 27)
GUICtrlCreateGroup("Gif Editing", 15, 145, 350, 50)
$SEDIT	 	= GUICtrlCreateCheckbox(" Prompt edit before upload", 25, 165, 150, 20)
$SEDITBUT	= GUICtrlCreateButton("Manually edit a gif", 220, 160, 130, 27)
GUICtrlSetState($SEDIT, $GUI_DISABLE);TEMP
#endRegion

GUICtrlCreateTabItem("To-do")
$STODO = "- Create upload queue so that program doesn't freeze while uploading" & @LF
$STODO &= "- Move color quantization to advanced settings" & @LF
$STODO &= "- Change gif editor to a video editor" & @LF
$STODO &= "- Add port selection and encryption to FTP upload" & @LF
$STODO &= "- Redo logo splash screen in c++ for less lags" & @LF
$STODO &= "- Change temporary files so that they are not in folders anymore" & @LF
$STODO &= "- Remove old version downloading because im lazy to upload every version source code" & @LF
GUICtrlCreateLabel($STODO, 15, 35, 350, 175)

_loadIni()

$boxDll = DllOpen($GIFTPATH & "areabox.dll")
DllCall($boxDll, "none", "initialize")
if @error Then ConsoleWrite("error: " & @error & @CRLF)
_endSplash()
;GUISetState(@SW_SHOW, $SMAIN)
#endRegion

While 1 ;Program Loop
	$TMSG = TrayGetMsg()
	Switch $TMSG
		Case $TEXIT
			_Exit()

		Case $TABOUT
			MsgBox($MB_ICONINFORMATION, "About: GifT v" & $VERSION, "GIF recorder and uploader via Imgur/Puush/Dropbox" & @LF & "with waa.ai/bit.ly as the URL shortener" & @LF & @LF & "Coded in Autoit")

		Case $TSETTINGS ;Open Settings Window
			GUISetState(@SW_SHOW, $SMAIN)
	EndSwitch

	$MSG = GUIGetMsg()
	Switch $MSG
		Case $GUI_EVENT_CLOSE
			_updateVar()
			If _dropboxCheck() == -1 Then
				MsgBox($MB_OK, "Revert", "Reverting to imgur service...")
				_FileWriteLog($LOG, "Reverted to imgur service due to failed Dropbox check")
				IniWrite($INIPATH, "settings", "service", "imgur")
				Exit
			EndIf
			GUISetState(@SW_HIDE, $SMAIN)

		Case $SVIDDEV
			IniWrite($INIPATH, "settings", "video", '"' & GUICtrlRead($SVIDDEV) & '"')

		Case $SAUDDEV
			IniWrite($INIPATH, "settings", "audio", '"' & GUICtrlRead($SAUDDEV) & '"')

		Case $SADV
			GUISetState(@SW_HIDE, $SMAIN)
			_AdvancedSettings()
			GUISetState(@SW_SHOW, $SMAIN)

		Case $SCOPY
			IniWrite($INIPATH, "settings", "copy", GUICtrlRead($SCOPY))

		Case $SOPEN
			IniWrite($INIPATH, "settings", "open", GUICtrlRead($SOPEN))

		Case $SSAVE
			IniWrite($INIPATH, "settings", "save", GUICtrlRead($SSAVE))

		Case $SDELETE
			IniWrite($INIPATH, "settings", "delete", GUICtrlRead($SDELETE))

		Case $SSOUND
			IniWrite($INIPATH, "settings", "sound", GUICtrlRead($SSOUND))

		Case $SMUTE
			GUICtrlSetState($SAUDDEV, GUICtrlRead($SMUTE) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
			IniWrite($INIPATH, "settings", "mute", GUICtrlRead($SMUTE))

		Case $SENCODE
			IniWrite($INIPATH, "settings", "encode", GUICtrlRead($SENCODE))

		Case $SUPDATE
			IniWrite($INIPATH, "settings", "update", GUICtrlRead($SUPDATE))

		Case $SDROPPATH
			If Not FileExists(GUICtrlRead($SDROPPATH)) Then
				GUICtrlSetData($SDROPPATH, @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
			EndIf
			IniWrite($INIPATH, "settings", "droppath", GUICtrlRead($SDROPPATH))

		Case $SDIRPATH
			If Not FileExists(GUICtrlRead($SDIRPATH)) Then
				GUICtrlSetData($SDIRPATH, $DIR)
			EndIf
			IniWrite($INIPATH, "settings", "dirpath", GUICtrlRead($SDIRPATH))

		Case $SDROPBROWSE
			$temp = FileSelectFolder("Dropbox Upload Path...", "", 3, GUICtrlRead($SDROPPATH))
			If Not @error Then
				GUICtrlSetData($SDROPPATH, $temp & "\")
			EndIf
			IniWrite($INIPATH, "settings", "droppath", GUICtrlRead($SDROPPATH))

		Case $SDIRBROWSE
			$temp = FileSelectFolder("File Save Path...", "", 3, GUICtrlRead($SDIRPATH))
			If Not @error Then
				GUICtrlSetData($SDIRPATH, $temp & "\")
			EndIf
			IniWrite($INIPATH, "settings", "dirpath", GUICtrlRead($SDIRPATH))

		Case $SRECORD, $SPICTURE, $SCOMPLETE
			GUISetState(@SW_HIDE, $SMAIN)
			$sMSG = $MSG
			GUICtrlSetData($MSG, _selectKey($MSG))
			Switch $sMSG
				Case $SRECORD
					GUICtrlSetState($SRECDF, GUICtrlRead($SRECORD) <> "CTRL + SHIFT + R" ? $GUI_ENABLE : $GUI_DISABLE)
					_updateHotkey(StringSplit(GUICtrlRead($SRECORD), " + ", 1), "recordkey")

				Case $SPICTURE
					GUICtrlSetState($SPICDF, GUICtrlRead($SPICTURE) <> "CTRL + SHIFT + E" ? $GUI_ENABLE : $GUI_DISABLE)
					_updateHotkey(StringSplit(GUICtrlRead($SPICTURE), " + ", 1), "picturekey")

				Case $SCOMPLETE
					GUICtrlSetState($SCOMPDF, GUICtrlRead($SCOMPLETE) <> "F4" ? $GUI_ENABLE : $GUI_DISABLE)
					_updateHotkey(StringSplit(GUICtrlRead($SCOMPLETE), " + ", 1), "completekey")
			EndSwitch
			GUISetState(@SW_SHOW, $SMAIN)

		Case $SRECDF
			If MsgBox($MB_TOPMOST + $MB_YESNO, "Reset", "Do you want to reset your 'recording' hotkey to default settings?") = $IDYES Then
				GUICtrlSetData($SRECORD, "CTRL + SHIFT + R")
				IniDelete($INIPATH, "settings", "recordkey")
				GUICtrlSetState($SRECDF, $GUI_DISABLE)
			EndIf

		Case $SPICDF
			If MsgBox($MB_TOPMOST + $MB_YESNO, "Reset", "Do you want to reset your 'picture' hotkey to default settings?") = $IDYES Then
				GUICtrlSetData($SPICTURE, "CTRL + SHIFT + E")
				IniDelete($INIPATH, "settings", "picturekey")
				GUICtrlSetState($SPICDF, $GUI_DISABLE)
			EndIf

		Case $SCOMPDF
			If MsgBox($MB_TOPMOST + $MB_YESNO, "Reset", "Do you want to reset your 'complete' hotkey to default settings?") = $IDYES Then
				GUICtrlSetData($SCOMPLETE, "F4")
				IniDelete($INIPATH, "settings", "completekey")
				GUICtrlSetState($SCOMPDF, $GUI_DISABLE)
			EndIf

		Case $SFTPSERVER
			$SERVER = GUICtrlRead($SFTPSERVER)
			IniWrite($INIPATH, "settings", "ftpserver", $SERVER)

		Case $SFTPUSER
			$USER = GUICtrlRead($SFTPUSER)
			IniWrite($INIPATH, "settings", "ftpuser", $USER)

		Case $SFTPPASS
			$PASS = GUICtrlRead($SFTPPASS)
			IniWrite($INIPATH, "settings", "ftppass", $PASS)

		Case $SAPI
			$PUSHKEY = GUICtrlRead($SAPI)
			IniWrite($INIPATH, "settings", "pushkey", $PUSHKEY)

		Case $SUID
			$UID = GUICtrlRead($SUID)
			IniWrite($INIPATH, "settings", "uid", $UID)

		Case $SSELOP
			$LIGHT = GUICtrlRead($SSELOP)
			IniWrite($INIPATH, "settings", "selop", $LIGHT)

		Case $SSELCOL
			$SELCOLOR = _GUIColorPicker_GetColor($SSELCOL)
			IniWrite($INIPATH, "settings", "selcol", $SELCOLOR)

		Case $SBOXCOL
			$BOXCOLOR = _GUIColorPicker_GetColor($SBOXCOL)
			IniWrite($INIPATH, "settings", "boxcol", $BOXCOLOR)

		Case $SWAAAI, $SBITLY, $SNSHORT
			$SHORTEN = GUICtrlRead($MSG, 1)
			IniWrite($INIPATH, "settings", "shorten", $SHORTEN)

		Case $SIMGUR, $SFTP, $SPUUSH, $SDROPBOX, $SNHOST
			$SERVICE = GUICtrlRead($MSG, 1)
			IniWrite($INIPATH, "settings", "service", $SERVICE)

		Case $SCQXIAO, $SCQNEURAL, $SCQNONE
			$str = GUICtrlRead($MSG, 1)
			If $str = "None" Then
				$GIFTYPE = 0
			ElseIf $str = "Xiaolin Wu" Then
				$GIFTYPE = 1
			ElseIf $str = "Neural-Net" Then
				$GIFTYPE = 2
			EndIf
			IniWrite($INIPATH, "settings", "quantize", $GIFTYPE)

		Case $SDLSOURCE
			$VER = GUICtrlRead($SVSELECT)
			If $VER < 1 Or $VER > $VERSION Then
				MsgBox($MB_OK, "Error!", "Invalid version number. Please try again.")
			Else
				ShellExecute("http://rasu.us/GifT/GifTv" & $VER & ".rar", "", "", "open")
			EndIf

		Case $SEDITBUT
			GUISetState(@SW_HIDE, $SMAIN)
			_GifEdit()
			GUISetState(@SW_SHOW, $SMAIN)
			;MsgBox(0, "Unprogrammed", "This function is not yet programmed!")
			;Exit
	EndSwitch

	If $PID = 0 And ProcessExists("ffmpeg.exe") Then
		ProcessClose("ffmpeg.exe")
		_FileWriteLog($LOG, "ffmpeg.exe was already running, and has been closed")
	ElseIf $PID <> 0 And Not ProcessExists("ffmpeg.exe") Then
		MsgBox(0, "Error", "ffmpeg.exe seems to have crashed unexpectedly.  The recording has been canceled.")
		_Cancel()
	EndIf
WEnd

Func _Record($box) ;Records the selection until terminated
	$FILENAME = @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "." & @MIN & "." & @SEC
	DirCreate($DIR & $FILENAME)
	Local $mute = GUICtrlRead($SMUTE) = $GUI_CHECKED
	Local $encode = GUICtrlRead($SENCODE) = $GUI_CHECKED
	Local $container = _getContainer()
	If $container = ".gif" Then
		$container = ".mkv"
		$mute = true ;gifs don't need sound anyway
		$encode = false ;the file will be reconverted anyway
	EndIf
	$PID = _FFmpeg_Record($box[0], $box[1], $box[2], $box[3], $DIR & $FILENAME & "\" & $FILENAME & $container, GUICtrlRead($SVIDDEV), GUICtrlRead($SAUDDEV), $mute, $encode) ;Might be problematic since you can do things while video recording
EndFunc   ;==>_Capture

Func _Capture($box) ;Takes a picture of the selection and uploads
	$FILENAME = @YEAR & "-" & @MON & "-" & @MDAY & "_" & @HOUR & "." & @MIN & "." & @SEC
	DirCreate($DIR & $FILENAME)
	_ScreenCapture_Capture($DIR & $FILENAME & "\" & $FILENAME & ".png", $box[0], $box[1], $box[0] + $box[2], $box[1] + $box[3], False)
	_Upload()
EndFunc

Func _Select($action) ;Selection process to determine what to record/take picture of
	If GUICtrlRead($SVIDDEV) = "No compatible Video devices" Then
		If MsgBox($MB_TOPMOST + $MB_SYSTEMMODAL + $MB_ICONERROR + $MB_YESNO, "Error", "No compatible DirectShow video devices were detected." & @LF & "Would you like to download one?") = $IDYES Then
			GUISetState(@SW_HIDE, $SMAIN)
			If _dShowDownload() <> 0 Then
				MsgBox($MB_TOPMOST + $MB_OK, "Exiting", "Please restart GifT once you have completed the installation.")
				Exit
			EndIf
		EndIf
		_FileWriteLog($LOG, "No DirectShow video devices found.")
		return -1
	EndIf
	If $SERVICE = "dropbox" And $UID <= 0 Then ;Check if UID is correctly set up
		MsgBox($MB_TOPMOST + $MB_SYSTEMMODAL + $MB_ICONERROR, "Error", "Unable to start capture due to UID value: " & $UID & @LF & "Please update your UID in the settings window.")
		_FileWriteLog($LOG, "Error: UID value - " & $UID & " is not valid")
		return -1
	ElseIf $SERVICE = "puush" And StringLen($PUSHKEY) <> 32 Then ;Check if API key is correctly set up
		MsgBox($MB_TOPMOST + $MB_SYSTEMMODAL + $MB_ICONERROR, "Error", "Unable to start capture due to API key value " & $PUSHKEY & @LF & "Please update your API key in the settings window.")
		_FileWriteLog($LOG, "Error: API key value - " & $PUSHKEY & " is not valid")
		return -1
	ElseIf $SERVICE = "ftp" And Not _ftpCheck($SERVER, $USER, $PASS) Then ;Check if FTP info is valid, might be bad to check because there is a timeout delay if wrong
		MsgBox($MB_TOPMOST + $MB_SYSTEMMODAL + $MB_ICONERROR, "Error", "Unable to establish FTP connection to: " & $SERVER & @LF & "Please check your FTP information in the settinigs window.")
		_FileWriteLog($LOG, "Error: Unable to establish FTP connection to: " & $SERVER)
		return -1
	EndIf

	DllCall($boxDll, "bool:cdecl", "setColor", "dword", $SELCOLOR, "byte", $LIGHT)
	if @error Then ConsoleWrite("error: " & @error & @CRLF)

	HotKeySet($RECKEY) ;Disable hotkeys to prevent queued commands
	HotKeySet($PICKEY)

	Local $areaBox = DllCall($boxDll, "int*:cdecl", "getSelection")
	if @error Then ConsoleWrite("error: " & @error & @CRLF)

	Local $arrStruct = DllStructCreate("int[4]", $areaBox[0])
	Local $box[4]

	For $i = 1 To 4
		$box[$i - 1] = DllStructGetData($arrStruct, 1, $i)
	Next

	If $box[2] * $box[3] <> 0 Then ;If area of selection is not nothing
		If $action = "r" Then
			HotKeySet($COMPKEY, $STOPFUNC) ;Need way to stop recording
			HotKeySet($CANCKEY, $CANCFUNC) ;Need way to cancel recording
			_Record($box)
			$SQUARE = _FrameResize($SQUARE, $box[0] - 3, $box[1] - 3, $box[2] + 7, $box[3] + 7)
			GUISetState(@SW_SHOW, $SQUARE)
			;DllCall($dllhand, "none", "moveFrame", "int", 3)
			;if @error Then ConsoleWrite("error: " & @error & @CRLF)
		ElseIf $action = "p" Then
			_Capture($box)
			HotKeySet($RECKEY, $RECFUNC) ;ReEnable hotkeys (Might want to enable before upload is called but it wouldn't matter if upload called in different thread
			HotKeySet($PICKEY, $PICFUNC) ;For recording reenable once recording is cancled or completed...
		EndIf
	Else
		HotKeySet($RECKEY, $RECFUNC) ;ReEnable hotkeys
		HotKeySet($PICKEY, $PICFUNC)
		TrayTip("Invalid Selection", "Your selection area is too small for recording.", 3, $TIP_ICONASTERISK)
	EndIf
	return
EndFunc   ;==>_Select

#region Clear Functions
Func _Exit() ;Exits the program
	_Stop()
	If MsgBox($MB_YESNO, "Are you sure?", "Are you sure you want to quit?") = $IDYES Then
		_Splash(2000)
		Exit
	EndIf
EndFunc   ;==>_Exit

Func _Video() ; Begin record selection
	_Select("r")
EndFunc

Func _Picture() ; Begin picture selection
	_Select("p")
EndFunc

Func _Stop() ;Stops the current recording and completes final steps
	If $PID <> 0 Then
		GUISetState(@SW_HIDE, $square)
		StdinWrite($PID, 'q')
		$PID = 0

		HotKeySet($COMPKEY)
		HotKeySet($CANCKEY)
		_Upload(1)
		HotKeySet($RECKEY, $RECFUNC)
		HotKeySet($PICKEY, $PICFUNC)
	EndIf
EndFunc   ;==>_Stop

Func _Cancel() ;Cancels the current recording and deletes files
	If $PID <> 0 Then
		GUISetState(@SW_HIDE, $square)
		StdinWrite($PID, 'q')
		$PID = 0

		HotKeySet($COMPKEY)
		HotKeySet($CANCKEY)
		HotKeySet($RECKEY, $RECFUNC)
		HotKeySet($PICKEY, $PICFUNC)

		DirRemove($DIR & $FILENAME, 1)
		TrayTip("Recording Canceled", "The recording has been canceled, and the temporary files have been deleted.", 3, $TIP_ICONASTERISK)
		_FileWriteLog($LOG, "Recording canceled and temporary files have been removed from: " & $DIR & $FILENAME)
	EndIf
EndFunc
#endregion Clear Functions

#region Helper Functions
Func _dShowDownload()
	Local $dShowGUI = GUICreate("UScreenCapture Download", 205, 65, -1, -1, -1, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
	Local $dShow32 = GUICtrlCreateButton("UScreenCapture (x86)", 5, 5, 140, 25)
	Local $dShow32m = GUICtrlCreateButton("Mirror", 150, 5, 50, 25)
	Local $dShow64 = GUICtrlCreateButton("UScreenCapture (x64)", 5, 35, 140, 25)
	Local $dShow64m = GUICtrlCreateButton("Mirror", 150, 35, 50, 25)

	If @OSArch = "X32" Then
		GUICtrlSetState($dShow64, $GUI_DISABLE)
		GUICtrlSetState($dShow64m, $GUI_DISABLE)
	EndIf

	GUISetState(@SW_SHOW, $dShowGUI)

	While 1
		Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				GUIDelete($dShowGUI)
				Return 0
			Case $dShow32
				ShellExecute("http://www.umediaserver.net/bin/UScreenCapture.zip", "", "", "open")
				GUIDelete($dShowGUI)
				Return 1
			Case $dShow32m
				ShellExecute("http://rasu.us/GifT/UScreenCapture_(x86).msi", "", "", "open")
				GUIDelete($dShowGUI)
				Return 1
			Case $dShow64
				ShellExecute("http://www.umediaserver.net/bin/UScreenCapture(x64).zip", "", "", "open")
				GUIDelete($dShowGUI)
				Return 1
			Case $dShow64m
				ShellExecute("http://rasu.us/GifT/UScreenCapture_(x64).msi", "", "", "open")
				GUIDelete($dShowGUI)
				Return 1
		EndSwitch
	WEnd
EndFunc

Func _GUICtrlEdit_GetCueBanner($hWnd)
	If Not IsHWnd($hWnd) Then
		$hWnd = GUICtrlGetHandle($hWnd)
	EndIf

	Local $tText = DllStructCreate("wchar[4096]")
	If _SendMessage($hWnd, $EM_GETCUEBANNER, $tText, 4096, 0, "struct*") <> 1 Then
		Return SetError(-1, 0, "")
	EndIf
	Return _WinAPI_WideCharToMultiByte($tText)
EndFunc   ;==>_GUICtrlEdit_GetCueBanner

Func _GUICtrlEdit_SetCueBanner($hWnd, $sText)
	If Not IsHWnd($hWnd) Then
		$hWnd = GUICtrlGetHandle($hWnd)
	EndIf

	Local $tText = _WinAPI_MultiByteToWideChar($sText)

	Return _SendMessage($hWnd, $EM_SETCUEBANNER, False, $tText, 0, "wparam", "struct*") = 1
EndFunc   ;==>_GUICtrlEdit_SetCueBanner
#endregion Helper Functions

#region Updates
Func _loadIni() ;Loads .ini file and sets data to controls (settings window)
	_GUICtrlComboBox_SelectString($SAUDDEV, IniRead($INIPATH, "settings", "audio", GUICtrlRead($SAUDDEV)))
	_GUICtrlComboBox_SelectString($SVIDDEV, IniRead($INIPATH, "settings", "video", GUICtrlRead($SVIDDEV)))
	GUICtrlSetData($SDIRPATH, IniRead($INIPATH, "settings", "dirpath", $DIR))
	GUICtrlSetData($SDROPPATH, IniRead($INIPATH, "settings", "droppath", @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\"))
	GUICtrlSetData($SUID, IniRead($INIPATH, "settings", "uid", ""))
	GUICtrlSetData($SAPI, IniRead($INIPATH, "settings", "pushkey", ""))
	GUICtrlSetData($SSELOP, IniRead($INIPATH, "settings", "selop", 50))
	GUICtrlSetData($SFTPSERVER, IniRead($INIPATH, "settings", "ftpserver", ""))
	GUICtrlSetData($SFTPUSER, IniRead($INIPATH, "settings", "ftpuser", ""))
	GUICtrlSetData($SFTPPASS, IniRead($INIPATH, "settings", "ftppass", ""))

	GUICtrlSetState($SCOPY, IniRead($INIPATH, "settings", "copy", $GUI_CHECKED))
	GUICtrlSetState($SOPEN, IniRead($INIPATH, "settings", "open", $GUI_UNCHECKED))
	GUICtrlSetState($SSAVE, IniRead($INIPATH, "settings", "save", $GUI_UNCHECKED))
	GUICtrlSetState($SDELETE, IniRead($INIPATH, "settings", "delete", $GUI_CHECKED))
	GUICtrlSetState($SSOUND, IniRead($INIPATH, "settings", "sound", $GUI_CHECKED))
	GUICtrlSetState($SMUTE, IniRead($INIPATH, "settings", "mute", $GUI_UNCHECKED))
	GUICtrlSetState($SENCODE, IniRead($INIPATH, "settings", "encode", $GUI_CHECKED))
	GUICtrlSetState($SUPDATE, IniRead($INIPATH, "settings", "update", $GUI_CHECKED))

	_setKeys($SRECORD, IniRead($INIPATH, "settings", "recordkey", "+ ^ r"))
	_setKeys($SPICTURE, IniRead($INIPATH, "settings", "picturekey", "+ ^ e"))
	_setKeys($SCOMPLETE, IniRead($INIPATH, "settings", "completekey", "{F4}"))

	GUICtrlSetState($SAUDDEV, GUICtrlRead($SMUTE) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)

	GUICtrlSetState($SRECDF, GUICtrlRead($SRECORD) = "CTRL + SHIFT + R" ? $GUI_DISABLE : $GUI_ENABLE)
	GUICtrlSetState($SPICDF, GUICtrlRead($SPICTURE) = "CTRL + SHIFT + E" ? $GUI_DISABLE : $GUI_ENABLE)
	GUICtrlSetState($SCOMPDF, GUICtrlRead($SCOMPLETE) = "F4" ? $GUI_DISABLE : $GUI_ENBALE)

	Local $temp = IniRead($INIPATH, "settings", "shorten", "none")
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
	ElseIf $temp = "ftp" Then
		GUICtrlSetState($SFTP, $GUI_CHECKED)
	Else
		GUICtrlSetState($SIMGUR, $GUI_CHECKED)
	EndIf

	$temp = IniRead($INIPATH, "settings", "quantize", 0)
	If $temp = 1 Then
		GUICtrlSetState($SCQXIAO, $GUI_CHECKED)
	ElseIf $temp = 2 Then
		GUICtrlSetState($SCQNEURAL, $GUI_CHECKED)
	Else
		GUICtrlSetState($SCQNONE, $GUI_CHECKED)
	EndIf
EndFunc   ;==>_loadIni

Func _updateVar() ;Updates variable values based on .ini file
	$PATH 		= IniRead($INIPATH, "settings", "droppath", @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
	$UID 		= IniRead($INIPATH, "settings", "uid", 0)
	$LINK 		= "https://dl.dropboxusercontent.com/u/" & $UID & "/"
	$PUSHKEY 	= IniRead($INIPATH, "settings", "pushkey", 0)
	$LIGHT 		= IniRead($INIPATH, "settings", "selop", 50)
	$SELCOLOR 	= IniRead($INIPATH, "settings", "selcol", 52479)
	$BOXCOLOR 	= IniRead($INIPATH, "settings", "boxcol", 16711680)
	HotKeySet($RECKEY)
	$RECKEY 	= StringReplace(IniRead($INIPATH, "settings", "recordkey", "+ ^ r"), " ", "")
	HotKeySet($RECKEY, $RECFUNC)
	HotKeySet($PICKEY)
	$PICKEY 	= StringReplace(IniRead($INIPATH, "settings", "picturekey", "+ ^ e"), " ", "")
	HotKeySet($PICKEY, $PICFUNC)
	$COMPKEY 	= StringReplace(IniRead($INIPATH, "settings", "completekey", "{F4}"), " ", "")
	$SERVER 	= IniRead($INIPATH, "settings", "ftpserver", "")
	$USER 		= IniRead($INIPATH, "settings", "ftpuser", "")
	$PASS 		= IniRead($INIPATH, "settings", "ftppass", "")
EndFunc   ;==>_updateVar
#endregion Updates

#region Splash Image
Func _Splash($d = -1) ;Begins the splash image
	_GDIPlus_Startup()
	; Load PNG image
	$hImage = _GDIPlus_ImageLoadFromFile($GIFTPATH & "GifT.png")
	Local $iWidth = _GDIPlus_ImageGetWidth($hImage)
	Local $iHeight = _GDIPlus_ImageGetHeight($hImage)

	; Create GUI
	$hGUI = GUICreate("", $iWidth, $iHeight, -1, -1, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TOPMOST + $WS_EX_TOOLWINDOW)
	Local $hGUI_child = GUICreate("", $iWidth, $iHeight, 0, 0, $WS_POPUP, $WS_EX_LAYERED + $WS_EX_TOPMOST + $WS_EX_MDICHILD, $hGUI)
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

#region Square GUI
Func _GUISetHole($hWin, $l, $t, $w, $h) ;Creates a hole in the gui
	Local $aWinPos, $Outer_Rgn, $Inner_Rgn, $Combined_Rgn
	$aWinPos = WinGetPos($hWin)

	$Outer_Rgn = DllCall("gdi32.dll", "long", "CreateRectRgn", "long", 0, "long", 0, "long", $aWinPos[2], "long", $aWinPos[3])
	$Inner_Rgn = DllCall("gdi32.dll", "long", "CreateRectRgn", "long", $l, "long", $t, "long", $l + $w, "long", $t + $h)
	$Combined_Rgn = DllCall("gdi32.dll", "long", "CreateRectRgn", "long", 0, "long", 0, "long", 0, "long", 0)
	DllCall("gdi32.dll", "long", "CombineRgn", "long", $Combined_Rgn[0], "long", $Outer_Rgn[0], "long", $Inner_Rgn[0], "int", 4)
	DllCall("user32.dll", "long", "SetWindowRgn", "hwnd", $hWin, "long", $Combined_Rgn[0], "int", 1)
EndFunc   ;==>_GUISetHole

Func GUICreateFrame($l, $t, $w, $h, $c = 0x00FF00, $thickness = 3) ;Creates a square GUI with a hole
	Local $frame = GUICreate("", $w, $h, $l, $t, $WS_POPUP, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
	GUISetBkColor($c)
	_GUISetHole($frame, $thickness, $thickness, $w - 2 * $thickness, $h - 2 * $thickness)
	Return $frame
EndFunc   ;==>GUICreateFrame

Func _FrameResize($frame, $l, $t, $w, $h, $thickness = 3) ;Reposition a frame GUI
	GUIDelete($frame)
	return GUICreateFrame($l, $t, $w, $h, $BOXCOLOR, $thickness)
EndFunc   ;==>Frame resize
#endRegion