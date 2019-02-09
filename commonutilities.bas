'commonutilities.bas
'author TT, 
'or taken from the FreeBasic documentation, 
'or inspired from the FreeBasic documentation
'or adapted from free short snippet from the internet
'for more information please search the freebasic.net community forum

namespace CreditFBDoc
	Const NULL As Any Ptr = 0
	Function BMPlOAD( ByRef filename As Const String ) As Any Ptr
	    Dim As Long filenum, bmpwidth, bmpheight
	    Dim As Any Ptr img
	    '' open BMP file
	    filenum = FreeFile()
	    If Open( filename For Binary Access Read As #filenum ) <> 0 Then Return NULL
	        '' retrieve BMP dimensions
	        Get #filenum, 19, bmpwidth
	        Get #filenum, 23, bmpheight
	    Close #filenum
	    '' create image with BMP dimensions
	    img = ImageCreate( bmpwidth, Abs(bmpheight) )
	    If img = NULL Then Return NULL
	    '' load BMP file into image buffer
	    If BLoad( filename, img )<>0 Then ImageDestroy( img ): Return NULL
	    Return img
	End Function
end namespace

function List_NormalFiles(	byref In_PathAndPattern as const string, _ 
							Out_FileNamesArray() as string	) _ 
							as integer
    erase Out_FileNamesArray
    redim preserve Out_FileNamesArray(ubound(Out_FileNamesArray) + 1)
    Out_FileNamesArray(ubound(Out_FileNamesArray)) = dir(In_PathAndPattern & "*.*", 33)
    '
    do while len(Out_FileNamesArray(ubound(Out_FileNamesArray)))>0
        redim preserve Out_FileNamesArray(ubound(Out_FileNamesArray) + 1)
        Out_FileNamesArray(ubound(Out_FileNamesArray)) = dir()
    loop
    '
    redim preserve Out_FileNamesArray(ubound(Out_FileNamesArray) - 1)
    '
    return ubound(Out_FileNamesArray) - lbound(Out_FileNamesArray) + 1
end function

#ifnDef XY
type XY
   as single _x
   as single _y
end type
#endIf

function DrawBezierCurve(ArrayOfXY() as XY, byval Tparam as single, byref OffsetXy as const XY, byval ScaleFactor as single) as integer
   'adapted from: https://pomax.github.io/bezierinfo/#bsplines
   'beware: the last point of the ArrayOfXY is ignored for some reason
   dim as XY workingArrayOfXY(lBound(ArrayOfXY) to uBound(ArrayOfXY))
   for index as integer = lBound(ArrayOfXY) to uBound(ArrayOfXY)
      workingArrayOfXY(index) = ArrayOfXY(index)
   next index
   '
   if (uBound(ArrayOfXY) - lBound(ArrayOfXY) + 0)=1 then
      circle (ArrayOfXY(0)._x - OffsetXy._x + 2, ArrayOfXY(0)._y + OffsetXy._y + 1), 4*ScaleFactor, rgb(ArrayOfXY(0)._x*255/1800, 80, 80)
      circle (ArrayOfXY(0)._x - OffsetXy._x, ArrayOfXY(0)._y + OffsetXy._y), 4*ScaleFactor, rgb(ArrayOfXY(0)._x*255/800, 180, 100)
   else
      redim preserve workingArrayOfXY(lBound(ArrayOfXY) to uBound(ArrayOfXY) - 1)
      for index as integer = lBound(workingArrayOfXY) to uBound(workingArrayOfXY) - 1
         var x => (1 - Tparam)*ArrayOfXY(index)._x + Tparam*ArrayOfXY(index + 1)._x
         var y => (1 - Tparam)*ArrayOfXY(index)._y + Tparam*ArrayOfXY(index + 1)._y
         workingArrayOfXY(index) = type(x,y)
      next index
      DrawBezierCurve(workingArrayOfXY(), Tparam, OffsetXy, ScaleFactor)
   end if
   '
   return 0
end function


'(eof)