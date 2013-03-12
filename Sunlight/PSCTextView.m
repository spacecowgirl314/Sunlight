//
//  PSCTextView.m
//  Sunlight
//
//  Created by Chloe Stars on 2/5/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCTextView.h"

@implementation PSCTextView

// We're only subclassing NSTextView so we can grab its mouse down event. Everything
// else will be handled like normal
- (void)mouseDown:(NSEvent *)theEvent {
	// Grab a usable NSPoint value for our mousedown event
	NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	
	// Starting in 10.5, NSTextView provides this nifty function to get the index of
	// the character at a specific NSPoint. It automatically takes into account all the
	// custom drawing attributes of our attributed string including line spacing.
	NSInteger charIndex = [self characterIndexForInsertionAtPoint:point];
	
	// If we actually clicked on a text character
	if (NSLocationInRange(charIndex, NSMakeRange(0, [[self string] length])) == YES ) {
		
		// Grab the attributes of our attributed string at this exact index
		NSDictionary *attributes = [[self attributedString] attributesAtIndex:charIndex effectiveRange:NULL];
		
		/*if( [attributes objectForKey:@"LinkMatch"] != nil ) {
			[[NSWorkspace sharedWorkspace] openURL:[attributes objectForKey:@"LinkMatch"]];
		}*/
		
		if( [attributes objectForKey:@"UsernameMatch"] != nil ) {
			NSLog( @"UsernameMatch: %@", [attributes objectForKey:@"UsernameMatch"] );
			[[NSNotificationCenter defaultCenter] postNotificationName:@"Profile" object:[attributes objectForKey:@"UsernameMatch"]];
		}
		
		if( [attributes objectForKey:@"HashtagMatch"] != nil ) {
			NSLog( @"HashtagMatch: %@", [attributes objectForKey:@"HashtagMatch"] );
			[[NSNotificationCenter defaultCenter] postNotificationName:@"Hashtag" object:[attributes objectForKey:@"HashtagMatch"]];
		}
		
	}
	
	[super mouseDown:theEvent];
}

- (NSDictionary *)linkTextAttributes {
	return [[NSDictionary alloc] initWithObjectsAndKeys:
	 [NSCursor pointingHandCursor], NSCursorAttributeName,
	 [NSColor colorWithDeviceRed:0.82 green:0.388 blue:0.031 alpha:1.0], NSForegroundColorAttributeName,
	 [NSFont fontWithName:@"Helvetica Neue Regular" size:13], NSFontAttributeName,
	 nil];
}

@end
