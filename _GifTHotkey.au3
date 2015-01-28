#region Hotkey window
$HKMAIN 	= GUICreate("Set Hotkey", 250, 80, -1, -1, $WS_SYSMENU, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))

$SKEY1 		= GUICtrlCreateCombo("NONE", 15, 17, 60, 20)
$SKEY2 		= GUICtrlCreateCombo("NONE", 90, 17, 60, 20)
$SKEY3 		= GUICtrlCreateCombo("0", 165, 17, 60, 20)
GUICtrlSetData($SKEY1, "ALT|CTRL|SHIFT|WIN", "NONE")
GUICtrlSetData($SKEY2, "ALT|CTRL|SHIFT|WIN", "NONE")
GUICtrlSetData($SKEY3, "1|2|3|4|5|6|7|8|9|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|F1|F2|F3|F4|F5|F6|F7|F8|F9|F10|F11|ESC", "0")
#endregion

Func _selectKey($BUTTON) ;GUI for selecting hotkey
	$keys = StringSplit(GUICtrlRead($BUTTON), " + ", 1)
	GUISetState(@SW_SHOW, $HKMAIN)
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

				GUISetState(@SW_HIDE, $HKMAIN)
				return $str
		EndSwitch
	WEnd
EndFunc   ;==>_selectKey

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