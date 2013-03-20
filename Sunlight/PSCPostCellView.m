//
//  PSCPostCellView.m
//  Sunlight
//
//  Created by Chloe Stars on 10/10/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCPostCellView.h"
#import "NSView+Fade.h"
#import "NSButton+TextColor.h"
#import "PSCMemoryCache.h"
#import "PocketAPI.h"

@implementation PSCPostCellView
@synthesize post;
@synthesize postController;
@synthesize postScrollView;
@synthesize postView;
@synthesize userField;
@synthesize postCreationField;
@synthesize conversationButton;
@synthesize avatarView;
@synthesize replyButton;
@synthesize muteButton;
@synthesize repostButton;
@synthesize starButton;
@synthesize repostImageView;
@synthesize repostedUserButton;
@synthesize deleteButton;
@synthesize avatarHoverButton;
@synthesize twoFingersTouches;
@synthesize topGradient;
@synthesize bottomGradient;

#define kSwipeMinimumLength 0.25

- (void)awakeFromNib
{
	//[self updateTrackingArea];
	//[self becomeFirstResponder];
	//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResize) name:NSViewFrameDidChangeNotification object:self];
	[replyButton setTextColor:[self defaultButtonColor]];
	[muteButton setTextColor:[self defaultButtonColor]];
	[repostButton setTextColor:[self defaultButtonColor]];
	[starButton setTextColor:[self defaultButtonColor]];
    [deleteButton setTextColor:[self defaultButtonColor]];
    
    [postView setSelectedTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSColor colorWithDeviceRed:0.961 green:0.965 blue:0.863 alpha:1.0], NSBackgroundColorAttributeName,
      nil]];
	
	[topGradient setStartingColor:[NSColor colorWithDeviceRed:0.894 green:0.894 blue:0.894 alpha:1.0] endingColor:[NSColor colorWithDeviceRed:0.965 green:0.965 blue:0.965 alpha:1.0]];
}

- (IBAction)viewRepostUser:(id)sender
{
	NSRange range = NSMakeRange(0, [[repostedUserButton attributedTitle] length]);
	NSDictionary *attributes = [[repostedUserButton attributedTitle] attributesAtIndex:0 effectiveRange:&range];
	
	if( [attributes objectForKey:@"UsernameMatch"] != nil ) {
		NSLog( @"UsernameMatch: %@", [attributes objectForKey:@"UsernameMatch"] );
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Profile" object:[attributes objectForKey:@"UsernameMatch"]];
	}
}

- (IBAction)viewUser:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Profile" object:[[post user] username]];
}

#pragma mark - Swiping

- (void)goBack:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PopTopBreadcrumbItem" object:nil];
}

- (void)goForward:(id)sender
{
	// make sure there is a conversation
	if ([post numberOfReplies]>0 || [post replyTo]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"Conversation" object:self.post];
	}
}

- (void)swipeWithEvent:(NSEvent *)event {
    NSLog(@"Swipe With Event");
    CGFloat x = [event deltaX];
    //CGFloat y = [event deltaY];
	
    if (x != 0) {
        (x > 0) ? [self goBack:self] : [self goForward:self];
    }
}

- (void)beginGestureWithEvent:(NSEvent *)event
{
	NSLog(@"Gesture detected!");
    /*if (![self recognizeTwoFingerGestures])
        return;*/
	
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
	
    self.twoFingersTouches = [[NSMutableDictionary alloc] init];
	
    for (NSTouch *touch in touches) {
        [twoFingersTouches setObject:touch forKey:touch.identity];
    }
}

- (void)endGestureWithEvent:(NSEvent *)event
{
	NSLog(@"Gesture end detected!");
    if (!twoFingersTouches) return;
	
    NSSet *touches = [event touchesMatchingPhase:NSTouchPhaseAny inView:nil];
	
    // release twoFingersTouches early
    NSMutableDictionary *beginTouches = [twoFingersTouches copy];
    self.twoFingersTouches = nil;
	
    NSMutableArray *magnitudes = [[NSMutableArray alloc] init];
	
    for (NSTouch *touch in touches)
    {
        NSTouch *beginTouch = [beginTouches objectForKey:touch.identity];
		
        if (!beginTouch) continue;
		
        float magnitude = touch.normalizedPosition.x - beginTouch.normalizedPosition.x;
        [magnitudes addObject:[NSNumber numberWithFloat:magnitude]];
    }
	
    // Need at least two points
    if ([magnitudes count] < 2) return;
	
    float sum = 0;
	
    for (NSNumber *magnitude in magnitudes)
        sum += [magnitude floatValue];
	
    // Handle natural direction in Lion
    BOOL naturalDirectionEnabled = [[[NSUserDefaults standardUserDefaults] valueForKey:@"com.apple.swipescrolldirection"] boolValue];
	
    if (naturalDirectionEnabled)
        sum *= -1;
	
    // See if absolute sum is long enough to be considered a complete gesture
    float absoluteSum = fabsf(sum);
	
    if (absoluteSum < kSwipeMinimumLength) return;
	
    // Handle the actual swipe
    if (sum > 0)
    {
        [self goForward:self];
		NSLog(@"Go forward");
    } else
    {
		NSLog(@"Go back");
        [self goBack:self];
    }
	
	
}

#pragma mark -

- (void)mouseDown:(NSEvent *)theEvent
{
    NSLog(@"mouseDown event detected!");
	[super mouseDown:theEvent];
}


- (NSColor*)defaultButtonColor
{
	return [NSColor colorWithDeviceRed:0.643 green:0.643 blue:0.643 alpha:1.0];
}

// Necessary for when the view is resized
/*-(void)updateTrackingArea 
 {
	// Allow for controls to disappear when mouse isn't in window.
	if (trackingArea!=nil) {
		[self removeTrackingArea:trackingArea];
	}
	NSTrackingAreaOptions trackingOptions =
	NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveAlways;*/
	/*NSTrackingArea *myTrackingArea = [[NSTrackingArea alloc]
	 initWithRect: [imageView bounds] // in our case track the entire view
	 options: trackingOptions
	 owner: self
	 userInfo: nil];*/
	/*trackingArea = [[NSTrackingArea alloc]
					  initWithRect: [self bounds] // in our case track the entire view
					  options: trackingOptions
					  owner: self
					  userInfo: nil];
	[self addTrackingArea: trackingArea];
}*/

/*- (void)didResize 
 {
	//NSLog(@"Resizing...");
	[self updateTrackingArea];
}*/

/*- (void) mouseEntered:(NSEvent*)theEvent 
 {
    // Mouse entered tracking area.
	//NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);
	if([fadeTimer isValid])
		[fadeTimer invalidate];
	fadeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f block:^(NSTimer *timer) {
		[replyButton setHidden:NO withFade:YES blocking:NO];
		[starButton setHidden:NO withFade:YES blocking:NO];
		[repostButton setHidden:NO withFade:YES blocking:NO];
		[postCreationField setHidden:YES withFade:YES blocking:NO];
	} repeats:NO];
}

- (void) mouseExited:(NSEvent*)theEvent 
 {
    // Mouse exited tracking area.
	//NSLog(@"<%p>%s:", self, __PRETTY_FUNCTION__);
	if([fadeTimer isValid])
		[fadeTimer invalidate];
	[replyButton setHidden:YES withFade:YES blocking:NO];
	[starButton setHidden:YES withFade:YES blocking:NO];
	[repostButton setHidden:YES withFade:YES blocking:NO];
	[postCreationField setHidden:NO withFade:YES blocking:NO];
}*/

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

- (CGImageRef)nsImageToCGImageRef:(NSImage*)image;
{
    NSData * imageData = [image TIFFRepresentation];
    CGImageRef imageRef;
    if(!imageData) return nil;
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    return imageRef;
}

- (NSImage*)maskImage:(NSImage *)image withMask:(NSImage *)maskImage
{
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

- (IBAction)openReplyPost:(id)sender
{
	if (!self.postController) {
		PSCNewPostController *pC = [[PSCNewPostController alloc] init];
		self.postController =  pC;
	}
	
	[self.postController draftReply:post];
	[self.postController showWindow:self];
	//[self.postController processResults:[questionField stringValue]];
	
	// get replies
	/*[post replyPostsWithCompletion:^(ANResponse *response, NSArray *posts, NSError *error) {
		if ([posts count]!=0) {
			ANPost *reply = [posts objectAtIndex:0];
			//NSLog(@"reply: %@", [reply text]);
		}
	}];*/
}

- (IBAction)starPost:(id)sender
{
	if (![post youStarred]) {
		[post starWithCompletion:^(ANResponse *response, ANPost *starredPost, NSError *error) {
			if (!starredPost) {
				NSLog(@"There was an error starring the post.");
			}
			else {
				NSLog(@"Starring was successful.");
				[starButton setImage:[NSImage imageNamed:@"timeline-star-highlight"]];
                [starButton setAlternateImage:[NSImage imageNamed:@"timeline-star-highlight-pressed"]];
                //[starButton setTitle:@"Starred"];
				//[starButton setTextColor:[NSColor colorWithDeviceRed:0.894 green:0.541 blue:0.082 alpha:1.0]];
			}
		}];
	}
	else {
		[post unstarWithCompletion:^(ANResponse *response, ANPost *starredPost, NSError *error) {
			if (!starredPost) {
				NSLog(@"There was an error starring the post.");
			}
			else {
				NSLog(@"Unstarring was successful.");
				[starButton setImage:[NSImage imageNamed:@"timeline-star"]];
				[starButton setAlternateImage:[NSImage imageNamed:@"timeline-star-pressed"]];
                //[starButton setTitle:@"Star"];
				//[starButton setTextColor:[self defaultButtonColor]];
			}
		}];
	}
}

- (IBAction)repostPost:(id)sender
{
	// keep in mind posts that have been starred but haven't been reloaded for the post status
	if (![post youReposted]) {
		[post repostWithCompletion:^(ANResponse *response, ANPost *repostPost, NSError *error) {
			if (!repostPost) {
				NSLog(@"There was an error reposting the post.");
			}
			else {
				NSLog(@"Reposting was successful.");
				[repostButton setImage:[NSImage imageNamed:@"timeline-repost-highlight"]];
                [repostButton setAlternateImage:[NSImage imageNamed:@"timeline-repost-highlight-pressed"]];
                //[repostButton setTitle:@"Reposted"];
				//[repostButton setTextColor:[NSColor colorWithDeviceRed:0.118 green:0.722 blue:0.106 alpha:1.0]];
			}
		}];
	}
	else {
		[post unrepostWithCompletion:^(ANResponse *response, ANPost *repostPost, NSError *error) {
			if (!repostPost) {
				NSLog(@"There was an error reposting the post.");
			}
			else {
				NSLog(@"Unreposting was successful.");
				[repostButton setImage:[NSImage imageNamed:@"timeline-repost"]];
				[starButton setAlternateImage:[NSImage imageNamed:@"timeline-repost-pressed"]];
                //[repostButton setTitle:@"Repost"];
				//[repostButton setTextColor:[self defaultButtonColor]];
			}
		}];
	}
}

- (IBAction)deletePost:(id)sender
{
	[post deleteWithCompletion:^(ANResponse *response, ANPost *deletedPost, NSError *error) {
		if (!deletedPost) {
			NSLog(@"There was an error deleting the post.");
		}
		else {
			NSLog(@"Post was deleted successfully.");
		}
	}];
}

- (IBAction)muteUser:(id)sender
{
	[ANSession.defaultSession muteUserWithID:[[post user] ID] completion:^(ANResponse *response, ANUser *user, NSError *error) {
		if (!user) {
			NSLog(@"There was an error muting the user.");
		}
		else {
			NSLog(@"%@ was muted successfully.", [user username]);
			//[muteButton setImage:[NSImage imageNamed:]];
			//[muteButton setTextColor:[self defaultButtonColor]];
		}
	}];
}

- (IBAction)openConversation:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Conversation" object:self.post];
}

- (IBAction)openUser:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"Profile" object:self.post.user.username];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[[NSColor colorWithDeviceRed:0.965 green:0.965 blue:0.965 alpha:1.0] set]; // Sets current drawing color.
	NSRectFill(self.bounds);
}

- (void)hideRepost
{
	[[self repostImageView] setHidden:YES];
	[[self repostedUserButton] setHidden:YES];
}

- (void)showRepost
{
	[[self repostImageView] setHidden:NO];
	[[self repostedUserButton] setHidden:NO];
	[[self repostedUserButton] addCursorRect:[[self repostedUserButton] bounds] cursor:[NSCursor pointingHandCursor]];
}

- (IBAction)openMore:(id)sender
{
	[moreMenu popUpMenuPositioningItem:nil atLocation:moreButton.frame.origin inView:self];
}

- (void)enableHighlight
{
	[topGradient setHidden:NO];
}

- (void)disableHightlight
{
	[topGradient setHidden:YES];
}

#pragma mark - More Button Methods

- (IBAction)addToReadingList:(id)sender
{
	for (ANEntity *link in post.entities.links)
	{
		NSURL *url = link.URL;
		NSString *urlString = [url absoluteString];
		NSString *source = [NSString stringWithFormat:@"tell application \"Safari\" to add reading list item \"%@\"", urlString];
		
		NSDictionary *errorDictionary;
		NSAppleScript *script = [[NSAppleScript alloc] initWithSource:source];
		
		if ( ![script executeAndReturnError:&errorDictionary] ) {
			NSLog(@"Error while saving to Safari Reading List: %@", errorDictionary);
		}
		else {
			// the URL was saved successfully
		}
	}
}

- (IBAction)addToPocket:(id)sender
{
	for (ANEntity *link in post.entities.links)
	{
		[[PocketAPI sharedAPI] saveURL:link.URL handler: ^(PocketAPI *API, NSURL *URL, NSError *error){
			if(error){
				// there was an issue connecting to Pocket
				// present some UI to notify if necessary
				NSLog(@"Error while saving to Pocket: %@", [error description]);
				
			}else{
				// the URL was saved successfully
			}
		}];
	}
}

- (IBAction)copyContents:(id)sender
{
	[[NSPasteboard generalPasteboard] clearContents];
	[[NSPasteboard generalPasteboard] setString:post.text forType:NSPasteboardTypeString];
}

- (IBAction)copyLink:(id)sender
{
	[[NSPasteboard generalPasteboard] clearContents];
	[[NSPasteboard generalPasteboard] setString:[post.canonicalURL absoluteString] forType:NSPasteboardTypeString];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	NSRange range = NSMakeRange(0, 4);
	NSIndexSet *theSet = [NSIndexSet indexSetWithIndexesInRange:range];
	for (NSMenuItem *item in [[moreMenu itemArray] objectsAtIndexes:theSet]) {
		if ([item isEqualTo:menuItem]) {
			return post.entities.links.count != 0;
		}
	}
	return YES;
}

#pragma mark - NSMenuDelegate

- (void)menuWillOpen:(NSMenu *)menu
{
	moreButton.alternateImage = [NSImage imageNamed:@"timeline-more-highlight"];
}

- (void)menuDidClose:(NSMenu *)menu
{
	moreButton.alternateImage = [NSImage imageNamed:@"timeline-more-pressed"];
}

@end
