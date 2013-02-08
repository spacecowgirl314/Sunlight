//
//  PSCAppDelegate.h
//  Sunlight
//
//  Created by Chloe Stars on 9/27/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EQSTRScrollView.h"
#import "AppNetKit.h"
#import "INAppStoreWindow.h"
#import "PSCNewPostController.h"
#import "PSCGradientView.h"
#import "PSCButtonCollection.h"
#import "PSCButtonCollectionButton.h"
#import "PSCLoginController.h"

typedef enum {
    PSCStream,
    PSCMentions,
    PSCStars,
	PSCProfile,
	PSCMessages
} PSCStreamType;

@interface PSCAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {
	PSCButtonCollection *buttonCollection;
	PSCStreamType currentStream;
	NSArray *postsArray;
}

@property (assign) IBOutlet INAppStoreWindow *window;
@property (assign) IBOutlet NSView *titleView;
@property (assign) IBOutlet EQSTRScrollView *appScrollView;
@property (assign) IBOutlet NSTableView *appTableView;
@property (retain, nonatomic) PSCNewPostController *postController;
@property (retain, nonatomic) PSCLoginController *loginController;
@property IBOutlet PSCButtonCollectionButton *streamButton;
@property IBOutlet PSCButtonCollectionButton *mentionsButton;
@property IBOutlet PSCButtonCollectionButton *starsButton;
@property IBOutlet PSCButtonCollectionButton *profileButton;
@property IBOutlet PSCButtonCollectionButton *messagesButton;
@property IBOutlet PSCGradientView *topShadow;
@property (nonatomic) NSString *authToken;
@property (assign) ANPost *replyPost;

@end
