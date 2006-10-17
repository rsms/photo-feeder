#import "PFText.h"

@implementation PFText

- (id) initWithText:(NSString*)text
{
	return [self initWithText:text font:[NSFont systemFontOfSize: 18.0] color:[NSColor whiteColor] shadow:nil];
}


- (id) initWithText:(NSString*)text font:(NSFont*)font color:(NSColor*)color
{
	return [self initWithText:text font:font color:color shadow:nil];
}


- (id) initWithText:(NSString*)text font:(NSFont*)font color:(NSColor*)color shadow:(NSShadow*)shadow
{
	NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
		color, NSForegroundColorAttributeName,
		font, NSFontAttributeName,
		nil];
	
	// set shadow
	if(shadow) {
		[shadow set];
		[attributes setObject:shadow forKey:NSShadowAttributeName];
	}
	
	attrString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];
	return self;
}


- (void) setText:(NSString*)text
{
	[attrString replaceCharactersInRange:NSMakeRange(0,[attrString length]) withString:text];
}


- (NSMutableAttributedString*) attrString { return attrString; }


- (void)drawAt:(NSPoint)p
{
	[attrString drawAtPoint:p];
}


@end
