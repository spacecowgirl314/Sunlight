//
//  PSCAttachmentTextView.m
//  Sunlight
//
//  Created by Chloe Stars on 4/8/13.
//  Copyright (c) 2013 Phantom Sun Creative, Ltd. All rights reserved.
//

#import "PSCAttachmentTextView.h"

@implementation PSCAttachmentTextView
@synthesize delegate;

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
		//NSLog(@"dragged types:%@", [self registeredDraggedTypes]);
	}
	
	return self;
}

#pragma mark Destination Operations

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	//self.mouseRollOver = YES;
	[self setNeedsDisplay:YES];
	NSLog(@"Dragging Entered");
	
	return NSDragOperationCopy;
}

- (BOOL)wantsPeriodicDraggingUpdates
{
	return YES;
}

- (NSDragOperation)draggingUpdated:(id < NSDraggingInfo >)sender
{
	return NSDragOperationCopy;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{	
	return YES;
}

- (void)concludeDragOperation:(id<NSDraggingInfo>)sender
{
	NSPasteboard *pasteboard = [sender draggingPasteboard];
	NSData *data = [pasteboard dataForType:NSFilenamesPboardType];
	NSLog(@"%ld bytes long", data.length);
	
	NSURL *fileURL=[NSURL URLFromPasteboard:pasteboard];
	NSString *fileName = [fileURL lastPathComponent];
	NSLog(@"Attached %@", fileName);
	
	[[self delegate] processDraggedFile:fileName data:data];
}

- (void)updateDraggingItemsForDrag:(id<NSDraggingInfo>)sender
{
	
}

@end
