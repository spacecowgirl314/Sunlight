//
//  PSCTextView.m
//  Sunlight
//
//  Created by Chloe Stars on 10/14/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCTextView.h"

@implementation PSCTextView

// from http://boutcher.tumblr.com/post/7842216960/nstextview-auto-resizing-text
- (void) didChangeText {
	// this method will reduce size of text to fit nicely inside a NSTextView.. Subclass NSTextView and drop this in it.
	// the max size is taken from whatever is initially set (so this won't "grow" the text, unless you tell the NSTextView
	// to set its font to 200pt or something...
	[super didChangeText];
	
	float maxDesiredHeight = self.frame.size.height - 28; // this is the "padding" on top and bottom.. should probably be changed to use insets or something.
	
	// Start evaluating at the biggest this field has ever seen, and go down..
	static float originalLargestFontSize = 0;
	originalLargestFontSize = MAX(originalLargestFontSize,[[self font] pointSize]);
	
	float newFontSize = originalLargestFontSize;
	[self setFont:[NSFont fontWithName:[[self font] fontName] size:newFontSize]];
	
	BOOL keepGoing = YES;
	while(keepGoing) {
		NSLayoutManager *layoutManager = [self layoutManager];
		unsigned index, numberOfGlyphs = [layoutManager numberOfGlyphs];
		float maxHeight = 0.0f;
		
		NSRange lineRange;
		for (index = 0; index < numberOfGlyphs; ){
			NSRect r = [layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange];
			maxHeight = MAX(maxHeight,r.origin.y+r.size.height);
			index = NSMaxRange(lineRange);
		}
		
		if(maxHeight > maxDesiredHeight) {
			newFontSize -= 0.5;
			[self setFont:[NSFont fontWithName:[[self font] fontName] size:newFontSize]];
		} else {
			keepGoing = NO;
		}
	}
	
}

@end