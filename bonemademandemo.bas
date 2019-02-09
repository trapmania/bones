'bonemademandemo.bas
'author TT - feel free to reuse   
'for more information please search the freebasic.net community forum

'this project contains 8 files + data forming a well defined directory tree
'basic files:
'  stonemonkey_triangles.bas
'  dodicat_fonts.bas
'  commondefines.bas
'  commonutilities.bas
'  tt_framework.bas
'  tt_boundingbox.bas
'  tt_draggablecircle.bas
'  tt_bones.bas


#include once "fbgfx.bi"

#include once  "stonemonkey_triangles.bas"
#include once  "dodicat_fonts.bas"

#define _execpath			curDir()
#define _datapath			curDir() & "\data\"
dim shared as fb.EVENT		         scrEvent
dim shared as ulong			         focusColor
dim shared as stonemonkey.STONEGFX_BUFFER ptr   stoneBuffer
stoneBuffer => new stonemonkey.STONEGFX_BUFFER

#include once  "commondefines.bas"
#include once  "commonutilities.bas"
#include once  "tt_framework.bas"
#include once  "tt_draggablecircle.bas"
#include once  "tt_bones.bas"


'-- main application loop

'splashscreen
   dim as AW	applicationWindow
   applicationWindow.DrawSplashscreen()
   while inkey()<>"" : wend

'game ground object
   dim as GG	ground
   ground.LinkToApplicationWindow(@applicationWindow)

'fonts initialisation
   applicationWindow.DrawMainWindow()
   dim as any ptr starter, starter2
   dodifont.createfont  starter, 2, RGB(200,200,200), 10
   dodifont.createfont  starter2, 2, RGB(10,200,200), 10

'triangles initialisation
   stonemonkey.InitializeStoneBuffer(stoneBuffer, applicationWindow._imageBuffer)

'protagon initialisation
   dim as PROTAGON   prota
   prota._protagonName  => "dummy"
   prota.ApplyOffsetXy(applicationWindow._imageBufferScreenOffsetXY, type(0,0))

'a timer utility initialisation (for development)
   dim as double  startTime      => TIMER
   dim as double  endTime        => TIMER
   dim as double  ellapsedTime   => any
   #macro _SETELLAPSEDTIME
      ellapsedTime   = TIMER - startTime
   #endMacro
   #macro _RESETELLAPSEDTIME
      ellapsedTime   = TIMER - startTime
      startTime      = TIMER
      endTime        = TIMER
   #endMacro

'last minute complements
dim as fb.IMAGE ptr  dulHeadImg
dulHeadImg => CreditFBDoc.BMPlOAD( _characterspath & "dul.bmp" )
dim as fb.IMAGE ptr  guiPanelLit
guiPanelLit => CreditFBDoc.BMPlOAD( _guipath & "panel_lit.bmp" )
dim as integer panelLitW
dim as integer panelLitH
imageInfo guiPanelLit, panelLitW, panelLitH
var guiPanelLitPosX  => 50
var guiPanelLitPosY  => 120
dim as boolean isControllerPanelOpen   => FALSE
dim as boolean hasPanelLitMouseOver    => FALSE
dim as boolean hasPanelLitMouseClick   => FALSE
dim as boolean hasPanelLitMouseClickPreviously  => FALSE
dim as single  panelOpenedTime         => -1.
#macro _PANELLITMOUSETEST()
   scope
      dim as integer gmX, gmY, gmW ,gmBtn
      getMouse gmX, gmY, gmW, gmBtn
      if gmX>=guiPanelLitPosX andAlso gmX<(guiPanelLitPosX + panelLitW) andAlso _ 
         gmY>=guiPanelLitPosY andAlso gmY<(guiPanelLitPosY + panelLitH) then
            if not hasPanelLitMouseOver then
               hasPanelLitMouseOver = TRUE
            end if
            if gmBtn>0 then
               if not hasPanelLitMouseClick then
                  hasPanelLitMouseClick = TRUE
               else
                  hasPanelLitMouseClickPreviously = TRUE
               end if
            end if
      else
         if hasPanelLitMouseOver then
            hasPanelLitMouseOver = FALSE
         end if
         if hasPanelLitMouseClick then
            hasPanelLitMouseClick = FALSE
            hasPanelLitMouseClickPreviously = FALSE
         end if
      end if
   end scope
#endMacro

prota._scaleFactor = 1.2 : prota.ApplyOffsetXy(applicationWindow._imageBufferScreenOffsetXY, type(applicationWindow.AppWidHei._w\2 - 140,180))

dim as PROTAGON   p2 => prota
p2._scaleFactor = 0.4
p2.ApplyOffsetXy(applicationWindow._imageBufferScreenOffsetXY, type(100,100))
p2.RefreshHierarchy()

'for testing
dim as single     radius   => 200
dim as single     angle    => 100
dim as single     orientationStep   =>  -.008
do
   '
   _SETELLAPSEDTIME
   '
	if (screenEvent(@screvent)) then
		select case scrEvent.type
			case fb.EVENT_WINDOW_GOT_FOCUS
  	        	focusColor = RGB(50,52,140)
			case fb.EVENT_WINDOW_LOST_FOCUS
				focusColor = RGB(60,66,100)
		end select
	endIf
   applicationWindow.TestKeyboard()
	applicationWindow.TestMouse()
   
   'panel_lit mousetest
   _PANELLITMOUSETEST()
   if hasPanelLitMouseClick then
      if not hasPanelLitMouseClickPreviously then         
         isControllerPanelOpen = not isControllerPanelOpen
         if (TIMER - panelOpenedTime)>1 then
            hasPanelLitMouseClick = FALSE
         end if
      end if
   end if
	'
	screenlock() 
		applicationWindow.ClearImageBuffer()
		
		'write something on the app. buffer
		ground.DrawGameGround()
      '
      '/'animation test
      if (rnd()*100)<90 then
            prota._bodyTorsoPGB.IncrementBoneOrientation(orientationStep/8)
            prota._upperArm1PGB.IncrementBoneOrientation(orientationStep/4)
            prota._upperArm2PGB.IncrementBoneOrientation(orientationStep/4)
            prota._upperLeg1PGB.IncrementBoneOrientation(orientationStep)
            prota._upperLeg2PGB.IncrementBoneOrientation(-orientationStep/2)
            prota._upperLeg2PGB.IncrementBoneOrientation(-orientationStep)
      else
            prota.SyncPgbFacing(_PGBFACING._face)
            orientationStep = - orientationStep
      end if
      '/
      prota.DrawProtagon(stoneBuffer, applicationWindow._imageBuffer, -1)
         p2.DrawProtagon(stoneBuffer, applicationWindow._imageBuffer)
      /'note: only if bones not drawn do ->/prota.RefreshHierarchy()'/
   
      'draw the application
      applicationWindow.DrawMainWindow()
      put (guiPanelLitPosX, guiPanelLitPosY), guiPanelLit, TRANS
      'draw direct to screen
      prota.DrawProtagonSkin()
         p2.DrawProtagonSkin()
      'prota.DrawEffectorBoundingBox()
      
      prota.ShowProtagonInfo()
      'prota.ShowPgbInfoForAll()
      
      put (prota._headPGB.BonePivot._x - 40, prota._headPGB.BonePivot._y + 20), dulHeadImg, TRANS
      
      if isControllerPanelOpen then
         prota._headPGB._isControllerPanelOpen = TRUE
         prota._headPGB._controllers(0).DrawTfControllerOnScreen()
      else
         prota._headPGB._isControllerPanelOpen = FALSE
      end if
   
      '__some informations for debug purpose__
		draw string (150,10), str(panelLitW)
		draw string (10,10), str(isControllerPanelOpen)
		'draw string (10,10), str(applicationWindow._hasMouseOver)
		'draw string (80,10), str(applicationWindow._hasMouseClick)
		'draw string (150,10), str(applicationWindow.ExitMessageTriggered)
		'draw string (230,10), str(scrEvent.type), , starter2
      'draw string (380,10), str(ellapsedTime), , starter
      'draw string (400,10), str(prota._headPGB._faceControlableEffectorBoundingBox._xA), , starter
		'draw string (480,10), str(applicationWindow._imageBufferScreenOffsetXY._x), , starter
		'draw string (580,10), str(applicationWindow._imageBufferScreenOffsetXY._y), , starter
      
      

	screenunlock()
	'
   _SLEEP1MS()
   '
   if ellapsedTime<2 then applicationWindow._escKeyPressed = FALSE   ''for better transition with splashcreen
loop until applicationWindow.ExitMessageTriggered


'-- program ending
sleep 400 : endTime = TIMER
delete stoneBuffer

'(eof)