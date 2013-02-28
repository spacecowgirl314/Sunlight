//
//  PSCBreadcrumbView.m
//  Sunlight
//
//  Created by Meiwin Fu on 1/13/13.
//  Modified by Chloe Stars on 2/25/13
//  Copyright (c) 2013 BlockThirty. All rights reserved.
//  Copyright (c) Phantom Sun Creative, Ltd.
//

#import "PSCBreadcrumbView.h"
#import "NSButton+TextColor.h"
#import <QuartzCore/QuartzCore.h>

#define kAnimationDuration 0.5

#define kShadowOpacity   0.3
#define kShadowOffset    CGSizeMake(1, 2)
#define kShadowRadius    2.5
#define kShadowColor     [NSColor blackColor].CGColor

#define mSetShadow(_view) \
CALayer *layer = [_view layer]; \
layer.shadowOffset = kShadowOffset; \
layer.shadowOpacity = kShadowOpacity; \
layer.shadowRadius = kShadowRadius; \
layer.shadowColor = kShadowColor

#define mRGBA(_red,_green,_blue,_alpha) \
[NSColor colorWithDeviceRed:(_red/255.0) green:(_green/255.0) blue:(_blue/255.0) alpha:_alpha]

#define mRect(_w,_h) CGRectMake(0,0,_w,_h)

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@implementation PSCBreadcrumbItem
@synthesize title = _title;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@interface PSCBreadcrumbView (Private)
- (NSButton *)startButton;
- (NSButton *)itemButton:(PSCBreadcrumbItem *)item;
- (void)didTapStartButton;
- (void)didTapItemAtIndex:(NSUInteger)index;
- (void)tapStartButton:(id)sender;
- (void)tapItemButton:(id)sender;
@end

#define kButtonPadding 10
#define kBreadcrumbHeight 30
@implementation PSCBreadcrumbView
@synthesize items = _items;
@synthesize delegate = _delegate;

- (void)prepare
{
	// Initialization code
	//self.backgroundColor = [NSColor whiteColor];
	self.autoresizesSubviews = YES;
	mSetShadow(self);
	_items = [NSArray new];
	
	_containerView = [[NSView alloc] initWithFrame:self.bounds];
	_containerView.autoresizingMask =
	_containerView.autoresizingMask = NSViewHeightSizable|NSViewWidthSizable;
	//_containerView.backgroundColor = [NSColor whiteColor];
	//_containerView.clipsToBounds = YES;
	[self addSubview:_containerView];
	
	// Create fixed subviews
	_startButton = [self startButton];
	[_containerView addSubview:_startButton];
}

- (id)init
{
	self = [super init];
	if (self) {
		[self prepare];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		[self prepare];
	}
	return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
  CGFloat total_width = kButtonPadding;
  for (NSView *itemView in _itemViews) {
    total_width += itemView.bounds.size.width;
  }
  if (_itemViews.count > 0)
  {
    //NSButton *lastButton = [_itemViews lastObject];
    //if (lastButton.titleEdgeInsets.right > 10)
    //{
      total_width -= 12;
    //}
  }
  return CGSizeMake(total_width, kBreadcrumbHeight);
}

#pragma mark Private
- (NSButton *)startButton
{
	NSButton *button = [[NSButton alloc] init];
	NSImage *bgImage = [NSImage imageNamed:@"button_item"];
	[button setImage:bgImage];
	[button setAlternateImage:bgImage];
	[button setImagePosition:NSImageRight];
	[button setBordered:NO];
	[button setButtonType:NSMomentaryChangeButton];
	button.font = [NSFont fontWithName:@"Helvetica" size:13];
	button.alignment = NSCenterTextAlignment;
	button.title = @"My Stream";
	button.textColor = [NSColor colorWithDeviceRed:0.643 green:0.643 blue:0.643 alpha:1.0];
	[button sizeToFit];
	CGSize s = button.bounds.size;
	button.frame = mRect(s.width+kButtonPadding, kBreadcrumbHeight);
	button.target = self;
	button.action = @selector(tapStartButton:);
  return button;
}

- (void)setStartTitle:(NSString *)title
{
	_startButton.title = title;
	_startButton.textColor = [NSColor colorWithDeviceRed:0.643 green:0.643 blue:0.643 alpha:1.0];
	[_startButton sizeToFit];
	CGSize s = _startButton.bounds.size;
	_startButton.frame = mRect(s.width+kButtonPadding, kBreadcrumbHeight);
}

- (NSButton *)itemButton:(PSCBreadcrumbItem *)item
{
	NSButton *button = [[NSButton alloc] init];
	button.alignment = NSCenterTextAlignment;
	button.font = [NSFont fontWithName:@"Helvetica" size:13];
	[button setBordered:NO];
	[button setButtonType:NSMomentaryChangeButton];
	[button highlight:NO];
	button.title = item.title;
	button.textColor = [NSColor colorWithDeviceRed:0.643 green:0.643 blue:0.643 alpha:1.0];
	
	NSImage *bgImage = [NSImage imageNamed:@"button_item"];
	[button setImage:bgImage];
	[button setAlternateImage:bgImage];
	[button setImagePosition:NSImageRight];
	
	[button sizeToFit];
	CGSize s = button.bounds.size;
	button.frame = CGRectMake(0, 0, s.width + kButtonPadding, kBreadcrumbHeight);
	button.target = self;
	button.action = @selector(tapItemButton:);
	
	return button;
}

- (void)didTapStartButton
{
  if (_delegate && [(id)_delegate respondsToSelector:@selector(breadcrumbViewDidTapStartButton:)])
  {
    [_delegate breadcrumbViewDidTapStartButton:self];
	  [self setItems:[NSArray new]];
  }
}
- (void)didTapItemAtIndex:(NSUInteger)index
{
  if (_delegate && [(id)_delegate respondsToSelector:@selector(breadcrumbView:didTapItemAtIndex:)])
  {
    [_delegate breadcrumbView:self didTapItemAtIndex:index];
	  [self popItem:[_items objectAtIndex:index]];
  }
}

- (void)tapStartButton:(id)sender
{
  [self didTapStartButton];
}
- (void)tapItemButton:(id)sender
{
  [self didTapItemAtIndex:[_itemViews indexOfObject:sender]];
}

#pragma mark Layout
- (void)layout
{
  [super layout];
  
	CGFloat cx = _startButton.bounds.size.width; //kStartButtonWidth;
  for (NSView *view in _itemViews)
  {
    CGSize s = view.bounds.size;
    view.frame = CGRectMake(cx, 0, s.width, s.height);
    cx += s.width;
  }
}

#pragma mark Public
- (void)setItems:(NSArray *)items
{
  if (_animating) return;
  
  // remove existings
  for (NSView *view in _itemViews) {
    [view removeFromSuperview];
  }
  
  // add all
  _itemViews = [NSMutableArray arrayWithCapacity:0];
  _items = items;
  int i = 0;
  for (PSCBreadcrumbItem *item in _items) {
	  NSButton *itemButton = [self itemButton:item];
	  [_containerView addSubview:itemButton];
	  [_itemViews addObject:itemButton];
	  i++;
  }
  //[self sizeToFit];
	[self layout];
  //[self setNeedsLayout:YES];
}

- (void)pushItem:(PSCBreadcrumbItem*)item
{
	NSMutableArray *mutableCopy = [_items mutableCopy];
	[mutableCopy addObject:item];
	[self setItems:mutableCopy];
}

- (void)popItem:(PSCBreadcrumbItem*)item
{
	NSMutableArray *mutableCopy = [_items mutableCopy];
	// iterate backwards until we reach the item being removed
	for (NSUInteger i=mutableCopy.count-1; i>[mutableCopy indexOfObject:item]; i--)
	{
		[mutableCopy removeObjectAtIndex:i];
	}
	[self setItems:mutableCopy];
}

- (void)clear
{
	[self setItems:[NSArray arrayWithObjects:nil]];
}

- (void)updateButton:(NSButton *)button setLastItem:(BOOL)isLastItem
{
  CGPoint o = button.frame.origin;
  CGSize s = button.frame.size;
  CGFloat w = s.width;
  if (isLastItem)
  {
    //if (button.currentBackgroundImage != nil)
    //{
      /*button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
      [button setBackgroundImage:nil forState:UIControlStateNormal];
      [button setBackgroundImage:nil forState:UIControlStateHighlighted];
      button.backgroundColor = [UIColor whiteColor];*/
      w = s.width-12;
    //}
  }
  else
  {
    //if (button.currentBackgroundImage == nil)
    //{
      /*button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 22);
      NSImage *bgImage = [[UIImage imageNamed:@"button_item.png"] stretchableImageWithLeftCapWidth:1 topCapHeight:0];
      [button setBackgroundImage:bgImage forState:UIControlStateNormal];
      [button setBackgroundImage:bgImage forState:UIControlStateHighlighted];
      button.backgroundColor = [UIColor clearColor];*/
      w = s.width+12;
    //}
  }
  button.frame  = CGRectMake(self.bounds.size.width-w, o.y, w, s.height);
	
}

/*- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
  if (_animating) return;
  
  if (animated)
  {
    // retract existings
    NSArray *oldItems = _items;
    _items = items;

    int oldCount = (int)oldItems.count;
    int newCount = (int)_items.count;
    
    int removeStartIndex = 0;
    for (int i = 0; i < oldCount; i++)
    {
      if (i < newCount)
      {
        PSCBreadcrumbItem *oldItem = [oldItems objectAtIndex:i];
        PSCBreadcrumbItem *newItem = [_items objectAtIndex:i];
        if (![newItem.title isEqual:oldItem.title])
        {
          break;
        }
      }
      else
      {
        break;
      }
      removeStartIndex++;
    }

    NSArray *oldItemViews = _itemViews;
    _itemViews = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < removeStartIndex; i++)
    {
      [_itemViews addObject:[oldItemViews objectAtIndex:i]];
    }
    
	  [[NSAnimationContext currentContext] setDuration:0.2];
	  
    // retract first
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
      
      _animating = YES;
      
      //[self sizeToFit];
      
      // right bound
      for (int i = removeStartIndex; i < oldCount; i++)
      {
        NSButton *oldView = [oldItemViews objectAtIndex:i];
        CGSize s = oldView.bounds.size;
        //oldView.frame = CGRectMake(self.bounds.size.width-s.width, 0, s.width, s.height);
		  [[oldView animator] setFrame:CGRectMake(self.bounds.size.width-s.width, 0, s.width, s.height)];
      }
     
      if (removeStartIndex < newCount)
      {
        if (removeStartIndex > 0)
        {
          NSButton *button = [_itemViews objectAtIndex:removeStartIndex-1];
          [self updateButton:button setLastItem:NO];
        }
      }

      //[self sizeToFit];
      
    }  completionHandler:^() {
      
      for (int i = removeStartIndex; i < oldCount; i++)
      {
        NSView *oldView = [oldItemViews objectAtIndex:i];
        [oldView removeFromSuperview];
      }
      
      // adding new item
      if (removeStartIndex < newCount)
      {
        for (int i = removeStartIndex; i < newCount; i++)
        {
          PSCBreadcrumbItem *item = [_items objectAtIndex:i];
          NSView *newView = [self itemButton:item];
          CGSize s = newView.bounds.size;
          newView.frame = CGRectMake(self.bounds.size.width-s.width, 0, s.width, s.height);
			//[[newView animator] setFrame:CGRectMake(self.bounds.size.width-s.width, 0, s.width, s.height)];
			//[_containerView addSubview:newView positioned:NSWindowBelow relativeTo:[_items objectAtIndex:0]];
			[_containerView addSubview:newView];
          //[_containerView insertSubview:newView atIndex:0];
          [_itemViews addObject:newView];
        }
        if (newCount > 0)
        {
          NSButton *lastButton = [_itemViews objectAtIndex:newCount-1];
          [self updateButton:lastButton setLastItem:YES];
        }
      }
      
      // animate them
      [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        //[self sizeToFit];
		  [self layout];
        //[self layoutSubviews];
      } completionHandler:^() {
        _animating = NO;
      }];
      
    }];
    
  }
  else
  {
    [self setItems:items];
  }
}*/

- (void)drawRect:(NSRect)dirtyRect
{
	// set any NSColor for filling, say white:
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
}

@end

