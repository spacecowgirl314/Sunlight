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

@implementation PSCAppDelegate
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
	
	/*ANDraft *newDraft = [ANDraft new];
	 [newDraft setText:@"Even more progress on my OS X ADN client. http://cl.ly/image/2b3h2x0X4712"];
	 [newDraft createPostViaSession:ANSession.defaultSession completion:^(ANResponse * response, ANPost * post, NSError * error) {
	 if(!post) {
	 //[self doSomethingWithError:error];
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
	}];
}

#pragma mark - Authentication and URL handling

- (void)authenticate {
	NSString *urlString = [NSString stringWithFormat:
						   @"https://alpha.app.net/oauth/authenticate?client_id=KXWTJNJeyw5fGQDmfAAcecepf7tp6eEY" \
						   "&response_type=token" \
						   "&redirect_uri=sunlight://api-key/" \
						   "&scope=stream"];
	NSURL *url = [NSURL URLWithString:urlString];
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

#pragma mark - NSTableView Delegates

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [postsArray count];
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // In IB, the TableColumn's identifier is set to "Automatic". The ATTableCellView's is also set to "Automatic". IB then keeps the two in sync, and we don't have to worry about setting the identifier.
    PSCPostCellView *result = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
    
	ANPost *post = [postsArray objectAtIndex:row];
	ANUser *user = [post user];
	
	// set real name
	[[result userField] setStringValue:[user name]];
	
	// round edges
	[[[result avatarView] layer] setCornerRadius:2.0];
	
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
	
	// set contents of post
	if ([post text]!=nil) {
		[[result postField] setStringValue:[post text]];
	}
	else {
		[[result postField] setStringValue:@"Deleted Post"];
	}
	
    return result;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    //[tableView deselectRowAtIndexPath:rowIndex animated:YES];
    return YES;
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
