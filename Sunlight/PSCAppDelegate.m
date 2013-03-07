//
//  PSCAppDelegate.m
//  Sunlight
//
//  Created by Chloe Stars on 9/27/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCAppDelegate.h"
#import "PSCPostCellView.h"
#import "PSCProfileCellView.h"
#import "PSCLoadMoreCellView.h"
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
#import "PSCStream.h"
#import "NSDictionary+Compression.h"
#import "NSAlert+Blocks.h"

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
@synthesize breadcrumbShadow;
@synthesize replyPost;
@synthesize topShadow;
@synthesize window;
@synthesize breadcrumbView;
@synthesize menu;

- (void)applicationWillBecomeActive:(NSNotification *)notification {
	//[[self window] setAlphaValue:0.0];
}

- (void)applicationWillFinishLaunching:(NSNotification *)notification {
	// keep the main window hidden until we know we've been logged in
	[[self window] orderOut:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Expiration code
	NSDate *now = [NSDate date];
	NSDate *expireDate = [NSDate dateWithNaturalLanguageString:@"April 1, 2013"];
	if ([now compare:expireDate] == NSOrderedDescending) {
		[menu setAutoenablesItems:NO];
		for (NSMenuItem *item in [menu itemArray]) {
			[item setEnabled:NO];
		}
		[NSAlert showSheetModalForWindow:self.window
								 message:@"Warning"
						 informativeText:@"This build has expired."
							  alertStyle:NSWarningAlertStyle
					   cancelButtonTitle:@"Okay"
					   otherButtonTitles:nil
							   onDismiss:^(int buttonIndex)  {
								   
							   }
								onCancel:^ {
									[[NSApplication sharedApplication] terminate:self];
								}];
	}
    [[self appTableView] setBackgroundColor:[NSColor colorWithDeviceRed:0.941 green:0.941 blue:0.941 alpha:1.0]];
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
    self.window.centerTrafficLightButtons = YES;
    self.window.showsTitle = NO;
    self.window.titleBarHeight = 40.0;
    self.window.baselineSeparatorColor = [NSColor colorWithDeviceRed:0.624 green:0.624 blue:0.624 alpha:1.0];
	// self.titleView is a an IBOutlet to an NSView that has been configured in IB with everything you want in the title bar
	self.titleView.frame = self.window.titleBarView.bounds;
	self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.window.titleBarView addSubview:self.titleView];
	// do nothing until loaded
    [[appScrollView refreshSpinner] setControlSize:NSSmallControlSize];
	[[self appScrollView] setRefreshBlock:^(EQSTRScrollView *scrollView) {
		[[self appScrollView] stopLoading];
	}];
	[[self appTableView] registerNib:[[NSNib alloc] initWithNibNamed:@"PSCPostCellView" bundle:nil] forIdentifier:@"PostCell"];
	[[self appTableView] registerNib:[[NSNib alloc] initWithNibNamed:@"PSCProfileCellView" bundle:nil] forIdentifier:@"ProfileCell"];
	[[self appTableView] registerNib:[[NSNib alloc] initWithNibNamed:@"PSCLoadMoreCellView" bundle:nil] forIdentifier:@"LoadMoreCell"];
	[[NSNotificationCenter defaultCenter]
	 addObserver: self
	 selector: @selector(windowDidResize:)
	 name: NSWindowDidResizeNotification
	 object: self.window];
	[[self topShadow] setStartingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.20f]];
	[[self topShadow] setEndingColor:[NSColor clearColor]];
    [[self topShadow] setAngle:270];
	[[self breadcrumbShadow] setStartingColor:[NSColor colorWithDeviceWhite:0.0f alpha:0.20f]];
	[[self breadcrumbShadow] setEndingColor:[NSColor clearColor]];
    [[self breadcrumbShadow] setAngle:270];
	[[self breadcrumbView] setDelegate:self];
	// setup navigation controller
	navigationController = [[PSCNavigationController alloc] init];
	// setup buttons
	buttonCollection = [[PSCButtonCollection alloc] initWithButtons:@[streamButton, mentionsButton, starsButton, profileButton, messagesButton]];
	[streamButton setSelectedButtonImage:[NSImage imageNamed:@"title-stream-highlight"]];
	[mentionsButton setSelectedButtonImage:[NSImage imageNamed:@"title-mentions-highlight"]];
	[starsButton setSelectedButtonImage:[NSImage imageNamed:@"title-star-highlight"]];
	[profileButton setSelectedButtonImage:[NSImage imageNamed:@"title-user-highlight"]];
	[messagesButton setSelectedButtonImage:[NSImage imageNamed:@"title-inbox-highlight"]];
	[streamButton selectButton];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadHashtag:) name:@"Hashtag" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadConversation:) name:@"Conversation" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadProfileFromNotification:) name:@"Profile" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadPreviousInStream:) name:@"LoadMore" object:nil];
    
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
		[self loadMyStream:YES];
	} repeats:YES];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
	[self.window makeKeyAndOrderFront:self];
	return YES;
}

#pragma mark - Breadcrumbs

- (void)breadcrumbView:(PSCBreadcrumbView *)view didTapItemAtIndex:(NSUInteger)index
{
	[navigationController popStreamAtIndex:(int)index];
	PSCStream *stream = [navigationController streamAtIndex:(int)index];
	[self popStreamWithPosts:stream.posts];
}

- (void)breadcrumbViewDidTapStartButton:(PSCBreadcrumbView *)view
{
	NSLog(@"Start");
	[navigationController clear];
	[self popIntoCurrentStream];
}

#pragma mark - Miscellanious Methods

/* from
 https://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/NSScrollViewGuide/Articles/Scrolling.html
 */
- (void)scrollToTop {
	NSPoint newScrollOrigin;
	
    // assume that the scrollview is an existing variable
    if ([[appScrollView documentView] isFlipped]) {
        newScrollOrigin=NSMakePoint(0.0,0.0);
    } else {
        newScrollOrigin=NSMakePoint(0.0,NSMaxY([[appScrollView documentView] frame])
									-NSHeight([[appScrollView contentView] bounds]));
    }
	
    [[appScrollView documentView] scrollPoint:newScrollOrigin];
}

#pragma mark - Switching Streams

// by keeping selectButton out of the original action we're keeping performance uniform
- (IBAction)switchToMyStreamFromMenu:(id)sender {
	[[[buttonCollection buttons] objectAtIndex:0] selectButton];
	[self switchToStream:sender];
}

- (IBAction)switchToMentionsFromMenu:(id)sender {
	[[[buttonCollection buttons] objectAtIndex:1] selectButton];
	[self switchToMentions:sender];
}

- (IBAction)switchToStarsFromMenu:(id)sender {
	[[[buttonCollection buttons] objectAtIndex:2] selectButton];
	[self switchToStars:sender];
}

- (IBAction)switchToProfileFromMenu:(id)sender {
	[[[buttonCollection buttons] objectAtIndex:3] selectButton];
	[self switchToProfile:sender];
}

- (IBAction)switchToMessagesFromMenu:(id)sender {
	[[[buttonCollection buttons] objectAtIndex:4] selectButton];
	[self switchToMessages:sender];
}

- (IBAction)switchToStream:(id)sender {
	NSLog(@"Switched to stream.");
	currentStream = PSCMyStream;
	[[[buttonCollection buttons] objectAtIndex:0] disableIndicator];
	[self loadMyStream:NO];
}

- (IBAction)switchToMentions:(id)sender {
	NSLog(@"Switched to mentions.");
	currentStream = PSCMentions;
	[[[buttonCollection buttons] objectAtIndex:1] disableIndicator];
	[self loadMentions:NO];
}

- (IBAction)switchToStars:(id)sender {
	NSLog(@"Switched to stars.");
	currentStream = PSCStars;
	[[[buttonCollection buttons] objectAtIndex:2] disableIndicator];
	[self loadStars:NO];
}

- (IBAction)switchToProfile:(id)sender {
	NSLog(@"Switched to profile.");
	currentStream = PSCProfile;
	[[[buttonCollection buttons] objectAtIndex:3] disableIndicator];
	[self loadProfile:NO];
}

- (IBAction)switchToMessages:(id)sender {
	NSLog(@"Switched to messages.");
	currentStream = PSCMessages;
	[[[buttonCollection buttons] objectAtIndex:4] disableIndicator];
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
	NSImageView *imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, view.frame.size.height-26-breadcrumbView.frame.size.height, notificationImage.size.width, notificationImage.size.height)];
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
	[view addSubview:imageView positioned:NSWindowBelow relativeTo:self.breadcrumbShadow];
	[view addSubview:errorLabel positioned:NSWindowAbove relativeTo:imageView];
	// TODO: insert reactive cocoa here that offsets any movement done by resizing the window vertically
	[NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.2f];
	// move the views into view
	[[imageView animator]setFrame:NSMakeRect(imageView.frame.origin.x, imageView.frame.origin.y-imageView.frame.size.height, imageView.frame.size.width, imageView.frame.size.height)];
	[[errorLabel animator] setFrame:NSMakeRect(errorLabel.frame.origin.x, errorLabel.frame.origin.y-errorLabel.frame.size.height, errorLabel.frame.size.width, errorLabel.frame.size.height)];
	[NSAnimationContext endGrouping];
	[NSTimer scheduledTimerWithTimeInterval:3.0 block:^{
		[NSAnimationContext beginGrouping];
		[[NSAnimationContext currentContext] setDuration:0.2f];
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

- (PSCBreadcrumbItem *)item:(NSString *)title {
	PSCBreadcrumbItem *item = [[PSCBreadcrumbItem alloc] init];
	item.title = title;
	return item;
}

- (void)loadConversation:(NSNotification*)notification {
	ANPost *postWithReplies = [notification object];
	[postWithReplies replyPostsWithCompletion:^(ANResponse *response, NSArray *posts, NSError *error) {
		if (error) {
			[self showErrorBarWithError:error];
			return;
		}
		[breadcrumbView pushItem:[self item:@"Conversation"]];
		//currentStream = PSCConversation;
		[titleTextField setStringValue:@"Conversation"];
		[self scrollToTop];
		[self pushStreamWithPosts:posts];
		PSCStream *stream = [PSCStream new];
		[stream setPosts:posts];
		[stream setReloadPosts:^{
			[postWithReplies replyPostsWithCompletion:^(ANResponse *response, NSArray *posts, NSError *error) {
				if (error) {
					[self showErrorBarWithError:error];
					return;
				}
				postsArray = posts;
				[[self appTableView] reloadData];
				dispatch_async(dispatch_get_main_queue(), ^{
					[[self appScrollView] stopLoading];
				});
			}];
		}];
		[navigationController pushStream:stream];
	}];
}

- (void)reloadStreamWithPosts:(NSMutableArray*)posts newSet:(NSIndexSet*)newSet deletedPosts:(NSArray*)deletedPosts {
	// Inject Load More Cell View
	[posts insertObject:[PSCLoadMore new] atIndex:posts.count];
	for (NSIndexSet *theSet in deletedPosts) {
		[[self appTableView] removeRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideLeft];
	}
	postsArray = posts;
	// insert new rows:
	[[self appTableView] insertRowsAtIndexes:newSet withAnimation:NSTableViewAnimationSlideDown];
}

- (void)pushStreamWithPosts:(NSArray*)newPosts
{
	[self scrollToTop];
	// remove current rows if present
	NSRange range = NSMakeRange(0, [postsArray count]);
	NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	[[self appTableView] removeRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideLeft];
	postsArray = newPosts;
	// insert new rows:
	range = NSMakeRange(0, [newPosts count]);
	theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	[[self appTableView] insertRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideRight];
}

- (void)popStreamWithPosts:(NSArray*)previousPosts
{
	// TODO: Set the current scroll position in the current stream before popping
	// remove current rows if present
	NSRange range = NSMakeRange(0, [postsArray count]);
	NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	[[self appTableView] removeRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideRight];
	postsArray = previousPosts;
	// insert new rows:
	range = NSMakeRange(0, [previousPosts count]);
	theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	[[self appTableView] insertRowsAtIndexes:theSet withAnimation:NSTableViewAnimationSlideLeft];
}

- (void)loadHashtag:(NSNotification*)theNotification {
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
				[self pushStreamWithPosts:posts];
				PSCStream *stream = [PSCStream new];
				[stream setPosts:posts];
				[stream setReloadPosts:^{
					[ANSession.defaultSession postsWithTag:tag completion:^(ANResponse * response, NSArray * posts, NSError * error) {
						if (error) {
							[self showErrorBarWithError:error];
						}
						postsArray = posts;
						[[self appTableView] reloadData];
						dispatch_async(dispatch_get_main_queue(), ^{
							[[self appScrollView] stopLoading];
						});
					}];
				}];
				[navigationController pushStream:stream];
				return;
			}
			[breadcrumbView pushItem:[self item:[[NSString alloc] initWithFormat:@"#%@", tag]]];
			[self pushStreamWithPosts:posts];
			PSCStream *stream = [PSCStream new];
			[stream setPosts:posts];
			[stream setReloadPosts:^{
				[ANSession.defaultSession postsWithTag:tag completion:^(ANResponse * response, NSArray * posts, NSError * error) {
					if (error) {
						[self showErrorBarWithError:error];
					}
					postsArray = posts;
					[[self appTableView] reloadData];
					dispatch_async(dispatch_get_main_queue(), ^{
						[[self appScrollView] stopLoading];
					});
				}];
			}];
			[navigationController pushStream:stream];
		}];
	});
}

- (void)loadPreviousInStream:(NSNotification*)notification {
	// -2 instead of -1 because we're skipping the PSCLoadMore item
	ANPost *lastPost = [postsArray objectAtIndex:postsArray.count-2];
	[ANSession.defaultSession postsInStreamBetweenID:ANUnspecifiedPostID andID:lastPost.ID completion:^(ANResponse *response, NSArray *posts, NSError *error) {
		NSMutableArray *stream = [postsArray mutableCopy];
		// Start adding at index position postsArray.count-2 and current array has count items
		NSRange range = NSMakeRange(postsArray.count-1, [posts count]);
		NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
		[stream insertObjects:posts atIndexes:indexSet];
		postsArray = stream;
		[[self appTableView] reloadData];
	}];
}

- (void)loadMyStream:(BOOL)reload {
	[self loadMyStream:reload popping:NO];
}

- (void)loadMyStream:(BOOL)reload popping:(BOOL)isPopping {
	NSArray *streamPosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCMyStream]];
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
		// set up the current user for operations if not yet done
		if (![[PSCMemoryCache sharedMemory] currentUser]) {
			[self setCurrentUser];
		}
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
				/*[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCMyStream]];*/
				BOOL isFirstTime = NO;
				if ([[[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCMyStream]] count]==0) {
					isFirstTime=YES;
				}
				NSDictionary *deltaIndices = [[PSCMemoryCache sharedMemory] filterNewPostsForKey:[[NSString alloc] initWithFormat:@"%d", PSCMyStream] posts:posts];
				// simulatenously check for new posts in the stream and filter them
				if ([deltaIndices objectForKey:@"newPosts"]) {
					[[[buttonCollection buttons] objectAtIndex:0] enableIndicator];
					[[NSSound soundNamed:@"151568__lukechalaudio__user-interface-generic.wav"] play];
				}
				// retrieve filtered posts from memory only if we are in the stream view
				if (currentStream==PSCMyStream && navigationController.levels==0) {
					[titleTextField setStringValue:@"My Stream"];
					[breadcrumbView clear];
					[navigationController clear];
					[breadcrumbView setStartTitle:@"My Stream"];
					//postsArray = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCMyStream]]; //posts;
					// grab deleted sets and new post set and animate
					NSMutableArray *cachedPostsMemory = [[[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCMyStream]] mutableCopy];
					// detect if we have any posts already.
					if (isFirstTime) {
						// Inject Load More Cell View
						[cachedPostsMemory insertObject:[PSCLoadMore new] atIndex:cachedPostsMemory.count];
						postsArray = cachedPostsMemory;
						[[self appTableView] reloadData];
					}
					else {
						if ([deltaIndices objectForKey:@"newPosts"]) {
							[self reloadStreamWithPosts:cachedPostsMemory newSet:[deltaIndices objectForKey:@"newPosts"] deletedPosts:[deltaIndices objectForKey:@"deletedPosts"]];
						}
					}
					dispatch_async(dispatch_get_main_queue(), ^{
						[[self appScrollView] stopLoading];
					});
				}
			}];
		});
	};
	if (streamPosts) {
		if (!reload) {
			[titleTextField setStringValue:@"My Stream"];
			[breadcrumbView clear];
			[navigationController clear];
			[breadcrumbView setStartTitle:@"My Stream"];
			// Inject Load More Cell View
			NSMutableArray *profileInjection = [streamPosts mutableCopy];
			[profileInjection insertObject:[PSCLoadMore new] atIndex:streamPosts.count];
			if (isPopping) {
				[self popStreamWithPosts:profileInjection];
			}
			else {
				postsArray = profileInjection;
				[[self appTableView] reloadData];
			}
			[self scrollToTop];
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

- (void)popIntoMyStream {
	[self loadMyStream:NO popping:YES];
}

- (void)loadMentions:(BOOL)reload {
	[self loadMentions:reload popping:NO];
}

- (void)loadMentions:(BOOL)reload popping:(BOOL)isPopping {
	NSArray *mentionsPosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCMentions]];
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
		// set up the current user for operations if not yet done
		if (![[PSCMemoryCache sharedMemory] currentUser]) {
			[self setCurrentUser];
		}
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
				if (currentStream==PSCMentions) {
					[titleTextField setStringValue:@"Mentions"];
					[breadcrumbView clear];
					[navigationController clear];
					[breadcrumbView setStartTitle:@"Mentions"];
					[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCMentions]];
					postsArray = posts;
					[[self appTableView] reloadData];
					dispatch_async(dispatch_get_main_queue(), ^{
						[[self appScrollView] stopLoading];
					});
				}
			}];
		});
	};
	if (mentionsPosts) {
		if (!reload) {
			[titleTextField setStringValue:@"Mentions"];
			[breadcrumbView clear];
			[navigationController clear];
			[breadcrumbView setStartTitle:@"Mentions"];
			if (isPopping) {
				[self popStreamWithPosts:mentionsPosts];
			}
			else {
				postsArray = mentionsPosts;
				[[self appTableView] reloadData];
			}
			[self scrollToTop];
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

- (void)popIntoMentions {
	[self loadMentions:NO popping:YES];
}

- (void)loadStars:(BOOL)reload {
	[self loadStars:reload popping:NO];
}

- (void)loadStars:(BOOL)reload popping:(BOOL)isPopping {
	NSArray *starsPosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCStars]];
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
		// set up the current user for operations if not yet done
		if (![[PSCMemoryCache sharedMemory] currentUser]) {
			[self setCurrentUser];
		}
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
				if (currentStream==PSCStars) {
					[titleTextField setStringValue:@"Starred"];
					[breadcrumbView clear];
					[navigationController clear];
					[breadcrumbView setStartTitle:@"Starred"];
					[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCStars]];
					postsArray = posts;
					[[self appTableView] reloadData];
					dispatch_async(dispatch_get_main_queue(), ^{
						[[self appScrollView] stopLoading];
					});
				}
			}];
		});
	};
	if (starsPosts) {
		if (!reload) {
			[titleTextField setStringValue:@"Starred"];
			[breadcrumbView clear];
			[navigationController clear];
			[breadcrumbView setStartTitle:@"Starred"];
			if (isPopping) {
				[self popStreamWithPosts:starsPosts];
			}
			else {
				postsArray = starsPosts;
				[[self appTableView] reloadData];
			}
			[self scrollToTop];
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

- (void)popIntoStars {
	[self loadStars:NO popping:YES];
}

- (void)loadProfileFromNotification:(NSNotification*)notification {
	NSString *username = [notification object];
	NSRange isRange = [username rangeOfString:@"@" options:NSCaseInsensitiveSearch];
	if(isRange.location == 0) {
		//found it...
		username = [[notification object] substringFromIndex:1];
	}
	[self loadProfile:YES withUsername:username popping:NO];
}

- (void)loadProfile:(BOOL)reload {
	[self loadProfile:reload withUsername:[[[PSCMemoryCache sharedMemory] currentUser] username] popping:NO];
}

- (void)loadProfile:(BOOL)reload withUsername:(NSString*)username popping:(BOOL)isPopping {
	NSArray *profilePosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCProfile]];
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
		// set up the current user for operations if not yet done
		if (![[PSCMemoryCache sharedMemory] currentUser]) {
			[self setCurrentUser];
		}
		[[[self appScrollView] verticalScroller] setFloatValue:1.0];
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			// Get the latest posts in the user's incoming post stream...
			[ANSession.defaultSession userWithUsername:username completion:^(ANResponse *response, ANUser *user, NSError *error) {
				if (error) {
					[self showErrorBarWithError:error];
					return;
				}
				else {
					[ANSession.defaultSession postsForUserWithID:[user ID] betweenID:nil andID:nil completion:^(ANResponse * response, NSArray * posts, NSError * error) {
						if (error) {
							[self showErrorBarWithError:error];
							return;
						}
						// set title
						if ([user ID]==[[[PSCMemoryCache sharedMemory] currentUser] ID] && currentStream==PSCProfile) {
							if ([[PSCMemoryCache sharedMemory] filterNewPostsForKey:[[NSString alloc] initWithFormat:@"%d", PSCProfile] posts:posts]) {
								//[[NSSound soundNamed:@"151568__lukechalaudio__user-interface-generic.wav"] play];
							}
							[titleTextField setStringValue:@"My Profile"];
							[breadcrumbView clear];
							[navigationController clear];
							[breadcrumbView setStartTitle:@"My Profile"];
						}
						else {
							if ([[PSCMemoryCache sharedMemory] filterNewPostsForKey:[[NSString alloc] initWithFormat:@"%lld", [user ID]] posts:posts]) {
								//[[NSSound soundNamed:@"151568__lukechalaudio__user-interface-generic.wav"] play];
							}
							[breadcrumbView pushItem:[self item:@"Profile"]];
							[titleTextField setStringValue:@"Profile"];
						}
						if(!posts) {
							dispatch_async(dispatch_get_main_queue(), ^{
								[[self appScrollView] stopLoading];
							});
							return;
						}
						// save posts to memory
						//[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCProfile]];
						
						// Retrieve filtered posts
						NSArray *filteredPosts;
						if ([user ID]==[[[PSCMemoryCache sharedMemory] currentUser] ID] && currentStream==PSCProfile) {
							filteredPosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%d", PSCProfile]];
						}
						else {
							filteredPosts = [[[PSCMemoryCache sharedMemory] streamsDictionary] objectForKey:[[NSString alloc] initWithFormat:@"%lld", [user ID]]];
						}
						
						// Inject Profile Cell View
						NSMutableArray *profileInjection = [filteredPosts mutableCopy];
						[profileInjection insertObject:user atIndex:0];
						
						if ([user ID]==[[[PSCMemoryCache sharedMemory] currentUser] ID] && currentStream==PSCProfile) {
							postsArray = profileInjection;
							//postsArray = posts;
							[[self appTableView] reloadData];
						}
						else {
							// we're pushing a profile to the navigation controller
							[self pushStreamWithPosts:profileInjection];
							PSCStream *stream = [PSCStream new];
							[stream setPosts:profileInjection];
							[stream setReloadPosts:^{
								[ANSession.defaultSession postsForUserWithID:[user ID] betweenID:nil andID:nil completion:^(ANResponse * response, NSArray * posts, NSError * error) {
									if (error) {
										[self showErrorBarWithError:error];
										return;
									}
									// Inject Profile Cell View
									NSMutableArray *profileInjection = [posts mutableCopy];
									[profileInjection insertObject:user atIndex:0];
									postsArray = profileInjection;
									[[self appTableView] reloadData];
									dispatch_async(dispatch_get_main_queue(), ^{
										[[self appScrollView] stopLoading];
									});
								}];
							}];
							[navigationController pushStream:stream];
						}
						dispatch_async(dispatch_get_main_queue(), ^{
							[[self appScrollView] stopLoading];
						});
					}];
				}
			}];
		});
	};
	if (profilePosts) {
		if (!reload) {
			// set title
			[titleTextField setStringValue:@"My Profile"];
			[breadcrumbView clear];
			[navigationController clear];
			[breadcrumbView setStartTitle:@"My Profile"];
			// Inject Profile Cell View
			NSMutableArray *profileInjection = [profilePosts mutableCopy];
			[profileInjection insertObject:[[PSCMemoryCache sharedMemory] currentUser] atIndex:0];
			if (isPopping) {
				[self popStreamWithPosts:profileInjection];
			}
			else {
				postsArray = profileInjection;
				//postsArray = profilePosts;
				[[self appTableView] reloadData];
			}
			[self scrollToTop];
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

- (void)popIntoProfile {
	[self loadProfile:NO withUsername:[[[PSCMemoryCache sharedMemory] currentUser] username] popping:YES];
}

- (void)loadMessages:(BOOL)reload {
	[self loadMessages:reload popping:NO];
}

- (void)loadMessages:(BOOL)reload popping:(BOOL)isPopping {
	postsArray = nil;
	[[self appTableView] reloadData];
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
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
	dispatch_async(queue,^{
		[ANSession.defaultSession messagesForUserWithCompletion:^(ANResponse *response, NSArray *posts, NSError *error) {
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
			if (currentStream==PSCMessages) {
				[titleTextField setStringValue:@"Messages"];
				[breadcrumbView clear];
				[navigationController clear];
				[breadcrumbView setStartTitle:@"Messages"];
				[[[PSCMemoryCache sharedMemory] streamsDictionary] setObject:posts forKey:[[NSString alloc] initWithFormat:@"%d", PSCMessages]];
				postsArray = posts;
				[[self appTableView] reloadData];
				dispatch_async(dispatch_get_main_queue(), ^{
					[[self appScrollView] stopLoading];
				});
			}
		}];
	});
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self appScrollView] stopLoading];
	});
	// do popping thing and reload thing here
}

- (void)popIntoMessages {
	[self loadMessages:NO popping:YES];
}

- (void)popIntoCurrentStream {
	switch (currentStream)
	{
		case PSCMyStream:
		{
			[self popIntoMyStream];
			break;
		}
		case PSCMentions:
		{
			[self popIntoMentions];
			break;
		}
		case PSCStars:
		{
			[self popIntoStars];
			break;
		}
		case PSCProfile:
		{
			[self popIntoProfile];
			break;
		}
		case PSCMessages:
		{
			[self popIntoMessages];
			break;
		}
	}

}

#pragma mark - Preparations and setup stuff

- (void)setCurrentUser {
	// set current user
	[ANSession.defaultSession userWithID:ANMeUserID completion:^(ANResponse *response, ANUser *user, NSError *error) {
		if (error) {
			return;
		}
		[[PSCMemoryCache sharedMemory] setCurrentUser:user];
	}];
}

- (IBAction)refreshStream:(id)sender {
	[self reload];
}

- (void)reload {
	if (navigationController.levels!=0) {
		PSCStream *stream = [navigationController streamAtIndex:navigationController.levels-1];
		stream.reloadPosts();
		//[[self appScrollView] stopLoading];
		return;
	}
	switch (currentStream)
	{
		case PSCMyStream:
		{
			[self loadMyStream:YES];
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
}

- (void)prepare {
	ANSession.defaultSession.accessToken = [PSCMemoryCache sharedMemory].authToken;
	currentStream = PSCMyStream;
	// set up the current user for operations if not yet done
	if (![[PSCMemoryCache sharedMemory] currentUser]) {
		[self setCurrentUser];
	}
	// start window off by not being seen
	[[self appScrollView] setRefreshBlock:^(EQSTRScrollView *scrollView) {
		[self reload];
	}];
	// Get the latest posts in the user's incoming post stream...
	switch (currentStream)
	{
		case PSCMyStream:
		{
			[self performSelector:@selector(loadMyStream:) withObject:NO afterDelay:0.0];
			//[self loadMyStream:YES];
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
		//[self showMention:(ANPost*)[posts objectAtIndex:0]];
		[[NSUserDefaults standardUserDefaults] setInteger:[[posts objectAtIndex:0] originalID] forKey:@"lastMention"];
	}];
}

- (BOOL)random {
	int tmp = (arc4random() % 30)+1;
    if(tmp % 5 == 0)
        return YES;
    return NO;
}

- (void)showMention:(ANPost*)mention
{
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = [NSString stringWithFormat: @"%@ mentioned you", [[mention user] name]];
	notification.informativeText = [mention text];
	notification.actionButtonTitle = @"Reply";
	NSNumber *postID = [NSNumber numberWithLongLong:mention.ID];
	notification.userInfo = @{@"postID":postID};
	notification.hasActionButton = YES;
	notification.soundName = [self random] ? @"171671__fins__success-1.wav" : @"171670__fins__success-2.wav";
	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
	if (!self.postController) {
		PSCNewPostController *pC = [[PSCNewPostController alloc] init];
		self.postController =  pC;
	}
	[center removeDeliveredNotification:notification];
	NSNumber *numberPostID = notification.userInfo[@"postID"];
	ANResourceID postID = [numberPostID longLongValue];
	[ANSession.defaultSession postWithID:postID completion:^(ANResponse *response, ANPost *post, NSError *error) {
		// TODO: detect if the post was deleted. if it was show an error
		switch (notification.activationType) {
			case NSUserNotificationActivationTypeActionButtonClicked:
				NSLog(@"Reply Button was clicked -> quick reply");
				[self.postController draftReply:post];
				[self.postController showWindow:self];
				break;
			case NSUserNotificationActivationTypeContentsClicked:
				NSLog(@"Notification body was clicked -> redirect to item");
				[self.postController draftReply:post];
				[self.postController showWindow:self];
				break;
			default:
				NSLog(@"Notification appears to have been dismissed!");
				break;
		}
	}];
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

- (CGSize)convertSizeToScale:(CGSize)size scale:(double)scale
{
    return CGSizeMake(size.width*scale, size.height*scale);
}

- (PSCProfileCellView*)configureProfileCellView:(NSTableView*)tableView user:(ANUser*)user
{
	PSCProfileCellView *profileCellView = [tableView makeViewWithIdentifier:@"ProfileCell" owner:nil];
	// clear out the banner and avatar view every time we configure a new profile cell view
	[[profileCellView bannerView] setImage:nil];
	[[profileCellView avatarView] setImage:nil];
	// TODO: then load them both cached
	// send user to the cell
	[profileCellView setUser:user];
	// set name
	NSString *name = [[NSString alloc] initWithFormat:@"%@ %@", [user name], [[user username] appNetUsernameString]];
	NSMutableAttributedString *nameAttributedString = [[NSMutableAttributedString alloc] initWithString:name attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue Medium" size:18], NSForegroundColorAttributeName:[NSColor whiteColor]}];
	[nameAttributedString addAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue" size:14], NSForegroundColorAttributeName:[NSColor colorWithDeviceWhite:1.0 alpha:0.85]} range:[name rangeOfString:[[user username] appNetUsernameString]]];
	//[[profileCellView userField] setStringValue:name];
	[[profileCellView userField] setAttributedStringValue:nameAttributedString];
	// set biography and protect from derps who don't have any biography set
	if ([[user userDescription] text]) {
		[[profileCellView biographyView] setStringValue:[[user userDescription] text]];
	}
	else {
		[[profileCellView biographyView] setStringValue:@""];
	}
	[[profileCellView followingCount] setIntegerValue:[[user counts] following]];
	[[profileCellView followerCount] setIntegerValue:[[user counts] followers]];
	[[profileCellView starredCount] setIntegerValue:[[user counts] stars]];
	if ([user followsYou]) {
		[[profileCellView isFollowingYouField] setStringValue:@"Following You"];
	}
	else {
		[[profileCellView isFollowingYouField] setStringValue:@"Not Following You"];
	}
	if ([user youFollow]) {
		[[profileCellView followButton] setImage:[NSImage imageNamed:@"profile-following-check"]];
		[[profileCellView followButton] setTitle:@" Following"];
		[[profileCellView followButton] setTextColor:[NSColor colorWithDeviceRed:0.161 green:0.376 blue:0.733 alpha:1]];
	}
	else {
		[[profileCellView followButton] setImage:[NSImage imageNamed:@"profile-following-add"]];
		[[profileCellView followButton] setTitle:@" Follow"];
		[[profileCellView followButton] setTextColor:[profileCellView defaultButtonColor]];
	}
	if ([user ID]==[[[PSCMemoryCache sharedMemory] currentUser] ID]) {
		[[profileCellView isYou] setHidden:NO];
		[[profileCellView followButton] setHidden:YES];
		[[profileCellView isFollowingYouField] setHidden:YES];
	}
	else {
		[[profileCellView isYou] setHidden:YES];
		[[profileCellView followButton] setHidden:NO];
		[[profileCellView isFollowingYouField] setHidden:NO];
	}
	// set avatar image.. note: don't use the cache because we request a different size here
	// also some weird stuff goes on here with the width, it increases by itself. Use height instead.
	[[user avatarImage] imageAtSize:CGSizeMake(profileCellView.avatarView.frame.size.height*window.backingScaleFactor, profileCellView.avatarView.frame.size.height*window.backingScaleFactor) completion:^(NSImage *image, NSError *error) {
		if (!error) {
			NSImage *maskedImage = [[PSCMemoryCache sharedMemory] maskImage:image withMask:[NSImage imageNamed:@"avatar-mask"]];
			[[profileCellView avatarView] setImage:maskedImage];
		}
		else {
			[[profileCellView avatarView] setImage:nil];
		}
	}];
	// set banner
	[[user coverImage] imageAtSize:[self convertSizeToScale:profileCellView.bannerView.frame.size scale:window.backingScaleFactor] completion:^(NSImage *image, NSError *error) {
		if (!error) {
			[[profileCellView bannerView] setImage:image];
		}
		else {
			[[profileCellView bannerView] setImage:nil];
		}
	}];
	return profileCellView;
}

- (void)carouselFix:(NSImageView*)imageView image:(NSImage*)image tableView:(NSTableView*)tableView rowIndex:(NSInteger)rowIndex {
	NSRange visibleRows = [tableView rowsInRect:[tableView visibleRect]];
	if (NSLocationInRange(rowIndex, visibleRows)) {
		[imageView setImage:image];
	}
	else {
		NSLog(@"Prevented carouselling");
	}
}

- (PSCPostCellView*)configurePostCellView:(NSTableView*)tableView post:(ANPost*)post rowIndex:(NSUInteger)rowIndex
{
	PSCPostCellView *result = [tableView makeViewWithIdentifier:@"PostCell" owner:nil];
	// clear out the old image first. prevent temporary flickering due to no caching
	[[[result avatarView] window] makeFirstResponder:[result avatarView]];
	[[result avatarView] setImage:nil];
    
	//ANPost *post = [postsArray objectAtIndex:row];
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
	
	if ([[post user] ID]==[[[PSCMemoryCache sharedMemory] currentUser] ID]) {
		[[result deleteButton] setHidden:NO];
        [[result repostButton] setHidden:YES];
	}
	else {
		[[result deleteButton] setHidden:YES];
        [[result repostButton] setHidden:NO];
	}
    
	// send post to the cell view
	[result setPost:post];
	// set real name
	NSString *userNameAndUsername = [[NSString alloc] initWithFormat:@"%@ %@", [user name], [[user username] appNetUsernameString]];
	NSMutableAttributedString *userNameandUsernameAttributedString = [[NSMutableAttributedString alloc] initWithString:userNameAndUsername attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue Medium" size:13], NSForegroundColorAttributeName:[NSColor colorWithDeviceRed:0.286 green:0.286 blue:0.286 alpha:1.0]}];
	[userNameandUsernameAttributedString addAttributes:@{NSFontAttributeName:[NSFont fontWithName:@"Helvetica Neue" size:12], NSForegroundColorAttributeName:[NSColor colorWithDeviceRed:0.545 green:0.545 blue:0.545 alpha:1.0]} range:[userNameAndUsername rangeOfString:[[user username] appNetUsernameString]]];
	[[result userField] setAttributedStringValue:userNameandUsernameAttributedString];
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
	if ([post numberOfReplies]>0 || [post replyTo]) {
		[[result conversationButton] setHidden:NO];
	}
	else {
		[[result conversationButton] setHidden:YES];
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
		[[user avatarImage] imageAtSize:[self convertSizeToScale:result.avatarView.frame.size scale:2] completion:^(NSImage *image, NSError *error) {
			if (!error) {
				NSImage *maskedImage = [[PSCMemoryCache sharedMemory] maskImage:image withMask:[NSImage imageNamed:@"avatar-mask"]];
				[[PSCMemoryCache sharedMemory].avatarImages setValue:maskedImage forKey:[user username]];
				[self carouselFix:[result avatarView] image:maskedImage tableView:tableView rowIndex:rowIndex];
				//[[result avatarView] setImage:maskedImage];
			}
			/*else {
				[[result avatarView] setImage:nil];
			}*/
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

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // In IB, the TableColumn's identifier is set to "Automatic". The ATTableCellView's is also set to "Automatic". IB then keeps the two in sync, and we don't have to worry about setting the identifier.
	id content = [postsArray objectAtIndex:row];
	if ([content isKindOfClass:[ANUser class]]) {
		return [self configureProfileCellView:tableView user:content];
	}
	if ([content isKindOfClass:[ANPost class]]) {
		return [self configurePostCellView:tableView post:content rowIndex:row];
	}
	if ([content isKindOfClass:[PSCLoadMore class]]) {
		PSCLoadMoreCellView *result = [tableView makeViewWithIdentifier:@"LoadMoreCell" owner:nil];
		return result;
	}
	// we should never reach this
	return nil;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    //[aTableView deselectRow:rowIndex];
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	//NSLog(@"row:%ld", row);
	id content = [postsArray objectAtIndex:row];
	if ([content isKindOfClass:[ANUser class]]) {
		// calculate for profile cell view
		NSString *biography = [[content userDescription] text];
		int customViewToTop = 143;
		int biographyToTopOfCustomView = 43;
		int heightOfBottomShadow = 3;
		int padding = 10;
		// detect nil biographies
		if (biography) {
			NSFont *font = [NSFont fontWithName:@"Helvetica Bold" size:14.0f];
			float height = [biography heightForWidth:[[self window] frame].size.width-32-11 font:font];
			return height+customViewToTop+biographyToTopOfCustomView+heightOfBottomShadow+padding;
		}
		else {
			return customViewToTop+biographyToTopOfCustomView+heightOfBottomShadow+(padding*2);
		}
	}
	if ([content isKindOfClass:[PSCLoadMore class]]) {
		return 50;
	}
	if ([content isKindOfClass:[ANPost class]]) {
		NSFont *font = [NSFont fontWithName:@"Helvetica Neue Medium" size:13.0f];
		float height = [[content text] heightForWidth:[[self window] frame].size.width-61-2 font:font]; // 61 was previously 70
		int spaceToTop=15; // 15 was 18
		int padding=10;
		int minimumViewHeight = 105; // 118, actually 139 though //105 was previously 108
		int spaceToBottom=45; // 45 was previous 46
		int extraRepostSpace = ([content repostOf]) ? 19 : 0;
		if (height+spaceToTop+spaceToBottom<minimumViewHeight)
		{
			return minimumViewHeight+extraRepostSpace;
		}
		else {
			return height+spaceToTop+spaceToBottom+padding+extraRepostSpace;
		}
	}
	// we should never reach this
	return 1;
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