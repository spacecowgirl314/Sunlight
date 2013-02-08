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
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)mouseUp:(NSEvent *)theEvent
{
	if (!isEnabled) {
		[self setImage:selectedButtonImage];
		for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
			if (![self isEqualTo:button]) {
				[button setImage:button.defaultButtonImage];
				[button setIsEnabled:NO];
			}
		}
		[super mouseUp:theEvent];
		isEnabled = YES;
	}
}

@end
