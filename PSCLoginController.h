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
@property IBOutlet NSTextField *usernameTextField;
@property IBOutlet NSTextField *passwordTextField;
@property IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) void(^successCallback)();

- (IBAction)pressCancel:(id)sender;
- (IBAction)signIn:(id)sender;

@end