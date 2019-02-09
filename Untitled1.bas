dim as stonemonkey.STONETRIANGLE ptr tri= new stonemonkey.STONETRIANGLE
dim as stonemonkey.STONETRIANGLE ptr tri2= new stonemonkey.STONETRIANGLE
tri->v0  => new stonemonkey.STONEVERTEX
tri->v1  => new stonemonkey.STONEVERTEX
tri->v2  => new stonemonkey.STONEVERTEX
tri2->v0 => new stonemonkey.STONEVERTEX
tri2->v1 => new stonemonkey.STONEVERTEX
tri2->v2 => new stonemonkey.STONEVERTEX
tri->v0->r=255    : tri->v0->g=155  : tri->v0->b=55
tri->v1->r=255    : tri->v1->g=155  : tri->v1->b=55
tri->v2->r=255    : tri->v2->g=155  : tri->v2->b=55
tri2->v0->r=255   : tri2->v0->g=105 : tri2->v0->b=55
tri2->v1->r=255   : tri2->v1->g=105 : tri2->v1->b=55
tri2->v2->r=255   : tri2->v2->g=105 : tri2->v2->b=55

      tri->v0->x = stoneBuffer->w/2 + 12
      tri->v0->y = stoneBuffer->h/2 + 22
      tri->v1->x = tri->v0->x + radius*cos(angle)
      tri->v1->y = tri->v0->y + radius*sin(angle)
      dim as single a = tri->v1->x - tri->v0->x
      dim as single b = tri->v1->y - tri->v0->y
      tri->v2->x = tri->v0->x  - 12*b/sqr(a^2 + b^2)
      tri->v2->y = tri->v0->y  + 12*a/sqr(a^2 + b^2)
      tri2->v0->x = tri->v0->x  - 12*b/sqr(a^2 + b^2)
      tri2->v0->y = tri->v0->y  + 12*a/sqr(a^2 + b^2)
      tri2->v1->x = tri->v1->x  - 12*b/sqr(a^2 + b^2)
      tri2->v1->y = tri->v1->y  + 12*a/sqr(a^2 + b^2)
      tri2->v2->x = tri->v1->x
      tri2->v2->y = tri->v1->y
      
		'draw the application
      stonemonkey.Gtriangle(stoneBuffer, applicationWindow._imageBuffer, tri)
      stonemonkey.Gtriangle(stoneBuffer, applicationWindow._imageBuffer, tri2)         
