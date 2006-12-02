
#ifndef TYPES_H
#define TYPES_H

enum {
	PFMovingTypeHorizontally,
	PFMovingTypeVertically,
	PFMovingTypeNone
};
typedef int PFMovingType;

typedef struct {
	int x;
	int y;
	int width;
	int height;
} PFRect;

static PFRect PFRectMake( int x, int y, int w, int h ) {
	PFRect r;
	r.x=x; r.y=y; r.width=w; r.height=h;
	return r;
}

#endif
