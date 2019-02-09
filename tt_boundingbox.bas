'tt_boundingbox.bas
'author TT - feel free to reuse 
'for more information please refer to the freebasic.net community forum

#include once  "commondefines.bas"

#macro _2DCROSSPRODUCT(xOrigin, yOrigin, xEnd1, yEnd1, xEnd2, yEnd2)
	( (xEnd1 - xOrigin)*(yEnd2 - yOrigin) - (xEnd2 - xOrigin)*(yEnd1 - yOrigin) )
#endMacro

type BOUNDINGBOX
	declare sub TestMouse()
	declare sub DrawBoundingBox(byval as integer=0)
		as single	_xA
		as single	_yA
		as single	_xB
		as single	_yB
		as single	_xC
		as single	_yC
		as single	_xD
		as single	_yD
	'interaction
		as boolean	_hasMouseOver
		as boolean	_hasMouseClick
end type
sub BOUNDINGBOX.TestMouse()
	dim as integer	gmX, gmY, gmWheel, gmBtn
	var errCode =>	getMouse(gmX, gmY, gmWheel, gmBtn)
	'
	if errCode<>0 then exit sub
	'
	dim as single	TT	=>  aTan2((THIS._yD - THIS._yA),(THIS._xD - THIS._xA))
	dim as single	xx	=> (gmX - THIS._xA)*cos(-TT) - (gmY - THIS._yA)*sin(-TT)
	dim as single	yy	=> (gmX - THIS._xA)*sin(-TT) + (gmY - THIS._yA)*cos(-TT)
	if xx>=0														               andAlso _ 
	   xx<=sqr((THIS._xD - THIS._xA)^2 + (THIS._yD - THIS._yA)^2)	andAlso _ 
	   yy>=0														               andAlso _ 
	   yy<=sqr((THIS._xB - THIS._xA)^2 + (THIS._yB - THIS._yA)^2)	then
		if not THIS._hasMouseOver then THIS._hasMouseOver = TRUE
      '
      if gmBtn>0 then
         if not THIS._hasMouseClick then
            THIS._hasMouseClick = TRUE
         end if
      else
         if THIS._hasMouseClick then
            THIS._hasMouseClick = FALSE
         end if
      end if
	else
		if THIS._hasMouseOver then THIS._hasMouseOver = FALSE
      if THIS._hasMouseClick then THIS._hasMouseClick = FALSE
	end if
end sub
sub BOUNDINGBOX.DrawBoundingBox(byval VisibilityFlag as integer=0)
	THIS.TestMouse()
	'
	with THIS
		if ._hasMouseOver then
         if VisibilityFlag=-1 then
            for t as single = 0 to 1 step .1
               line (._xA + t*(._xB - ._xA), ._yA + t*(._yB - ._yA))- _ 
                   (._xD + t*(._xC - ._xD), ._yD + t*(._yC - ._yD)), _ 
                   rgb(100,100,150), _ 
                    , _ 
                   &b010111010101
            next t
         end if
		end if
      if VisibilityFlag=-1 then
         line (._xA, ._yA)-(._xB, ._yB), rgb(200,100,100), , &b010101010101
         line (._xB, ._yB)-(._xC, ._yC), rgb(200,100,100), , &b010101010101
         line (._xC, ._yC)-(._xD, ._yD), rgb(200,100,100), , &b010101010101
         line (._xD, ._yD)-(._xA, ._yA), rgb(200,100,100), , &b010101010101
      end if
	end with
end sub


type BOXEDSEGMENT
	declare constructor()
	declare constructor(byval X1 as single, _ 
						byval Y1 as single, _
						byval X2 as single, _
						byval Y2 as single)
   declare destructor()
	declare property BoundingBox() as BOUNDINGBOX
	declare sub DrawSegmentAxis()
	declare sub DrawSegmentBoundingBoxAtDistance(byval D as single=-1)
		as single	_x1
		as single	_y1
		as single	_x2
		as single	_y2
		as single	_boundingBoxWidth
end type
constructor BOXEDSEGMENT()
	dim as integer	scrX, scrY
		screenInfo	scrX, scrY
	if screenPtr=0 then
		windowTitle "BoxedSegment is a 32bits color gui object"
		screenRes 0.6*scrX, 0.6*scrY, 32
	end if
	'
	with THIS
		._x1				=>	0.6*scrX\2
		._y1				=>	0.6*scrY\2
		._x2				=>	._x1
		._y2				=>	._y1 + 0.3*scrY\2
		._boundingBoxWidth	=>	25
	end with
end constructor
constructor BOXEDSEGMENT(byval X1 as single, _ 
						 byval Y1 as single, _
						 byval X2 as single, _
						 byval Y2 as single)
	with THIS
		._x1				=>	X1
		._y1				=>	Y1
		._x2				=>	X2
		._y2				=>	Y2
		._boundingBoxWidth	=>	25
	end with
end constructor
destructor BOXEDSEGMENT()
   '
end destructor
property BOXEDSEGMENT.BoundingBox() as ..BOUNDINGBOX
	var D	   => THIS._boundingBoxWidth
	var TT	=>  aTan2((THIS._y2 - THIS._y1),(THIS._x2 - THIS._x1))
	var L	   =>	sqr((THIS._x2 - THIS._x1)^2 + (THIS._y2 - THIS._y1)^2)
	'
	var	xdP	=>	THIS._x1 + (1 + d/L)*(THIS._x2 - THIS._x1)
	var	ydP	=>	THIS._y1 + (1 + d/L)*(THIS._y2 - THIS._y1)
	var	xdM	=>	THIS._x1 - d/L*(THIS._x2 - THIS._x1)
	var	ydM	=>	THIS._y1 - d/L*(THIS._y2 - THIS._y1)
	'
	var	xA =>	 xdP + d*cos(TT + _pi/2)
	var	yA =>	 ydP + d*sin(TT + _pi/2)
	var	xB =>	 xdP - d*cos(TT + _pi/2)
	var	yB =>	 ydP - d*sin(TT + _pi/2)
	var	xC =>	 xdM - d*cos(TT + _pi/2)
	var	yC =>	 ydM - d*sin(TT + _pi/2)
	var	xD =>	 xdM + d*cos(TT + _pi/2)
	var	yD =>	 ydM + d*sin(TT + _pi/2)
	'
	return type<..BOUNDINGBOX>(xA, yA, xB, yB, xC, yC, xD, yD)
end property
sub BOXEDSEGMENT.DrawSegmentAxis()
	line (THIS._x1,THIS._y1)-(THIS._x2,THIS._y2)
end sub
sub BOXEDSEGMENT.DrawSegmentBoundingBoxAtDistance(byval D as single=-1)
	if D=-1 then D = THIS._boundingBoxWidth
	'
	var TT	=>  aTan2((THIS._y2 - THIS._y1),(THIS._x2 - THIS._x1))
	var L	   =>	sqr((THIS._x2 - THIS._x1)^2 + (THIS._y2 - THIS._y1)^2)
	'
	var	xdP	=>	THIS._x1 + (1 + d/L)*(THIS._x2 - THIS._x1)
	var	ydP	=>	THIS._y1 + (1 + d/L)*(THIS._y2 - THIS._y1)
	var	xdM	=>	THIS._x1 - d/L*(THIS._x2 - THIS._x1)
	var	ydM	=>	THIS._y1 - d/L*(THIS._y2 - THIS._y1)
	'
	var	xA =>	 xdP + D*cos(TT + _pi/2)
	var	yA =>	 ydP + D*sin(TT + _pi/2)
	var	xB =>	 xdP - D*cos(TT + _pi/2)
	var	yB =>	 ydP - D*sin(TT + _pi/2)
	var	xC =>	 xdM - D*cos(TT + _pi/2)
	var	yC =>	 ydM - D*sin(TT + _pi/2)
	var	xD =>	 xdM + D*cos(TT + _pi/2)
	var	yD =>	 ydM + D*sin(TT + _pi/2)
	'
	circle (THIS._x1, THIS._y1), D, rgb(100,100,120)
	circle (THIS._x2, THIS._y2), D, rgb(100,100,120)
	circle (xA, yA), 2
	circle (xB, yB), 2
	circle (xC, yC), 2
	circle (xD, yD), 2
	'
	draw string (xA, yA), "A"
	draw string (xB, yB), "B"
	draw string (xC, yC), "C"
	draw string (xD, yD), "D"
	line (xA, yA)-(xB, yB), rgb(200,200,100), , &b101010
	line (xB, yB)-(xC, yC), rgb(200,200,100), , &b101010
	line (xC, yC)-(xD, yD), rgb(200,200,100), , &b101010
	line (xD, yD)-(xA, yA), rgb(200,200,100), , &b101010
end sub




/'usage
dim as BOXEDSEGMENT		bxseg

dim as single	orientationStep	=> .008
dim as single	angle
var keypressed	=> inkey()
do
	'
	angle += orientationStep
	'rotate point 2
	bxseg._x2 = bxseg._x1 + (bxseg._x2 - bxseg._x1)*sin(angle)+ (bxseg._y2 - bxseg._y1)*cos(angle)
	bxseg._y2 = bxseg._y1 + (bxseg._x2 - bxseg._x1)*cos(angle)- (bxseg._y2 - bxseg._y1)*sin(angle)
	screenLock
		cls
		bxseg.DrawSegmentAxis()
		bxseg.DrawSegmentBoundingBoxAtDistance()
		bxseg.BoundingBox.DrawBoundingBox()
	screenUnlock
	'
	keypressed = inkey()
	sleep 15
loop until keypressed=chr(27)
'/

'(eof)