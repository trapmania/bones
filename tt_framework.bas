'tt_framework.bas
'author TT - feel free to reuse 
'-> note that this is not the perfered game framework that I ever made 
'-> but it went too far and I have no time to redo the project from start
'-> so let's build on it anyway ...
'for more information please search the freebasic.net community forum

#define _tittlepath			_datapath & "\tittle\"
#define _guipath			   _datapath & "\gui\"
#define _characterspath    _datapath & "\characters\"

type WH
		as single	_w
		as single	_h
end type
#ifnDef XY
type XY
      as single _x
      as single _y
end type
#endIf


'_
type DESKTOPINFO
	declare property DesktopWidHei() as WH
	declare property DesktopMidScreen() as XY
	declare function MidXY(byref as WH) byref as XY
	private:
		as WH	_widthHeight
		as XY	_midScreen
	public:
	static as DESKTOPINFO ptr	nullPtr
End Type
dim as DESKTOPINFO ptr	desktopinfo_null
property DESKTOPINFO.DesktopWidHei() as WH
	if @T=0 then
		dim as integer	dskW, dskH
		screencontrol	fb.GET_DESKTOP_SIZE, dskW, dskH
		return type<WH>(dskW, dskH)
	else
		'dev.note::not tested..
		screencontrol	fb.GET_DESKTOP_SIZE, _ 
         cInt(T._widthHeight._w), _ 
         cInt(T._widthHeight._h)
		'
		return type<WH>(T._widthHeight._w, T._widthHeight._h)
	end if
End Property
property DESKTOPINFO.DesktopMidScreen() as XY
	if @T=0 then
		dim as integer	dskW, dskH
		screencontrol	fb.GET_DESKTOP_SIZE, dskW, dskH
		return type<XY>(dskW\2, dskH\2)
	else
		'dev.note::not tested..
		screencontrol	fb.GET_DESKTOP_SIZE, _ 
         cInt(T.MidXY(T._widthHeight)._x), _ 
         cInt(T.MidXY(T._widthHeight)._y)
		'
		return type<XY>(T._midScreen._x, T._midScreen._y)
	end if
End Property
function DESKTOPINFO.MidXY(byref XYvalue as WH) byref as XY
	T._midScreen._x	= XYvalue._w/2
	T._midScreen._y	= XYvalue._h/2
	'
	return T._midScreen
End Function

'_
type APPWINDOW
	declare constructor()
	declare destructor()
	declare property AppWidHei() as WH
	declare property AppMidPos() as XY
	declare property AppPos() as XY
	declare property ExitMessageTriggered() as boolean
	declare sub TestKeyboard()
	declare sub TestMouse()
	declare function ImgToCenter(byval as any ptr) as XY
	declare sub ClearImageBuffer()
	declare sub RaiseSplashscreen()
	declare sub RaiseAppwindowscreen()
	declare sub DrawSplashscreen()
	declare sub DrawMainWindow() 
		as DESKTOPINFO		_desktopInfo
		as WH				_widthHeight
	enum _APPWINDOWSPLASHSCREEN
		_nosplashscreen
		_defaultsplashscreen
		_buffersplashscreen
	End Enum
	enum _APPWINDOWSTYLE
		_normal
		_shaped
	End Enum
		as _APPWINDOWSPLASHSCREEN	_splashscreenStatus
		as _APPWINDOWSTYLE			_style
		as integer					   _splashscreenRaisedFlag
		as integer					   _appwindowscreenRaisedFlag
		as boolean			         _hasMouseOver
		as boolean			         _hasMouseClick
		as boolean			         _escKeyPressed
		as boolean			         _exitButtonHasMouseOver
		as boolean			         _exitButtonPressed
		as boolean			         _appWindowScrTopMost
		as boolean			         _isTheValidInstance
		as fb.IMAGE	ptr		      _splashscreenImageBuffer
		as fb.IMAGE	ptr		      _imageBuffer
      as XY                      _imageBufferScreenOffsetXY
	static as integer		instanceCounter
End Type
type AW as APPWINDOW
dim as integer	AW.instanceCounter	=> 0
constructor AW()
	AW.instanceCounter +=> 1
	if AW.instanceCounter=1 then
		T._isTheValidInstance => TRUE
	else
		T.destructor()
	EndIf
	'
	T._hasMouseOver					=> FALSE
	T._hasMouseClick				   => FALSE
	T._escKeyPressed				   => FALSE
	T._appWindowScrTopMost			=> TRUE
	T._exitButtonPressed			   => FALSE
	T._exitButtonHasMouseOver		=> FALSE
	T._splashscreenRaisedFlag		=> 0
	T._appwindowscreenRaisedFlag	=> 0
	T._widthHeight._w	=> (new(0) DESKTOPINFO)->DesktopWidHei._w*0.65
	T._widthHeight._h	=> (new(0) DESKTOPINFO)->DesktopWidHei._h*0.65
	'configure splashscreen
	T._splashscreenStatus	=> AW._APPWINDOWSPLASHSCREEN._buffersplashscreen
	'configure appscreen
	T._style				=> AW._APPWINDOWSTYLE._shaped
End Constructor
destructor AW()
	imagedestroy T._imagebuffer
	if AW.instanceCounter>1 then
		AW.instanceCounter -= 1
		T._isTheValidInstance = FALSE
	else
		screen 0
		T._isTheValidInstance = FALSE
	EndIf
End Destructor
property AW.AppWidHei() as WH
	dim as integer	scrW, scrH
	screeninfo		scrW, scrH
	return type<WH>(scrW, scrH)
End Property
property AW.AppMidPos() as XY
	dim as XY	appwinMidPos
	appwinMidPos = T.AppPos
	return type<XY>(AppPos._x*1.5, AppPos._y*1.5)
End Property
property AW.AppPos() as XY
	dim as integer	appwinPosX, appwinPosY
	screenControl	fb.GET_WINDOW_POS, appwinPosX, appwinPosY
	return type<XY>(appwinPosX, appwinPosY)
End Property
property AW.ExitMessageTriggered() as boolean
	if T._escKeyPressed orElse T._exitButtonPressed then
		return TRUE
	else
		return FALSE
	EndIf
End Property
sub AW.TestKeyboard()
	if multiKey(fb.SC_ESCAPE) then 
		if not T._escKeyPressed then T._escKeyPressed = TRUE
		
	EndIf
	while inkey()<>"" : wend
End Sub
sub AW.TestMouse()
	dim as integer	gmX
	dim as integer	gmY
	dim as integer	gmWheel
	dim as integer	gmBtn
	dim as integer	gmError
	gmError	= getMouse(gmX, gmY, gmWheel, gmBtn, 1)
	'
	if gmX>0						andAlso _
	   gmX<(T.AppWidHei._w - 1)		andAlso _
	   gmY>0						andAlso _
	   gmY<(T.AppWidHei._h - 1)		then
		'
		if T._hasMouseOver	then
			if _P2DDIST(type<XY>(gmX,gmY),type<XY>(T._widthHeight._w - 28,20))<10 then
				if not T._exitButtonHasMouseOver then
					T._exitButtonHasMouseOver = TRUE
				EndIf
			else
				T._exitButtonHasMouseOver = FALSE
			EndIf
			'
			if gmBtn>0 andAlso (not T._hasMouseClick) then
				T._hasMouseClick	= TRUE
				'
				if T._exitButtonHasMouseOver then
					T._exitButtonPressed = TRUE
				else
					T._exitButtonPressed = FALSE
				EndIf
				'
				if _P2DDIST(type<XY>(gmX,gmY),type<XY>(T._widthHeight._w - 58,20))<12 then
					T._appWindowScrTopMost = not T._appWindowScrTopMost
					T._appwindowscreenRaisedFlag = 0
				EndIf
			elseIf gmBtn<=0 andAlso T._hasMouseClick then
				T._hasMouseClick = FALSE
			EndIf
		else
			T._hasMouseOver		= TRUE
		EndIf
	else
		if T._hasMouseOver then
			T._hasMouseOver		= FALSE
		EndIf
		if T._exitButtonHasMouseOver then
			T._exitButtonHasMouseOver = FALSE
		EndIf
		if T._hasMouseClick then
			T._hasMouseClick	= FALSE
		EndIf
	EndIf
End Sub
function AW.ImgToCenter(byval ImgBuffer as any ptr) as XY
	dim as integer	scrW, scrH
	screenInfo		scrW, scrH
	dim as integer	imgW, imgH
	imageInfo		ImgBuffer, imgW, imgH
	'
	return type<XY>((scrW - imgW)\2,(scrH - imgH)\2)
End Function
sub AW.ClearImageBuffer()
	imagedestroy T._imagebuffer
	if screenPtr()<>0 then
		T._imagebuffer	=> imageCreate(T._widthHeight._w - 8, T._widthHeight._h - 48, rgb(80,75,95) / focusColor, 32)
	end if	
End Sub
sub AW.RaiseSplashscreen()
	if T._splashscreenRaisedFlag=0 then
		T._splashscreenRaisedFlag	= 1
		'
		screenres T._widthHeight._w*.68, T._widthHeight._h*.68, _ 
			32, _ 
			2, _
	        fb.GFX_ALPHA_PRIMITIVES		+ _ 
	        fb.GFX_NO_FRAME				+ _ 
	        fb.GFX_SHAPED_WINDOW
	    imagedestroy T._splashscreenImageBuffer
	    T._splashscreenImageBuffer	=> _ 
	    	imageCreate(T._widthHeight._w*.6 - 8, T._widthHeight._h*.6 - 48, rgb(255,0,255), 32)
	else
		exit sub
	end if
End Sub
sub AW.RaiseAppwindowscreen()
	if T._appwindowscreenRaisedFlag=0 then
		T._appwindowscreenRaisedFlag	= 1
		'
		select case T._appWindowScrTopMost
			case TRUE
				screenres T._widthHeight._w, T._widthHeight._h, _ 
					32, _ 
					2, _
			        fb.GFX_ALPHA_PRIMITIVES		+ _ 
			        fb.GFX_NO_FRAME				+ _ 
			        fb.GFX_ALWAYS_ON_TOP		+ _ 
	        		fb.GFX_SHAPED_WINDOW, _ 
			        10
			case else
				screenres T._widthHeight._w, T._widthHeight._h, _ 
					32, _ 
					2, _
			        fb.GFX_ALPHA_PRIMITIVES		+ _ 
			        fb.GFX_NO_FRAME				+ _ 
	        		fb.GFX_SHAPED_WINDOW
		end select
		T.ClearImageBuffer()
	else
		exit sub
	end if
End Sub
sub AW.DrawSplashscreen()
	T.RaiseSplashscreen()
	'
	imageDestroy T._splashscreenImageBuffer
	T._splashscreenImageBuffer = CreditFBDoc.BMPlOAD( _tittlepath & "title.bmp" )
	dim as integer	imgW, imgH
	imageInfo T._splashscreenImageBuffer, imgW, imgH
	'
	color rgb(100,200,120), rgb(255,0,255)
	cls
	line (T.ImgToCenter(T._splashscreenImageBuffer)._x,0)-step(imgW - 1, imgH*2 - 1), _ 
			rgb(100, 120, 190), _ 
			bf
	put (T.ImgToCenter(T._splashscreenImageBuffer)._x,T.ImgToCenter(T._splashscreenImageBuffer)._y), _ 
			T._splashscreenImageBuffer, _ 
			TRANS
	'
	'? "splash screen"
	'? T.AppPos._x, T.AppPos._y
	'? T.AppMidPos._x, T.AppMidPos._y
	sleep 3200, 0
End Sub
sub AW.DrawMainWindow()
	static as integer alertRadiusAroundBtn	=> 0
	if T._exitButtonHasMouseOver then
		alertRadiusAroundBtn += 1
		alertRadiusAroundBtn = alertRadiusAroundBtn mod 4
	else
		alertRadiusAroundBtn = 0
	end if
	'
	T.RaiseAppwindowscreen()
	'
	line (1, 1)-(T._widthHeight._w - 2, T._widthHeight._h - 2), _ 
			focusColor + 40, _ 
			bf
	line (1, 1)-(T._widthHeight._w - 2, 40), _ 
			focusColor + 10, _ 
			bf
	circle (T._widthHeight._w - 28, 20), 10 + alertRadiusAroundBtn, _ 
			rgb(120 + 20*alertRadiusAroundBtn,235 - iif(T._exitButtonPressed orElse T._escKeyPressed,0,200),100), , , , F
	draw string step(-2,-2), "X", rgb(180,200,080) + iif(scrEvent.type=12,focusColor\2,0)
	'
	circle (T._widthHeight._w - 58, 20), 12, rgb(195 - iif(T._appWindowScrTopMost,200,0),180,100), , , , F
	draw string step(-11,-2), iif(T._appWindowScrTopMost,"TOP","___"), rgb(090,040,180) + iif(scrEvent.type=12,0,-focusColor\2)
	'
   THIS._imageBufferScreenOffsetXY._x = T.ImgToCenter(T._imagebuffer)._x
   THIS._imageBufferScreenOffsetXY._y = T.ImgToCenter(T._imagebuffer)._y + 20
	put (THIS._imageBufferScreenOffsetXY._x, THIS._imageBufferScreenOffsetXY._y), T._imagebuffer, PSET
End Sub

'_
type GAMEGROUND
	declare constructor()
	declare destructor()
	declare property AppWindowCenter() as XY
	declare function LinkToApplicationWindow(byref as APPWINDOW ptr) as any ptr
	declare sub DrawGameGround()
		as XY				_originOffset
		as WH				_groundWH
		as APPWINDOW ptr	_applicationWindowPtr
		as fb.IMAGE	ptr		_gameGroundBuffer
End Type
type GG as GAMEGROUND
constructor GG()
	T._originOffset		=> type<XY>(0,0)
	T._groundWH			   => type<WH>(1800,400)
	T._gameGroundBuffer	=> imageCreate(T._groundWH._w,T._groundWH._h,rgb(255,0,255),32)
	'
   'draw background
	line T._gameGroundBuffer, (0,0)-step(T._groundWH._w - 1, T._groundWH._h - 1), rgb(20,20,100), bf
	for x as integer = 0 to T._groundWH._w  step 100
		line T._gameGroundBuffer, (x,0)-step(0,T._groundWH._h - 1), , , &b01101
		for y as integer = 0 to T._groundWH._h step 100
			line T._gameGroundBuffer, (0,y)-step(T._groundWH._w - 1,0), , , &b01101
			draw string T._gameGroundBuffer, (x + 12, y + 12), _ 
						"x" & str(x - T._groundWH._w\2) & ",y" & str(y - T._groundWH._h\2), _
                  rgb(20,30,160)
		next y
	Next x
   line T._gameGroundBuffer, (0, 200)-step(T._groundWH._w - 1, T._groundWH._h - 1), rgb(200,20,100), bf
   '
End Constructor
destructor GG()
	imageDestroy T._gameGroundBuffer
End Destructor
property GG.AppWindowCenter() as XY
	if T._applicationWindowPtr=0 then
		return type<XY>(-1,-1)
	else
		return T._applicationWindowPtr->AppMidPos
	EndIf
End Property
function GG.LinkToApplicationWindow(byref AwPtr as APPWINDOW ptr) as any ptr
	T._applicationWindowPtr	=> AwPtr
	'
	return AwPtr
End Function
sub GG.DrawGameGround()
	put T._applicationWindowPtr->_imageBuffer, _ 
		(	T._originOffset._x + T._applicationWindowPtr->ImgToCenter(T._gameGroundBuffer)._x, _ 
			T._originOffset._y + T._applicationWindowPtr->ImgToCenter(T._gameGroundBuffer)._y	), _ 
		T._gameGroundBuffer, _ 
		TRANS
End Sub

'(eof)