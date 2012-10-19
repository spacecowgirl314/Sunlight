//
//  PSCPostCellView.m
//  Sunlight
//
//  Created by Chloe Stars on 10/10/12.
//  Copyright (c) 2012 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCPostCellView.h"
#import "NSView+Fade.h"
#import "NSTimer+Blocks.h"

@implementation PSCPostCellView
@synthesize post;
@synthesize postScrollView;
@synthesize postView;
@synthesize userField;
@synthesize postCreationField;
@synthesize avatarView;
@synthesize replyButton;
@synthesize starButton;
@synthesize repostButton;

- (void)awakeFromNib {
	[self updateTrackingArea];
	[self setAcceptsTouchEvents:YES];
	[self becomeFirstResponder];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didResize) name:NSViewFrameDidChangeNotification object:self];
}

- (BOOL) acceptsFirstResponder
{
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

- (void) mouseEntered:(NSEvent*)theEvent {
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
}

- (IBAction)openReplyPost:(id)sender {
	if (!self.postController) {
		PSCNewPostController *pC = [[PSCNewPostController alloc] init];
		self.postController =  pC;
	}
	
	[self.postController draftReply:post];
	[self.postController showWindow:self];
	//[self.postController processResults:[questionField stringValue]];
	
	// get replies
	[post replyPostsWithCompletion:^(ANResponse *response, NSArray *posts, NSError *error) {
		if ([posts count]!=0) {
			ANPost *reply = [posts objectAtIndex:0];
			NSLog(@"reply: %@", [reply text]);
		}
	}];
}

- (IBAction)starPost:(id)sender {
	[post starWithCompletion:^(ANResponse *response, ANPost *starredPost, NSError *error) {
		if (!starredPost) {
			NSLog(@"There was an error starring the post.");
		}
		else {
			NSLog(@"Starring was successful.");
		}
	}];
}

- (IBAction)repostPost:(id)sender {
	[post repostWithCompletion:^(ANResponse *response, ANPost *repostPost, NSError *error) {
		if (!repostPost) {
			NSLog(@"There was an error reposting the post.");
		}
		else {
			NSLog(@"Reposting was successful.");
		}
	}];
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

- (void)swipeWithEvent:(NSEvent *)event {
	int swipeColorValue;
	const int SwipeLeftGreen = 0;
	const int SwipeRightBlue = 1;
	const int SwipeUpRed = 2;
	const int SwipeDownYellow = 3;
	
    CGFloat x = [event deltaX];
    CGFloat y = [event deltaY];
    if (x != 0) {
        swipeColorValue = (x > 0)  ? SwipeLeftGreen : SwipeRightBlue;
    }
    if (y != 0) {
        swipeColorValue = (y > 0)  ? SwipeUpRed : SwipeDownYellow;
    }
    NSString *direction;
    switch (swipeColorValue) {
        case SwipeLeftGreen:
            direction = @"left";
            break;
        case SwipeRightBlue:
            direction = @"right";
            break;
        case SwipeUpRed:
            direction = @"up";
            break;
        case SwipeDownYellow:
        default:
            direction = @"down";
            break;
    }
    [postCreationField setStringValue:[NSString stringWithFormat:@"Swipe %@", direction]];
    [self setNeedsDisplay:YES];
}

@end
