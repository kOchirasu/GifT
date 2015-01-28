#Include <WinAPIEx.au3>
Func _FFmpeg_DeviceList()
	Local $dList = ""
	Dim $avList[2][5]
	$avList[0][0] = 0
	$avList[1][0] = 0

	Local $PID = Run('ffmpeg -list_devices true -f dshow -i dummy', $GIFTPATH, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)
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
						If Not StringInStr($dList[$i], "Could not enumerate") And Not StringInStr($dList[$i], "exit") Then
							$avList[1][0] += 1
							$avList[1][$avList[1][0]] = StringStripCR($dList[$i])
						EndIf
					Next
				Else
					If Not StringInStr($dList[$i], "Could not enumerate") And Not StringInStr($dList[$i], "cam") Then
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
	Local $PID = Run('ffmpeg -y -f dshow -i video="UScreenCapture" -vf crop=' & _toEven($w) & ':' & _toEven($h) & ':' & $l & ':' & $t & ' "' & $out & '"', $GIFTPATH, @SW_HIDE, $STDERR_CHILD)
	If @error Then
		return -1
	EndIf
	return $PID
EndFunc

Func _FFmpeg_Record($l, $t, $w, $h, $out, $vdv, $adv, $mute = false, $realtime = true)
	Local $ext = StringSplit($out, ".")
	Local $path = 'ffmpeg -y -f dshow -i video=' & $vdv & ':audio=' & $adv & ' '
	$path &= '-vf crop=' & _toEven($w) & ':' & _toEven($h) & ':' & $l & ':' & $t & ' '
	If $realtime Then
		$path &= _getCommand($ext[$ext[0]])
		If $mute Then
			$path &= "-an "
		EndIf
		$path &= '"' & $out & '"'
	Else
		$path &= '-vcodec libx264 -qp 0 -preset ultrafast -acodec pcm_s16le '
		$path &= '"' & StringReplace($out, $ext[$ext[0]], "mkv") & '"'
	EndIf
	;ConsoleWrite($path)
	$PID = Run($path, $GIFTPATH, @SW_HIDE, $STDIN_CHILD)
	If @error Then
		return -1
	EndIf
	return $PID
EndFunc

Func _FFmpeg_Encode($in, $out, $delete)
	Local $path = 'ffmpeg -i "' & $in & '" '
	Local $ext = StringSplit($out, ".")
	$path &= _getCommand($ext[$ext[0]])
	$path &= '"' & $out & '"'
	Local $PID = Run($path, $GIFTPATH, @SW_HIDE)
	If @error Then
		return -1
	EndIf
	While ProcessExists($PID) ;Can remove this later maybe if there are multiple threads
		Sleep(25)
	WEnd
	If $delete Then
		FileDelete($in)
	EndIf
	return 1
EndFunc

Func _FFmpeg_Split($in, $fps, $delete = true)
	Local $out = StringTrimRight($in, StringLen($in) - StringInStr($in, "\", 0, -1))
	Local $PID = Run('ffmpeg -i "' & $in & '" -r ' & $fps & ' "' & $out & '%d.png"', $GIFTPATH, @SW_HIDE)
	If @error Then
		return -1
	EndIf
	While ProcessExists($PID)
		Sleep(25)
	WEnd
	If $delete Then
		FileDelete($in)
	EndIf
	return 1
EndFunc

Func _toEven($n)
	If Mod($n, 2) <> 0 Then
		return $n + 1
	EndIf
	return $n
EndFunc