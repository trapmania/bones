'commondefines.bas
'most common defines and some compiler's intrinsics checked for system info

#ifnDef _P
#macro _P(expression)
   ? #expression, expression
#endMacro
#else
#print __FILE__ , _P already defined
#endIf

#ifnDef boolean
#define boolean            integer
#endIf

#ifnDef TRUE
#define TRUE               -1
#endIf

#ifnDef FALSE
#define FALSE               0
#endIf

#ifnDef T
#define T					   THIS
#else
#print __FILE__ , T already defined
#endIf

#ifnDef _pi
#define _pi					   ( 4*atn(1) )
#else
#print __FILE__ , _pi already defined
#endIf

#ifnDef _MIN
#define _MIN(a, b)			( iif((a)<(b), (a), (b)) )
#else
#print __FILE__ , _MIN already defined
#endIf

#ifnDef _MAX
#define _MAX(a, b)			( iif((a)>(b), (a), (b)) )
#else
#print __FILE__ , _MAX already defined
#endIf

#ifnDef _P2DDIST
#define _P2DDIST(p1, p2)	sqr( ((p1)._x - (p2)._x)*((p1)._x - (p2)._x) + ((p1)._y - (p2)._y)*((p1)._y - (p2)._y) )
#else
#print __FILE__ , _P2DDIST already defined
#endIf

#ifnDef  __FB_PCOS__
#print "not a PC OS like system"
#print "you may have to change the file-path syntax"
#endIf

#ifDef __FB_64BIT__
#print "compiling to .. a 64bit environment"
#else
#print "not compiling to a 64bit environment"
#endIf

'Credit::FBCommunity
#ifDef __FB_WIN32__
#print "compiling to .. a win32 API platform"
	declare function TimeBeginPeriod alias "timeBeginPeriod" (as ulong=1) as long
	declare function TimeEndPeriod alias "timeEndPeriod" (as ulong=1) as long
#else
#print "compiling to a win32 API platform"
	#define TimeBeginPeriod
	#define TimeEndPeriod
#endIf
#ifnDef _SLEEP1MS
   #macro _SLEEP1MS()
      TimeBeginPeriod
      sleep 1
      TimeEndPeriod
   #endMacro
#else
#print __FILE__ , _SLEEP1MS already defined
#endIf

'(eof)