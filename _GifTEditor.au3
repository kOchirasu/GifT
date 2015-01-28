#region Gif Edit window
$EIMGH 		= 500
$EIMGW 		= 600
$EGIFFILE 	= 0
$ECURF 		= 1
$EMAXF 		= 1
$ESLIDEH 	= 0
$EGRAPHIC 	= 0

$EMAIN 		= GUICreate("Gif Editor", $EIMGW, $EIMGH, -1, -1, $WS_SYSMENU)
$EPATHL 	= GUICtrlCreateLabel("Gif Source:", 10, 10, 70, 20)
$EPATH 		= GUICtrlCreateInput("C:\GifT\Local\", 75, 9, 240, 20)
$EBROWSE 	= GUICtrlCreateButton("Browse...", 325, 5, 70, 27)
$ELOAD 		= GUICtrlCreateButton("Load Gif", 405, 5, 60, 27)

$EFCUR 		= GUICtrlCreateLabel("1", 500, 10, 30, 20, $SS_RIGHT)
$EFMAX 		= GUICtrlCreateLabel("/ ?", 535, 10, 30, 20)
$EGROUP 	= GUICtrlCreateGroup("Gif Preview", 10, 35, 575, 365)

$ESLIDE 	= GUICtrlCreateSlider(10, 400, 575, 30)

$EPREVF 	= GUICtrlCreateButton("<", 10, 435, 40, 30)
$ENEXTF 	= GUICtrlCreateButton(">", 55, 435, 40, 30)
$EINSERT 	= GUICtrlCreateButton("Insert", 110, 435, 65, 30)
$EREMOVE 	= GUICtrlCreateButton("Remove", 180, 435, 65, 30)
$EPLAY		= GUICtrlCreateButton("Play", 260, 435, 65, 30)
$EFPSL		= GUICtrlCreateLabel("FPS:", 400, 440, 50, 30)
$EFPS		= GUICtrlCreateInput("10", 435, 437, 40, 25)
$ESAVE		= GUICtrlCreateButton("Done!", 490, 435, 85, 30)

GUICtrlSetResizing($EPATHL, $GUI_DOCKALL)
GUICtrlSetResizing($EPATH, $GUI_DOCKALL)
GUICtrlSetResizing($EBROWSE, $GUI_DOCKALL)
GUICtrlSetResizing($ELOAD, $GUI_DOCKALL)
GUICtrlSetResizing($EFCUR, $GUI_DOCKALL)
GUICtrlSetResizing($EFMAX, $GUI_DOCKALL)
GUICtrlSetResizing($EGROUP, $GUI_DOCKBORDERS)
GUICtrlSetResizing($ESLIDE, 4+64+512)
GUICtrlSetResizing($EPREVF, 2+64+256+512)
GUICtrlSetResizing($ENEXTF, 2+64+256+512)
GUICtrlSetResizing($EINSERT, 2+64+256+512)
GUICtrlSetResizing($EREMOVE, 2+64+256+512)
GUICtrlSetResizing($EPLAY, 2+64+256+512)
GUICtrlSetResizing($EFPSL, 4+64+256+512)
GUICtrlSetResizing($EFPS, 4+64+256+512)
GUICtrlSetResizing($ESAVE, 4+64+256+512)

GUICtrlSetState($ESLIDE, $GUI_DISABLE)
GUICtrlSetState($EPREVF, $GUI_DISABLE)
GUICtrlSetState($ENEXTF, $GUI_DISABLE)
GUICtrlSetState($EINSERT, $GUI_DISABLE)
GUICtrlSetState($EREMOVE, $GUI_DISABLE)
GUICtrlSetState($EPLAY, $GUI_DISABLE)
GUICtrlSetState($ESAVE, $GUI_DISABLE)
#endregion
#endregion Settings Window

#region Settings - Load information

Func _GifEdit()
	GUISetState(@SW_SHOW, $EMAIN)
	While 1
		$MSG = GUIGetMsg()
		Switch $MSG
				Case $GUI_EVENT_CLOSE
				GUISetState(@SW_HIDE, $EMAIN)
				return -1

			Case $EBROWSE
				$EFOLD = FileSelectFolder("Choose a folder.", $DIR)
				If $EFOLD <> "" Then
					GUICtrlSetData($EPATH, $EFOLD & "\")
				EndIf

			Case $ELOAD
				$EGIFFILE = _FileListToArray(GUICtrlRead($EPATH), "*.gif")
				If $EGIFFILE <> 0 Then
					$EMAXF = $EGIFFILE[0]
					GUICtrlSetLimit($ESLIDE, $EMAXF, 1)
					;_ArrayDisplay($EGIFFILE)
					_GDIPlus_Startup()
					For $i = 1 To $EMAXF Step 1
						$EGIFFILE[$i] = _GDIPlus_BitmapCreateFromFile(GUICtrlRead($EPATH) & $EGIFFILE[$i])
					Next
					;$EIMG = _GDIPlus_BitmapCreateFromFile(GUICtrlRead($EPATH) & $EGIFFILE[1])
					$EIMGH = _GDIPlus_ImageGetHeight($EGIFFILE[1])
					$EIMGW = _GDIPlus_ImageGetWidth($EGIFFILE[1])
					If $EIMGW < 555 Then
						$EIMGW = 554
					EndIf
					WinMove($EMAIN, "", Default, Default, 600 + $EIMGW - 555, 510 + $EIMGH - 345)
					$EGRAPHIC = _GDIPlus_GraphicsCreateFromHWND($EMAIN)
					_GDIPlus_GraphicsDrawImage($EGRAPHIC, $EGIFFILE[1], 20, 54)
					GUICtrlSetData($EFMAX, "/ " & $EMAXF)
					$ECURF = 1

					GUICtrlSetState($EINSERT, $GUI_ENABLE)
					If $EMAXF > 1 Then
						GUICtrlSetState($ESLIDE, $GUI_ENABLE)
						GUICtrlSetState($EPREVF, $GUI_ENABLE)
						GUICtrlSetState($ENEXTF, $GUI_ENABLE)
						GUICtrlSetState($EREMOVE, $GUI_ENABLE)
						GUICtrlSetState($EPLAY, $GUI_ENABLE)
					EndIf
					GUICtrlSetState($ESAVE, $GUI_ENABLE)
					GUICtrlSetData($ESLIDE, $ECURF)
				Else
					MsgBox(0, "Error", "No .gif files found.")
				EndIf

			Case $ENEXTF
				If $ECURF = $EMAXF Then
					$ECURF = 1
				Else
					$ECURF += 1
				EndIf
				GUICtrlSetData($ESLIDE, $ECURF)
				_DrawPic($EGRAPHIC, $EGIFFILE[$ECURF])
				GUICtrlSetData($EFCUR, $ECURF)

			Case $EPREVF
				If $ECURF = 1 Then
					$ECURF = $EMAXF
				Else
					$ECURF -= 1
				EndIf
				GUICtrlSetData($ESLIDE, $ECURF)
				_DrawPic($EGRAPHIC, $EGIFFILE[$ECURF])
				GUICtrlSetData($EFCUR, $ECURF)

			Case $EINSERT
				MsgBox(0, "Ops", "This doesnt even work")

			Case $EREMOVE
				GUICtrlSetState($EREMOVE, $GUI_DISABLE)
				If MsgBox(4, "Are you sure?", "Are you sure you want to remove this frame?") = 6 Then
					_GDIPlus_BitmapDispose($EGIFFILE[$ECURF])
					If $ECURF = $EMAXF Then
						$ECURF -= 1
					Else
						For $i = $ECURF To $EMAXF - 1 Step 1
							$EGIFFILE[$i] = $EGIFFILE[$i + 1]
						Next
					EndIf
					$EMAXF -= 1
					_DrawPic($EGRAPHIC, $EGIFFILE[$ECURF])
					GUICtrlSetData($EFCUR, $ECURF)
					GUICtrlSetData($EFMAX, "/ " & $EMAXF)
					GUICtrlSetLimit($ESLIDE, $EMAXF)
				EndIf
				GUICtrlSetState($EREMOVE, $GUI_ENABLE)
				If $EMAXF = 1 Then
					GUICtrlSetState($EREMOVE, $GUI_DISABLE)
				EndIf
				GUICtrlSetLimit($ESLIDE, $EMAXF, 1)

			Case $EPLAY
				$EDELAY = 1000 / GUICtrlRead($EFPS)
				GUICtrlSetState($ESLIDE, $GUI_DISABLE)
				GUICtrlSetState($EPREVF, $GUI_DISABLE)
				GUICtrlSetState($ENEXTF, $GUI_DISABLE)
				GUICtrlSetState($EINSERT, $GUI_DISABLE)
				GUICtrlSetState($EREMOVE, $GUI_DISABLE)
				GUICtrlSetState($EPLAY, $GUI_DISABLE)
				GUICtrlSetState($ESAVE, $GUI_DISABLE)

				For $i = $ECURF To $EMAXF Step 1
					_DrawPic($EGRAPHIC, $EGIFFILE[$i])
					GUICtrlSetData($EFCUR, $i)
					Sleep($EDELAY - 25)
				Next
				Sleep(1000)
				_DrawPic($EGRAPHIC, $EGIFFILE[$ECURF])
				GUICtrlSetData($EFCUR, $ECURF)

				GUICtrlSetState($ESLIDE, $GUI_ENABLE)
				GUICtrlSetState($EPREVF, $GUI_ENABLE)
				GUICtrlSetState($ENEXTF, $GUI_ENABLE)
				GUICtrlSetState($EINSERT, $GUI_ENABLE)
				GUICtrlSetState($EREMOVE, $GUI_ENABLE)
				GUICtrlSetState($EPLAY, $GUI_ENABLE)
				GUICtrlSetState($ESAVE, $GUI_ENABLE)

			Case $ESAVE
				GUISetState(@SW_HIDE, $EMAIN)
				;MsgBox(0, "", GUICtrlRead($EPATH))
				$theFiles = _GetFiles(GUICtrlRead($EPATH), 0) ;The 0 means Gif
				_convert($theFiles, $GIFTPATH, 1000 / GUICtrlRead($EFPS), $GIFTPATH & "Gif.exe")
				;MsgBox(0, "", "do not work")
				MsgBox(0, "Saved", "File Located: " & $GIFTPATH)
				return 1

		EndSwitch
		$ESTAT = GUICtrlRead($ESLIDE)
		If $ESTAT <> $ESLIDEH Then
			$ECURF = $ESTAT
			_DrawPic($EGRAPHIC, $EGIFFILE[$ECURF])
			GUICtrlSetData($EFCUR, $ECURF)
			$ESLIDEH = $ECURF
		EndIf
		Sleep(20)
	WEnd
EndFunc