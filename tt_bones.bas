'tt_bones.bas
'author TT - feel free to reuse   
'for more information please search the freebasic.net community forum

'this freebasic file will define a programmable bone 
'with 1 front and 1 back clickable effectors rectangles
'it's made from old stuff gathered, and a new object, the *timeforcecontroller*

#include once  "fbgfx.bi"

#ifnDef XY
type XY
   as single _x
   as single _y
end type
#endIf
#macro _GETMAINCENTEREDANGULARVALUE(Angle, CentralAngleValue, MainCenteredValue)
   scope
      var ma => (Angle)
      if ma>((CentralAngleValue) + _pi) then
         do
            ma -= 2*_pi
         loop until ma<=((CentralAngleValue) + _pi)
      elseIf ma<=((CentralAngleValue) - _pi) then
         do
            ma += 2*_pi
         loop until ma>((CentralAngleValue) - _pi)
      end if
      MainCenteredValue = ma - (CentralAngleValue)
   end scope
#endMacro

#include once  "stonemonkey_triangles.bas"
#include once  "commondefines.bas"
#include once  "commonutilities.bas"

#include once  "tt_boundingbox.bas"

#ifnDef DRAGGABLECIRCLE
type DRAGGABLECIRCLE
    declare constructor()
    declare constructor(byval as integer, _ 
                        byval as integer, _ 
                        byval as integer, _ 
                        byval as ulong, _ 
                        byval as string)
    declare destructor()
    declare function AddDraggableCirclePtrToFamily() as integer
    declare sub TestDraggablePointForMouse()
    declare sub DrawDraggablePoint()
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
        as integer					_draggableCircleFamilyMemberIndex
    static as integer				draggableCirclePtrFamilyMemberCount
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
#endIf

type LENGTH
      as single      _lengthValue
end type
type ANGLEOXY
      as single      _angleValue
end type
type POSITIONXY
      as single      _x
      as single      _y
end type
type ORIENTATION
      as ANGLEOXY      _angleOxy
end type
type BONEPARAMETER
      as integer         _boneHierarchyRank
      as POSITIONXY      _bonePivotPosition
      as LENGTH         _boneLength
      as ORIENTATION      _boneOrientation
end type
type BONEPARENT      as BONE ptr
type BONECHILD       as BONE ptr

type BONE
   'dev.note::adhoc addition to correct a misconception in the project
   'note: there is at least 2 types of offsets to take into account
   'note: relative to screen and relative to buffer
      as XY       _correctiveAdhocOffsetXY
   '
   declare constructor()
   declare destructor()
   declare property BonePivot() as POSITIONXY
   declare property BoneEnd() as POSITIONXY
   declare property BoneLength() as LENGTH
   declare property BoneOrientation() byref as single
   declare property BoneOrientation(byval as single)
   'hierarchy
   declare sub DefineBoneLength(byref L as const LENGTH)
   declare sub AttachBoneToParentBone( byval P as BONEPARENT=0, _
                                       byref XY as POSITIONXY=type<POSITIONXY>(0,0) )
   declare sub RefreshHierarchy()
   declare sub UpdateFixHierarchy()
      as BONEPARENT      _parent
      as BONECHILD       _child(any)
      as BONEPARAMETER   _parameter
   'interaction
   declare function DistanceToTubeFrom overload(byref Xy as const POSITIONXY) as single
   declare function DistanceToTubeFrom(byref X as const single, _
                              byref Y as const single) _
                              as single
   declare sub TestMouse()
      as integer         _detectionScreenDistanceToAxis
      as boolean         _hasMouseOver
      as boolean         _hasMouseOverAxis
      as boolean         _hasMouseOverTube
   'visualization
   declare sub DrawBone(byval as any ptr, byval as any ptr, byval as integer=0 )
   declare sub DrawBoneDetectionTube(byval as any ptr)
      as ulong         _defaultColor
      as ulong         _mouseOverColor
      as ulong         _mouseOverDetectionTubeColor
   'bone stonetriangle
   declare property StoneTriangle() as stonemonkey.STONETRIANGLE ptr
      as stonemonkey.STONEVERTEX    _v0
      as stonemonkey.STONEVERTEX    _v1
      as stonemonkey.STONEVERTEX    _v2
      as uinteger                   _boneBaseHalfLength
end type
constructor BONE()
   if screenPtr=0 then
      dim as integer   deskX, deskY
         screenInfo   deskX, deskY
      windowTitle "Bone is a 32bits color gui object"
      screenRes 0.6*deskX, 0.6*deskY, 32
   end if
   with THIS
      'hierarchy
   end with
   with THIS
      'interaction
      ._detectionScreenDistanceToAxis  => 4
      ._hasMouseOver                   => FALSE
   end with
   with THIS
      'visualization
      ._defaultColor                   => rgb(220,200,140)
      ._mouseOverColor                 => rgb(100,240,240)
      ._mouseOverDetectionTubeColor    => rgb(100,200,240)
   end with
end constructor
destructor BONE()
   if THIS._parent<>0 then
      for index as integer =  lBound(THIS._child) to _
                              uBound(THIS._child)
         THIS._child(index)->_parent = THIS._parent
      next index
   end if
end destructor
property BONE.BonePivot() as POSITIONXY
   return THIS._parameter._bonePivotPosition
end property
property BONE.BoneEnd() as POSITIONXY
   var returnValue   =>   THIS._parameter._bonePivotPosition
   with THIS._parameter
      returnValue._x   +=   cos(._boneOrientation._angleOxy._angleValue)*._boneLength._lengthValue
      returnValue._y   +=   sin(._boneOrientation._angleOxy._angleValue)*._boneLength._lengthValue
   end with
   '
   return returnValue
end property
property BONE.BoneLength() as LENGTH
   return THIS._parameter._boneLength
end property
property BONE.BoneOrientation() byref as single
   return THIS._parameter._boneOrientation._angleOxy._angleValue
end property
property BONE.BoneOrientation(byval SetValue as single)
   THIS._parameter._boneOrientation._angleOxy._angleValue = SetValue
end property
sub BONE.DefineBoneLength(byref L as const LENGTH)
   with THIS
      with ._parameter
         ._boneLength      => L
      end with
   end with
   'refresh child position
   for index as integer =   lBound(THIS._child) to _
                     uBound(THIS._child)
      THIS._child(index)->_parameter._bonePivotPosition = THIS.BoneEnd
   next index
end sub
sub BONE.AttachBoneToParentBone(byval P as BONEPARENT=0, _
                        byref XY as POSITIONXY=type<POSITIONXY>(0,0))
   if P<>0 then
      THIS._parent   => P
      redim preserve P->_child(uBound(P->_child) - lBound(P->_child) + 1)
      P->_child(uBound(P->_child) - lBound(P->_child)) => @THIS
      P->_child(uBound(P->_child) - lBound(P->_child))->_parameter._bonePivotPosition = P->BoneEnd
   end if
end sub
sub BONE.RefreshHierarchy()
   for index as integer =   lBound(THIS._child) to _
                              uBound(THIS._child)
      THIS._child(index)->_parameter._bonePivotPosition = THIS.BoneEnd
   next index
end sub
sub BONE.UpdateFixHierarchy()
   var index   => lBound(THIS._child)
   while index<=uBound(THIS._child)
      if THIS._child(index)=0 then
         swap   THIS._child(index), _
               THIS._child(uBound(THIS._child))
         if (uBound(THIS._child) - lBound(THIS._child))>0 then
            redim preserve THIS._child(uBound(THIS._child) - lBound(THIS._child) - 1)
         else
            erase THIS._child
         end if
      else
         index += 1
      end if
   wend
end sub
function BONE.DistanceToTubeFrom(byref Xy as const POSITIONXY) as single
   var byref angle      => THIS._parameter._boneOrientation._angleOxy._angleValue
   var byref xPivot     => THIS._parameter._bonePivotPosition._x
   var byref yPivot     => THIS._parameter._bonePivotPosition._y
   '
   return _
   abs( Xy._x*sin(angle) - Xy._y*cos(angle) + yPivot*cos(angle) - xPivot*sin(angle) )
end function
function BONE.DistanceToTubeFrom(byref X as const single, _
                                 byref Y as const single) _
                                 as single
   var byref angle   => THIS._parameter._boneOrientation._angleOxy._angleValue
   var byref xPivot  => THIS._parameter._bonePivotPosition._x
   var byref yPivot  => THIS._parameter._bonePivotPosition._y
   '
   return _
   abs( X*sin(angle) - Y*cos(angle) + yPivot*cos(angle) - xPivot*sin(angle) )
end function
sub BONE.TestMouse()
   ''dev.note::detection is broken, drawing detection tube will for now be useless
   dim as integer   gmX, gmY, gmWheel, gmBtn
   var errorCode   => getMouse(gmX, gmY, gmWheel, gmBtn)
   if errorCode<>0 then exit sub
   '
   var byref yPivot   => THIS._parameter._bonePivotPosition._y
   var byref yEnd      => THIS.BoneEnd._y
   var distanceToBoneAxis => THIS.DistanceToTubeFrom(cSng(gmX), cSng(gmY))
   if distanceToBoneAxis<THIS._detectionScreenDistanceToAxis   andAlso _
      gmY>_MIN(yPivot, yEnd)                           andAlso _
      gmY<_MAX(yPivot, yEnd)                           then
      if distanceToBoneAxis<1 then
         if not THIS._hasMouseOverAxis then THIS._hasMouseOverAxis = TRUE
      else
         if THIS._hasMouseOverAxis then THIS._hasMouseOverAxis = FALSE
      end if
      if not THIS._hasMouseOverTube then THIS._hasMouseOverTube = TRUE
      if not THIS._hasMouseOver andAlso _
         (THIS._hasMouseOverAxis orElse THIS._hasMouseOverTube) then
         THIS._hasMouseOver = TRUE
      end if
   else
      if THIS._hasMouseOverAxis then THIS._hasMouseOverAxis = FALSE
      if THIS._hasMouseOverTube then THIS._hasMouseOverTube = FALSE
      if THIS._hasMouseOver then THIS._hasMouseOver = FALSE
   end if
end sub
property BONE.StoneTriangle() as stonemonkey.STONETRIANGLE ptr
   'fill vertex
   ''dev.note::there is an ad-hoc x-offset here --> have to see why (buffer offset?)
   THIS._v0.x   = THIS.BonePivot._x + THIS._correctiveAdhocOffsetXY._x 
   THIS._v0.y   = THIS.BonePivot._y + THIS._correctiveAdhocOffsetXY._y
   dim as single a   => THIS.BoneEnd._x + THIS._correctiveAdhocOffsetXY._x - THIS._v0.x
   dim as single b   => THIS.BoneEnd._y + THIS._correctiveAdhocOffsetXY._y - THIS._v0.y
   dim as single d   => (-b)/sqr(a^2 + b^2)
   dim as single e   => a/sqr(a^2 + b^2)
   THIS._v1.x   = THIS.BoneEnd._x + THIS._correctiveAdhocOffsetXY._x + THIS._boneBaseHalfLength*d
   THIS._v1.y   = THIS.BoneEnd._y + THIS._correctiveAdhocOffsetXY._y + THIS._boneBaseHalfLength*e
   THIS._v2.x   = THIS.BoneEnd._x + THIS._correctiveAdhocOffsetXY._x - THIS._boneBaseHalfLength*d
   THIS._v2.y   = THIS.BoneEnd._y + THIS._correctiveAdhocOffsetXY._y - THIS._boneBaseHalfLength*e
   '
   'make triangle
   dim as stonemonkey.STONETRIANGLE ptr tri= new stonemonkey.STONETRIANGLE
   tri->v0  = @THIS._v0
   tri->v1  = @THIS._v1
   tri->v2  = @THIS._v2
   tri->v0->r=155    : tri->v0->g=155  : tri->v0->b=55
   tri->v1->r=155    : tri->v1->g=155  : tri->v1->b=255
   tri->v2->r=255    : tri->v2->g=255  : tri->v2->b=255
   '
   StoneTriangle = tri
   delete tri
end property
sub BONE.DrawBone(byval StoneBuffer as any ptr, byval DisplayBuffer as any ptr, byval VisibilityStatus as integer=0)
   THIS.TestMouse()
   '
   dim as stonemonkey.STONETRIANGLE ptr smTri => THIS.StoneTriangle
   stonemonkey.Gtriangle(StoneBuffer, DisplayBuffer, smTri, VisibilityStatus)
   '
   line(THIS.BonePivot._x, THIS.BonePivot._y) - _
      (THIS.BoneEnd._x, THIS.BoneEnd._y), _
      THIS._defaultColor
   for index as integer =  lBound(THIS._child) to _
                           uBound(THIS._child)
      THIS._child(index)->DrawBone(StoneBuffer, DisplayBuffer, VisibilityStatus)
   next index
   if THIS._hasMouseOver then
      line(THIS.BonePivot._x, THIS.BonePivot._y) - _
         (THIS.BoneEnd._x, THIS.BoneEnd._y), _
         THIS._mouseOverColor
   end if
   '
end sub
sub BONE.DrawBoneDetectionTube(byval DisplayBuffer as any ptr)
   ''dev.note::detection is broken, drawing detection tube will for now be useless
   THIS.TestMouse()
   '
   var angle   => THIS._parameter._boneOrientation._angleOxy._angleValue + 2*aTn(1)
   if THIS._hasMouseOverTube then
      for u as integer =   -THIS._detectionScreenDistanceToAxis to _
                           +THIS._detectionScreenDistanceToAxis step 4
         line  DisplayBuffer, _ 
               (THIS.BonePivot._x + u*cos(angle), THIS.BonePivot._y + u*sin(angle)) - _
               (THIS.BoneEnd._x + u*cos(angle), THIS.BoneEnd._y + u*sin(angle)), _
               THIS._mouseOverDetectionTubeColor, , _ 
               &b0001000100010001
      next u
   else
      for u as integer =   -THIS._detectionScreenDistanceToAxis to _
                           +THIS._detectionScreenDistanceToAxis step 2
         line  DisplayBuffer, _
               (THIS.BonePivot._x + u*cos(angle), THIS.BonePivot._y + u*sin(angle)) - _
               (THIS.BoneEnd._x + u*cos(angle), THIS.BoneEnd._y + u*sin(angle)), _
               0
      next u
   end if
   if THIS._hasMouseOverAxis then
      line  DisplayBuffer, _
            (THIS.BonePivot._x, THIS.BonePivot._y) - _
            (THIS.BoneEnd._x, THIS.BoneEnd._y), _
            THIS._mouseOverColor
   else
      line  DisplayBuffer, _
            (THIS.BonePivot._x, THIS.BonePivot._y) - _
            (THIS.BoneEnd._x, THIS.BoneEnd._y), _
            THIS._defaultColor*100
   end if
end sub


type TEMPORALFORCECONTROLLER
   declare constructor()
   declare destructor()
   declare function AddControlPoint() as integer
   declare sub TestMouseOnScreen()
   declare sub TestMouse()
   declare sub DrawTfControllerOnScreen()
   declare sub DrawTfController(byval as any ptr)
      as string               _tfcId
      as boolean              _isEditorPanelOpen
      as XY                   _displayBufferOffsetXy
      '
      as XY                   _topLeftCornerDefaultAppScreenPosition
      as WH                   _widthHeight
      '
      as boolean              _hasMouseOver
      as boolean              _hasMouseBtn1Click
      as boolean              _hasMouseBtn2Click
      as boolean              _hasMouseWheel
      as fb.IMAGE ptr         _tfcContentBuffer
      as fb.IMAGE ptr         _tfcImageBuffer
      as integer              _totalCycleCount
      as integer              _controlPointCount
      as DRAGGABLECIRCLE ptr  _arrayOfDraggableCirclePointers(any)
      as single               _correspondingArrayOfForceValue(any)
end type
type TFC    as TEMPORALFORCECONTROLLER
constructor TFC()
   dim as integer scrW     => any
   dim as integer scrH     => any
   screenInfo  scrW, scrH
   '
   with THIS
      ._tfcId              => "noId"
      ._isEditorPanelOpen  => FALSE
      ._topLeftCornerDefaultAppScreenPosition._x   => scrW\6
      ._topLeftCornerDefaultAppScreenPosition._y   => scrH - scrH\3 - 14
      ._widthHeight._w                             => scrW - scrW\6
      ._widthHeight._h                             => scrH - scrH\24
   end with
         THIS._tfcContentBuffer => imageCreate (abs(THIS._widthHeight._w - THIS._topLeftCornerDefaultAppScreenPosition._x), _ 
                                                abs(THIS._widthHeight._h - THIS._topLeftCornerDefaultAppScreenPosition._y), _ 
                                                rgb(255,10,255), _ 
                                                32)
         THIS._tfcImageBuffer => imageCreate (  abs(THIS._widthHeight._w - THIS._topLeftCornerDefaultAppScreenPosition._x), _ 
                                                abs(THIS._widthHeight._h - THIS._topLeftCornerDefaultAppScreenPosition._y), _ 
                                                rgb(255,0,255), _ 
                                                32)
end constructor
destructor TFC()
   'imageDestroy THIS._tfcImageBuffer
   'imageDestroy THIS._tfcContentBuffer
end destructor
sub TFC.TestMouseOnScreen()
   '
   '
end sub
sub TFC.TestMouse()
   '
end sub
sub TFC.DrawTfControllerOnScreen()
   THIS.TestMouseOnScreen()
   '
   var byref   tlcX  => THIS._topLeftCornerDefaultAppScreenPosition._x
   var byref   tlcY  => THIS._topLeftCornerDefaultAppScreenPosition._y
   var byref   wid   => THIS._widthHeight._w 
   var byref   hei   => THIS._widthHeight._h
   line (tlcX, tlcY)-(wid, hei), rgb(100,250,250), bf
   line (tlcX, tlcY + 14)-(wid, hei), rgb(100,100,200), bf
   '
   put THIS._tfcImageBuffer, (1, 20), THIS._tfcContentBuffer, PSET
   put (tlcX, tlcY), THIS._tfcImageBuffer, XOR
end sub
sub TFC.DrawTfController(byval DisplayBuffer as any ptr)
   '
end sub



enum _PGBFACING
   _undecided
   _up
   _down
   _face
   _back
   _left
   _right
end enum
type PROGRAMMABLEBONE extends BONE
   declare constructor()
   declare constructor(byref as XY)
   declare destructor()
   declare sub StoreCurrentOrientationAsParentRelativeRestAngle()
   declare property ParentRelativeAngle() as single
   declare property FparentRelativeAngle() as single
   declare property BparentRelativeAngle() as single
   declare property CanFacingSwitchFforB() as boolean
   declare property CanFacingSwitchBforF() as boolean
   declare function SwitchBFfacing() as boolean
   declare property FaceEffector() as BOUNDINGBOX  'resistor
   declare property BackEffector() as BOUNDINGBOX  'rotator
   declare sub IncrementBoneOrientation(byval as single)
   declare sub RefreshEffectors()
      as string         _pgbName
      as XY             _displayBufferScreenOffsetXY   
      as BOUNDINGBOX    _faceControlableEffectorBoundingBox
      as BOUNDINGBOX    _backControlableEffectorBoundingBox
      as .._PGBFACING   _pgbFacing        
      as single         _faceEffectorIntensity
      as single         _backEffectorIntensity
      as single         _faceEffectorMaximumIntensity
      as single         _backEffectorMaximumIntensity
   declare sub TestMouse()
   declare sub DrawProgrammableBone(byval DisplayBuffer as any ptr)
      as boolean        _isControllerPanelOpen
   declare sub DrawController(byval as any ptr)
      as TFC            _controllers(any)
   '
      as single         _restAngleRelativeToParentBoneOrientation
      as single         _angleRelativeToParentBoneOrientation
      as single         _facewiseAngleRelativeToParentBoneOrientation
      as single         _backwiseAngleRelativeToParentBoneOrientation
      as single         _maximumFacewiseAngleRelativeToParentBoneOrientation 'it will be a delta
      as single         _maximumBackwiseAngleRelativeToParentBoneOrientation 'it will be a delta
end type
type PGB as PROGRAMMABLEBONE
constructor PGB()
   BASE()
   '
   THIS._facewiseAngleRelativeToParentBoneOrientation       => 1
   THIS._backwiseAngleRelativeToParentBoneOrientation       => 1
   THIS._faceEffectorIntensity                              => 0
   THIS._backEffectorIntensity                              => 0
   THIS._faceEffectorMaximumIntensity                       => 1
   THIS._backEffectorMaximumIntensity                       => 1
   '
   THIS._faceControlableEffectorBoundingBox._hasMouseOver   => FALSE
   THIS._backControlableEffectorBoundingBox._hasMouseOver   => FALSE
   THIS._faceControlableEffectorBoundingBox._hasMouseClick  => FALSE
   THIS._backControlableEffectorBoundingBox._hasMouseClick  => FALSE
   THIS._isControllerPanelOpen                              => FALSE
   '
   redim THIS._controllers(0)
end constructor
constructor PGB(byref DisplayBufferScreenOffsetXY as XY)
   BASE()
   '
   THIS._displayBufferScreenOffsetXY = DisplayBufferScreenOffsetXY
   '
   THIS._facewiseAngleRelativeToParentBoneOrientation       => 1
   THIS._backwiseAngleRelativeToParentBoneOrientation       => 1
   THIS._faceEffectorIntensity                              => 0
   THIS._backEffectorIntensity                              => 0
   THIS._faceEffectorMaximumIntensity                       => 1
   THIS._backEffectorMaximumIntensity                       => 1
   '
   THIS._faceControlableEffectorBoundingBox._hasMouseOver   => FALSE
   THIS._backControlableEffectorBoundingBox._hasMouseOver   => FALSE
   THIS._faceControlableEffectorBoundingBox._hasMouseClick  => FALSE
   THIS._backControlableEffectorBoundingBox._hasMouseClick  => FALSE
   THIS._isControllerPanelOpen                              => FALSE
   '
   redim THIS._controllers(0)
end constructor
destructor PGB()
   '
   erase THIS._controllers
   BASE.Destructor()
end destructor  
sub PGB.StoreCurrentOrientationAsParentRelativeRestAngle()
   THIS._restAngleRelativeToParentBoneOrientation = THIS.BoneOrientation
end sub
property PGB.ParentRelativeAngle() as single
   ''dev.note::something goes wrong when using this definition... no time to investigate..
   dim as single  pra  => any
   if THIS._parent<>0 then
      _GETMAINCENTEREDANGULARVALUE( (THIS._parent->BoneOrientation - THIS.BoneOrientation), _ 
                                    THIS._restAngleRelativeToParentBoneOrientation, _ 
                                    pra  )
   else
      _GETMAINCENTEREDANGULARVALUE( (THIS._restAngleRelativeToParentBoneOrientation - THIS.BoneOrientation), _ 
                                    THIS._restAngleRelativeToParentBoneOrientation, _ 
                                    pra  )
   end if
   return pra
end property
property PGB.FparentRelativeAngle() as single
   if THIS.ParentRelativeAngle>=0 then
      return +THIS.ParentRelativeAngle
   else
      return -THIS.ParentRelativeAngle
   end if
end property
property PGB.BparentRelativeAngle() as single
   if THIS.ParentRelativeAngle<0 then
      return -THIS.ParentRelativeAngle
   else
      return +THIS.ParentRelativeAngle
   end if
end property
property PGB.CanFacingSwitchFforB() as boolean
   if THIS.BparentRelativeAngle<=THIS._maximumFacewiseAngleRelativeToParentBoneOrientation then
      return TRUE
   else
      return FALSE
   end if
end property
property PGB.CanFacingSwitchBforF() as boolean
   if THIS.FparentRelativeAngle<=THIS._maximumBackwiseAngleRelativeToParentBoneOrientation then
      return TRUE
   else
      return FALSE
   end if
end property
function PGB.SwitchBFfacing() as boolean
   dim as boolean switchResult   => FALSE
   select case THIS._pgbFacing
      case .._PGBFACING._face
         if THIS.CanFacingSwitchFforB then
            THIS._pgbFacing   = .._PGBFACING._back
            switchResult      = TRUE
         end if
      case .._PGBFACING._back
         if THIS.CanFacingSwitchBforF then
            THIS._pgbFacing   = .._PGBFACING._face
            switchResult      = TRUE
         end if
      case else
         '
   end select
   return switchResult
end function
property PGB.FaceEffector() as BOUNDINGBOX
   dim as single a   => THIS.BoneEnd._x - THIS._v0.x
   dim as single b   => THIS.BoneEnd._y - THIS._v0.y
   dim as single d   => (-b)/sqr(a^2 + b^2)
   dim as single e   => a/sqr(a^2 + b^2)
   select case THIS._pgbFacing
      case .._PGBFACING._back
         THIS._faceControlableEffectorBoundingBox._xB = THIS.BonePivot._x - THIS._displayBufferScreenOffsetXY._x
         THIS._faceControlableEffectorBoundingBox._yB = THIS.BonePivot._y + THIS._displayBufferScreenOffsetXY._y
         THIS._faceControlableEffectorBoundingBox._xA = THIS.BonePivot._x - (THIS._boneBaseHalfLength + 1)*d - THIS._displayBufferScreenOffsetXY._x
         THIS._faceControlableEffectorBoundingBox._yA = THIS.BonePivot._y - (THIS._boneBaseHalfLength + 1)*e + THIS._displayBufferScreenOffsetXY._y
         THIS._faceControlableEffectorBoundingBox._xD = THIS.BoneEnd._x - (THIS._boneBaseHalfLength + 1)*d - THIS._displayBufferScreenOffsetXY._x
         THIS._faceControlableEffectorBoundingBox._yD = THIS.BoneEnd._y - (THIS._boneBaseHalfLength + 1)*e + THIS._displayBufferScreenOffsetXY._y
         THIS._faceControlableEffectorBoundingBox._xC = THIS.BoneEnd._x - THIS._displayBufferScreenOffsetXY._x
         THIS._faceControlableEffectorBoundingBox._yC = THIS.BoneEnd._y + THIS._displayBufferScreenOffsetXY._y
      case .._PGBFACING._face
         THIS._faceControlableEffectorBoundingBox._xA = THIS.BonePivot._x - THIS._displayBufferScreenOffsetXY._x
         THIS._faceControlableEffectorBoundingBox._yA = THIS.BonePivot._y + THIS._displayBufferScreenOffsetXY._y
         THIS._faceControlableEffectorBoundingBox._xB = THIS.BonePivot._x + (THIS._boneBaseHalfLength + 1)*d - THIS._displayBufferScreenOffsetXY._x
         THIS._faceControlableEffectorBoundingBox._yB = THIS.BonePivot._y + (THIS._boneBaseHalfLength + 1)*e + THIS._displayBufferScreenOffsetXY._y
         THIS._faceControlableEffectorBoundingBox._xC = THIS.BoneEnd._x + (THIS._boneBaseHalfLength + 1)*d - THIS._displayBufferScreenOffsetXY._x
         THIS._faceControlableEffectorBoundingBox._yC = THIS.BoneEnd._y + (THIS._boneBaseHalfLength + 1)*e + THIS._displayBufferScreenOffsetXY._y
         THIS._faceControlableEffectorBoundingBox._xD = THIS.BoneEnd._x - THIS._displayBufferScreenOffsetXY._x
         THIS._faceControlableEffectorBoundingBox._yD = THIS.BoneEnd._y + THIS._displayBufferScreenOffsetXY._y
   end select
   '
   return THIS._faceControlableEffectorBoundingBox
end property
property PGB.BackEffector() as BOUNDINGBOX
   dim as single a   => THIS.BoneEnd._x - THIS._v0.x
   dim as single b   => THIS.BoneEnd._y - THIS._v0.y
   dim as single d   => (-b)/sqr(a^2 + b^2)
   dim as single e   => a/sqr(a^2 + b^2)
   THIS._backControlableEffectorBoundingBox._xA = THIS.BonePivot._x - THIS._displayBufferScreenOffsetXY._x
   THIS._backControlableEffectorBoundingBox._yA = THIS.BonePivot._y + THIS._displayBufferScreenOffsetXY._y
   THIS._backControlableEffectorBoundingBox._xB = THIS.BonePivot._x + (THIS._boneBaseHalfLength + 1)*d - THIS._displayBufferScreenOffsetXY._x
   THIS._backControlableEffectorBoundingBox._yB = THIS.BonePivot._y + (THIS._boneBaseHalfLength + 1)*e + THIS._displayBufferScreenOffsetXY._y
   THIS._backControlableEffectorBoundingBox._xC = THIS.BoneEnd._x + (THIS._boneBaseHalfLength + 1)*d - THIS._displayBufferScreenOffsetXY._x
   THIS._backControlableEffectorBoundingBox._yC = THIS.BoneEnd._y + (THIS._boneBaseHalfLength + 1)*e + THIS._displayBufferScreenOffsetXY._y
   THIS._backControlableEffectorBoundingBox._xD = THIS.BoneEnd._x - THIS._displayBufferScreenOffsetXY._x
   THIS._backControlableEffectorBoundingBox._yD = THIS.BoneEnd._y + THIS._displayBufferScreenOffsetXY._y
   '
   return THIS._backControlableEffectorBoundingBox
end property
sub PGB.IncrementBoneOrientation(byval AngleIncrement as single)
   (THIS.BoneOrientation) += AngleIncrement
   select case THIS._pgbFacing
      case .._PGBFACING._face
         if AngleIncrement>=0 then
            goto facewardbranchLbl
         else
            goto backwardbranchLbl
         end if
      case .._PGBFACING._back
         if AngleIncrement<0 then
            goto facewardbranchLbl
         else
            goto backwardbranchLbl
         end if
      case else
         '
   end select
   exit sub
   '
   facewardbranchLbl:     
      dim as single  mainFpra => any
      _GETMAINCENTEREDANGULARVALUE(THIS.BoneOrientation, THIS._restAngleRelativeToParentBoneOrientation, mainFpra)
      if abs(mainFpra)>THIS._maximumFacewiseAngleRelativeToParentBoneOrientation then
         (THIS.BoneOrientation) -= AngleIncrement
      end if
      for index as integer = lBound(THIS._child) to uBound(THIS._child)
         if left(cast(PGB ptr, THIS._child(index))->_pgbName, 8) = "lowerarm" then
            cast(PGB ptr, THIS._child(index))->IncrementBoneOrientation(8*AngleIncrement)
         end if
         if left(cast(PGB ptr, THIS._child(index))->_pgbName, 4) = "hand" then
            cast(PGB ptr, THIS._child(index))->IncrementBoneOrientation(1.2*AngleIncrement)
         end if
         '
         cast(PGB ptr, THIS._child(index))->IncrementBoneOrientation(AngleIncrement)
      next index
      exit sub
   backwardbranchLbl:
      dim as single  mainBpra => any
      _GETMAINCENTEREDANGULARVALUE(THIS.BoneOrientation, THIS._restAngleRelativeToParentBoneOrientation, mainBpra)
      if abs(mainBpra)>THIS._maximumBackwiseAngleRelativeToParentBoneOrientation then
         (THIS.BoneOrientation) -= AngleIncrement
      end if
      exit sub
end sub
sub PGB.RefreshEffectors()
   '
end sub


type PROTAGON
   declare constructor()
   declare destructor()
   declare sub ApplyOffsetXy(byref as XY,  byref as POSITIONXY)
   declare sub RefreshHierarchy()
   declare sub SyncPgbFacing(byref as const _PGBFACING)
   declare sub DrawProtagon(byval as any ptr, byval as any ptr=0, byval as integer=0)
   declare sub DrawProtagonSkin()
   declare sub DrawEffectorBoundingBox(byval as integer=0)
   declare sub ShowPgbInfo(byval as PGB ptr)
   declare sub ShowPgbInfoForAll()
   declare sub ShowProtagonInfo()
      as string   _protagonName
      as single   _scaleFactor
      as PGB      _headPGB
      as PGB      _shoulder1PGB     :  as PGB      _shoulder2PGB     :  as PGB      _hand1PGB
      as PGB      _hand2PGB         :  as PGB      _bodyTorsoPGB     :  as PGB      _bodyStomachPGB
      as PGB      _hankle1PGB       :  as PGB      _hankle2PGB       :  as PGB      _upperArm1PGB
      as PGB      _upperArm2PGB     :  as PGB      _lowerArm1PGB     :  as PGB      _lowerArm2PGB
      as PGB      _upperLeg1PGB     :  as PGB      _upperLeg2PGB     :  as PGB      _lowerLeg1PGB
      as PGB      _lowerLeg2PGB     :  as PGB      _foot1PGB         :  as PGB      _foot2PGB
      as PGB ptr  _arrayOfPgbPointers(any)
end type
constructor PROTAGON()
   redim THIS._arrayOfPgbPointers(18)
   with THIS
      ._protagonName       => "dul"
      ._scaleFactor        => 1
      .ApplyOffsetXy(type(0,0), type(400, 180))
   end with
   THIS._headPGB._isControllerPanelOpen = FALSE
end constructor
destructor PROTAGON()
   erase THIS._arrayOfPgbPointers
end destructor
sub PROTAGON.ApplyOffsetXy(byref DisplayBufferOffsetXY as XY, byref Position as POSITIONXY)
   'dev.note::it turned out to be where the object is initialized
   with THIS
      'head
      ._headPGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(0) => @THIS._headPGB
      with ._headPGB
         ._pgbName                        => "head"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''dev.note::will be useless it seems..
         ._parameter._bonePivotPosition   => Position
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(20*THIS._scaleFactor))
         ._boneBaseHalfLength             => 10*THIS._scaleFactor
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 1
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 1
      end with
      'torso
      ._bodyTorsoPGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(1) => @THIS._bodyTorsoPGB
      with ._bodyTorsoPGB
         ._pgbName                        => "torso"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''dev.note::will be useless all around
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(30*THIS._scaleFactor))
         ._boneBaseHalfLength             => 10*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._headPGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 3
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 2
      end with
      'shoulder1
      ._shoulder1PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(2) => @THIS._shoulder1PGB
      with ._shoulder1PGB
         ._pgbName                        => "shoulder1"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => 0
         .DefineBoneLength(type(24*THIS._scaleFactor))
         ._boneBaseHalfLength             => 5*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._headPGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 1
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 1
      end with
      'shoulder2
      ._shoulder2PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(3) => @THIS._shoulder2PGB
      with ._shoulder2PGB
         ._pgbName                        => "shoulder2"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi
         .DefineBoneLength(type(24*THIS._scaleFactor))
         ._boneBaseHalfLength             => 5*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._headPGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 1
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 1
      end with
      'upperarm1
      ._upperArm1PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(4) => @THIS._upperArm1PGB
      with ._upperArm1PGB
         ._pgbName                        => "upperarm1"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2 - .2
         .DefineBoneLength(type(34*THIS._scaleFactor))
         ._boneBaseHalfLength             => 4*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._shoulder1PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 3
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 1
      end with
      'upperarm2
      ._upperArm2PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(5) => @THIS._upperArm2PGB
      with ._upperArm2PGB
         ._pgbName                        => "upperarm2"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2 + .2
         .DefineBoneLength(type(34*THIS._scaleFactor))
         ._boneBaseHalfLength             => 4*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._shoulder2PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 3
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 1
      end with
      'lowerarm1
      ._lowerArm1PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(6) => @THIS._lowerArm1PGB
      with ._lowerArm1PGB
         ._pgbName                        => "lowerarm1"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(28*THIS._scaleFactor))
         ._boneBaseHalfLength             => 3*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._upperArm1PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 3
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 3
      end with
      'lowerarm2
      ._lowerArm2PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(7) => @THIS._lowerArm2PGB
      with ._lowerArm2PGB
         ._pgbName                        => "lowerarm2"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(28*THIS._scaleFactor))
         ._boneBaseHalfLength             => 3*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._upperArm2PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 3
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 3
      end with
      'hand1
      ._hand1PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(8) => @THIS._hand1PGB
      with ._hand1PGB
         ._pgbName                        => "hand1"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(10*THIS._scaleFactor))
         ._boneBaseHalfLength             => 5*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._lowerArm1PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 3
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 2
      end with
      'hand2
      ._hand2PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(9) => @THIS._hand2PGB
      with ._hand2PGB
         ._pgbName                        => "hand2"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(10*THIS._scaleFactor))
         ._boneBaseHalfLength             => 5*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._lowerArm2PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 3
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 2
      end with
      'stomach
      ._bodyStomachPGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(10) => @THIS._bodyStomachPGB
      with ._bodyStomachPGB
         ._pgbName                        => "stomach"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(34*THIS._scaleFactor))
         ._boneBaseHalfLength             => 8*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._bodyTorsoPGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 3
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 3
      end with
      'hankle1
      ._hankle1PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(11) => @THIS._hankle1PGB
      with ._hankle1PGB
         ._pgbName                        => "hankle1"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => 0
         .DefineBoneLength(type(12*THIS._scaleFactor))
         ._boneBaseHalfLength             => 3*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._bodyStomachPGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 1
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 1
      end with
      'hankle2
      ._hankle2PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(12) => @THIS._hankle2PGB
      with ._hankle2PGB
         ._pgbName                        => "hankle2"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi
         .DefineBoneLength(type(12*THIS._scaleFactor))
         ._boneBaseHalfLength             => 3*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._bodyStomachPGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 1
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 1
      end with
      'upperleg1
      ._upperLeg1PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(13) => @THIS._upperLeg1PGB
      with ._upperLeg1PGB
         ._pgbName                        => "upperleg1"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(44*THIS._scaleFactor))
         ._boneBaseHalfLength             => 6*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._hankle1PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 2
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 2
      end with
      'upperleg2
      ._upperLeg2PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(14) => @THIS._upperLeg2PGB
      with ._upperLeg2PGB
         ._pgbName                        => "upperleg2"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(44*THIS._scaleFactor))
         ._boneBaseHalfLength             => 6*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._hankle2PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 2
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 2
      end with
      'lowerleg1
      ._lowerLeg1PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(15) => @THIS._lowerLeg1PGB
      with _lowerLeg1PGB
         ._pgbName                        => "lowerleg1"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(38*THIS._scaleFactor))
         ._boneBaseHalfLength             => 4*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._upperLeg1PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 0
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 3
      end with
      'lowerleg2
      ._lowerLeg2PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(16) => @THIS._lowerLeg2PGB
      with _lowerLeg2PGB
         ._pgbName                        => "lowerleg2"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2
         .DefineBoneLength(type(38*THIS._scaleFactor))
         ._boneBaseHalfLength             => 4*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._upperLeg2PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 0
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 3
      end with
      'foot1
      ._foot1PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(17) => @THIS._foot1PGB
      with _foot1PGB
         ._pgbName                        => "foot1"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2 - .2
         .DefineBoneLength(type(14*THIS._scaleFactor))
         ._boneBaseHalfLength             => 4*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._lowerLeg1PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 2
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 1
      end with
      'foot2
      ._foot2PGB   = PGB(DisplayBufferOffsetXY)
      ._arrayOfPgbPointers(18) => @THIS._foot2PGB
      with _foot2PGB
         ._pgbName                        => "foot2"
         ._pgbFacing                      => _PGBFACING._back
         ._detectionScreenDistanceToAxis  => 8  ''
         ._parameter._bonePivotPosition   => type(0, 0)
         .BoneOrientation                 => _pi/2 + .2
         .DefineBoneLength(type(14*THIS._scaleFactor))
         ._boneBaseHalfLength             => 4*THIS._scaleFactor
         .AttachBoneToParentBone(@THIS._lowerLeg2PGB)
         .StoreCurrentOrientationAsParentRelativeRestAngle()
         ._maximumFacewiseAngleRelativeToParentBoneOrientation => 2
         ._maximumBackwiseAngleRelativeToParentBoneOrientation => 1
      end with
   end with
end sub
sub PROTAGON.RefreshHierarchy()
   for index as integer = lBound(THIS._arrayOfPgbPointers) to uBound(THIS._arrayOfPgbPointers)
      if not THIS._arrayOfPgbPointers(index)=0 then
         THIS._arrayOfPgbPointers(index)->RefreshHierarchy()
      end if
   next index
end sub
sub PROTAGON.SyncPgbFacing(byref Facing as const _PGBFACING)
   for index as integer = lBound(THIS._arrayOfPgbPointers) to uBound(THIS._arrayOfPgbPointers)
      if not THIS._arrayOfPgbPointers(index)=0 then
         THIS._arrayOfPgbPointers(index)->_pgbFacing  = Facing
      end if
   next index
end sub
sub PROTAGON.DrawProtagon(byval StoneBuffer as any ptr, byval DisplayBuffer as any ptr=0, byval VisibilityStatus as integer=0)
   static as single timeLapse
   '
   THIS.RefreshHierarchy()
   '
   if (TIMER - timeLapse)>.2 then
      for index as integer = lBound(THIS._arrayOfPgbPointers) to uBound(THIS._arrayOfPgbPointers)
         if not THIS._arrayOfPgbPointers(index)=0 then
            THIS._arrayOfPgbPointers(index)->_faceControlableEffectorBoundingBox.TestMouse()
            if THIS._arrayOfPgbPointers(index)->_faceControlableEffectorBoundingBox._hasMouseClick then
               THIS._headPGB._isControllerPanelOpen = not THIS._headPGB._isControllerPanelOpen
               exit for
            end if
            THIS._arrayOfPgbPointers(index)->_backControlableEffectorBoundingBox.TestMouse()
            if THIS._arrayOfPgbPointers(index)->_backControlableEffectorBoundingBox._hasMouseClick then
               THIS._headPGB._isControllerPanelOpen = not THIS._headPGB._isControllerPanelOpen
               exit for
            end if
         end if
      next index
      timeLapse = TIMER
   end if
   '
   'dev.note::don't see what to do with the below commented block... not necessary stuff anyway to run this project
   /'
      if DisplayBuffer=0 then
      if screenPtr()=0 then
         ? "no graphics surface found to DRAWPROTAGON"
         exit sub
      else
         with THIS
            ._headPGB.DrawBone(StoneBuffer, screenPtr())
            ._bodyTorseBone.DrawBone(StoneBuffer, screenPtr())
            ._bodyStomachBone.DrawBone(StoneBuffer, screenPtr())
            ._bodyUpperArm1.DrawBone(StoneBuffer, screenPtr())
            ._bodyUpperArm2.DrawBone(StoneBuffer, screenPtr())
            ._bodyLowerArm1.DrawBone(StoneBuffer, screenPtr())
            ._bodyLowerArm2.DrawBone(StoneBuffer, screenPtr())
            ._bodyUpperLeg1.DrawBone(StoneBuffer, screenPtr())
            ._bodyUpperLeg2.DrawBone(StoneBuffer, screenPtr())
            ._bodyLowerLeg1.DrawBone(StoneBuffer, screenPtr())
            ._bodyLowerLeg2.DrawBone(StoneBuffer, screenPtr())
            ._bodyFoot1.DrawBone(StoneBuffer, screenPtr())
            ._bodyFoot2.DrawBone(StoneBuffer, screenPtr())
         end with
      end if
      end if
   '/
   'dev.note::to draw the head will suffice to draw all the childs
   with THIS
      ._headPGB.DrawBone(StoneBuffer, DisplayBuffer, VisibilityStatus)
   end with
end sub
sub PROTAGON.DrawProtagonSkin()   
   redim as POSITIONXY arrayOfBoneEndJoints(5)
   arrayOfBoneEndJoints(0) = THIS._headPGB.BoneEnd
   arrayOfBoneEndJoints(1) = THIS._shoulder1PGB.BoneEnd
   arrayOfBoneEndJoints(2) = THIS._upperArm1PGB.BoneEnd
   arrayOfBoneEndJoints(3) = THIS._lowerArm1PGB.BoneEnd
   arrayOfBoneEndJoints(4) = THIS._hand1PGB.BoneEnd   
   for tParam as single = 0 to 1 step .001
      DrawBezierCurve(arrayOfBoneEndJoints(), tParam, THIS._headPGB._displayBufferScreenOffsetXY, THIS._scaleFactor)
   next tParam
   '
   redim as POSITIONXY arrayOfBoneEndJoints(5)
   arrayOfBoneEndJoints(0) = THIS._headPGB.BoneEnd
   arrayOfBoneEndJoints(1) = THIS._shoulder2PGB.BoneEnd
   arrayOfBoneEndJoints(2) = THIS._upperArm2PGB.BoneEnd
   arrayOfBoneEndJoints(3) = THIS._lowerArm2PGB.BoneEnd
   arrayOfBoneEndJoints(4) = THIS._hand2PGB.BoneEnd   
   for tParam as single = 0 to 1 step .001
      DrawBezierCurve(arrayOfBoneEndJoints(), tParam, THIS._headPGB._displayBufferScreenOffsetXY, THIS._scaleFactor)
   next tParam
   '
   redim as POSITIONXY arrayOfBoneEndJoints(5)
   arrayOfBoneEndJoints(0) = THIS._bodyStomachPGB.BoneEnd
   arrayOfBoneEndJoints(1) = THIS._hankle1PGB.BoneEnd
   arrayOfBoneEndJoints(2) = THIS._upperLeg1PGB.BoneEnd
   arrayOfBoneEndJoints(3) = THIS._lowerLeg1PGB.BoneEnd
   arrayOfBoneEndJoints(4) = THIS._foot1PGB.BoneEnd   
   for tParam as single = 0 to 1 step .001
      DrawBezierCurve(arrayOfBoneEndJoints(), tParam, THIS._headPGB._displayBufferScreenOffsetXY, THIS._scaleFactor)
   next tParam
   '
   redim as POSITIONXY arrayOfBoneEndJoints(5)
   arrayOfBoneEndJoints(0) = THIS._bodyStomachPGB.BoneEnd
   arrayOfBoneEndJoints(1) = THIS._hankle2PGB.BoneEnd
   arrayOfBoneEndJoints(2) = THIS._upperLeg2PGB.BoneEnd
   arrayOfBoneEndJoints(3) = THIS._lowerLeg2PGB.BoneEnd
   arrayOfBoneEndJoints(4) = THIS._foot2PGB.BoneEnd   
   for tParam as single = 0 to 1 step .001
      DrawBezierCurve(arrayOfBoneEndJoints(), tParam, THIS._headPGB._displayBufferScreenOffsetXY, THIS._scaleFactor)
   next tParam
   '
   redim as POSITIONXY arrayOfBoneEndJoints(5)
   arrayOfBoneEndJoints(0) = THIS._headPGB.BonePivot
   arrayOfBoneEndJoints(1) = THIS._shoulder1PGB.BonePivot
   arrayOfBoneEndJoints(2) = THIS._headPGB.BoneEnd
   arrayOfBoneEndJoints(3) = THIS._bodyTorsoPGB.BoneEnd
   arrayOfBoneEndJoints(4) = THIS._bodyStomachPGB.BoneEnd
   for tParam as single = 0 to 1 step .011
      DrawBezierCurve(arrayOfBoneEndJoints(), tParam, THIS._headPGB._displayBufferScreenOffsetXY, THIS._scaleFactor)
   next tParam
   '
   redim as POSITIONXY arrayOfBoneEndJoints(5)
   arrayOfBoneEndJoints(0) = THIS._headPGB.BonePivot
   arrayOfBoneEndJoints(1) = THIS._shoulder2PGB.BonePivot
   arrayOfBoneEndJoints(2) = THIS._headPGB.BoneEnd
   arrayOfBoneEndJoints(3) = THIS._bodyTorsoPGB.BoneEnd
   arrayOfBoneEndJoints(4) = THIS._bodyStomachPGB.BoneEnd
   for tParam as single = 0 to 1 step .009
      DrawBezierCurve(arrayOfBoneEndJoints(), tParam, THIS._headPGB._displayBufferScreenOffsetXY, THIS._scaleFactor)
   next tParam
end sub
sub PROTAGON.DrawEffectorBoundingBox(byval VisibilityFlag as integer=0)
   for index as integer = lBound(THIS._arrayOfPgbPointers) to uBound(THIS._arrayOfPgbPointers)
      if not THIS._arrayOfPgbPointers(index)=0 then
         THIS._arrayOfPgbPointers(index)->FaceEffector.DrawBoundingBox(VisibilityFlag)
         THIS._arrayOfPgbPointers(index)->BackEffector.DrawBoundingBox(VisibilityFlag)
      end if
   next index
end sub
sub PROTAGON.ShowPgbInfo(byval PgbPtr as PGB ptr)
   'check if the PGB is registered in the dedicated array
   dim as boolean pgbPtrFound => FALSE
   dim as integer index       => any
   for index = lBound(THIS._arrayOfPGBPointers) to uBound(THIS._arrayOfPgbPointers)
      if THIS._arrayOfPgbPointers(index)=PgbPtr then
         pgbPtrFound = TRUE
         exit for
      end if
   next index
   '
   if not pgbPtrFound then exit sub
   '
   var txtNodeX   => _ 
      (28 + 8*index)*THIS._scaleFactor*cos(-_pi/2 + (-1)^index*index*2*_pi/(uBound(THIS._arrayOfPGBPointers) - lBound(THIS._arrayOfPGBPointers) + 1))
   var txtNodeY   => _ 
      28*THIS._scaleFactor*sin(-_pi/2 + (-1)^index*index*_pi/(uBound(THIS._arrayOfPGBPointers) - lBound(THIS._arrayOfPGBPointers) + 1))   
   circle ( PgbPtr->BonePivot._x - THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._x, _ 
            PgbPtr->BonePivot._y + THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._y   ), _ 
            2, _ 
            rgb(140,240,120)
   line (PgbPtr->BonePivot._x - THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._x, _ 
         PgbPtr->BonePivot._y + THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._y)- _ 
         step( txtNodeX, _ 
               txtNodeY  ), _ 
               rgb(140,240,120), _ 
               , &b01110110110110111011011011
   draw string (  PgbPtr->BonePivot._x + txtNodeX - THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._x + _ 
                  iif((index mod 2)<>0, (-1)^index*8*len(THIS._arrayOfPGBPointers(index)->_pgbName), 0), _ 
                  PgbPtr->BonePivot._y + txtNodeY + THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._y ), _ 
                  THIS._arrayOfPGBPointers(index)->_pgbName, _ 
                  rgb(140 + index,240 - 8*index,120 - 4*(-1)^index)
   draw string (  PgbPtr->BonePivot._x + txtNodeX - THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._x + _ 
                  iif((index mod 2)<>0, (-1)^index*8*len(THIS._arrayOfPGBPointers(index)->_pgbName), 0), _ 
                  PgbPtr->BonePivot._y + txtNodeY + THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._y + 10  ), _ 
                  str(THIS._arrayOfPGBPointers(index)->_restAngleRelativeToParentBoneOrientation), _ 
                  rgb(140,240 - 8*index,120 - 4*(-1)^index)
   '
   dim as single  restrel  => any
   _GETMAINCENTEREDANGULARVALUE( THIS._arrayOfPGBPointers(index)->BoneOrientation, _ 
                                 THIS._arrayOfPGBPointers(index)->_restAngleRelativeToParentBoneOrientation, _ 
                                 restrel)
   draw string (  PgbPtr->BonePivot._x + txtNodeX - THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._x + _ 
                  iif((index mod 2)<>0, (-1)^index*8*len(THIS._arrayOfPGBPointers(index)->_pgbName), 0), _ 
                  PgbPtr->BonePivot._y + txtNodeY + THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._y + 20  ), _ 
                  str(restrel), _ 
                  iif(restrel>=0, rgb(140,240,120), rgb(240,120,140))
   '
   circle ( 3 + PgbPtr->BonePivot._x + txtNodeX - THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._x + _ 
            iif((index mod 2)<>0, (-1)^index*8*len(THIS._arrayOfPGBPointers(index)->_pgbName), 0), _ 
            3 + PgbPtr->BonePivot._y + txtNodeY + THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._y + 40  ), _
            8
   draw string (  PgbPtr->BonePivot._x + txtNodeX - THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._x + _ 
                  iif((index mod 2)<>0, (-1)^index*8*len(THIS._arrayOfPGBPointers(index)->_pgbName), 0), _ 
                  PgbPtr->BonePivot._y + txtNodeY + THIS._arrayOfPGBPointers(index)->_displayBufferScreenOffsetXY._y + 40  ), _ 
                  str(PgbPtr->_pgbFacing), _ 
                  iif(PgbPtr->_pgbFacing=5, rgb(140,240,120), rgb(240,120,140))
end sub
sub PROTAGON.ShowPgbInfoForAll()
   for index as integer = lBound(THIS._arrayOfPGBPointers) to uBound(THIS._arrayOfPgbPointers)
      THIS.ShowPgbInfo(THIS._arrayOfPGBPointers(index))
   next index
end sub
sub PROTAGON.ShowProtagonInfo()
   line (   THIS._headPGB.BonePivot._x - 8 - 4*len(THIS._protagonName) - THIS._headPGB._displayBufferScreenOffsetXY._x, _ 
            THIS._headPGB.BonePivot._y - 58 + THIS._headPGB._displayBufferScreenOffsetXY._y  )- _ 
         step(8*len(THIS._protagonName) + 16, 14), _ 
         rgb(80,120,20), _ 
         bf
   line (   THIS._headPGB.BonePivot._x - 8 - 4*len(THIS._protagonName) - THIS._headPGB._displayBufferScreenOffsetXY._x, _ 
            THIS._headPGB.BonePivot._y - 58 + THIS._headPGB._displayBufferScreenOffsetXY._y  )- _ 
         step(8*len(THIS._protagonName) + 16, 14), _ 
         rgb(80,200,130), _ 
         b
   draw string (  THIS._headPGB.BonePivot._x - 4*len(THIS._protagonName) - THIS._headPGB._displayBufferScreenOffsetXY._x, _ 
                  THIS._headPGB.BonePivot._y - 54 + THIS._headPGB._displayBufferScreenOffsetXY._y  ), _ 
                  THIS._protagonName, _ 
                  rgb(140,240,120)
end sub



'(some usage example:)
/'
screenres 1000,600,32
dim shared as stonemonkey.STONEGFX_BUFFER ptr   stoneBuffer1
stoneBuffer1 => new stonemonkey.STONEGFX_BUFFER
stonemonkey.InitializeStoneBuffer(stoneBuffer1, 0)
dim as PROGRAMMABLEBONE pb
with pb
   ._detectionScreenDistanceToAxis  => 2
   ._parameter._bonePivotPosition   => type(320, 190)
   .BoneOrientation                 => _pi/2
   .DefineBoneLength(type(20))
   ._boneBaseHalfLength             => 10
end with
dim as PROTAGON   prota
do
   screenLock()
   cls
      'pb.RefreshHierarchy()
      'pb.DrawBoneDetectionTube(screenPtr())
      pb.DrawBone(stoneBuffer1, screenPtr())
      'pb.FaceEffector.DrawBoundingBox()
      'pb.BackEffector.DrawBoundingBox()
   '
   (prota._headPGB.BoneOrientation) += .006
   prota.DrawProtagon(stoneBuffer1, screenPtr())
   prota.DrawEffectorBoundingBox()
   screenUnLock
   sleep 12
loop until inkey()=chr(27)
'/

'(eof)