//
//  PSCButtonCollection.m
//  Sunlight
//
//  Created by Chloe Stars on 2/7/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCButtonCollection.h"
#import "PSCButtonCollectionButton.h"

@implementation PSCButtonCollection
@synthesize buttons;

- (id)initWithButtons:(NSArray*)_buttons {
	for (PSCButtonCollectionButton *button in _buttons) {
		[button setButtonCollection:self];
	}
	buttons = _buttons;
	
	return self;
}

@end
