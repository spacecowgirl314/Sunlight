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
#import "PSCLoginController.h"
#import "PSCGradientView.h"
#import "PSCButtonCollection.h"
#import "PSCButtonCollectionButton.h"
#import "PSCNavigationController.h"
#import "PSCBreadcrumbView.h"
#import "PSCLoadMore.h"

typedef enum {
    PSCMyStream,
    PSCMentions,
    PSCStars,
	PSCProfile,
	PSCMessages
} PSCStreamType;

@interface PSCAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate, PSCBreadcrumbViewDelegate, NSUserNotificationCenterDelegate> {
	PSCButtonCollection *buttonCollection;
	PSCStreamType currentStream;
	NSArray *postsArray;
    IBOutlet NSTextField *titleTextField;
	ANResourceID profileUserID;
	PSCNavigationController *navigationController;
	NSMutableDictionary *streamScrollPositions;
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
@property IBOutlet PSCGradientView *breadcrumbShadow;
@property IBOutlet NSTextField *titleTextField;
@property IBOutlet PSCBreadcrumbView *breadcrumbView;
@property IBOutlet NSMenu *menu;
@property (assign) ANPost *replyPost;

- (IBAction)switchToMyStreamFromMenu:(id)sender;
- (IBAction)switchToMentionsFromMenu:(id)sender;
- (IBAction)switchToStarsFromMenu:(id)sender;
- (IBAction)switchToProfileFromMenu:(id)sender;
- (IBAction)switchToMessagesFromMenu:(id)sender;
- (IBAction)switchToStream:(id)sender;
- (IBAction)switchToMentions:(id)sender;
- (IBAction)switchToStars:(id)sender;
- (IBAction)switchToProfile:(id)sender;
- (IBAction)switchToMessages:(id)sender;
- (IBAction)loadPreviousInStream:(id)sender;
- (IBAction)openReplyPost:(id)sender;
- (IBAction)refreshStream:(id)sender;

// test stuff
- (IBAction)scrollPositionTestMethod:(id)sender;

@end
