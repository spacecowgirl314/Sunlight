//
//  PSCAppDelegate.m
//  Sunlight
//
//  Created by Chloe Stars on 9/27/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCAppDelegate.h"
#import "PSCPostCellView.h"
#import "DDHotKeyCenter.h"
#import "NSDate+HumanizedTime.h"
#import <Quartz/Quartz.h>
#import "NS(Attributed)String+Geometrics.h"
#import "RegexKitLite.h"
#import "NSButton+TextColor.h"
#import "PSCMemoryCache.h"
#import "PSCButtonCollection.h"
#import "PSCSwipeableScrollView.h"
#import "NSTimer+Blocks.h"

@implementation PSCAppDelegate
@synthesize postController;
@synthesize loginController;
@synthesize titleView;
@synthesize streamButton;
@synthesize mentionsButton;
@synthesize starsButton;
@synthesize profileButton;
@synthesize messagesButton;
@synthesize titleTextField;
@synthesize appScrollView;
@synthesize appTableView;

- (void)applicationWillBecomeActive:(NSNotification *)notification {
	//[[self window] setAlphaValue:0.0];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	// keep the main window hidden until we know we've been logged in
	[[self window] orderOut:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// register for startup events
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
													   andSelector:@selector(receivedURL:withReplyEvent:)
													 forEventClass:kInternetEventClass
														andEventID:kAEGetURL];
	self.window.trafficLightButtonsLeftMargin = 7.0;
    self.window.trafficLightButtonsTopMargin = 7.0;
    self.window.fullScreenButtonRightMargin = 7.0;
    self.window.hideTitleBarInFullScreen = YES;
    self.window.centerFullScreenButton = YES;
    self.window.centerTrafficLightButtons = NO;
    self.window.titleBarHeight = 60.0;
    self.window.baselineSeparatorColor = [NSColor colorWithDeviceRed:0.624 green:0.624 blue:0.624 alpha:1.0];
	// self.titleView is a an IBOutlet to an NSView that has been configured in IB with everything you want in the title bar
	self.titleView.frame = self.window.titleBarView.bounds;
	self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.window.titleBarView addSubview:self.titleView];
	// do nothing until loaded
	[[self appScrollView] setRefreshBlock:^(EQSTRScrollView *scrollView) {
		[[self appScrollView] stopLoading];
	}];
	[[self appTableView] registerNib:[[NSNib alloc] initWithNibNamed:@"PSCPostCellView" bundle:nil] forIdentifier:@"PostCell"];
	[[NSNotificationCenter defaultCenter]
	 addObserver: self
	 selector: @selector(windowDidResize:)
	 name: NSWindowDidResizeNotification
	 object: self.window];
	[[self topShadow] setStartingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.20f]];
	[[self topShadow] setEndingColor:[NSColor clearColor]];
    [[self topShadow] setAngle:270];
	// setup buttons
	buttonCollection = [[PSCButtonCollection alloc] initWithButtons:@[streamButton, mentionsButton, starsButton, profileButton, messagesButton]];
	[streamButton setSelectedButtonImage:[NSImage imageNamed:@"title-stream-highlight"]];
	[mentionsButton setSelectedButtonImage:[NSImage imageNamed:@"title-mentions-highlight"]];
	[starsButton setSelectedButtonImage:[NSImage imageNamed:@"title-star-highlight"]];
	[profileButton setSelectedButtonImage:[NSImage imageNamed:@"title-user-highlight"]];
	[messagesButton setSelectedButtonImage:[NSImage imageNamed:@"title-inbox-highlight"]];
	[streamButton selectButton];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHashtag:) name:@"Hashtag" object:nil];
    
	// Register
	//[self addOutput:@"Attempting to register hotkey for example 1"];
	//DDHotKeyCenter * c = [[DDHotKeyCenter alloc] init];
	/*if (![c registerHotKeyWithKeyCode:0 modifierFlags:NSAlternateKeyMask target:self action:@selector(hotkeyWithEvent:) object:nil]) {
	 //[self addOutput:@"Unable to register hotkey for example 1"];
	 } else {
	 //[self addOutput:@"Registered hotkey for example 1"];
	 //[self addOutput:[NSString stringWithFormat:@"Registered: %@", [c registeredHotKeys]]];
	 }*/
	// Check the presence of the API key.
	if ([[PSCMemoryCache sharedMemory].authToken length]) {
		// know that we're sure we've been logged in show the main window
		[self.window makeKeyAndOrderFront:self];
		[self prepare];
	} else {
		[self authenticate];
	}
	// check and then setup notifications
	[self checkForMentions];
	NSTimer *mentionsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForMentions) userInfo:nil repeats:YES];
	[NSTimer scheduledTimerWithTimeInterval:60*3 block:^{
		[self loadStream:YES];
	} repeats:YES];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self.window makeKeyAndOrderFront:self];
	return YES;
}

#pragma mark - Login

- (IBAction)openLogin:(id)sender {
	if (!self.loginController) {
		PSCLoginController *pL = [[PSCLoginController alloc] init];
		self.loginController =  pL;
	}
	[self.loginController showWindow:self];
}

#pragma mark - Switching Streams

- (IBAction)switchToStream:(id)sender {
	NSLog(@"Switched to stream.");
	currentStream = PSCStream;
	[self loadStream:NO];
}

- (IBAction)switchToMentions:(id)sender {
	NSLog(@"Switched to mentions.");
	currentStream = PSCMentions;
	[self loadMentions:NO];
}

- (IBAction)switchToStars:(id)sender {
	NSLog(@"Switched to stars.");
	currentStream = PSCStars;
	[self loadStars:NO];
}

- (IBAction)switchToProfile:(id)sender {
	NSLog(@"Switched to profile.");
	currentStream = PSCProfile;
	[self loadProfile:NO];
}

- (IBAction)switchToMessages:(id)sender {
	NSLog(@"Switched to messages.");
	currentStream = PSCMessages;
	[self loadMessages:NO];
}

- (void)showErrorBarWithError:(NSError*)error {
	// prevent resizing. this keeps the user from seeing my poorly formed layout code (ie. moving bar)
	[self.window setResizeIncrements:NSMakeSize(MAXFLOAT, MAXFLOAT)];
	NSString *errorMessage;
	switch ([error code]) {
		case -1004:
			errorMessage = @"App.net appears to be offline.";
			break;
		case -1009:
			errorMessage = @"Internet connection appears offline.";
			break;
		default:
			errorMessage = @"There was an unknown issue connecting to App.net.";
			break;
	}
	NSView *view = self.window.contentView;
	NSImage *notificationImage = [NSImage imageNamed:@"notification-banner"];
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, view.frame.size.height-26, notificationImage.size.width, notificationImage.size.height)];
	NSArray *heightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[imageView(==26)]"
																   options:0
																   metrics:nil
																	 views:NSDictionaryOfVariableBindings(imageView)];
	/*NSArray *topConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[imageView(==0)]"
																	  options:NSLayoutAttributeTop
																	  metrics:nil
																		views:NSDictionaryOfVariableBindings(imageView)];*/
	NSArray *widthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[imageView(>=360)]"
																		 options:0
																		 metrics:nil
																		   views:NSDictionaryOfVariableBindings(imageView)];
	[imageView addConstraints:heightConstraints];
	[imageView addConstraints:widthConstraints];
	//[imageView addConstraints:topConstraints];
	[imageView setImage:notificationImage];
	NSTextField *errorLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(view.frame.size.width/2, imageView.frame.origin.y, view.frame.size.width, notificationImage.size.height)];
	[errorLabel setEditable:NO];
	/*heightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[errorLabel(==26)]"
																		 options:0
																		 metrics:nil
																		   views:NSDictionaryOfVariableBindings(errorLabel)];
	widthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"[errorLabel(>=360)]"
																		options:0
																		metrics:nil
																		  views:NSDictionaryOfVariableBindings(errorLabel)];
	NSLayoutConstraint *centerConstraint = [NSLayoutConstraint constraintWithItem:errorLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0];
	[errorLabel addConstraints:heightConstraints];
	[errorLabel addConstraint:centerConstraint];*/
	errorLabel.autoresizingMask = (NSViewMinXMargin|NSViewMaxXMargin);
	errorLabel.translatesAutoresizingMaskIntoConstraints = YES;
	[errorLabel setStringValue:errorMessage];
	[errorLabel setAlignment:NSCenterTextAlignment];
	[errorLabel setBackgroundColor:[NSColor clearColor]];
	[errorLabel setBordered:NO];
	[errorLabel setFont:[NSFont fontWithName:@"Helvetica Neue Medium" size:13]];
	[errorLabel setTextColor:[NSColor colorWithDeviceRed:0.227 green:0.227 blue:0.227 alpha:1.0]];
	// move the views out of view
	[imageView setFrame:NSMakeRect(imageView.frame.origin.x, imageView.frame.origin.y+imageView.frame.size.height, imageView.frame.size.width, imageView.frame.size.height)];
	[errorLabel setFrame:NSMakeRect(errorLabel.frame.origin.x, errorLabel.frame.origin.y+errorLabel.frame.size.height, errorLabel.frame.size.width, errorLabel.frame.size.height)];
	[view addSubview:imageView positioned:NSWindowBelow relativeTo:self.topShadow];
	[view addSubview:errorLabel positioned:NSWindowAbove relativeTo:imageView];
	[view addSubview:imageView];
	[view addSubview:errorLabel];
	// TODO: insert reactive cocoa here that offsets any movement done by resizing the window vertically
	[NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5f];
	// move the views into view
	[[imageView animator]setFrame:NSMakeRect(imageView.frame.origin.x, imageView.frame.origin.y-imageView.frame.size.height, imageView.frame.size.width, imageView.frame.size.height)];
	[[errorLabel animator] setFrame:NSMakeRect(errorLabel.frame.origin.x, errorLabel.frame.origin.y-errorLabel.frame.size.height, errorLabel.frame.size.width, errorLabel.frame.size.height)];
	[NSAnimationContext endGrouping];
	[NSTimer scheduledTimerWithTimeInterval:3.0 block:^{
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:0.5f];
		[[imageView animator] setFrame:NSMakeRect(imageView.frame.origin.x, imageView.frame.origin.y+imageView.frame.size.height, imageView.frame.size.width, imageView.frame.size.height)];
		[[errorLabel animator] setFrame:NSMakeRect(errorLabel.frame.origin.x, errorLabel.frame.origin.y+errorLabel.frame.size.height, errorLabel.frame.size.width, errorLabel.frame.size.height)];
		[NSAnimationContext endGrouping];
	} repeats:NO];
	[NSTimer scheduledTimerWithTimeInterval:3.0+0.5 block:^{
		// enable resizing again
		[self.window setResizeIncrements:NSMakeSize(1, 1)];
		[imageView removeFromSuperview];
		[errorLabel removeFromSuperview];
	} repeats:NO];
}

#pragma mark - Loading Streams

- (void)loadHashtag:(NSNotification*)theNotification{
	// setup copy view
	NSString *tag = [[theNotification object] substringFromIndex:2];
	NSLog(@"tag:%@", tag);
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
	dispatch_async(queue,^{
		[ANSession.defaultSession postsWithTag:tag completion:^(ANResponse * response, NSArray * posts, NSError * error) {
			if (error) {
				[self showErrorBarWithError:error];
			}
			if(!posts) {
				postsArray = posts;
				[[self appTableView] reloadData];
				dispatch_async(dispatch_get_main_queue(), ^{
					[[self appScrollView] stopLoading];
				});
				return;
			}
			// save posts to memory
			//[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCStream]];
			// theoretical test for loading more posts
			/*ANPost *post =  [posts objectAtIndex:[posts count]];
			 ANResourceID *resourceID = [post ID];
			 [ANSession.defaultSession postsInStreamBetweenID:nil andID:resourceID completion:^(ANResponse *response, NSArray *posts, NSError *error) {
			 
			 }];*/
			postsArray = posts;
			[[self appTableView] reloadData];
			/*dispatch_async(dispatch_get_main_queue(), ^{
				[[self appScrollView] stopLoading];
			});*/
		}];
	});
	/*PSCSwipeableScrollView *newScrollView = [[PSCSwipeableScrollView alloc] initWithFrame:[self appScrollView].frame];
	NSTableView *newTableView = [[NSTableView alloc] initWithFrame:[self appScrollView].frame];
	[newTableView registerNib:[[NSNib alloc] initWithNibNamed:@"PSCPostCellView" bundle:nil] forIdentifier:@"PostCell"];
	//[newScrollView addSubview:newTableView];
	NSTableColumn * column1 = [[NSTableColumn alloc] initWithIdentifier:@"Col1"];
	[column1 setWidth:360];
	// generally you want to add at least one column to the table view.
	[newTableView addTableColumn:column1];
	[newTableView setDelegate:self];
	[newTableView setDataSource:self];
	[newTableView reloadData];
	[newScrollView setDocumentView:newTableView];
	[newScrollView setHasVerticalScroller:YES];
	[[[self window] contentView] addSubview:newScrollView positioned:NSWindowBelow relativeTo:[self appScrollView]];
	NSRect endFrame = NSMakeRect([self appScrollView].frame.origin.x, [self appScrollView].frame.origin.y, [self appScrollView].frame.size.width, [self appScrollView].frame.size.height);
	
	NSRect exitFrame = NSMakeRect(-[self appScrollView].frame.size.height, [self appScrollView].bounds.origin.y, [self appScrollView].frame.size.width, [self appScrollView].frame.size.height);
	[NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5f];
	[newScrollView setFrame:endFrame];
	[[[self appScrollView] animator] setFrame:exitFrame];
	[NSAnimationContext endGrouping];
	self.appScrollView = newScrollView;
	self.appTableView = newTableView;*/
}

- (IBAction)loadMoreInStream:(id)sender {
	
}

- (void)loadStream:(BOOL)reload {
	NSArray *streamPosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCStream]];
    [titleTextField setStringValue:@"My Stream"];
    NSShadow * shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowColor:[NSColor colorWithDeviceWhite:1 alpha:0.5]];
	[streamButton setShadow:shadow];
	for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
		if (![button isEqual:streamButton]) {
			[button setShadow:nil];
		}
	}
	void (^reloadPosts)() = ^() {
		[[[self appScrollView] verticalScroller] setFloatValue:1.0];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			[ANSession.defaultSession postsInStreamWithCompletion:^(ANResponse * response, NSArray * posts, NSError * error) {
				if (error) {
					[self showErrorBarWithError:error];
				}
				if(!posts) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[[self appScrollView] stopLoading];
					});
					return;
				}
				// save posts to memory
				/*[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCStream]];*/
				// simulatenously check for new posts in the stream and filter them
				if ([[PSCMemoryCache sharedMemory] filterNewPostsForKey:[[NSString alloc] initWithFormat:@"%d", PSCStream] posts:posts]) {
					[[NSSound soundNamed:@"151568__lukechalaudio__user-interface-generic.wav"] play];
				}
				// theoretical test for loading more posts
				/*ANPost *post =  [posts objectAtIndex:[posts count]];
				 ANResourceID *resourceID = [post ID];
				 [ANSession.defaultSession postsInStreamBetweenID:nil andID:resourceID completion:^(ANResponse *response, NSArray *posts, NSError *error) {
				 
				 }];*/
				// retrieve filtered posts from memory
				postsArray = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCStream]]; //posts;
				[[self appTableView] reloadData];
				dispatch_async(dispatch_get_main_queue(), ^{
					[[self appScrollView] stopLoading];
				});
			}];
		});
	};
	if (streamPosts) {
		if (!reload) {
			postsArray = streamPosts;
			// scroll to the top and reload or start animating in the cells
			[[[self appScrollView] verticalScroller] setFloatValue:1.0];
			[[self appTableView] reloadData];
		}
		else {
			reloadPosts();
		}
	}
	else
	{
		reloadPosts();
	}
}

- (void)loadMentions:(BOOL)reload {
	NSArray *mentionsPosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCMentions]];
    [titleTextField setStringValue:@"Mentions"];
    NSShadow * shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowColor:[NSColor colorWithDeviceWhite:1 alpha:0.5]];
    [mentionsButton setShadow:shadow];
	for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
		if (![button isEqual:mentionsButton]) {
			[button setShadow:nil];
		}
	}
	void (^reloadPosts)() = ^() {
		[[[self appScrollView] verticalScroller] setFloatValue:1.0];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			[ANSession.defaultSession postsMentioningUserWithID:ANMeUserID betweenID:nil andID:nil completion:^(ANResponse *response, NSArray *posts, NSError *error) {
				if (error) {
					[self showErrorBarWithError:error];
				}
				if(!posts) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[[self appScrollView] stopLoading];
					});
					return;
				}
				// save posts to memory
				[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCMentions]];
				postsArray = posts;
				[[self appTableView] reloadData];
				dispatch_async(dispatch_get_main_queue(), ^{
					[[self appScrollView] stopLoading];
				});
			}];
		});
	};
	if (mentionsPosts) {
		if (!reload) {
			postsArray = mentionsPosts;
			// scroll to the top and reload or start animating in the cells
			[[[self appScrollView] verticalScroller] setFloatValue:1.0];
			[[self appTableView] reloadData];
		}
		else {
			reloadPosts();
		}
	}
	else
	{
		reloadPosts();
	}
}

- (void)loadStars:(BOOL)reload {
	NSArray *starsPosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCStars]];
    [titleTextField setStringValue:@"Starred"];
    NSShadow * shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowColor:[NSColor colorWithDeviceWhite:1 alpha:0.5]];
    [starsButton setShadow:shadow];
	for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
		if (![button isEqual:starsButton]) {
			[button setShadow:nil];
		}
	}
	void (^reloadPosts)() = ^() {
		[[[self appScrollView] verticalScroller] setFloatValue:1.0];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			[ANSession.defaultSession postsStarredByUserWithID:ANMeUserID betweenID:nil andID:nil completion:^(ANResponse * response, NSArray * posts, NSError * error) {
				if (error) {
					[self showErrorBarWithError:error];
				}
				if(!posts) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[[self appScrollView] stopLoading];
					});
					return;
				}
				// save posts to memory
				[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCStars]];
				postsArray = posts;
				[[self appTableView] reloadData];
				dispatch_async(dispatch_get_main_queue(), ^{
					[[self appScrollView] stopLoading];
				});
			}];
		});
	};
	if (starsPosts) {
		if (!reload) {
			postsArray = starsPosts;
			// scroll to the top and reload or start animating in the cells
			[[[self appScrollView] verticalScroller] setFloatValue:1.0];
			[[self appTableView] reloadData];
		}
		else {
			reloadPosts();
		}
	}
	else
	{
		reloadPosts();
	}
}

- (void)loadProfile:(BOOL)reload {
	NSArray *profilePosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCProfile]];
    [titleTextField setStringValue:@"My Profile"];
    NSShadow * shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowColor:[NSColor colorWithDeviceWhite:1 alpha:0.5]];
    [profileButton setShadow:shadow];
    for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
		if (![button isEqual:profileButton]) {
			[button setShadow:nil];
		}
	}
	void (^reloadPosts)() = ^() {
		[[[self appScrollView] verticalScroller] setFloatValue:1.0];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			// Get the latest posts in the user's incoming post stream...
			[ANSession.defaultSession postsForUserWithID:ANMeUserID betweenID:nil andID:nil completion:^(ANResponse * response, NSArray * posts, NSError * error) {
				if (error) {
					[self showErrorBarWithError:error];
				}
				if(!posts) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[[self appScrollView] stopLoading];
					});
					return;
				}
				// save posts to memory
				[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCProfile]];
				postsArray = posts;
				[[self appTableView] reloadData];
				dispatch_async(dispatch_get_main_queue(), ^{
					[[self appScrollView] stopLoading];
				});
			}];
		});
	};
	if (profilePosts) {
		if (!reload) {
			postsArray = profilePosts;
			// scroll to the top and reload or start animating in the cells
			[[[self appScrollView] verticalScroller] setFloatValue:1.0];
			[[self appTableView] reloadData];
		}
		else {
			reloadPosts();
		}
	}
	else
	{
		reloadPosts();
	}
}

- (void)loadMessages:(BOOL)reload {
	// API docs here http://developers.app.net/docs/basics/messaging/
	NSShadow * shadow = [[NSShadow alloc] init];
    [shadow setShadowBlurRadius:5.0];
    [shadow setShadowColor:[NSColor colorWithDeviceWhite:1 alpha:0.5]];
    [messagesButton setShadow:shadow];
    for (PSCButtonCollectionButton *button in buttonCollection.buttons) {
		if (![button isEqual:messagesButton]) {
			[button setShadow:nil];
		}
	}
}

- (void)prepare {
	ANSession.defaultSession.accessToken = [PSCMemoryCache sharedMemory].authToken;
	currentStream = PSCStream;
	// start window off by not being seen
	[[self appScrollView] setRefreshBlock:^(EQSTRScrollView *scrollView) {
		switch (currentStream)
		{
			case PSCStream:
			{
				[self loadStream:YES];
				break;
			}
			case PSCMentions:
			{
				[self loadMentions:YES];
				break;
			}
			case PSCStars:
			{
				[self loadStars:YES];
				break;
			}
			case PSCProfile:
			{
				[self loadProfile:YES];
				break;
			}
			case PSCMessages:
			{
				[self loadMessages:YES];
				break;
			}
		}
	}];
	/*[engine writePost:@"Hello, World! #testing" replyToPostWithID:-1 annotations:nil links:nil block:^(ADNPost *post, NSError *error) {
	 if (error) {
	 //[self requestFailed:error];
	 } else {
	 //[self receivedPost:post];
	 }
	 }];*/
	// Get the latest posts in the user's incoming post stream...
	switch (currentStream)
	{
		case PSCStream:
		{
			[self performSelector:@selector(loadStream:) withObject:NO afterDelay:0.0];
			//[self loadStream];
			break;
		}
		case PSCMentions:
		{
			[self performSelector:@selector(loadMentions:) withObject:NO afterDelay:0.0];
			//[self loadMentions];
			break;
		}
		case PSCStars:
		{
			[self performSelector:@selector(loadStars:) withObject:NO afterDelay:0.0];
			//[self loadStars:NO];
			break;
		}
		case PSCProfile:
		{
			[self performSelector:@selector(loadProfile:) withObject:NO afterDelay:0.0];
			//[self loadProfile:NO];
			break;
		}
		case PSCMessages:
		{
			[self performSelector:@selector(loadMessages:) withObject:NO afterDelay:0.0];
			//[self loadMessages:NO];
			break;
		}
	}
}

#pragma mark - Posting

- (IBAction)openNewPost:(id)sender {
	if (!self.postController) {
		PSCNewPostController *pC = [[PSCNewPostController alloc] init];
		self.postController =  pC;
	}
	[self.postController showWindow:self];
	//[self.postController processResults:[questionField stringValue]];
}

#pragma mark - Mentions Notifications

- (void)checkForMentions {
	[ANSession.defaultSession postsMentioningUserWithID:ANMeUserID betweenID:nil andID:nil completion:^(ANResponse *response, NSArray *posts, NSError *error) {
		// don't continue if there was an error
		if (error) {
			return;
		}
		ANResourceID lastMention = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastMention"];
		for (ANPost *mention in posts) {
			//NSLog(@"this id: %llu > last id: %llu", [mention originalID], lastMention);
			if ([mention originalID] && ([mention originalID]  > lastMention)) {
				//NSString *postURLString = [NSString stringWithFormat:@"https://alpha.app.net/%@/post/%@", username, postId];
				if (![mention isDeleted]) {
					// Deleted posts seem to have nil text
					[self showMention:mention];
				}
				NSLog(@"[%llu] Mentioned by %@: %@", [mention originalID], [[mention user] username], [mention text]);
			}
		}
		// save the lastMention
		[[NSUserDefaults standardUserDefaults] setInteger:[[posts objectAtIndex:0] originalID] forKey:@"lastMention"];
	}];
}

- (void)showMention:(ANPost*)mention
{
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = [NSString stringWithFormat: @"%@ mentioned you", [[mention user] name]];
	notification.informativeText = [mention text];
	notification.actionButtonTitle = @"Reply";
	notification.userInfo = @{ @"post" : mention };
	notification.hasActionButton = YES;
	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
	if (!self.postController) {
		PSCNewPostController *pC = [[PSCNewPostController alloc] init];
		self.postController =  pC;
	}
	[center removeDeliveredNotification:notification];
	switch (notification.activationType) {
		case NSUserNotificationActivationTypeActionButtonClicked:
			NSLog(@"Reply Button was clicked -> quick reply");
			[self.postController draftReply:notification.userInfo[@"post"]];
			[self.postController showWindow:self];
			break;
		case NSUserNotificationActivationTypeContentsClicked:
			NSLog(@"Notification body was clicked -> redirect to item");
			[self.postController draftReply:notification.userInfo[@"post"]];
			[self.postController showWindow:self];
			break;
		default:
			NSLog(@"Notification appears to have been dismissed!");
			break;
	}
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return !notification.isPresented;
}

#pragma mark - Authentication and URL handling

- (void)authenticate {
	[ANAuthenticator.sharedAuthenticator setClientID:@"KXWTJNJeyw5fGQDmfAAcecepf7tp6eEY"];
	[ANAuthenticator.sharedAuthenticator setPasswordGrantSecret:@"kPtJeNSnfQgm4QqQcn7BfHWfeG8c5ZTH"];
	//[ANAuthenticator.sharedAuthenticator setRedirectURL:[NSURL URLWithString:@"sunlight://api-key/"]];
	/*NSURL *url = [ANAuthenticator.sharedAuthenticator URLToAuthorizeForScopes:@[ANScopeStream, ANScopeEmail, ANScopeWritePost, ANScopeFollow, ANScopeMessages]];
	[[NSWorkspace sharedWorkspace] openURL:url];*/
	if (!self.loginController) {
		PSCLoginController *pL = [[PSCLoginController alloc] init];
		self.loginController =  pL;
		[self.loginController setSuccessCallback:^{
			[self.window makeKeyAndOrderFront:self];
			[self prepare];
		}];
	}
	[[self window] orderOut:nil];
	[self.loginController.window setLevel:NSPopUpMenuWindowLevel];
	[NSApp runModalForWindow:self.loginController.window];
	//[self.loginController showWindow:self];
}

- (void)receivedURL:(NSAppleEventDescriptor*)event withReplyEvent: (NSAppleEventDescriptor*)replyEvent
{
	NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	NSRange tkIdRange = [url rangeOfString:@"#access_token="];
	if (tkIdRange.location != NSNotFound) {
		[PSCMemoryCache sharedMemory].authToken = [url substringFromIndex:NSMaxRange(tkIdRange)];
		[self prepare];
		//[statusItem setImage:[NSImage imageNamed:@"status_icon.png"]];
		//[self checkToken];
	}
}

- (void)windowDidResize:(NSNotification*)aNotification {
	for (int i = 0; i < [postsArray count]; i++) {
		[self.appTableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:i]];
	}
}

#pragma mark - NSTableView Delegates

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [postsArray count];
}

- (NSImage*)roundCorners:(NSImage *)image scale:(int)doubling
{
	NSImage *existingImage = image;
	NSSize existingSize = [existingImage size];
	NSSize newSize = NSMakeSize(existingSize.height, existingSize.width);
	NSImage *composedImage = [[NSImage alloc] initWithSize:newSize];
	[composedImage lockFocus];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	NSRect imageFrame = NSRectFromCGRect(CGRectMake(0, 0, 52*doubling, 52*doubling));
	NSBezierPath *clipPath = [NSBezierPath bezierPathWithRoundedRect:imageFrame xRadius:27*doubling yRadius:27*doubling];
	[clipPath setWindingRule:NSEvenOddWindingRule];
	[clipPath addClip];
	[image drawAtPoint:NSZeroPoint fromRect:NSMakeRect(0, 0, newSize.width, newSize.height) operation:NSCompositeSourceOver fraction:1];
	NSColor *strokeColor = [NSColor blackColor];
    [strokeColor set];
    [NSBezierPath setDefaultLineWidth:2.0];
    [[NSBezierPath bezierPathWithRoundedRect:imageFrame xRadius:27*doubling yRadius:27*doubling] stroke];
	[composedImage unlockFocus];
	return composedImage;
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // In IB, the TableColumn's identifier is set to "Automatic". The ATTableCellView's is also set to "Automatic". IB then keeps the two in sync, and we don't have to worry about setting the identifier.
    PSCPostCellView *result = [tableView makeViewWithIdentifier:@"PostCell" owner:nil]; //[PSCPostCellView viewFromNib]; // [tableColumn identifier]
	// clear out the old image first. prevent temporary flickering due to no caching
	[[result avatarView] setImage:nil];
    
	ANPost *post = [postsArray objectAtIndex:row];
	ANUser *user = [post user];
	if ([post repostOf]) {
		//NSLog(@"this is a repost");
		ANUser *userReposting = user;
		user = [[post repostOf] user];
		post = [post repostOf];
		[result showRepost];
		NSString *repostByString = [[NSString alloc] initWithFormat:@"Reposted by %@", [userReposting name]];
		NSMutableAttributedString *repostedByAttributedString = [[NSMutableAttributedString alloc] initWithString:repostByString attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue" size:13], NSForegroundColorAttributeName:[NSColor colorWithDeviceRed:0.500 green:0.500 blue:0.500 alpha:1.0], @"UsernameMatch":[userReposting username]}];
		[repostedByAttributedString addAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue Medium" size:13], NSForegroundColorAttributeName:[NSColor colorWithDeviceRed:0.302 green:0.302 blue:0.302 alpha:1.0]} range:[repostByString rangeOfString:[userReposting name]]];
		[[result repostedUserButton] setAttributedTitle:repostedByAttributedString];
	}
	else {
		//NSLog(@"this is not a repost");
		[result hideRepost];
	}
	
	if ([[post user] ID]==[[post user] ID]) {
		// ANMeUserID
		[[result deleteButton] setHidden:NO];
	}
	else {
		[[result deleteButton] setHidden:YES];
	}
    
    if ([post isDeleted]) {
        [result hideDeletedPost];
    }
    else {
        nil;
    }
    
	// send post to the cell view
	[result setPost:post];
	// set real name
	[[result userField] setStringValue:[user name]];
	// set action button's status, have we starred something?
	if ([post youStarred]) {
		[[result starButton] setImage:[NSImage imageNamed:@"star-highlight"]];
        [[result starButton] setAlternateImage:[NSImage imageNamed:@"star-highlight-pressed"]];
        [[result starButton] setTitle:@"Starred"];
		[[result starButton] setTextColor:[NSColor colorWithDeviceRed:0.894 green:0.541 blue:0.082 alpha:1.0]];
	}
	else {
		[[result starButton] setImage:[NSImage imageNamed:@"timeline-star"]];
        [[result starButton] setTitle:@"Star"];
		[[result starButton] setTextColor:[result defaultButtonColor]];
	}
	if ([post youReposted]) {
		[[result repostButton] setImage:[NSImage imageNamed:@"repost-highlight"]];
        [[result repostButton] setAlternateImage:[NSImage imageNamed:@"repost-highlight-pressed"]];
        [[result repostButton] setTitle:@"Reposted"];
        [[result repostButton] setTextColor:[NSColor colorWithDeviceRed:0.118 green:0.722 blue:0.106 alpha:1.0]];
	}
	else {
		[[result repostButton] setImage:[NSImage imageNamed:@"timeline-repost"]];
        [[result repostButton] setTitle:@"Repost"];
		[[result repostButton] setTextColor:[result defaultButtonColor]];
	}
	if ([post numberOfReplies]>0) {
		[[result conversationImageView] setHidden:NO];
	}
	else {
		[[result conversationImageView] setHidden:YES];
	}
	// set creation date
	NSString *postCreationString = [[post createdAt] stringWithHumanizedTimeDifference:NSDateHumanizedSuffixNone withFullString:NO];
	NSAttributedString *postCreationAttributedString = [[NSAttributedString alloc] initWithString:postCreationString attributes:@{NSShadowAttributeName:[self theShadow]}];
	[[result postCreationField] setAttributedStringValue:postCreationAttributedString];
	// download avatar image and store in a dictionary
	if ([[PSCMemoryCache sharedMemory].avatarImages objectForKey:[user username]])
	{
		[[result avatarView] setImage:[[PSCMemoryCache sharedMemory].avatarImages objectForKey:[user username]]];
	}
	else {
		[[user avatarImage] imageAtSize:[[result avatarView] convertSizeToBacking:[result avatarView].frame.size] completion:^(NSImage *image, NSError *error) {
			if (!error) {
				NSImage *maskedImage = [[PSCMemoryCache sharedMemory] maskImage:image withMask:[NSImage imageNamed:@"avatar-mask"]];
				[[PSCMemoryCache sharedMemory].avatarImages setValue:maskedImage forKey:[user username]];
				[[result avatarView] setImage:maskedImage];
			}
			else {
				[[result avatarView] setImage:nil];
			}
		}];
	}
	// set contents of post
	if (![post isDeleted]) {
		[[[result postView] textStorage] setAttributedString:[self stylizeStatusString:[post text]]];
		[[result postView] setEditable:NO];
		// set height of the post text view
		NSFont *font = [NSFont fontWithName:@"Helvetica Neue Bold" size:13.0f];
		float height = [[post text] heightForWidth:[[self window] frame].size.width font:font];
		//NSLog(@"text height:%f", height);
		result.postScrollView.frame = CGRectMake(result.postView.frame.origin.x, result.postView.frame.origin.y, result.postView.frame.size.width, height);
	}
	else {
		[[result postView] setString:@"[Post deleted]"];
	}
    
    return result;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    //[aTableView deselectRow:rowIndex];
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	//NSLog(@"row:%ld", row);
	ANPost *post = [postsArray objectAtIndex:row];
	if ([post repostOf]) {
		
	}
	NSFont *font = [NSFont fontWithName:@"Helvetica Neue Medium" size:13.0f];
	float height = [[post text] heightForWidth:[[self window] frame].size.width-61-2 font:font]; // 61 was previously 70
	int spaceToTop=15; // 15 was 18
	int padding=10;
	int minimumViewHeight = 105; // 118, actually 139 though //105 was previously 108
	int spaceToBottom=45; // 45 was previous 46
	int extraRepostSpace = ([post repostOf]) ? 19 : 0;
	if (height+spaceToTop+spaceToBottom<minimumViewHeight)
	{
		return minimumViewHeight+extraRepostSpace;
	}
	else {
		return height+spaceToTop+spaceToBottom+padding+extraRepostSpace;
	}
}

#pragma mark -

- (void)fadeOutWindow:(NSWindow*)window{
	float alpha = 1.0;
	[window setAlphaValue:alpha];
	//[window makeKeyAndOrderFront:self];
	for (int x = 0; x < 10; x++) {
		alpha -= 0.1;
		[window setAlphaValue:alpha];
		[NSThread sleepForTimeInterval:0.020];
	}
}

- (void)fadeInWindow:(NSWindow*)window{
	float alpha = 0.0;
	[window setAlphaValue:alpha];
	[window makeKeyAndOrderFront:self];
	for (int x = 0; x < 10; x++) {
		alpha += 0.1;
		[window setAlphaValue:alpha];
		[NSThread sleepForTimeInterval:0.020];
	}
}

- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
	[[self window] center];
	if ([[self window] alphaValue]>0.0f) {
		//[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		[self fadeOutWindow:[self window]];
	}
	else {
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		[self fadeInWindow:[self window]];
	}
	//[_window orderFront:nil];
	NSLog(@"%@",[NSString stringWithFormat:@"Firing -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]);
	NSLog(@"%@", [NSString stringWithFormat:@"Hotkey event: %@", hkEvent]);
}

- (NSShadow*)theShadow {
	NSShadow *textShadow = [[NSShadow alloc] init];
	[textShadow setShadowColor:[NSColor colorWithDeviceWhite:1 alpha:.8]];
	[textShadow setShadowBlurRadius:0];
	[textShadow setShadowOffset:NSMakeSize(0, -1)];
	return textShadow;
}

/*
 Special thanks to Mike Rundle for this. 
 http://flyosity.com/mac-os-x/clickable-tweet-links-hashtags-usernames-in-a-custom-nstextview.php
 */
-(NSAttributedString*)stylizeStatusString:(NSString*)string {
	// Building up our attributed string
	NSMutableAttributedString *attributedStatusString = [[NSMutableAttributedString alloc] initWithString:string];
	[attributedStatusString addAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue" size:13.0f],NSForegroundColorAttributeName:[NSColor colorWithDeviceRed:0.251 green:0.251 blue:0.251 alpha:1.0]} range:NSMakeRange(0, [string length])];

	// Generate arrays of our interesting items. Links, usernames, hashtags.
	NSArray *linkMatches = [self scanStringForLinks:string];
	NSArray *usernameMatches = [self scanStringForUsernames:string];
	NSArray *hashtagMatches = [self scanStringForHashtags:string];
	[attributedStatusString addAttribute:NSShadowAttributeName value:[self theShadow] range:NSMakeRange(0, [string length])];
    
	
	// Iterate across the string matches from our regular expressions, find the range
	// of each match, add new attributes to that range
	for (NSString *linkMatchedString in linkMatches) {
		NSRange range = [string rangeOfString:linkMatchedString];
		if( range.location != NSNotFound ) {
			// Add custom attribute of LinkMatch to indicate where our URLs are found. Could be blue
			// or any other color.
			NSDictionary *linkAttr = [[NSDictionary alloc] initWithObjectsAndKeys:
									  [NSCursor pointingHandCursor], NSCursorAttributeName,
									  [NSColor colorWithDeviceRed:0.157 green:0.459 blue:0.737 alpha:1.0], NSForegroundColorAttributeName,
									  linkMatchedString, @"LinkMatch",
									   [NSFont fontWithName:@"Helvetica Neue Regular" size:13], NSFontAttributeName,
									  nil];
			[attributedStatusString addAttributes:linkAttr range:range];
		}
	}
	
	for (NSString *usernameMatchedString in usernameMatches) {
		NSRange range = [string rangeOfString:usernameMatchedString];
		if( range.location != NSNotFound ) {
			// Add custom attribute of UsernameMatch to indicate where our usernames are found
			NSDictionary *linkAttr2 = [[NSDictionary alloc] initWithObjectsAndKeys:
									   [NSColor colorWithDeviceRed:0.157 green:0.459 blue:0.737 alpha:1.0], NSForegroundColorAttributeName,
									   [NSCursor pointingHandCursor], NSCursorAttributeName,
									   usernameMatchedString, @"UsernameMatch",
									   [NSFont fontWithName:@"Helvetica Neue Regular" size:13], NSFontAttributeName,
									   nil];
			[attributedStatusString addAttributes:linkAttr2 range:range];
		}
	}
	
	for (NSString *hashtagMatchedString in hashtagMatches) {
		NSRange range = [string rangeOfString:hashtagMatchedString];
		if( range.location != NSNotFound ) {
			// Add custom attribute of HashtagMatch to indicate where our hashtags are found
			NSDictionary *linkAttr3 = [[NSDictionary alloc] initWithObjectsAndKeys:
									   [NSColor colorWithDeviceRed:0.639 green:0.639 blue:0.639 alpha:1.0], NSForegroundColorAttributeName,
									   [NSCursor pointingHandCursor], NSCursorAttributeName,
									   hashtagMatchedString, @"HashtagMatch",
									   [NSFont fontWithName:@"Helvetica Neue Regular" size:13], NSFontAttributeName,
									   nil];
			[attributedStatusString addAttributes:linkAttr3 range:range];
		}
	}
	
	return attributedStatusString;
}

#pragma mark -
#pragma mark String parsing

// These regular expressions aren't the greatest. There are much better ones out there to parse URLs, @usernames
// and hashtags out of tweets. Getting the escaping just right is a pain in the ass, so be forewarned.

- (NSArray *)scanStringForLinks:(NSString *)string {
	return [string componentsMatchedByRegex:@"(?i)\\b((?:[a-z][\\w-]+:(?:/{1,3}|[a-z0-9%])|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/?)(?:[^,\\]\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))*(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’])*)"];
	// gruber's crappy regex \\b(([\\w-]+://?|www[.])[^\\s()<>]+(?:\\([\\w\\d]+\\)|([^[:punct:]\\s]|/)))
	// (http(s)?://)?([\\w-]+\\.)+[\\w-]+(/[\\w- ;,./?%&=]*)? works without http
}

- (NSArray *)scanStringForUsernames:(NSString *)string {
	return [string componentsMatchedByRegex:@"@{1}([-A-Za-z0-9_]{2,})"];
}

- (NSArray *)scanStringForHashtags:(NSString *)string {
	return [string componentsMatchedByRegex:@"[\\s]{1,}#{1}([^\\s]{2,})"];
}

@end