/*
 * Flickr Objective-C Framework is the legal property of its developers.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version. You should have received a copy 
 * of the GNU General Public License along with this program; if not, 
 * write to the Free Software Foundation, Inc., 59 Temple Place, 
 * Suite 330, Boston, MA 02111-1307 USA
 */
#import "FlickrResponse.h"

@implementation FlickrResponse

- (id) initWithErrorCode:(int)code errorMessage:(NSString*)msg
{
	errorCode = code;
	errorMessage = [msg retain];
	return self;
}

- (id) initWithDOM:(NSXMLElement*)root
{
	dom = root;
	return self;
}

- (int) errorCode {
	return errorCode;
}

- (NSString*) errorMessage {
	return errorMessage;
}

- (NSXMLElement*) dom {
	return dom;
}

@end
