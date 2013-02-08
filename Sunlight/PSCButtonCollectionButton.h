//
//  PSCButtonCollectionButton.h
//  Sunlight
//
//  Created by Chloe Stars on 2/7/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PSCButtonCollection.h"

@interface PSCButtonCollectionButton : NSButton

@property NSImage *defaultButtonImage;
@property NSImage *selectedButtonImage;
@property BOOL isEnabled;
@property PSCButtonCollection *buttonCollection;

@end
