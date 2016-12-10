//
//  PopupInfoView.m
//  SailsMyMap
//
//  Created by Eddie Hua on 2014/5/12.
//  Copyright (c) 2014年 SAILS Tech. All rights reserved.
//
#import "CommonDefine.h"
#import "PopupInfoView.h"
#import "CMPopTipView.h"
#import "POI.h"
#import <locating/LocationRegion.h>

// Size
const static int TEXT_MARGIN = 10;
// Button TAG
const static int TAG_BUTTON_NAVI = 1;
const static int TAG_BUTTON_INFO = 2;


const static CGFloat kCornerRadius = 4;  // 圓角
const static CGFloat kNaviButtonSize = 50;

@implementation PopupInfoView
{
    CMPopTipView*       mPopView;
    UIButton*           mBtnNavi;
    UIButton*           mBtnInfo;
    UIFont*             mFont;
    
    UIColor*            mHighlightColor;
    
    BOOL                mArrowDirectionUp;
    
    //UIButton*           mOutsideDismissArea;
    
    CGRect              bubbleRect;
    CGPoint             _targetPoint;
    NSString *kEmptyString;
}

- (void) dealloc
{
    mPopView = nil;
    mBtnNavi = nil;
    mBtnInfo = nil;
    mFont = nil;
    mHighlightColor = nil;
    //mOutsideDismissArea = nil;
}
- (id)init
{
    self = [super init];
    if (self) {
        mArrowDirectionUp = NO;
        _btwArrowAndClickGap = 18;
        mHighlightColor = [UIColor lightGrayColor];
        _labelColor = [UIColor whiteColor];
        _buttonColor = [UIColor blueColor];
        self.backgroundColor = [UIColor clearColor];
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowRadius = 2.0;
        self.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        self.layer.shadowOpacity = 0.7;
        _arrowSize = 8;

        mFont = [UIFont systemFontOfSize:24];
        // Button
        //UIImage* imgNavi = [UIImage imageNamed:@"popupinfo_navito"];
        mBtnNavi = [UIButton buttonWithType:UIButtonTypeCustom];
        mBtnNavi.tag = TAG_BUTTON_NAVI;
        [mBtnNavi addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [mBtnNavi setImage:[UIImage imageNamed:@"sample"] forState:UIControlStateNormal];
        mBtnNavi.frame = CGRectMake(0, 0, kNaviButtonSize, kNaviButtonSize);
        [self addSubview:mBtnNavi];
        
        // Info
        mBtnInfo = [UIButton buttonWithType:UIButtonTypeCustom];
        mBtnInfo.titleLabel.font = mFont;
        [mBtnInfo.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [mBtnInfo setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [mBtnInfo setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [mBtnInfo setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [mBtnInfo setTitleColor:[UIColor colorWithRed:0x44/255.0 green:0x71/255.0 blue:0xe3/255.0 alpha:1.0] forState:UIControlStateHighlighted];
//        [mBtnInfo setBackgroundImage:newUIImageWithUIColor(mHighlightColor) forState:UIControlStateHighlighted];
        mBtnInfo.tag = TAG_BUTTON_INFO;
        [mBtnInfo addTarget:self action:@selector(onButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:mBtnInfo];
        //[mBtnNavi setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        //[mBtnNavi setTitleEdgeInsets:UIEdgeInsetsMake(0, 8.0, 0, 0)];
        //[mBtnNavi setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    return self;
}

- (IBAction) onButtonTouchDown:(id)sender
{
    switch ([sender tag])
    {
        case TAG_BUTTON_INFO:
            [_delegate ShowDetail:_extPOI PopupInfoView:self];
//            [self dismissAnimated:YES];
            break;
        case TAG_BUTTON_NAVI:
            
            [_delegate setRouteLocationRegion:_extPOI PopupInfoView:self];
            [self dismissAnimated:YES];
            break;
    }
}
-(BOOL) isHidden
{
    return (nil == [self superview]);
}
-(void) setHidden:(BOOL)hidden
{
    [self dismissAnimated:YES];
}

-(void)showInfo:(POI*)poi InView:(UIView*) view clickOn:(CGPoint) point HideNavi:(BOOL) bHidden
{
    _extPOI = poi;
    NSString* strInfo = kEmptyString;
    if (poi != nil)
    {
        strInfo = poi[@"name"];
    }

    [mBtnNavi setHidden:bHidden];
    [self presentInfo:strInfo InView:view clickOn:point hasURL:poi[@"link"]!=nil animated:YES];
}
-(void)showInfo:(POI*)poi Info:(NSString*) info InView:(UIView*) view clickOn:(CGPoint) point HideNavi:(BOOL) bHidden
{
    _extPOI = poi;
    [mBtnNavi setHidden:bHidden];
    [self presentInfo:info InView:view clickOn:point hasURL:poi[@"link"]!=nil animated:YES];
}

//
- (void)presentInfo:(NSString*) strInfo InView:(UIView *)containerView clickOn:(CGPoint) ptInContainer hasURL:(BOOL)hasUrl animated:(BOOL)animated
{
//    if (mOutsideDismissArea == nil)
//    {
//        mOutsideDismissArea = [UIButton buttonWithType:UIButtonTypeCustom];
//        [mOutsideDismissArea addTarget:self action:@selector(dismissTapAnywhereFired:) forControlEvents:UIControlEventTouchDown];
//        [mOutsideDismissArea setTitle:@"" forState:UIControlStateNormal];
//    }
//    [containerView addSubview:mOutsideDismissArea];
//    mOutsideDismissArea.frame = containerView.bounds;
    
    if (nil != [self superview])
    {
        [self removeFromSuperview];
    }
    float fInfoButtonPosX = 0;
    if (![mBtnNavi isHidden])
    {
        fInfoButtonPosX = kNaviButtonSize;
    }
	const CGFloat fContainerWidth = containerView.bounds.size.width;
    const CGFloat fMaxLabelWidth = fContainerWidth - fInfoButtonPosX - TEXT_MARGIN * 2;
    
    CGSize textSize = [strInfo sizeWithAttributes:@{ NSFontAttributeName : mFont }];
    float fLabelWidth = MIN(fMaxLabelWidth, textSize.width) + TEXT_MARGIN * 2;
    float fViewWidth = fInfoButtonPosX + fLabelWidth;
    [mBtnInfo setTitle:strInfo forState:UIControlStateNormal];
    [mBtnInfo setHighlighted:hasUrl];
    bubbleRect = CGRectMake(0,0, fViewWidth, kNaviButtonSize);
    //-------------------------------------------------------
	CGFloat pointerY;	// Y coordinate of pointer target (within containerView)
	CGFloat fullHeight = bubbleRect.size.height + _arrowSize;
    // 照 Android Version 的習慣，先考慮箭頭向下 (視窗在點選的上方）
    pointerY = ptInContainer.y - (fullHeight + _btwArrowAndClickGap);
    if (pointerY < 0)
    {
        // Menu 在手指下方
        pointerY = ptInContainer.y + (_arrowSize + _btwArrowAndClickGap);
        mArrowDirectionUp = YES;
    } else {
        pointerY = ptInContainer.y - (_arrowSize + _btwArrowAndClickGap);
        mArrowDirectionUp = NO;
    }
	CGPoint ptCenter = ptInContainer;   // 以 click pos 為中心
	CGFloat left = ptCenter.x - roundf(bubbleRect.size.width/2);
	if (left < 0) {
		left = 0;
	}
	if (left + bubbleRect.size.width > fContainerWidth) {
		left = fContainerWidth - bubbleRect.size.width;
	}
	CGFloat y_b;
	if (mArrowDirectionUp) {
		y_b = pointerY;
		_targetPoint = CGPointMake(ptCenter.x-left, 0);
	}
	else {
		y_b = pointerY - fullHeight;
		_targetPoint = CGPointMake(ptCenter.x-left, fullHeight);
	}
    // ----
    float fArrowOffsetY = mArrowDirectionUp ? _arrowSize : 0;
    mBtnNavi.frame = CGRectMake(0, fArrowOffsetY,
                                kNaviButtonSize, kNaviButtonSize);

    mBtnInfo.frame = CGRectMake(fInfoButtonPosX, fArrowOffsetY,
                                fLabelWidth, kNaviButtonSize);

    // ----
    const float fOffset = 70;
	CGRect finalFrame = CGRectMake(left,
								   y_b + fOffset,
								   bubbleRect.size.width,
								   fullHeight);
	//NSLog(@"containerView Frame : %@", NSStringFromCGRect(containerView.frame));
	//NSLog(@"finalFrame Frame : %@", NSStringFromCGRect(finalFrame));
   	[self layoutSubviews];
	[containerView addSubview:self];
    //[containerView bringSubviewToFront:self];
	if (animated) {
        [self _show_animate:finalFrame];
	}
	else {
		// Not animated
		[self setNeedsDisplay];
		self.frame = finalFrame;
	}
}

- (void) _show_animate:(CGRect) finalFrame
{
    self.frame = finalFrame;
    self.alpha = 0.5;
    
    // start a little smaller
    self.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
    
    // animate to a bigger size
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(popAnimationDidStop:finished:context:)];
    [UIView setAnimationDuration:0.1f];
    self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
    self.alpha = 1.0;
    [UIView commitAnimations];
    
    [self setNeedsDisplay];
}

- (void)popAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // at the end set to normal size
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (void)dismissTapAnywhereFired:(UIButton *)button
{
	[self dismissAnimated:YES];
}

- (void) dismissAnimated:(BOOL)animated {
	
	if (animated) {
        [UIView animateWithDuration:0.2f
                         animations:^{
                             self.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             [self finaliseDismiss];
                         }];
	}
	else {
		[self finaliseDismiss];
	}
}

- (void)finaliseDismiss {
//    if (mOutsideDismissArea) {
//        [mOutsideDismissArea removeTarget:self action:@selector(dismissTapAnywhereFired:) forControlEvents:UIControlEventTouchDown];
//        [mOutsideDismissArea removeFromSuperview];
//		mOutsideDismissArea = nil;
//    }
    //[mOutsideDismissArea removeFromSuperview];
	[self removeFromSuperview];
}

- (void)drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
    
	CGMutablePathRef bubblePath = CGPathCreateMutable();
	
	if (mArrowDirectionUp) {
		CGPathMoveToPoint(bubblePath, NULL, _targetPoint.x, _targetPoint.y);
		CGPathAddLineToPoint(bubblePath, NULL, _targetPoint.x +_arrowSize, _targetPoint.y+_arrowSize);
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x + bubbleRect.size.width, _arrowSize + bubbleRect.origin.y,
							bubbleRect.origin.x + bubbleRect.size.width, _arrowSize + bubbleRect.origin.y + kCornerRadius,
							kCornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x + bubbleRect.size.width,
                            _arrowSize + bubbleRect.origin.y + bubbleRect.size.height,
							bubbleRect.origin.x + bubbleRect.size.width - kCornerRadius,
                            _arrowSize + bubbleRect.origin.y + bubbleRect.size.height,
							kCornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x,
                            _arrowSize + bubbleRect.origin.y + bubbleRect.size.height,
							bubbleRect.origin.x,
                            _arrowSize + bubbleRect.origin.y + bubbleRect.size.height - kCornerRadius,
							kCornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, _arrowSize + bubbleRect.origin.y,
							bubbleRect.origin.x + kCornerRadius, _arrowSize + bubbleRect.origin.y,
							kCornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, _targetPoint.x-_arrowSize, _targetPoint.y+_arrowSize);
	}
	else {
        //bubbleRect = CGRectOffset(bubbleRect, 0, 2);
        //_targetPoint.y = _targetPoint.y + 2;
		CGPathMoveToPoint(bubblePath, NULL, _targetPoint.x, _targetPoint.y);
		CGPathAddLineToPoint(bubblePath, NULL, _targetPoint.x - _arrowSize, _targetPoint.y-_arrowSize);
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height - kCornerRadius,
							kCornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y,
							bubbleRect.origin.x + kCornerRadius, bubbleRect.origin.y,
							kCornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y + kCornerRadius,
							kCornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width - kCornerRadius,
                            bubbleRect.origin.y+bubbleRect.size.height,
							kCornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, _targetPoint.x+_arrowSize, _targetPoint.y-_arrowSize);
	}
	CGPathCloseSubpath(bubblePath);
    
    CGContextSaveGState(c);
	CGContextAddPath(c, bubblePath);
	CGContextClip(c);
    
    // Fill with solid color : 要分兩邊顏色
    CGContextSetFillColorWithColor(c, [UIColor whiteColor].CGColor);//[mBtnInfo isHighlighted] ? [mHighlightColor CGColor] : [_labelColor CGColor]);
    CGContextFillRect(c, self.bounds);
    
    if (![mBtnNavi isHidden])
    {
        CGRect rcLeft = self.bounds;
        rcLeft.size.width = mBtnNavi.frame.size.width;
        CGContextSetFillColorWithColor(c, [_buttonColor CGColor]);
        CGContextFillRect(c, rcLeft);
    }
	
	CGContextRestoreGState(c);

	CGPathRelease(bubblePath);
}
@end
