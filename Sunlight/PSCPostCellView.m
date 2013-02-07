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

@implementation PSCPostCellView
@synthesize post;
@synthesize postScrollView;
@synthesize postView;
@synthesize userField;
@synthesize postCreationField;
@synthesize avatarView;
@synthesize replyButton;
@synthesize muteButton;
@synthesize repostButton;
@synthesize starButton;
@synthesize repostImageView;
@synthesize repostedUserButton;

- (void)awakeFromNib {
	[self updateTrackingArea];
	[self setAcceptsTouchEvents:YES];
	[self becomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResize) name:NSViewFrameDidChangeNotification object:self];
	[replyButton setTextColor:[self defaultButtonColor]];
	[muteButton setTextColor:[self defaultButtonColor]];
	[repostButton setTextColor:[self defaultButtonColor]];
	[starButton setTextColor:[self defaultButtonColor]];
}

- (IBAction)viewRepostUser:(id)sender
{
	NSRange range = NSMakeRange(0, [[repostedUserButton attributedTitle] length]);
	NSDictionary *attributes = [[repostedUserButton attributedTitle] attributesAtIndex:0 effectiveRange:&range];
	
	if( [attributes objectForKey:@"UsernameMatch"] != nil ) {
		NSLog( @"UsernameMatch: %@", [attributes objectForKey:@"UsernameMatch"] );
	}
}

- (BOOL)wantsScrollEventsForSwipeTrackingOnAxis:(NSEventGestureAxis)axis {
	return (axis == NSEventGestureAxisHorizontal) ? YES : NO; }

// semi-working swipe detection, needs to filter out scrolling up and down
/*- (void)scrollWheel:(NSEvent *)event
{
	if([event phase] == NSEventPhaseBegan)
	{
		scrollDeltaX = [event deltaX];
		NSLog(@"x delta:%f", scrollDeltaX);
		scrollDeltaY = [event deltaY];
	}
    if([event phase] == NSEventPhaseEnded)
    {
		int swipeColorValue;
		const int SwipeLeft = 0;
		const int SwipeRight = 1;
		const int SwipeUp = 2;
		const int SwipeDown = 3;
		
		CGFloat x = scrollDeltaX; //[event deltaX];
		CGFloat y = scrollDeltaY; //[event deltaY];
		//NSLog(@"x delta:%f", x);
		if (x != 0) {
			swipeColorValue = (x < 0)  ? SwipeLeft : SwipeRight;
		}
		if (y != 0) {
			swipeColorValue = (y > 0)  ? SwipeUp : SwipeDown;
		}
		NSString *direction;
		switch (swipeColorValue) {
			case SwipeLeft:
				direction = @"left";
				break;
			case SwipeRight:
				direction = @"right";
				break;
			case SwipeUp:
				direction = @"up";
				break;
			case SwipeDown:
			default:
				direction = @"down";
				break;
		}
		NSLog(@"Swipe %@", direction);
    }
    [super scrollWheel:event];
}*/

- (NSColor*)defaultButtonColor {
	return [NSColor colorWithDeviceRed:0.643 green:0.643 blue:0.643 alpha:1.0];
}

- (BOOL)acceptsFirstResponder
{
	return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

// Necessary for when the view is resized
-(void)updateTrackingArea {
	// Allow for controls to disappear when mouse isn't in window.
	if (trackingArea!=nil) {
		[self removeTrackingArea:trackingArea];
	}
	NSTrackingAreaOptions trackingOptions =
	NSTrackingMouseEnteredAndExited|NSTrackingMouseMoved|NSTrackingActiveAlways;
	/*NSTrackingArea *myTrackingArea = [[NSTrackingArea alloc]
	 initWithRect: [imageView bounds] // in our case track the entire view
	 options: trackingOptions
	 owner: self
	 userInfo: nil];*/
	trackingArea = [[NSTrackingArea alloc]
					  initWithRect: [self bounds] // in our case track the entire view
					  options: trackingOptions
					  owner: self
					  userInfo: nil];
	[self addTrackingArea: trackingArea];
}

- (void)didResize {
	//NSLog(@"Resizing...");
	[self updateTrackingArea];
}

/*- (void) mouseEntered:(NSEvent*)theEvent {
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

- (void) mouseExited:(NSEvent*)theEvent {
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

- (IBAction)openReplyPost:(id)sender {
	if (!self.postController) {
		PSCNewPostController *pC = [[PSCNewPostController alloc] init];
		self.postController =  pC;
	}
	
	[self.postController draftReply:post];
	[ANSession.defaultSession userWithID:ANMeUserID completion:^(ANResponse *response, ANUser *user, NSError *error) {
		if ([[PSCMemoryCache sharedMemory].avatarImages objectForKey:[user username]])
		{
			[[self.postController avatarView] setImage:[[PSCMemoryCache sharedMemory].avatarImages objectForKey:[user username]]];
		}
		else {
			[[user avatarImage] imageAtSize:CGSizeMake(52*2, 52*2) completion:^(NSImage *image, NSError *error) {
				NSImage *maskedImage = [[PSCMemoryCache sharedMemory] maskImage:image withMask:[NSImage imageNamed:@"avatar-mask"]];
				[[PSCMemoryCache sharedMemory].avatarImages setValue:maskedImage forKey:[user username]];
				[[self.postController avatarView] setImage:maskedImage];
			}];
		}
	}];
	[self.postController showWindow:self];
	//[self.postController processResults:[questionField stringValue]];
	
	// get replies
	[post replyPostsWithCompletion:^(ANResponse *response, NSArray *posts, NSError *error) {
		if ([posts count]!=0) {
			ANPost *reply = [posts objectAtIndex:0];
			//NSLog(@"reply: %@", [reply text]);
		}
	}];
}

- (IBAction)starPost:(id)sender {
	if (![post youStarred]) {
		[post starWithCompletion:^(ANResponse *response, ANPost *starredPost, NSError *error) {
			if (!starredPost) {
				NSLog(@"There was an error starring the post.");
			}
			else {
				NSLog(@"Starring was successful.");
				[starButton setImage:[NSImage imageNamed:@"star-highlight"]];
				[starButton setTextColor:[NSColor colorWithDeviceRed:0.894 green:0.541 blue:0.082 alpha:1.0]];
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
				[starButton setTextColor:[self defaultButtonColor]];
			}
		}];
	}
}

- (IBAction)repostPost:(id)sender {
	// keep in mind posts that have been starred but haven't been reloaded for the post status
	if (![post youReposted]) {
		[post repostWithCompletion:^(ANResponse *response, ANPost *repostPost, NSError *error) {
			if (!repostPost) {
				NSLog(@"There was an error reposting the post.");
			}
			else {
				NSLog(@"Reposting was successful.");
				[repostButton setImage:[NSImage imageNamed:@"repost-highlight"]];
				[repostButton setTextColor:[NSColor colorWithDeviceRed:0.118 green:0.722 blue:0.106 alpha:1.0]];
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
				[repostButton setTextColor:[self defaultButtonColor]];
			}
		}];
	}
}

- (IBAction)deletePost:(id)sender {
	[post deleteWithCompletion:^(ANResponse *response, ANPost *deletedPost, NSError *error) {
		if (!deletedPost) {
			NSLog(@"There was an error deleting the post.");
		}
		else {
			NSLog(@"Post was deleted successfully.");
		}
	}];
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"mouseDown event detected!");
}

- (void)drawRect:(NSRect)dirtyRect {
	[[NSColor colorWithDeviceRed:0.941 green:0.941 blue:0.941 alpha:1.0] set]; // Sets current drawing color.
	NSRectFill(self.bounds);
}

- (void)hideRepost {
	[[self repostImageView] setHidden:YES];
	[[self repostedUserButton] setHidden:YES];
}

- (void)showRepost {
	[[self repostImageView] setHidden:NO];
	[[self repostedUserButton] setHidden:NO];
	[[self repostedUserButton] addCursorRect:[[self repostedUserButton] bounds] cursor:[NSCursor pointingHandCursor]];
}

@end
