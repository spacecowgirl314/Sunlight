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
#import <Quartz/Quartz.h>
#import <AutoHyperlinks/AutoHyperlinks.h>

@implementation PSCAppDelegate
@synthesize postController;
@synthesize authToken = _authToken;

- (void)applicationWillBecomeActive:(NSNotification *)notification {
	//[[self window] setAlphaValue:0.0];
	//[[self window] orderOut:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// register for startup events
	[[NSAppleEventManager sharedAppleEventManager] setEventHandler:self
													   andSelector:@selector(receivedURL:withReplyEvent:)
													 forEventClass:kInternetEventClass
														andEventID:kAEGetURL];
	
	self.window.trafficLightButtonsLeftMargin = 7.0;
    self.window.fullScreenButtonRightMargin = 7.0;
    self.window.hideTitleBarInFullScreen = YES;
    self.window.centerFullScreenButton = YES;
    self.window.titleBarHeight = 40.0;
		
	// do nothing until loaded
	[[self appScrollView] setRefreshBlock:^(EQSTRScrollView *scrollView) {
		[[self appScrollView] stopLoading];
	}];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver: self
	 selector: @selector(windowDidResize:)
	 name: NSWindowDidResizeNotification
	 object: self.window];
	
	// self.titleView is a an IBOutlet to an NSView that has been configured in IB with everything you want in the title bar
	/*self.titleView.frame = self.window.titleBarView.bounds;
	self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.window.titleBarView addSubview:self.titleView];*/
	
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
	if ([self.authToken length]) {
		//[self checkToken];
		[self prepare];
	} else {
		[self authenticate];
	}
	
	
	// check and then setup notifications
	[self checkForMentions];
	NSTimer *mentionsTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkForMentions) userInfo:nil repeats:YES];
}

- (void)prepare {
	ANSession.defaultSession.accessToken = self.authToken;
	
	// start window off by not being seen
	[[self appScrollView] setRefreshBlock:^(EQSTRScrollView *scrollView) {
		dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
		dispatch_async(queue,^{
			// Get the latest posts in the user's incoming post stream...
			[ANSession.defaultSession postsInStreamWithCompletion:^(ANResponse * response, NSArray * posts, NSError * error) {
				if(!posts) {
					//[self doSomethingWithError:error];
					return;
				}
				
				// Grab the most recent post.
				ANPost * latestPost = posts[0];
				NSLog(@"post:%@ count:%ld", [latestPost text], [posts count]);
				
				postsArray = posts;
				[[self appTableView] reloadData];
				
				// Compose a reply...
				ANDraft * newPost = [latestPost draftReply];
				newPost.text = @"test"; //[newPost.text appendString:@"Me too!"];  // The default text includes an @mention
				
				// And post it.
				/*[newPost createPostViaSession:ANSession.defaultSession completion:^(ANResponse * response, ANPost * post, NSError * error) {
				 if(!post) {
				 //[self doSomethingWithError:error];
				 }
				 }];*/
				
				dispatch_async(dispatch_get_main_queue(), ^{
					[[self appScrollView] stopLoading];
				});
			}];
		});
	}];
	
	/*[engine writePost:@"Hello, World! #testing" replyToPostWithID:-1 annotations:nil links:nil block:^(ADNPost *post, NSError *error) {
	 if (error) {
	 //[self requestFailed:error];
	 } else {
	 //[self receivedPost:post];
	 }
	 }];*/
	
	// Get the latest posts in the user's incoming post stream...
	[ANSession.defaultSession postsInStreamWithCompletion:^(ANResponse * response, NSArray * posts, NSError * error) {
		if(!posts) {
			//[self doSomethingWithError:error];
			return;
		}
		
		// Grab the most recent post.
		ANPost * latestPost = posts[0];
		//NSLog(@"post:%@ count:%ld", [latestPost text], [posts count]);
		
		postsArray = posts;
		[[self appTableView] reloadData];
		
		// Compose a reply...
		ANDraft * newPost = [latestPost draftReply];
		newPost.text = @"test"; //[newPost.text appendString:@"Me too!"];  // The default text includes an @mention
		
		// And post it.
		/*[newPost createPostViaSession:ANSession.defaultSession completion:^(ANResponse * response, ANPost * post, NSError * error) {
		 if(!post) {
		 //[self doSomethingWithError:error];
		 }
		 }];*/
	}];
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
	[ANSession.defaultSession postsMentioningUserWithID:ANMeUserID betweenID:ANMeUserID andID:ANMeUserID completion:^(ANResponse *response, NSArray *posts, NSError *error) {
		for (ANPost *mention in posts) {
			//NSLog(@"mention: %@ %lli", [mention text], [mention originalID]);
			
			ANResourceID lastMention = [[NSUserDefaults standardUserDefaults] integerForKey:@"lastMention"];
			if ([mention originalID] && ([mention originalID]  > lastMention)) {
				//NSString *postURLString = [NSString stringWithFormat:@"https://alpha.app.net/%@/post/%@", username, postId];
				if (![mention isDeleted]) {
					// Deleted posts seem to have nil text
					[self showMention:mention];
				}
				NSLog(@"[%llu] Mentioned by %@: %@", [mention originalID], [[mention user] username], [mention text]);
				// save the lastMention
				[[NSUserDefaults standardUserDefaults] setInteger:[mention originalID] forKey:@"lastMention"];
			}
		}
	}];
}

- (void) showMention: (ANPost*)mention
{
	NSUserNotification *notification = [[NSUserNotification alloc] init];
	notification.title = [NSString stringWithFormat: @"%@ mentioned you", [[mention user] name]];
	notification.informativeText = [mention text];
	notification.actionButtonTitle = @"Reply";
	notification.userInfo = nil; //@{ @"post" : @0 };
	notification.hasActionButton = YES;
	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
	[center removeDeliveredNotification:notification];
	switch (notification.activationType) {
		case NSUserNotificationActivationTypeActionButtonClicked:
			NSLog(@"Reply Button was clicked -> quick reply");
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:notification.userInfo[@"url"]]];
			break;
		case NSUserNotificationActivationTypeContentsClicked:
			NSLog(@"Notification body was clicked -> redirect to item");
			[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:notification.userInfo[@"url"]]];
			break;
		default:
			NSLog(@"Notfiication appears to have been dismissed!");
			break;
	}
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return !notification.isPresented;
}

#pragma mark - Authentication and URL handling

- (void)authenticate {
	ANAuthenticator *authenticator = [ANAuthenticator new];
	[authenticator setClientID:@"KXWTJNJeyw5fGQDmfAAcecepf7tp6eEY"];
	[authenticator setRedirectURL:[NSURL URLWithString:@"sunlight://api-key/"]];
	NSURL *url = [authenticator URLToAuthorizeForScopes:@[ANScopeStream, ANScopeEmail, ANScopeWritePost, ANScopeFollow, ANScopeMessages]];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (void)receivedURL:(NSAppleEventDescriptor*)event withReplyEvent: (NSAppleEventDescriptor*)replyEvent
{
	NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
	NSRange tkIdRange = [url rangeOfString:@"#access_token="];
	if (tkIdRange.location != NSNotFound) {
		self.authToken = [url substringFromIndex:NSMaxRange(tkIdRange)];
		[self prepare];
		//[statusItem setImage:[NSImage imageNamed:@"status_icon.png"]];
		//[self checkToken];
	}
}

- (void) setAuthToken:(NSString *)apiKey {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	_authToken = apiKey;
	if (apiKey) {
		[defaults setObject:apiKey forKey:@"api_key"];
	} else {
		[defaults removeObjectForKey:@"api_key"];
	}
	[defaults synchronize];
}

- (NSString*) authToken {
	if (!_authToken) {
		_authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"api_key"];
		NSLog(@"Read API Key %@", _authToken);
	}
	return _authToken;
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

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // In IB, the TableColumn's identifier is set to "Automatic". The ATTableCellView's is also set to "Automatic". IB then keeps the two in sync, and we don't have to worry about setting the identifier.
    PSCPostCellView *result = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
	
	// round edges
	[[result avatarView] setWantsLayer:YES];
	[[[result avatarView] layer] setMasksToBounds:YES];
	[[[result avatarView] layer] setCornerRadius:5.0];
	[[[result avatarView] layer] setBorderWidth:1.0f];
	
	// clear out the old image first. prevent temporary flickering due to no caching
	[[result avatarView] setImage:nil];
    
	ANPost *post = [postsArray objectAtIndex:row];
	ANUser *user = [post user];
	// send post to the cell view
	[result setPost:post];
	
	// set real name
	[[result userField] setStringValue:[user name]];
	
	// prevents buttons from requeued cells from being unhidden
	[[result replyButton] setHidden:YES];
	[[result starButton] setHidden:YES];
	[[result repostButton] setHidden:YES];
	
	// adjust for retina... this is really weird
	if ([[self window] backingScaleFactor] == 2.0) {
		[[user avatarImage] imageAtSize:[[result avatarView] convertSizeToBacking:[result avatarView].frame.size] completion:^(NSImage *image, NSError *error) {
			[[result avatarView] setImage:image];
		}];
	}
	else {
		[[user avatarImage] imageAtSize:[result avatarView].frame.size completion:^(NSImage *image, NSError *error) {
			[[result avatarView] setImage:image];
		}];
	}
	
	//[[result postField] setAllowsEditingTextAttributes: YES];
    //[[result postField] setSelectable: YES];
	
	// set contents of post
	if ([post text]!=nil) {
		AHHyperlinkScanner *postScanner = [[AHHyperlinkScanner alloc] initWithString:[post text] usingStrictChecking:NO];
		[[result postView] setString:@""];
		NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
		[attributedString insertAttributedString:[postScanner linkifiedString] atIndex:0];
		[[result postView] setFont:[NSFont fontWithName:@"Avenir Book" size:13.0f]];
		// temporarily set the text view editable so we can insert our attributed string with links
		[[result postView] setEditable:YES];
		[[result postView] insertText:attributedString];
		[[result postView] setEditable:NO];
	}
	else {
		[[result postView] setString:@"[Post deleted]"];
	}
	//NSLog(@"height %f, height %f", [[result postView] frame].size.height, [[result postScrollView] contentSize].height);
	
	//float heightDifference = [[result postView] frame].size.height - [[result postScrollView] contentSize].height;
	
	//NSLog(@"difference: %f", heightDifference);
	
	//rowHeight = [[result postView] frame].size.height;
	
	//[tableView noteHeightOfRowsWithIndexesChanged:[NSIndexSet indexSetWithIndex:row]];
	
    return result;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    //[tableView deselectRowAtIndexPath:rowIndex animated:YES];
    return YES;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	//NSLog(@"row:%ld", row);
	ANPost *post = [postsArray objectAtIndex:row];
	
	NSTextStorage *textStorage;
	if ([post text]!=nil) {
		textStorage = [[NSTextStorage alloc]
								  initWithString:[post text]];
	}
	else {
		textStorage = [[NSTextStorage alloc]
					   initWithString:@"[Post deleted]"];
	}
	
	//NSLog(@"wdith:%f", [[self window] frame].size.width);
	NSTextContainer *textContainer = [[NSTextContainer alloc]
									  initWithContainerSize: NSMakeSize([[self window] frame].size.width-125, FLT_MAX)]; //[[self window] frame].size.width-68-2
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	
	[layoutManager addTextContainer:textContainer];
	[textStorage addLayoutManager:layoutManager];
	
	NSFont *font = [NSFont fontWithName:@"Avenir Book" size:13.0f];
	
	[textStorage addAttribute:NSFontAttributeName value:font
						range:NSMakeRange(0, [textStorage length])];
	[textContainer setLineFragmentPadding:0.0];
	
	[layoutManager glyphRangeForTextContainer:textContainer];
	/*NSLog(@"height:%f", [layoutManager
						 usedRectForTextContainer:textContainer].size.height);*/
	
	if ([layoutManager
		 usedRectForTextContainer:textContainer].size.height+28 < 98) {
		return 8+52+5;
	}
	else {
		return [layoutManager
				usedRectForTextContainer:textContainer].size.height+28; //28
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

@end
