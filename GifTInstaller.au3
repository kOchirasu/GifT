#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=upload.ico
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseUpx=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <MsgBoxConstants.au3>
$GIFTPATH 	= @HomeDrive & "\Program Files\GifT\"
DirCreate($GIFTPATH)

$successes = _Files()
If $successes < 7 Then
	MsgBox($MB_ICONWARNING + $MB_OK, "Error!", "One or more files were not installed successfully.")
Else
	MsgBox($MB_ICONINFORMATION + $MB_OK, "Complete!", "The installation has completed successfully.")
EndIf

Func _Files()
	Local $count = 0
	;Need to change these paths to own local path
	$count += FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\GifT.png", $GIFTPATH & "GifT.png", 1);Logo image
	$count += FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\beep.mp3", $GIFTPATH & "beep.mp3", 1);Sound alert on successful upload
	$count += FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\curl.exe", $GIFTPATH & "curl.exe", 1);used for uploading files
	$count += FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\ffmpeg.exe", $GIFTPATH & "ffmpeg.exe", 1);used for recording
	$count += FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\quantgif.dll", $GIFTPATH & "quantgif.dll", 1);used for gif quantizing
	$count += FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\areabox.dll", $GIFTPATH & "areabox.dll", 1);used for selection drawing
	$count += FileInstall("C:\Users\Computer\Documents\Autoit\GifTsrc\FreeImage.dll", $GIFTPATH & "FreeImage.dll", 1);used for converting files

	return $count
EndFunc