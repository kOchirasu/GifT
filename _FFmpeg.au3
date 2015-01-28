#Include <WinAPIEx.au3>

Func _FFmpeg_DeviceList()
	Local $dList = ""
	Dim $avList[2][5]
	$avList[0][0] = 0
	$avList[1][0] = 0

	Local $PID = Run('ffmpeg -list_devices true -f dshow -i dummy', $GIFTPATH, @SW_HIDE, $STDERR_CHILD)

	While ProcessExists($PID)
		$stderr = StderrRead($PID)
		If Not @error And StringInStr($stderr, "dshow") Then
			$dList &= $stderr
		EndIf
	WEnd

	$dList = StringSplit(StringRegExpReplace($dList, "\[.*\] *", ""), @LF)
	$dList[0] -= 1
	For $i = 1 To $dList[0]
		If StringInStr($dList[$i], "video devices") Then
			For $i = $i + 1 To $dList[0]
				If StringInStr($dList[$i], "audio devices") Then
					For $i = $i + 1 To $dList[0]
						If Not StringInStr($dList[$i], "Could not enumerate") And Not StringInStr($dList[$i], "dummy") Then
							$avList[1][0] += 1
							$avList[1][$avList[1][0]] = StringStripCR($dList[$i])
						EndIf
					Next
				Else
					If Not StringInStr($dList[$i], "Could not enumerate")Then
						$avList[0][0] += 1
						$avList[0][$avList[0][0]] = StringStripCR($dList[$i])
					EndIf
				EndIf
			Next
		EndIf
	Next
	return $avList
EndFunc

;If Run fails it returns 0
Func _FFmpeg_Screenshot($l, $t, $w, $h, $out)
	Local $PID = Run('ffmpeg -y -f dshow -i video="UScreenCapture" -vf crop=' & _toEven($w) & ':' & _toEven($h) & ':' & $l & ':' & $t & ' ' & $out, $GIFTPATH, @SW_HIDE, $STDERR_CHILD)
	If @error Then
		return -1
	EndIf
	return $PID
EndFunc

;Presets can be ultrafast, superfast, veryfast, faster, fast, medium (default), slow and veryslow
Func _FFmpeg_Record($l, $t, $w, $h, $out, $vdv, $adv, $mute = false)
	Local $path = 'ffmpeg -y -f dshow -i video=' & $vdv & ':audio=' & $adv
	$path &= ' -vf crop=' & _toEven($w) & ':' & _toEven($h) & ':' & $l & ':' & $t & ' ' & _getCommand()
	If $mute Then
		$path &= "-an "
	EndIf
	$path &= $out
	$PID = Run($path, $GIFTPATH, @SW_HIDE, $STDIN_CHILD)
	If @error Then
		return -1
	EndIf
	return $PID
EndFunc

Func _FFmpeg_Convert($in, $out)
	Local $path = 'ffmpeg -i ' & $in & ' '
	Local $ext = StringSplit($out, ".")
	If $ext[$ext[0]] = "webm" Then ;Still need to change to allow more customization
		$path &= '-acodec libvorbis -aq 5 -ac 2 -qmax 25 -threads 2 '
	EndIf
	$path &= $out
	Local $PID = Run($path, $GIFTPATH, @SW_HIDE)
	If @error Then
		return -1
	EndIf
	While ProcessExists($PID)
		Sleep(25)
	WEnd
	return 1
EndFunc

Func _FFmpeg_Split($in, $fps)
	Local $out = StringTrimRight($in, StringLen($in) - StringInStr($in, "\", 0, -1))
	Local $PID = Run('ffmpeg -i ' & $in & ' -r ' & $fps & ' ' & $out & '%d.png', $GIFTPATH, @SW_HIDE)
	If @error Then
		return -1
	EndIf
	While ProcessExists($PID)
		Sleep(25)
	WEnd
	return 1
EndFunc

Func _toEven($n)
	If Mod($n, 2) <> 0 Then
		return $n + 1
	EndIf
	return $n
EndFunc

#cs
$output = ""
	While ProcessExists($PID)
		$output = StdoutRead($PID)
		If $output <> "" Then
			ConsoleWrite($output & @CRLF)
		EndIf
	WEnd
#ce