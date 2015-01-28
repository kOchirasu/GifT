$AVMAIN 		= GUICreate("GifT Advanced Settings", 285, 520, -1, -1, $WS_SYSMENU, BitOR($WS_EX_TOPMOST, $WS_EX_TOOLWINDOW))
GUICtrlCreateGroup("General Options", 5, 5, 269, 100)
;$AVFFMPEG		= GUICtrlCreateInput($GIFTPATH, 10, 25, 200, 20)
GUICtrlCreateLabel("Threads:", 10, 27, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Max Length:", 10, 52, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Container:", 10, 77, 65, 20, $SS_RIGHT)

$AVTHREAD		= GUICtrlCreateInput("", 80, 25, 70, 20, $ES_NUMBER)
$AVTIME			= GUICtrlCreateInput("", 80, 50, 70, 20, $ES_NUMBER)
$AVCONT			= GUICtrlCreateInput("", 80, 75, 70, 20)

$AVCTHREAD		= GUICtrlCreateInput("-threads ", 160, 25, 50, 20, $ES_READONLY)
$AVCTIME		= GUICtrlCreateInput("-t ", 160, 50, 50, 20, $ES_READONLY)

$AVATHREAD		= GUICtrlCreateCheckbox(" Auto", 220, 25, 50, 20)
$AVATIME		= GUICtrlCreateCheckbox(" Auto", 220, 50, 50, 20)

GUICtrlSetLimit($AVTHREAD, 1)
GUICtrlSetLimit($AVTIME, 4)

GUICtrlCreateGroup("Video Options", 5, 110, 269, 175)
GUICtrlCreateLabel("Framerate:", 10, 132, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("CRF:", 10, 157, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Codec:", 10, 182, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Bitrate:", 10, 207, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Pixel Format:", 10, 232, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Preset:", 10, 257, 65, 20, $SS_RIGHT)

$AVFPS			= GUICtrlCreateInput("", 80, 130, 70, 20, $ES_NUMBER) ;1 to 30
$AVCRF			= GUICtrlCreateInput("", 80, 155, 70, 20, $ES_NUMBER) ;0 to 51
$AVCODECV		= GUICtrlCreateInput("", 80, 180, 70, 20) ;'copy'
$AVBITRATEV		= GUICtrlCreateInput("", 80, 205, 70, 20, $ES_NUMBER)
$AVPIXFMT		= GUICtrlCreateInput("", 80, 230, 70, 20)
$AVPRESET		= GUICtrlCreateCombo("ultrafast", 80, 255, 70, 20, $CBS_DROPDOWNLIST)
GUICtrlSetData($AVPRESET, "superfast|veryfast|faster|fast|medium|slow|slower|veryslow", "ultrafast")

$AVCFPS			= GUICtrlCreateInput("-r ", 160, 130, 50, 20, $ES_READONLY)
$AVCCRF			= GUICtrlCreateInput("-crf ", 160, 155, 50, 20, $ES_READONLY)
$AVCCODECV		= GUICtrlCreateInput("-c:v ", 160, 180, 50, 20, $ES_READONLY)
$AVCBITRATEV	= GUICtrlCreateInput("-b:v ", 160, 205, 50, 20, $ES_READONLY)
$AVCPIXFMT		= GUICtrlCreateInput("-pix_fmt ", 160, 230, 50, 20, $ES_READONLY)
$AVCPRESET		= GUICtrlCreateInput("-preset ", 160, 255, 50, 20, $ES_READONLY)

$AVAFPS			= GUICtrlCreateCheckbox(" Auto", 220, 130, 50, 20)
$AVACRF			= GUICtrlCreateCheckbox(" Auto", 220, 155, 50, 20)
$AVACODECV		= GUICtrlCreateCheckbox(" Auto", 220, 180, 50, 20)
$AVABITRATEV	= GUICtrlCreateCheckbox(" Auto", 220, 205, 50, 20)
$AVAPIXFMT		= GUICtrlCreateCheckbox(" Auto", 220, 230, 50, 20)
$AVAPRESET		= GUICtrlCreateCheckbox(" Auto", 220, 255, 50, 20)

GUICtrlSetLimit($AVFPS, 2)
GUICtrlSetLimit($AVCRF, 2)
GUICtrlSetLimit($AVBITRATEV, 4)

GUICtrlCreateGroup("Audio Options", 5, 290, 269, 175)
GUICtrlCreateLabel("Sample Rate:", 10, 312, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Quality:", 10, 337, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Channels:", 10, 362, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Codec:", 10, 387, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Bitrate:", 10, 412, 65, 20, $SS_RIGHT)
GUICtrlCreateLabel("Volume:", 10, 437, 65, 20, $SS_RIGHT)

$AVRATE			= GUICtrlCreateInput("", 80, 310, 70, 20, $ES_NUMBER)
$AVQUALITY		= GUICtrlCreateInput("", 80, 335, 70, 20, $ES_NUMBER)
$AVCHANNEL		= GUICtrlCreateInput("", 80, 360, 70, 20, $ES_NUMBER)
$AVCODECA		= GUICtrlCreateInput("", 80, 385, 70, 20)
$AVBITRATEA		= GUICtrlCreateInput("", 80, 410, 70, 20, $ES_NUMBER)
$AVVOLUME		= GUICtrlCreateInput("", 80, 435, 70, 20, $ES_NUMBER) ;0 to 256

$AVCRATE		= GUICtrlCreateInput("-ar ", 160, 310, 50, 20, $ES_READONLY)
$AVCQUALITY		= GUICtrlCreateInput("-aq ", 160, 335, 50, 20, $ES_READONLY)
$AVCCHANNEL		= GUICtrlCreateInput("-ac ", 160, 360, 50, 20, $ES_READONLY)
$AVCCODECA		= GUICtrlCreateInput("-c:a ", 160, 385, 50, 20, $ES_READONLY)
$AVCBITRATEA	= GUICtrlCreateInput("-b:a ", 160, 410, 50, 20, $ES_READONLY)
$AVCVOLUME		= GUICtrlCreateInput("-vol ", 160, 435, 50, 20, $ES_READONLY)

$AVARATE		= GUICtrlCreateCheckbox(" Auto", 220, 310, 50, 20)
$AVAQUALITY		= GUICtrlCreateCheckbox(" Auto", 220, 335, 50, 20)
$AVACHANNEL		= GUICtrlCreateCheckbox(" Auto", 220, 360, 50, 20)
$AVACODECA		= GUICtrlCreateCheckbox(" Auto", 220, 385, 50, 20)
$AVABITRATEA	= GUICtrlCreateCheckbox(" Auto", 220, 410, 50, 20)
$AVAVOLUME		= GUICtrlCreateCheckbox(" Auto", 220, 435, 50, 20)

GUICtrlSetLimit($AVQUALITY, 3)
GUICtrlSetLimit($AVCHANNEL, 1)
GUICtrlSetLimit($AVBITRATEA, 3)
GUICtrlSetLimit($AVVOLUME, 3)

_loadIniAdv()

$AVCMD = GUICtrlCreateInput(_getCommand(), 5, 470, 270, 20, $ES_READONLY)

;_AdvancedSettings()

Func _AdvancedSettings()
	GUICtrlSetData($AVCMD, _getCommand())
	GUISetState(@SW_SHOW, $AVMAIN)
	While 1
		$MSG = GUIGetMsg()
		Switch $MSG
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_HIDE, $AVMAIN)
				return

			Case $AVTHREAD
				IniWrite($INIPATH, "general", "thread", _rangeLimit(GUICtrlRead($AVTHREAD), 1, 6))

			Case $AVTIME
				IniWrite($INIPATH, "general", "time", GUICtrlRead($AVTIME))

			Case $AVCONT
				InitWrite($INIPATH, "general", "cont", GUICtrlRead($AVCONT))

			Case $AVATHREAD, $AVATIME
				$AVCHECK = GUICtrlRead($MSG) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE
				Switch $MSG
					Case $AVATHREAD
						GUICtrlSetState($AVTHREAD, $AVCHECK)
						IniWrite($INIPATH, "general", "threadbox", GUICtrlRead($MSG))
					Case $AVATIME
						GUICtrlSetState($AVTIME, $AVCHECK)
						IniWrite($INIPATH, "general", "timebox", GUICtrlRead($MSG))
				EndSwitch

			Case $AVFPS
				IniWrite($INIPATH, "video", "fps", _rangeLimit(GUICtrlRead($AVFPS), 1, 30))

			Case $AVCRF
				IniWrite($INIPATH, "video", "crf", _rangeLimit(GUICtrlRead($AVCRF), 0, 51))

			Case $AVCODECV
				IniWrite($INIPATH, "video", "codec", GUICtrlRead($AVCODECV))

			Case $AVBITRATEV
				IniWrite($INIPATH, "video", "bitrate", GUICtrlRead($AVBITRATEV))

			Case $AVPIXFMT
				IniWrite($INIPATH, "video", "pixfmt", GUICtrlRead($AVPIXFMT))

			Case $AVPRESET
				IniWrite($INIPATH, "video", "preset", GUICtrlRead($AVPRESET))

			Case $AVAFPS, $AVACRF, $AVACODECV, $AVABITRATEV, $AVAPIXFMT, $AVAPRESET
				$AVCHECK = GUICtrlRead($MSG) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE
				Switch $MSG
					Case $AVAFPS
						GUICtrlSetState($AVFPS, $AVCHECK)
						IniWrite($INIPATH, "video", "fpsbox", GUICtrlRead($MSG))
					Case $AVACRF
						GUICtrlSetState($AVCRF, $AVCHECK)
						IniWrite($INIPATH, "video", "crfbox", GUICtrlRead($MSG))
					Case $AVACODECV
						GUICtrlSetState($AVCODECV, $AVCHECK)
						IniWrite($INIPATH, "video", "codecbox", GUICtrlRead($MSG))
					Case $AVABITRATEV
						GUICtrlSetState($AVBITRATEV, $AVCHECK)
						IniWrite($INIPATH, "video", "bitratebox", GUICtrlRead($MSG))
					Case $AVAPIXFMT
						GUICtrlSetState($AVPIXFMT, $AVCHECK)
						IniWrite($INIPATH, "video", "pixfmtbox", GUICtrlRead($MSG))
					Case $AVAPRESET
						GUICtrlSetState($AVPRESET, $AVCHECK)
						IniWrite($INIPATH, "video", "presetbox", GUICtrlRead($MSG))
				EndSwitch

			Case $AVRATE
				IniWrite($INIPATH, "audio", "rate", GUICtrlRead($AVRATE))

			Case $AVQUALITY
				IniWrite($INIPATH, "audio", "quality", GUICtrlRead($AVQUALITY))

			Case $AVCHANNEL
				IniWrite($INIPATH, "audio", "channel", _rangeLimit(GUICtrlRead($AVCHANNEL), 1, 8))

			Case $AVCODECA
				IniWrite($INIPATH, "audio", "codec", GUICtrlRead($AVCODECA))

			Case $AVBITRATEA
				IniWrite($INIPATH, "audio", "bitrate", GUICtrlRead($AVBITRATEA))

			Case $AVVOLUME
				IniWrite($INIPATH, "audio", "volume", _rangeLimit(GUICtrlRead($AVVOLUME), 1, 256))

			Case $AVARATE, $AVAQUALITY, $AVACHANNEL, $AVACODECA, $AVABITRATEA, $AVAVOLUME
				$AVCHECK = GUICtrlRead($MSG) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE
				Switch $MSG
					Case $AVARATE
						GUICtrlSetState($AVRATE, $AVCHECK)
						IniWrite($INIPATH, "audio", "ratebox", GUICtrlRead($MSG))
					Case $AVAQUALITY
						GUICtrlSetState($AVQUALITY, $AVCHECK)
						IniWrite($INIPATH, "audio", "qualitybox", GUICtrlRead($MSG))
					Case $AVACHANNEL
						GUICtrlSetState($AVCHANNEL, $AVCHECK)
						IniWrite($INIPATH, "audio", "channelbox", GUICtrlRead($MSG))
					Case $AVACODECA
						GUICtrlSetState($AVCODECA, $AVCHECK)
						IniWrite($INIPATH, "audio", "codecbox", GUICtrlRead($MSG))
					Case $AVABITRATEA
						GUICtrlSetState($AVBITRATEA, $AVCHECK)
						IniWrite($INIPATH, "audio", "bitratebox", GUICtrlRead($MSG))
					Case $AVAVOLUME
						GUICtrlSetState($AVVOLUME, $AVCHECK)
						IniWrite($INIPATH, "audio", "volumebox", GUICtrlRead($MSG))
				EndSwitch
		EndSwitch
	WEnd
EndFunc

Func _getCommand()
	Local $cmd = ""

	$cmd &= GUICtrlRead($AVCFPS)
	If GUICtrlRead($AVAFPS) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVFPS) & " "
	Else
		$cmd &= (GUICtrlRead($AVCONT) = "gif" ? 10 : 20) & " "
	EndIf
	If GUICtrlRead($AVACRF) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCCRF) & GUICtrlRead($AVCRF) & " "
	EndIf
	If GUICtrlRead($AVACODECV) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCCODECV) & GUICtrlRead($AVCODECV) & " "
	EndIf
	If GUICtrlRead($AVABITRATEV) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCBITRATEV) & GUICtrlRead($AVBITRATEV) & " "
	EndIf
	If GUICtrlRead($AVAPIXFMT) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCPIXFMT) & GUICtrlRead($AVPIXFMT) & " "
	EndIf
	$cmd &= GUICtrlRead($AVCPRESET)
	If GUICtrlRead($AVAPRESET) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVPRESET) & " "
	Else
		$cmd &= "ultrafast "
	EndIf

	If GUICtrlRead($AVARATE) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCRATE) & GUICtrlRead($AVRATE) & " "
	EndIf
	If GUICtrlRead($AVAQUALITY) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCQUALITY) & GUICtrlRead($AVQUALITY) & " "
	EndIf
	If GUICtrlRead($AVACHANNEL) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCCHANNEL) & GUICtrlRead($AVCHANNEL) & " "
	EndIf
	If GUICtrlRead($AVACODECA) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCCODECA) & GUICtrlRead($AVCODECA) & " "
	EndIf
	If GUICtrlRead($AVABITRATEA) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCBITRATEA) & GUICtrlRead($AVBITRATEA) & " "
	EndIf
	If GUICtrlRead($AVAVOLUME) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCVOLUME) & GUICtrlRead($AVVOLUME) & " "
	EndIf

	If GUICtrlRead($AVATHREAD) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVCTHREAD) & GUICtrlRead($AVTHREAD) & " "
	EndIf

	$cmd &= GUICtrlRead($AVCTIME)
	If GUICtrlRead($AVATIME) = $GUI_UNCHECKED Then
		$cmd &= GUICtrlRead($AVTIME) & " "
	Else
		$cmd &= "300 "
	EndIf

	Return $cmd
EndFunc

Func _getContainer()
	Return "." & GUICtrlRead($AVCONT)
EndFunc

Func _rangeLimit($val, $min, $max)
	If $vol < $min Then
		return $min
	ElseIf $vol > $max Then
		return $max
	EndIf
	return $val
EndFunc

Func _loadIniAdv() ;Loads .ini file and sets data to controls (settings window)
	GUICtrlSetData($AVTHREAD, IniRead($INIPATH, "general", "thread", 1))
	GUICtrlSetData($AVTIME, IniRead($INIPATH, "general", "time", 300))
	GUICtrlSetData($AVCONT, IniRead($INIPATH, "general", "cont", "webm"))

	GUICtrlSetData($AVFPS, IniRead($INIPATH, "video", "fps", 20))
	GUICtrlSetData($AVCRF, IniRead($INIPATH, "video", "crf", 23))
	GUICtrlSetData($AVCODECV, IniRead($INIPATH, "video", "codec", "libx264"))
	GUICtrlSetData($AVBITRATEV, IniRead($INIPATH, "video", "bitrate", "500k"))
	GUICtrlSetData($AVPIXFMT, IniRead($INIPATH, "video", "pixfmt", "yuv444p"))
	GUICtrlSetData($AVPRESET, IniRead($INIPATH, "video", "preset", "ultrafast"))

	GUICtrlSetData($AVRATE, IniRead($INIPATH, "audio", "rate", 22050))
	GUICtrlSetData($AVQUALITY, IniRead($INIPATH, "audio", "quality", 4))
	GUICtrlSetData($AVCHANNEL, IniRead($INIPATH, "audio", "channel", 2))
	GUICtrlSetData($AVCODECA, IniRead($INIPATH, "audio", "codec", "libvorbis"))
	GUICtrlSetData($AVBITRATEA, IniRead($INIPATH, "audio", "bitrate", "128k"))
	GUICtrlSetData($AVVOLUME, IniRead($INIPATH, "audio", "volume", 256))

	GUICtrlSetState($AVATHREAD, IniRead($INIPATH, "general", "threadbox", $GUI_CHECKED))
	GUICtrlSetState($AVATIME, IniRead($INIPATH, "general", "timebox", $GUI_CHECKED))

	GUICtrlSetState($AVAFPS, IniRead($INIPATH, "video", "fpsbox", $GUI_CHECKED))
	GUICtrlSetState($AVACRF, IniRead($INIPATH, "video", "crfbox", $GUI_CHECKED))
	GUICtrlSetState($AVACODECV, IniRead($INIPATH, "video", "codecbox", $GUI_CHECKED))
	GUICtrlSetState($AVABITRATEV, IniRead($INIPATH, "video", "bitratebox", $GUI_CHECKED))
	GUICtrlSetState($AVAPIXFMT, IniRead($INIPATH, "video", "pixfmtbox", $GUI_CHECKED))
	GUICtrlSetState($AVAPRESET, IniRead($INIPATH, "video", "presetbox", $GUI_CHECKED))

	GUICtrlSetState($AVARATE, IniRead($INIPATH, "audio", "ratebox", $GUI_CHECKED))
	GUICtrlSetState($AVAQUALITY, IniRead($INIPATH, "audio", "qualitybox", $GUI_CHECKED))
	GUICtrlSetState($AVACHANNEL, IniRead($INIPATH, "audio", "channelbox", $GUI_CHECKED))
	GUICtrlSetState($AVACODECA, IniRead($INIPATH, "audio", "codecbox", $GUI_CHECKED))
	GUICtrlSetState($AVABITRATEA, IniRead($INIPATH, "audio", "bitratebox", $GUI_CHECKED))
	GUICtrlSetState($AVAVOLUME, IniRead($INIPATH, "audio", "volumebox", $GUI_CHECKED))

	GUICtrlSetState($AVTHREAD, GUICtrlRead($AVATHREAD) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVTIME, GUICtrlRead($AVATIME) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)

	GUICtrlSetState($AVFPS, GUICtrlRead($AVAFPS) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVCRF, GUICtrlRead($AVACRF) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVCODECV, GUICtrlRead($AVACODECV) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVBITRATEV, GUICtrlRead($AVABITRATEV) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVPIXFMT, GUICtrlRead($AVAPIXFMT) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVPRESET, GUICtrlRead($AVAPRESET) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)

	GUICtrlSetState($AVRATE, GUICtrlRead($AVARATE) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVQUALITY, GUICtrlRead($AVAQUALITY) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVCHANNEL, GUICtrlRead($AVACHANNEL) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVCODECA, GUICtrlRead($AVACODECA) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVBITRATEA, GUICtrlRead($AVABITRATEA) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
	GUICtrlSetState($AVVOLUME, GUICtrlRead($AVAVOLUME) = $GUI_UNCHECKED ? $GUI_ENABLE : $GUI_DISABLE)
EndFunc   ;==>_loadIni