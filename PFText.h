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

@interface PFText : NSObject {
	NSMutableAttributedString* attrString;
}

- (id) initWithText:(NSString*)text 
			   font:(NSFont*)font 
			  color:(NSColor*)color 
			 shadow:(NSShadow*)shadow;

- (id) initWithText:(NSString*)text 
			   font:(NSFont*)font 
			  color:(NSColor*)color;

- (id) initWithText:(NSString*)text;

- (NSMutableAttributedString*) attrString;

- (void) setText:(NSString*)text;
- (void) drawAt:(NSPoint)pos;

@end
