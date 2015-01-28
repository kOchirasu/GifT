Global const $VERSION 	= 15
Global const $RECFUNC 	= "_Video"
Global const $PICFUNC 	= "_Picture"
Global const $CANCKEY	= "{ESC}"
Global const $CANCFUNC	= "_Cancel"
Global const $STOPFUNC	= "_Stop"
Global const $GIFTPATH 	= @HomeDrive & "\Program Files\GifT\"
Global const $INIPATH 	= $GIFTPATH & "settings.ini"
Global const $LOGPATH	= $GIFTPATH & "uploads.log"
Global const $DIR 		= IniRead($INIPATH, "settings", "dirpath", $GIFTPATH & "Local\")

#include "_ColorChooser.au3"
#include "_ColorPicker.au3"
#include "_FFmpeg.au3"
#include "_GifTAdvanced.au3"
#include "_GifTUpload.au3"
#include "_GifTHotkey.au3"
#include "_GifTEditor.au3"

Func _checkFiles()
	Local $missing = ""
	If Not FileExists($GIFTPATH & "GifT.png") Then
		$missing &= "GifT.png" & @LF
	EndIf
	If Not FileExists($GIFTPATH & "beep.mp3") Then
		$missing &= "beep.mp3" & @LF
	EndIf
	If Not FileExists($GIFTPATH & "curl.exe") Then
		$missing &= "curl.exe" & @LF
	EndIf
	If Not FileExists($GIFTPATH & "ffmpeg.exe") Then
		$missing &= "ffmpeg.exe" & @LF
	EndIf
	If Not FileExists($GIFTPATH & "quantgif.dll") Then
		$missing &= "quantgif.dll" & @LF
	EndIf
	If Not FileExists($GIFTPATH & "areabox.dll") Then
		$missing &= "areabox.dll" & @LF
	EndIf
	If Not FileExists($GIFTPATH & "FreeImage.dll") Then
		$missing &= "FreeImage.dll" & @LF
	EndIf

	return $missing
EndFunc