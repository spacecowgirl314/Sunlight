//
//  PSCAvatarImageView.h
//  Sunlight
//
//  Created by Chloe Stars on 2/22/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PSCAvatarImageView : NSImageView {
	id realTarget;
	SEL realAction;
}

@end
