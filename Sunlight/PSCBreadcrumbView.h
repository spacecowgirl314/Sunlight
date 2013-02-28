//
//  PSCBreadcrumbView.h
//  Sunlight
//
//  Created by Meiwin Fu on 1/13/13.
//  Modified by Chloe Stars on 2/25/13
//  Copyright (c) 2013 BlockThirty. All rights reserved.
//  Copyright (c) Phantom Sun Creative, Ltd.
//

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@class PSCBreadcrumbView;
@protocol PSCBreadcrumbViewDelegate
@optional
- (void)breadcrumbViewDidTapStartButton:(PSCBreadcrumbView *)view;
- (void)breadcrumbView:(PSCBreadcrumbView *)view didTapItemAtIndex:(NSUInteger)index;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@interface PSCBreadcrumbItem : NSObject
@property (nonatomic,strong) NSString *title;
@end

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
@interface PSCBreadcrumbView : NSView
{
  NSView *_containerView;
  NSButton *_startButton;
  NSArray * _items;
  NSMutableArray * _itemViews;
	NSString *_title;
  
  BOOL _animating;
  __unsafe_unretained id<PSCBreadcrumbViewDelegate> _delegate;
}
@property (nonatomic,strong) NSArray *items;
@property (nonatomic,assign) id<PSCBreadcrumbViewDelegate> delegate;

- (void)setItems:(NSArray *)items;
//- (void)setItems:(NSArray *)items animated:(BOOL)animated;
- (void)pushItem:(PSCBreadcrumbItem*)item;
- (void)popItem:(PSCBreadcrumbItem*)item;
- (void)setStartTitle:(NSString*)title;
@end

