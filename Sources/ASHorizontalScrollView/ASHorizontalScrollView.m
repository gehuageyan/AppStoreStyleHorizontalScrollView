//
//  ASHorizontalScrollView.m
//  ScrollViewSample
//
//  Created by Vivien on 2014-06-01.
//  Copyright (c) 2014 Zuse. All rights reserved.
//

#import "ASHorizontalScrollView.h"

@implementation ASHorizontalScrollView

#define kDefaultLeftMargin 5.0f;
#define kMinMarginBetweenItems 10.0f;
#define kMinWidthAppearOfLastItem 10.0f;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _items = [NSMutableArray array];
        
        //default item size is 80% of height
        _uniformItemSize = CGSizeMake(frame.size.height*0.8, frame.size.height*0.8);
        
        //default attributes
        _leftMarginPx = kDefaultLeftMargin;
        _miniMarginPxBetweenItems = kMinMarginBetweenItems;
        _miniAppearPxOfLastItem = kMinWidthAppearOfLastItem;
        
        //get default item margin
        [self setItemsMarginOnce];
        
        [self setShowsHorizontalScrollIndicator:NO];
        [self setDecelerationRate:UIScrollViewDecelerationRateFast];
        
        scrollViewdelegate = [[ASHorizontalScrollViewDelegate alloc] init];
        self.delegate = scrollViewdelegate;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    itemY = (frame.size.height-self.uniformItemSize.height)/2;
}

- (void)setUniformItemSize:(CGSize)uniformItemSize
{
    _uniformItemSize = uniformItemSize;
    itemY = (self.frame.size.height-uniformItemSize.height)/2;
}



#pragma mark - add item
- (void)addItem:(UIView*)item
{
    //setup new item size and origin
    if (self.items.count>0) {
        CGRect lastItemRect = ((UIView*)self.items.lastObject).frame;
        [item setFrame:CGRectMake(lastItemRect.origin.x + self.uniformItemSize.width + self.itemsMargin, itemY, self.uniformItemSize.width, self.uniformItemSize.height)];
    }
    else [item setFrame:CGRectMake(self.leftMarginPx, itemY, self.uniformItemSize.width, self.uniformItemSize.height)];
    
    [_items addObject:item];
    [self addSubview:item];
    // set the content size of scroll view to fit new width and with the same margin as left margin
    self.contentSize = CGSizeMake(item.frame.origin.x + self.uniformItemSize.width + self.leftMarginPx, self.frame.size.height);
}

- (void)addItems:(NSArray *)items
{
    for (UIView* item in items) {
        [self addItem:item];
    }
}

//calculate the exact margin between items
- (int)calculateMarginBetweenItems
{
    //calculate how many items listed on current screen except the last half appearance one
    int numberOfItemForCurrentWidth = floorf((self.frame.size.width-self.leftMarginPx-self.miniAppearPxOfLastItem)/(_uniformItemSize.width+self.miniMarginPxBetweenItems));
    
    return round((self.frame.size.width-self.leftMarginPx-self.miniAppearPxOfLastItem)/numberOfItemForCurrentWidth - _uniformItemSize.width);
}

- (void)setItemsMarginOnce
{
    _itemsMargin = [self calculateMarginBetweenItems];
}

#pragma mark - remove item
//return whether removing action is success
- (BOOL)removeItem:(UIView *)item
{
    NSInteger index = [self.items indexOfObject:item];
    if (index != NSNotFound) {
        return [self removeItemAtIndex:index];
    }
    else return false;
}

- (BOOL)removeItemAtIndex:(NSInteger)index
{
    if (index < 0 || index > self.items.count-1) return false;
    //set new x position from index to the end
    for (NSInteger i = self.items.count-1; i > index; i--) {
        UIView *item = [self.items objectAtIndex:i];
        item.frame = CGRectMake(CGRectGetMinX(item.frame)-self.itemsMargin-self.uniformItemSize.width, CGRectGetMinY(item.frame), CGRectGetWidth(item.frame), CGRectGetHeight(item.frame));
    }
    UIView *item = [self.items objectAtIndex:index];
    [item removeFromSuperview];
    [self.items removeObjectAtIndex:index];
    self.contentSize = CGSizeMake(self.contentSize.width-self.itemsMargin-self.uniformItemSize.width, self.frame.size.height);
    
    return true;
}


@end