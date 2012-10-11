//
//  PSCAppDelegate.m
//  Sunlight
//
//  Created by Chloe Stars on 9/27/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCAppDelegate.h"
#import "DDHotKeyCenter.h"

@implementation PSCAppDelegate

- (void)applicationWillBecomeActive:(NSNotification *)notification {
	//[[self window] setAlphaValue:0.0];
	//[[self window] orderOut:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	self.window.trafficLightButtonsLeftMargin = 7.0;
    self.window.fullScreenButtonRightMargin = 7.0;
    self.window.hideTitleBarInFullScreen = YES;
    self.window.centerFullScreenButton = YES;
    self.window.titleBarHeight = 40.0;
	
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
	
	NSString *token = @"AQAAAAAAAVyV4SA0yw08VNPZ4c-mknUJYyaEjwIuFMB_H18bvwMYB08iV1g8dKHvFuJLHMlh1kjl-PYz366bEunDdPoajirjyA";
	
	ANSession.defaultSession.accessToken = token;
	
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
	[newDraft setText:@"Progress on the ADN OS X client. http://cl.ly/image/3u362v3U1x42"];
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

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [postsArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    // this should hopefully never stay like this
    NSCell *cell = [[NSCell alloc] init];
    
	ANPost *post = [postsArray objectAtIndex:rowIndex];
	if ([post text]!=nil) {
    cell = [[NSCell alloc] initTextCell:[post text]];
	}
	else {
		cell = [[NSCell alloc] initTextCell:@"Deleted post."];
	}
	//cell.cellSize
    return cell;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
    //[tableView deselectRowAtIndexPath:rowIndex animated:YES];
    return YES;
}

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
