'tt_draggablecircle.bas
'author TT - feel free to reuse   
'for more information please search the freebasic.net community forum

#include once "fbgfx.bi"

#ifnDef WH
#define _WH    WH
#else
#define _WH    WH2
#endIf

#ifnDef XY
#define _XY    XY
#else
#define _XY    XY2
#endIf


type _WH
		as single	_w
		as single	_h
end type
type _XY
		as single	_x
		as single	_y
end type

type DRAGGABLECIRCLE
    declare constructor()
    declare constructor(byval as integer, _ 
                        byval as integer, _ 
                        byval as integer, _ 
                        byval as ulong, _ 
                        byval as string)
    declare destructor()
    declare function AddDraggableCirclePtrToFamily() as integer
    declare sub      TestDraggablePointForMouse()
    declare sub      DrawDraggablePoint()
        as integer  				_x
        as integer  				_y
        as integer  				_radius
        as ulong    				_color
        as string   				_pointName
        as boolean  				_mouseOver
        as boolean  				_mouseClick
        as boolean  				_dragStarted
        as integer  				_xAtDragtime
        as integer  				_yAtDragtime
    'private:
        as integer					   _draggableCircleFamilyMemberIndex
    static as integer				   draggableCirclePtrFamilyMemberCount
    static as DRAGGABLECIRCLE ptr	familyArrayOfDraggableCirclePtr(any)
end type 'DRAGGABLECIRCLE
'static member initialization_
dim as integer	DRAGGABLECIRCLE.draggableCirclePtrFamilyMemberCount	=> -1
dim as DRAGGABLECIRCLE ptr	DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr(any)
'member method implementation_
constructor DRAGGABLECIRCLE()
    dim as integer scrW, scrH, scrD
    if screenPtr()=0 then
        scrW => 200
        scrH => 200
        scrD => 032
        screenRes scrW, scrH, scrD
        windowTitle "opened by DRAGGABLECIRCLE"
    else
        screenInfo scrW, scrH, scrD
    end if
    with THIS
        ._x             => scrW\2
        ._y             => scrH\2
        ._radius        => 4
        ._color         => iif(scrD=8, 14, rgb(200,200,0))
        ._pointName     => "Default"
        ._mouseOver     => FALSE
        ._mouseClick    => FALSE
        ._dragStarted   => FALSE        
    end with 'THIS
    '
	THIS._draggableCircleFamilyMemberIndex => THIS.AddDraggableCirclePtrToFamily()
	'
end constructor 'DRAGGABLECIRCLE default constructor
constructor DRAGGABLECIRCLE(byval X      as integer, _ 
                           byval Y      as integer, _ 
                           byval Radius as integer, _ 
                           byval Colour as ulong, _ 
                           byval PointName as string)
    with THIS
        ._x             => X
        ._y             => Y
        ._radius        => Radius
        ._color         => Colour
        ._pointName     => PointName
        ._mouseOver     => FALSE
        ._mouseClick    => FALSE
        ._dragStarted   => FALSE        
    end with 'THIS
    '
	THIS._draggableCircleFamilyMemberIndex => THIS.AddDraggableCirclePtrToFamily()
	'
end constructor 'DRAGGABLECIRCLE(valINT,valINT,valINT,valULNG,valSTR)
destructor DRAGGABLECIRCLE()
	if THIS._draggableCircleFamilyMemberIndex=-1 then exit destructor
	'
	select case DRAGGABLECIRCLE.draggableCirclePtrFamilyMemberCount
		case is>1
			DRAGGABLECIRCLE.draggableCirclePtrFamilyMemberCount -= 1
			'
			swap DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr( _ 
								DRAGGABLECIRCLE.draggableCirclePtrFamilyMemberCount - 1), _ 
				 DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr( _ 
				 				THIS._draggableCircleFamilyMemberIndex)
			'
			redim preserve DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr( _ 
								uBound(DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr) - 1)
			'
			for index as integer = 0 to uBound(DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr)
				DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr(index)->_draggableCircleFamilyMemberIndex = _ 
																										index
			next index
		case else
			DRAGGABLECIRCLE.draggableCirclePtrFamilyMemberCount = 0
			erase DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr		
	end select 'DRAGGABLECIRCLE.draggableCirclePtrFamilyMemberCount
	'
	THIS._draggableCircleFamilyMemberIndex = -1
end destructor 'DRAGGABLECIRCLE default destructor
function DRAGGABLECIRCLE.AddDraggableCirclePtrToFamily() as integer
	redim preserve DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr( _ 
					uBound(DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr) + 1)
	DRAGGABLECIRCLE.draggableCirclePtrFamilyMemberCount =  _ 
						uBound(DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr) + 1
	DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr( _ 
					uBound(DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr) ) = @THIS
	'---->
	return DRAGGABLECIRCLE.draggableCirclePtrFamilyMemberCount - 1
end function 'INT:=DRAGGABLECIRCLE.AddDraggableCirclePtrToFamily()
sub DRAGGABLECIRCLE.TestDraggablePointForMouse()
	if THIS._draggableCircleFamilyMemberIndex=-1 then exit sub
	'
    dim as integer gmX, gmY, gmBtn1
    getMouse gmX, gmY, , gmBtn1
    '
    if abs(gmX - THIS._x)<=THIS._radius and _
       abs(gmY - THIS._y)<=THIS._radius then
        if not THIS._mouseOver then THIS._mouseOver = TRUE
        if gmBtn1=+1 then
            if not THIS._mouseClick then 
                THIS._mouseClick    = TRUE
                dim as boolean otherFamillyMemberHasDragStarted => FALSE
                for index as integer = 0 to DRAGGABLECIRCLE.draggableCirclePtrFamilyMemberCount - 1
                	if DRAGGABLECIRCLE.familyArrayOfDraggableCirclePtr(index)->_dragStarted then
                		otherFamillyMemberHasDragStarted = TRUE
                		exit for
                	end if
                next index
                if not otherFamillyMemberHasDragStarted then 
                	THIS._dragStarted = TRUE
	                THIS._xAtDragtime   = gmX
	                THIS._yAtDragtime   = gmY                	
                end if
            end if
        else
            if THIS._mouseClick then 
                THIS._mouseClick    = FALSE
                THIS._dragStarted   = FALSE
            end if
        end if
    else
        if THIS._mouseOver then THIS._mouseOver = FALSE
        if THIS._mouseClick and not THIS._dragStarted then 
            THIS._mouseClick    = FALSE
        end if
    end if
end sub 'DRAGGABLECIRCLE.TestDraggablePointForMouse()
sub DRAGGABLECIRCLE.DrawDraggablePoint()
	if THIS._draggableCircleFamilyMemberIndex=-1 then 
		exit sub
	else
		THIS.TestDraggablePointForMouse()
	end if
    '
    circle (THIS._x,THIS._y), (THIS._radius + 1), THIS._color
    draw string (THIS._x - 8 - (THIS._radius + 1), _ 
                 THIS._y - 8 - (THIS._radius + 1)), _ 
                 THIS._pointName, _ 
                 THIS._color 
    '
    if THIS._mouseOver then
        circle (THIS._x,THIS._y), THIS._radius - 1, rgb(0,255,0),,,,f
    end if
    if THIS._mouseClick then
        circle (THIS._x,THIS._y), THIS._radius - 2, rgb(255,0,0),,,,f
    end if
    if THIS._dragStarted then
        dim as integer gmX, gmY, gmBtn1
        getMouse gmX, gmY, , gmBtn1
        if gmX=-1 or gmY=-1 then exit sub
        if ((gmX - THIS._x)^2 + (gmY - THIS._y)^2)>THIS._radius^2 then
            setMouse ( THIS._x + 4*(gmX - THIS._x)/5 ), _ 
                     ( THIS._y + 4*(gmY - THIS._y)/5 )
            'this below lowers a little the mouse speed
            THIS._x = THIS._x + 3*(gmX - THIS._x)/5
            THIS._y = THIS._y + 3*(gmY - THIS._y)/5
        else
            THIS._x = gmX
            THIS._y = gmY
            setMouse gmX, gmY
        end if       
    end if
end sub 'DRAGGABLECIRCLE.DrawDraggablePoint()

type PARTITION
   declare constructor()
   declare destructor()
   'parameter
      as _XY                  _topLeftCorner
      as _WH                  _widthHeight
      as integer              _totalBeatCount
      as integer              _actualBeatCount
      as DRAGGABLECIRCLE ptr  _arrayOfDraggableCirclePtr(any)
   'interaction
      
   
end type












'(eof)