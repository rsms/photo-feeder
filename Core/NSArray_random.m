/*
 * PhotoFeeder is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */

#import "NSArray_random.h"
#import "PFUtil.h"

#include <stdlib.h>
#include <CoreServices/CoreServices.h>


@implementation NSArray (RandomAddition)

- (NSArray*) randomCopy
{
	//double t = [PFUtil microtime];
	unsigned i, x, count;
	NSMutableArray* ca;
	NSMutableArray* na;
	
	count = [self count];
	ca = [self mutableCopy];
	na = [[NSMutableArray alloc] initWithCapacity:count];
	x = count;
	
	while(x--)
	{
		srandom([PFUtil microseed]);
		i = (unsigned)random() % count--;
		
		// Take obj from current
		id o = [ca objectAtIndex:i];
		[ca removeObjectAtIndex:i];
		
		// Put obj into new
		[na addObject:o];
	}
	
	//DLog(@"Time: %f seconds", [PFUtil microtime]-t);
	return na;
}

@end
