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
		
		// Depending on what they clicked we could open a URL or perhaps pop open a profile HUD
		// if they clicked on a username. For now, we'll just throw it out to the log.
		if( [attributes objectForKey:@"LinkMatch"] != nil ) {
			NSString *URLString = [attributes objectForKey:@"LinkMatch"];
			NSURL *statusLink;// = [NSURL URLWithString:URLString];
			//NSURL *myURL;
			if ([URLString hasPrefix:@"http://"]) {
				statusLink = [NSURL URLWithString:URLString];
			}
            else if ([URLString hasPrefix:@"https://"]) {
                statusLink = [NSURL URLWithString:URLString];
                
            } else {
				NSString *rer = [NSString stringWithFormat:@"http://%@", URLString];
				statusLink = [NSURL URLWithString:rer];
				//rer = URLbox.text;
				//NSLog(@"updated textbox");
			}
			[[NSWorkspace sharedWorkspace] openURL:statusLink];
			// Remember what object we stashed in this attribute? Oh yeah, it's a URL string. Boo ya!
			NSLog( @"LinkMatch: '%@'", [attributes objectForKey:@"LinkMatch"] );
			
		}
		
		if( [attributes objectForKey:@"UsernameMatch"] != nil ) {
			NSLog( @"UsernameMatch: %@", [attributes objectForKey:@"UsernameMatch"] );
		}
		
		if( [attributes objectForKey:@"HashtagMatch"] != nil ) {
			NSLog( @"HashtagMatch: %@", [attributes objectForKey:@"HashtagMatch"] );
		}
		
	}
	
	[super mouseDown:theEvent];
}

@end
