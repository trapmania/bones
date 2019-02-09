'dodicat_fonts.bas
'all rights here goes to the original authors
'for more information please refer to the freebasic.net community forum

namespace dodifont
    declare Function Filter(Byref tim As Ulong Pointer,Byval rad As Single,Byval destroy As Long=1,Byval fade As Long=0) As Ulong Pointer
    declare Sub drawstring(Byval xpos As Long,Byval ypos As Long,Byref text As String,Byval co As Ulong,Byval size As Single,Byref im As Any Pointer=0)
    declare Function Colour(Byref im As Any Pointer,Byval newcol As Ulong,Byval tweak As Long,Byval fontsize As Single) As Any Pointer
    declare Sub CreateFont(Byref myfont As Any Pointer,Byval fontsize As Single,Byval col As Ulong,Byval tweak As Long=0)
    Sub init Constructor
        drawstring(0,0,"",0,0)
        Screen 0
    End Sub
end namespace
using dodifont

dodicatfontmanagement:
        Function Filter(Byref tim As Ulong Pointer,_
        Byval rad As Single,_
        Byval destroy As Long=1,_
        Byval fade As Long=0) As Ulong Pointer
        #define map(a,b,_x_,c,d) ((d)-(c))*((_x_)-(a))/((b)-(a))+(c)
        If fade<0 Then fade=0:If fade>100 Then fade=100
        Type p2 : As Long x,y : As Ulong col : End Type
        #macro ppoint(_x,_y,colour): pixel=row+pitch*(_y)+(_x)*4 : (colour)=*pixel
        #endmacro
        #macro ppset(_x,_y,colour)
        pixel=row+pitch*(_y)+(_x)*4 : *pixel=(colour)
        #endmacro
        #macro average()
        ar=0:ag=0:ab=0:inc=0 : xmin=x:If xmin>rad Then xmin=rad
        xmax=rad:If x>=(_x-1-rad) Then xmax=_x-1-x
        ymin=y:If ymin>rad Then ymin=rad
        ymax=rad:If y>=(_y-1-rad) Then ymax=_y-1-y
        For y1 As Long=-ymin To ymax : For x1 As Long=-xmin To xmax
        inc=inc+1 : ar=ar+(NewPoints(x+x1,y+y1).col Shr 16 And 255)
        ag=ag+(NewPoints(x+x1,y+y1).col Shr 8 And 255)
        ab=ab+(NewPoints(x+x1,y+y1).col And 255) : Next x1
        Next y1 : If fade=0 Then
        averagecolour=Rgb(ar/(inc),ag/(inc),ab/(inc))
        Else
        averagecolour=Rgb(fd*ar/(inc),fd*ag/(inc),fd*ab/(inc))
        End If
        #endmacro
        Dim As Single fd=map(0,100,fade,1,0) : Dim As Integer _x,_y : Imageinfo tim,_x,_y
        Dim  As Ulong Pointer im=Imagecreate(_x,_y) : Dim As Integer pitch : Dim  As Any Pointer row
        Dim As Ulong Pointer pixel : Dim As Ulong col : Imageinfo tim,,,,pitch,row : Dim As p2 NewPoints(_x-1,_y-1)
        For y As Long=0 To (_y)-1 : For x As Long=0 To (_x)-1 : ppoint(x,y,col)
        NewPoints(x,y)=Type<p2>(x,y,col) : Next x : Next y : Dim As Ulong averagecolour
        Dim As Long ar,ag,ab : Dim As Long xmin,xmax,ymin,ymax,inc : Imageinfo im,,,,pitch,row
        For y As Long=0 To _y-1 : For x As Long=0 To _x-1 : average() : ppset((NewPoints(x,y).x),(NewPoints(x,y).y),averagecolour)
        Next x : Next y : If destroy Then Imagedestroy tim: tim = 0
        Function= im : End Function
        Sub drawstring(Byval xpos As Long,Byval ypos As Long,Byref text As String,Byval co As Ulong,Byval size As Single,Byref im As Any Pointer=0)
        Type D2
        As Double x,y
        As Ulong col
        End Type
        size=Abs(size) : Static As d2 XY() : Static As Long runflag
        If runflag=0 Then   
        Redim  XY(128,127): Screen 8 : Width 640\8,200\16 : Dim As Ulong Pointer img
        Dim count As Long : For ch As Long=1 To 127 : img=Imagecreate(9,17) : Draw String img,(1,1),Chr(ch)
        For x As Long=1 To 8 : For y As Long=1 To 16 : If Point(x,y,img)<>0 Then
            count=count+1
            XY(count,ch)=Type<D2>(x,y)
        End If : Next y : Next x : count=0 : Imagedestroy img : Next ch
        runflag=1 : End If
        If size=0 Then Exit Sub
        Dim As D2 np,t
        #macro Scale(p1,p2,d)
        np.col=p2.col
        np.x=d*(p2.x-p1.x)+p1.x
        np.y=d*(p2.y-p1.y)+p1.y
        #endmacro
        Dim As D2 c=Type<D2>(xpos,ypos) : Dim As Long dx=xpos,dy=ypos,f
        If Abs(size)=1.5 Then f=3 Else f=2
        For z6 As Long=1 To Len(text)
        Var asci=text[z6-1] : For _x1 As Long=1 To 64*2
        t=Type<D2>(XY(_x1,asci).x+dx,XY(_x1,asci).y+dy,co)         
        Scale(c,t,size)
        If XY(_x1,asci).x<>0 Then
        If size>1 Then
        Line im,(np.x-size/f,np.y-size/f)-(np.x+size/f,np.y+size/f),np.col,bf
        Else
        Pset im,(np.x,np.y),np.col
        End If : End If : Next _x1
        dx=dx+8 : Next z6: End Sub  
        Function Colour(Byref im As Any Pointer,Byval newcol As Ulong,Byval tweak As Long,Byval fontsize As Single) As Any Pointer
        #macro ppset2(_x,_y,colour)
        pixel2=row2+pitch2*(_y)+(_x)*dpp2
        *pixel2=(colour)
        #endmacro
        #macro ppoint(_x,_y,colour)
        pixel=row+pitch*(_y)+(_x)*dpp
        (colour)=*pixel
        #endmacro
        Dim As Long grade : Select Case  fontsize
        Case 1 To 1.5:grade=205
        Case 2 :grade=225
        Case 2.5:grade=222
        Case 3 To 3.5:grade=200
        Case 4 To 4.5:grade=190
        Case 5 To 5.5:grade=165
        Case Else: grade=160
        End Select
        Dim As Integer w,h : Dim As Integer pitch,pitch2,dpp,dpp2 : Dim  As Any Pointer row,row2 : Dim As Ulong Pointer pixel,pixel2
        Dim As Ulong col : Imageinfo im,w,h,dpp,pitch,row : Dim As Any Pointer temp=Imagecreate(w,h)
        Imageinfo temp,,,dpp2,pitch2,row2 : For y As Long=0 To h-1
        For x As Long=0 To w-1 : ppoint(x,y,col) : Var v=.299*((col Shr 16)And 255)+.587*((col Shr 8)And 255)+.114*(col And 255)
        If v>(grade+tweak) Then
        ppset2(x,y,newcol)
        Else
        ppset2(x,y,Rgb(255,0,255))
        End If : Next x : Next y : Return temp : End Function
        Sub CreateFont(Byref myfont As Any Pointer,Byval fontsize As Single,Byval col As Ulong,Byval tweak As Long=0)
        fontsize=Int(2*Abs(fontsize))/2 : If fontsize=0 Then fontsize=.5
        Dim As Ubyte Ptr p : Dim As Any Pointer temp
        Dim As Integer i : temp = Imagecreate(FontSize*768,FontSize*16) : myfont=Imagecreate(FontSize*768,FontSize*16)
        For i = 32 To 127 : drawstring ((i-32)*FontSize*8,1,Chr(i),Rgb(255,255,255),FontSize,temp)
        Next i : If fontsize>1.5 Then
        For n As Single=0 To fontsize-2:temp=filter(temp,1,1,0):Next
        End If : temp=Colour(temp,col,tweak,fontsize) : Put myfont,(0,0),temp,trans : Imageinfo( myfont,i,,,, p )
        p[0]=0:p[1]=32:p[2]=127 : For i = 32 To 127 : p[3+i-32]=FontSize*8 : Next i : Imagedestroy(temp) : End Sub

'(eof)