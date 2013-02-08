//
//  PSCButtonCollectionButton.m
//  Sunlight
//
//  Created by Chloe Stars on 2/7/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCButtonCollectionButton.h"

@implementation PSCButtonCollectionButton
@synthesize defaultButtonImage;
@synthesize selectedButtonImage;
@synthesize isEnabled;
@synthesize buttonCollection;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        defaultButtonImage = self.image;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		defaultButtonImage = self.image;
	}
	return self;
}

// manual button selection
- (void)selectButton {
	[self setImage:selectedButtonImage];
	// disable other buttons
	for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
		if (![self isEqualTo:button]) {
			[button setImage:button.defaultButtonImage];
			[button setIsEnabled:NO];
		}
	}
	isEnabled = YES;
}

- (BOOL)sendAction:(SEL)theAction to:(id)theTarget {
	if (!isEnabled) {
		[self setImage:selectedButtonImage];
		for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
			if (![self isEqualTo:button]) {
				[button setImage:button.defaultButtonImage];
				[button setIsEnabled:NO];
			}
		}
		// send our action that was set
		[super sendAction:theAction to:theTarget];
		isEnabled = YES;
		return YES;
	}
	else {
		return NO;
	}
}

@end
