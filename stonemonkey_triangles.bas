'stonemonkey_triangles.bas
'all rights here goes to the original authors
'for more information please refer to the freebasic.net community forum

nameSpace stonemonkey
   type STONEVERTEX
     as single x, y, r, g, b
   end type
   type STONETRIANGLE
         as STONEVERTEX ptr v0, v1, v2
   end type
   type STONEEDGE
     as single x, e, r, g, b, dx, de, dr, dg, db
   end type
   type STONEGFX_BUFFER
     as integer   w, h, b, p
     as ulong ptr pixels
   end type
   dim shared as STONEGFX_BUFFER ptr buffer
   sub Gtriangle( byval stoneBuffer as STONEGFX_BUFFER ptr, _
                  byval DisplayBuffer as any ptr, _
                  byval Tri as STONETRIANGLE ptr, _ 
                  byval VisibilityStatus as integer=0 )
      '
      stoneBuffer->pixels  = DisplayBuffer
      '
     dim as STONEEDGE edge => any
     dim as STONEEDGE scan => any
     dim as single d1 => any, d2 => any
     dim as STONEVERTEX ptr v0 => Tri->v0
     dim as STONEVERTEX ptr v1 => Tri->v1
     dim as STONEVERTEX ptr v2 => Tri->v2
     if v1->y<v0->y then swap v1,v0
     if v2->y<v0->y then swap v2,v0
     if v2->y<v1->y then swap v2,v1
     d1        = 1.0/(v2->y - v0->y)
     edge.dx   = (v2->x - v0->x)*d1 : edge.dr = (v2->r - v0->r)*d1
     edge.dg   = (v2->g - v0->g)*d1 : edge.db = (v2->b - v0->b)*d1
     d1        = v1->y - v0->y
     edge.de   = (v1->x - v0->x)/d1
     d2        = 1.0/( v1->x - (v0->x + d1*edge.dx) )
     scan.dr   = ( v1->r - (v0->r + d1*edge.dr) )*d2
     scan.dg   = ( v1->g - (v0->g+d1*edge.dg) )*d2
     scan.db   = ( v1->b - (v0->b+d1*edge.db) )*d2
     dim as single ptr xl  => @edge.x, xr = @edge.e
     if edge.dx>edge.de then swap xl,xr
     dim as integer y_start   => v0->y - 0.4999
     if y_start<0 then y_start = 0
     dim as integer y_end     => v1->y - 0.4999
     if y_end>=stoneBuffer->h then y_end = stoneBuffer->h - 1
     dim as integer y_fin     => v2->y - 0.4999
     if y_fin>=stoneBuffer->h then y_fin =stoneBuffer->h - 1
     d1        = y_start-v0->y
     edge.x    = v0->x + edge.dx*d1 : edge.e = v0->x + edge.de*d1
     edge.r    = v0->r + edge.dr*d1 : edge.g = v0->g + edge.dg*d1
     edge.b    = v0->b + edge.db*d1
     while (y_start<=y_fin)
       while (y_start<=y_end)
         dim as integer x_start  => *xl - 0.4999
         if x_start<0 then x_start = 0
         dim as integer x_end    => *xr - 0.4999
         if x_end>=stoneBuffer->w then x_end = stoneBuffer->w - 1
         d1    = x_start-edge.x
         dim as single  r => edge.r + scan.dr*d1
         dim as single  g => edge.g + scan.dg*d1
         dim as single  b => edge.b + scan.db*d1
         dim as ulong ptr  p_start  => stoneBuffer->pixels + x_start + y_start*stoneBuffer->p
         dim as ulong ptr  p_end    => stoneBuffer->pixels + x_end + y_start*stoneBuffer->p
         select case VisibilityStatus
            case 0
               while (p_start<=p_end)
                  *p_start = (r shl 16) or (g shl 8) or b
                  r += scan.dr : g += scan.dg
                  b += scan.db : p_start += 1
               wend
               edge.x += edge.dx : edge.e += edge.de
               edge.r += edge.dr : edge.g += edge.dg
               edge.b += edge.db : y_start += 1
            case +1
               while (p_start<=p_end)
                  *p_start = (r shl 16) or (g shl 8) or b
                  r += scan.dr : g += scan.dg
                  b += scan.db : p_start += 4
               wend
               edge.x += edge.dx : edge.e += edge.de
               edge.r += edge.dr : edge.g += edge.dg
               edge.b += edge.db : y_start += 1
            case -1
               *p_start = (r shl 16) or (g shl 8) or b
               r = 0*scan.dr : g = 0*scan.dg
               b = 0*scan.db : p_start += 1
               edge.x = 0 : edge.e = 0
               edge.r = 0 : edge.g = 0
               edge.b = 0 : y_start += 1
               exit sub
            case else
               while (p_start<=p_end)
                  *p_start = (r shl 16) or (g shl 8) or b
                  r += scan.dr : g += scan.dg
                  b += scan.db : p_start += 4
               wend
               edge.x += edge.dx : edge.e += edge.de
               edge.r += edge.dr : edge.g += edge.dg
               edge.b += edge.db : y_start += 4
         end select
         '
         p_start   = 0
         p_end     = 0
       wend
       if y_start<=y_fin then
         y_end = y_fin : edge.de = (v2->x - v1->x)/(v2->y - v1->y)
         d1    = y_start - v2->y : edge.e = v2->x + edge.de*d1
       end if
     wend
   end sub
   function InitializeStoneBuffer(  byval stoneBuffer as STONEGFX_BUFFER ptr, _ 
                                    byval DisplayBuffer as any ptr   ) _ 
                                    as boolean
      if screenPtr()=0 then
         return FALSE
      end if
      '      
      if DisplayBuffer=0 then
         screenInfo  _
            stoneBuffer->w,  _ ' width
            stoneBuffer->h,, _ ' height
            stoneBuffer->b,  _ ' bytes
            stoneBuffer->p     ' pitch
         stoneBuffer->pixels  = screenptr()
         stoneBuffer->p shr= 2
      else
         screenInfo  _
            stoneBuffer->w,  _ ' width
            stoneBuffer->h,, _ ' height
            stoneBuffer->b,  _ ' bytes
            stoneBuffer->p     ' pitch
         imageInfo  _ 
            DisplayBuffer,    _ 
            stoneBuffer->w,   _     ' width
            stoneBuffer->h,   _     ' height
            stoneBuffer->b,   _     ' bytes
            stoneBuffer->p
         stoneBuffer->pixels  = DisplayBuffer
         stoneBuffer->p shr= 2           
      end if
      '
      return TRUE
   end function
end nameSpace

'(eof)