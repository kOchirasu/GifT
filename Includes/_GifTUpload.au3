Dim $linkArr[62] = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', _
					'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', _
					'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', _
					'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', _
					'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', _
					'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z']

;$DIR 		= GifT\Local\
;Need to start upload in a different thread so you can continue using this program
;Need to make it so that when conversion fails it doesnt get stuck
Func _Upload($t = 0)
	If $SERVICE <> "none" Then
		Local $uPath = $DIR & $FILENAME & "\"
		If $t == 1 Then

			If _getContainer() = ".gif" And $GIFTYPE <> 0 Then
				_FFmpeg_Split($uPath & $FILENAME & ".mkv", _getFPS(), GUICtrlRead($SDELETE) = $GUI_CHECKED)
				DllCall($GIFTPATH & "quantgif.dll", "int:cdecl", "quantizeGif", "wstr", StringTrimRight($uPath, 1), "int", $GIFTYPE - 1, "int", _getFPS()) ;Trim off the \ char
				If @error Then
					MsgBox(0, "quantgif.dll Error!", "DllCall error code : " & @error)
					return -1
				EndIf
			ElseIf GUICtrlRead($SENCODE) = $GUI_UNCHECKED Then
				_FFmpeg_Encode($uPath & $FILENAME & ".mkv", $uPath & $FILENAME & _getContainer(), GUICtrlRead($SDELETE) = $GUI_CHECKED)
			EndIf
			$FILENAME &= _getContainer()
		Else
			$FILENAME &= ".png"
		EndIf

		If $service = "dropbox" Then
			If _dropboxCheck() = -1 Then ;If it fails dropbox check
				If GUICtrlRead($SSAVE) == $GUI_UNCHECKED Then
					DirRemove($uPath, 1)
				EndIf
				Exit
			EndIf

			FileCopy($uPath & $FILENAME, $path & $FILENAME)
			$UPLOADURL = _shortURL($LINK & $FILENAME)
			While Not StringInStr(_GetTrayText("Dropbox"), "Up to date")
				Sleep(100)
			WEnd
		Else
			If $service = "imgur" Then
				$ERRCHECK = _imgurUpload($LOG, $uPath & $FILENAME)
			ElseIf $service = "puush" Then
				$ERRCHECK = _puushUpload($LOG, $uPath & $FILENAME, $PUSHKEY)
			ElseIf $service = "ftp" Then
				$ERRCHECK = _ftpUpload($LOG, $uPath & $FILENAME, $SERVER, $USER, $PASS)
			EndIf
			If $ERRCHECK == -1 Then
				TrayTip("Upload Failed", "There was an error uploading. Temporary files not deleted.", 5, $TIP_ICONASTERISK)
				return
			EndIf
			$UPLOADURL = _shortURL($ERRCHECK)
		EndIf

		If GUICtrlRead($SSOUND) == $GUI_CHECKED Then
			SoundPlay($GIFTPATH & "beep.mp3")
		EndIf
		TrayTip("Upload Complete", $UPLOADURL, 5, $TIP_ICONASTERISK)
		If GUICtrlRead($SCOPY) == $GUI_CHECKED Then
			ClipPut($UPLOADURL)
		EndIf
		If GUICtrlRead($SOPEN) == $GUI_CHECKED Then
			ShellExecute($UPLOADURL, "", "", "open")
		EndIf

		If GUICtrlRead($SSAVE) == $GUI_UNCHECKED Then
			DirRemove($uPath, 1)
		EndIf

		Local $logMsg = "Uploaded " & $FILENAME & " via " & $SERVICE & " URL="
		Local $longURL
		If $SERVICE = "dropbox" Then
			$longURL = $LINK & $FILENAME
		Else
			$longURL &= $ERRCHECK
		EndIf
		$logMsg &= $longURL
		If $longURL <> $UPLOADURL Then
			$logMsg &= " shortURL=" & $UPLOADURL
		EndIf
		_FileWriteLog($LOG, $logMsg)
	EndIf
EndFunc

Func _shortURL($url) ;shortens URL
	If $SHORTEN = "waa.ai" Then
		Return BinaryToString(InetRead("http://api.waa.ai/?url=" & $url))
	ElseIf $SHORTEN = "bit.ly" Then
		Return BinaryToString(InetRead("http://api.bit.ly/v3/shorten?login=giftupload&apiKey=R_026342ffc376b66dc50460a5634fe2ec&longUrl=" & $url & "&format=txt"))
	Else
		return $url
	EndIf
EndFunc   ;==>_shortURL

Func _imgurUpload($log, $path, $key = "f77d0b8cd41eb62792be0bf303e649df") ;Uploads to imgur
	Local $stdoutr = ""
	Local $output = ""
	Local $run = "curl -F image=@" & $path & " -F key=" & $key & " --retry 2 --location-trusted --url http://api.imgur.com/2/upload.xml"
	Local $PID = Run($run, $GIFTPATH, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

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
		$array = StringRegExp($output, "<message>(.*?)</message>", 2)
		_FileWriteLog($log, "Imgur Upload ERROR: " & $array[1])
		MsgBox(262144 + 4096 + 16, "Error", "Sorry, an error occured", 4)
		return -1
	EndIf
EndFunc

Func _puushUpload($log, $path, $key) ;Uploads to puush
	Local $output = ""
	Local $run = "curl -F k=" & $key & " -F z=poop -F f=@" & $path & " --retry 2 --location-trusted --url http://puush.me/api/up"
	Local $PID = Run($run, $GIFTPATH, @SW_HIDE, $STDERR_CHILD + $STDOUT_CHILD)

	While $output = ""
		$output = StdoutRead($PID)
		Sleep(20)
	WEnd
	Local $piclink = StringSplit($output, ",")
	If Not @error Then
		return StringLeft($piclink[2], StringInStr($piclink[2], ".", 0, -1))
	Else
		MsgBox(0, $key, $path)
		_FileWriteLog($log, "Puush Upload ERROR: " & $output)
		MsgBox(262144 + 4096 + 16, "Error", "Sorry, an error occured", 4)
		return -1
	EndIf
EndFunc

Func _ftpUpload($log, $path, $sServer, $sUser, $sPass)
	Local $hOpen = _FTP_Open('FTP Connection')
	Local $hConn = _FTP_Connect($hOpen, $sServer, $sUser, $sPass)

	Local $fName = _ftpLinkGen($hConn)
	If $fName = -1 Then
		_FileWriteLog($log, "Unable to generate file url.")
		MsgBox(262144 + 4096 + 16, "Error", "Sorry, an error occured", 4)
		return -1
	EndIf
	Local $ext = StringSplit($path, ".")
	_FTP_FilePut($hConn, $path, $fName[1] & "." & $ext[$ext[0]])
	If @error Then
		_FileWriteLog($log, "FTP Upload ERROR: " & $path)
		MsgBox(262144 + 4096 + 16, "Error", "Sorry, an error occured", 4)
		return -1
	EndIf

	_FTP_Close($hConn)
	_FTP_Close($hOpen)
	return $fName[0] & $fName[1]
EndFunc

Func _ftpCheck($sServer, $sUser, $sPass)
	Local $hOpen = _FTP_Open('FTP Connection')
	Local $hConn = _FTP_Connect($hOpen, $sServer, $sUser, $sPass)
	If @error Then
		_FTP_Close($hOpen)
		return False
	EndIf
	_FTP_Close($hConn)
	_FTP_Close($hOpen)
	Return True
EndFunc

Func _ftpLinkGen($hConn)
	Local $pLink[2]
	Local $uFile = _FTP_FileOpen($hConn, ".link", $GENERIC_READ, $FTP_TRANSFER_TYPE_BINARY)
	If @error Then return -1
	$pLink[0] = BinaryToString(_FTP_FileRead($uFile, 17))
	_FTP_FileClose($uFile)

	$uFile = _FTP_FileOpen($hConn, ".count", $GENERIC_READ, $FTP_TRANSFER_TYPE_BINARY)
	If @error Then return -1
	Local $count = BinaryToString(_FTP_FileRead($uFile, 10))
	_FTP_FileClose($uFile)

	_FTP_FileGet($hConn, ".count", @TempDir & ".count")
	If @error Then return -1
	_ReplaceStringInFile(@TempDir & ".count", $count, $count + 1)
	If @error Then return -1
	_FTP_FilePut($hConn, @TempDir & ".count", ".count")
	If @error Then return -1

	$pLink[1] = _base62($count + 1)
	return $pLink
EndFunc

Func _base62($n)
	Local $s = ""
	While $n > 0
		$r = Mod($n, 62)
		$n = Floor($n / 62)

		$s = $linkArr[$r] & $s
	WEnd
	return $s
EndFunc

Func _dropboxCheck() ;Checks that dropbox is fully functioning and ready to be used
	If $SERVICE = "dropbox" Then
		If Not FileExists(@HomeDrive & "\Users\" & @UserName & "\Dropbox\") Then
			If MsgBox(262148, "Error", "You do not seem to have Dropbox installed.  Would you like to install?" & @LF & @LF & "Expected path: " & @HomeDrive & "\Users\" & @UserName & "\Dropbox\") == 6 Then
				ShellExecute("https://www.dropbox.com/downloading", "", "", "open")
				MsgBox(262144, "Notice", "Please try again once you have completed the install process.")
			EndIf
			_FileWriteLog($LOG, "Dropbox not installed on computer")
			return -1
		ElseIf Not FileExists(@HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\") Then
			If MsgBox(262148, "Error", "A public Dropbox folder was not detected.  You will need one enabled in order to upload files. Would you like to enable it?" & @LF & @LF & "Expected path: " & @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\") == 6 Then
				ShellExecute("https://www.dropbox.com/enable_public_folder", "", "", "open")
				MsgBox(262144, "Notice", "You must run GifT again once you have created your public folder.")
			Else
				MsgBox(262144, "Notice", "If you already have a public Dropbox folder, please change its location to: " & @HomeDrive & "\Users\" & @UserName & "\Dropbox\Public\")
			EndIf
			_FileWriteLog($LOG, "Public Dropbox folder not detected")
			return -1
		ElseIf Not ProcessExists("Dropbox.exe") Then
			MsgBox(262144, "Error", "Dropbox is not running.  You must run dropbox in order to upload files")
			_FileWriteLog($LOG, "Dropbox is not running")
			return -1
		Else
			If _GetTrayText("Dropbox") == "" Then
				MsgBox(262144, "Error", "Unable to find Dropbox tray icon. Please set it to 'Show icon and notifications'" & @LF & @LF & @TAB & "Control Panel -> Notification Area Icons")
				_FileWriteLog($LOG, "Unable to find Dropbox tray icon")
				return -1
			EndIf
		EndIf
	EndIf
	return 1
EndFunc

Func _GetTrayText($sToolTipTitle) ;Gets text of tray tip
	; Find systray handle
	Local $hSysTray_Handle = ControlGetHandle("[Class:Shell_TrayWnd]", "", "[Class:ToolbarWindow32;Instance:1]")
	If @error Then
		_FileWriteLog($LOG, "System tray not found")
		Exit
	EndIf

	; Get systray item count
	Local $iSystray_ButCount = _GUICtrlToolbar_ButtonCount($hSysTray_Handle)
	If $iSystray_ButCount = 0 Then
		_FileWriteLog($LOG, "No items found in system tray")
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