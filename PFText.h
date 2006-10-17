
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
