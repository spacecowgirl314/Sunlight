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
#import "AutoHyperlinks.framework/Source/AutoHyperlinks.h"
#import "NS(Attributed)String+Geometrics.h"

@implementation PSCAppDelegate
@synthesize postController;
@synthesize titleView;
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
	// self.titleView is a an IBOutlet to an NSView that has been configured in IB with everything you want in the title bar
	self.titleView.frame = self.window.titleBarView.bounds;
	self.titleView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
	[self.window.titleBarView addSubview:self.titleView];
	// do nothing until loaded
	[[self appScrollView] setRefreshBlock:^(EQSTRScrollView *scrollView) {
		[[self appScrollView] stopLoading];
	}];
	avatarImages = [NSMutableDictionary new];
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
		//NSLog(@"Read API Key %@", _authToken);
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

- (CGImageRef)nsImageToCGImageRef:(NSImage*)image;
{
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef;
    if(!imageData) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    return imageRef;
}

- (NSImage*)imageFromCGImageRef:(CGImageRef)image
{
    NSRect imageRect = NSMakeRect(0.0, 0.0, 0.0, 0.0);
    CGContextRef imageContext = nil;
    NSImage* newImage = nil; // Get the image dimensions.
    imageRect.size.height = CGImageGetHeight(image);
    imageRect.size.width = CGImageGetWidth(image);
	
    // Create a new image to receive the Quartz image data.
    newImage = [[NSImage alloc] initWithSize:imageRect.size];
    [newImage lockFocus];
	
    // Get the Quartz context and draw.
    imageContext = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawImage(imageContext, *(CGRect*)&imageRect, image); [newImage unlockFocus];
    return newImage;
}

- (NSImage*)maskImage:(NSImage *)image withMask:(NSImage *)maskImage {
	
	CGImageRef maskRef = [self nsImageToCGImageRef:maskImage];
	
	CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(maskRef),
										CGImageGetHeight(maskRef),
										CGImageGetBitsPerComponent(maskRef),
										CGImageGetBitsPerPixel(maskRef),
										CGImageGetBytesPerRow(maskRef),
										CGImageGetDataProvider(maskRef), NULL, false);
	
	CGImageRef masked = CGImageCreateWithMask([self nsImageToCGImageRef:image], mask);
	return [self imageFromCGImageRef:masked];
	
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // In IB, the TableColumn's identifier is set to "Automatic". The ATTableCellView's is also set to "Automatic". IB then keeps the two in sync, and we don't have to worry about setting the identifier.
    PSCPostCellView *result = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
	// clear out the old image first. prevent temporary flickering due to no caching
	[[result avatarView] setImage:nil];
    
	ANPost *post = [postsArray objectAtIndex:row];
	ANUser *user = [post user];
	// send post to the cell view
	[result setPost:post];
	// set real name
	[[result userField] setStringValue:[user name]];
	// prevents buttons from requeued cells from being unhidden
	/*[[result replyButton] setHidden:YES];
	[[result starButton] setHidden:YES];
	[[result repostButton] setHidden:YES];*/
	// set creation date
	[[result postCreationField] setStringValue:[[post createdAt] stringWithHumanizedTimeDifference:NSDateHumanizedSuffixNone withFullString:NO]];
	// download avatar image and store in a dictionary
	if ([avatarImages objectForKey:[user username]])
	{
		[[result avatarView] setImage:[avatarImages objectForKey:[user username]]];
	}
	else {
		[[user avatarImage] imageAtSize:[[result avatarView] convertSizeToBacking:[result avatarView].frame.size] completion:^(NSImage *image, NSError *error) {
			NSImage *maskedImage = [self maskImage:image withMask:[NSImage imageNamed:@"avatar-mask"]];
			[avatarImages setValue:maskedImage forKey:[user username]];
			[[result avatarView] setImage:maskedImage];
		}];
	}
	// set contents of post
	if ([post text]!=nil) {
		AHHyperlinkScanner *postScanner = [[AHHyperlinkScanner alloc] initWithString:[post text] usingStrictChecking:NO];
		[[result postView] setString:@""];
		NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
		[attributedString insertAttributedString:[postScanner linkifiedString] atIndex:0];
		[[result postView] setFont:[NSFont fontWithName:@"Helvetica Neue" size:13.0f]];
		// temporarily set the text view editable so we can insert our attributed string with links
		[[result postView] setEditable:YES];
		[[result postView] insertText:attributedString];
		[[result postView] setEditable:NO];
		// set height of the post text view
		NSFont *font = [NSFont fontWithName:@"Helvetica Neue" size:13.0f];
		float height = [[post text] heightForWidth:[[self window] frame].size.width-68-2 font:font];
		//NSLog(@"text height:%f", height);
		//result.postView.frame = CGRectZero;
		//[result.postView setVerticallyResizable:YES];
		result.postScrollView.frame = CGRectMake(result.postView.frame.origin.x, result.postView.frame.origin.y, result.postView.frame.size.width, height);
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
    //[aTableView deselectRow:rowIndex];
    return NO;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
	//NSLog(@"row:%ld", row);
	ANPost *post = [postsArray objectAtIndex:row];
	NSFont *font = [NSFont fontWithName:@"Helvetica Neue" size:13.0f];
	float height = [[post text] heightForWidth:[[self window] frame].size.width-68-2 font:font];
	int spaceToTop=28;
	int padding=10;
	int minimumViewHeight = 118; // 118, actually 139 though
	int spaceToBottom=46;
	if (height+spaceToTop+spaceToBottom<minimumViewHeight)
	{
		return minimumViewHeight;
	}
	else {
		return height+spaceToTop+spaceToBottom+padding;
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