//
//  PSCLoginController.h
//  Sunlight
//
//  Created by Brady Valentino on 2013-02-07.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "INAppStoreWindow.h"
#import "PSCGradientView.h"

@interface PSCLoginController: NSWindowController {
    IBOutlet PSCGradientView *loginGradientView;
    IBOutlet NSButton *cancelButton;
}

@property (assign) IBOutlet NSView *titleView;
@property IBOutlet NSButton *cancelButton;

- (IBAction)pressCancel:(id)sender;

@end