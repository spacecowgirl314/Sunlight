//
//  PSCAppDelegate.h
//  Sunlight
//
//  Created by Chloe Stars on 9/27/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EQSTRScrollView.h"

@interface PSCAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet EQSTRScrollView *appScrollView;
@property (assign) IBOutlet NSTableView *appTableView;

@end
