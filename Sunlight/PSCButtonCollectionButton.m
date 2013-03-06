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
@synthesize defaultAlternateButtonImage;
@synthesize selectedButtonImage;
@synthesize isEnabled;
@synthesize buttonCollection;
@synthesize indicatorImageView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        defaultButtonImage = self.image;
		defaultAlternateButtonImage = self.alternateImage;
		indicatorImageView = [[NSImageView alloc] init];
		indicatorImageView.image = [NSImage imageNamed:@"indicator"];
		indicatorImageView.frame = NSMakeRect(NSMidX([self bounds])-indicatorImageView.image.size.width/2, self.frame.size.height-indicatorImageView.image.size.height-2, indicatorImageView.image.size.width, indicatorImageView.image.size.height);
		indicatorImageView.alphaValue = 0.0;
		[self addSubview:indicatorImageView];
		[[NSAnimationContext currentContext] setDuration:0.2f];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		defaultButtonImage = self.image;
		defaultAlternateButtonImage = self.alternateImage;
		indicatorImageView = [[NSImageView alloc] init];
		indicatorImageView.image = [NSImage imageNamed:@"indicator"];
		indicatorImageView.frame = NSMakeRect(NSMidX([self bounds])-indicatorImageView.image.size.width/2, self.frame.size.height-indicatorImageView.image.size.height-2, indicatorImageView.image.size.width, indicatorImageView.image.size.height);
		indicatorImageView.alphaValue = 0.0;
		[self addSubview:indicatorImageView];
		[[NSAnimationContext currentContext] setDuration:0.2f];
	}
	return self;
}

- (void)enableIndicator {
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
		[[indicatorImageView animator] setAlphaValue:1.0];
	} completionHandler:^{
	}];
}

- (void)disableIndicator {
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
		[[indicatorImageView animator] setAlphaValue:0.0];
	} completionHandler:^{
	}];
}

// manual button selection
- (void)selectButton {
	[self setImage:selectedButtonImage];
	// remove the pressed state image
	[self setAlternateImage:selectedButtonImage];
	// disable other buttons
	for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
		if (![self isEqualTo:button]) {
			[button setImage:button.defaultButtonImage];
			[button setAlternateImage:button.defaultAlternateButtonImage];
			[button setIsEnabled:NO];
		}
	}
	isEnabled = YES;
}

- (BOOL)sendAction:(SEL)theAction to:(id)theTarget {
	if (!isEnabled) {
		/*[self setImage:selectedButtonImage];
		// remove the pressed state image
		[self setAlternateImage:selectedButtonImage];
		for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
			if (![self isEqualTo:button]) {
				[button setImage:button.defaultButtonImage];
				[button setAlternateImage:button.defaultAlternateButtonImage];
				[button setIsEnabled:NO];
			}
		}*/
		[self selectButton];
		// send our action that was set
		[super sendAction:theAction to:theTarget];
		//isEnabled = YES;
		return YES;
	}
	else {
		return NO;
	}
}

@end
