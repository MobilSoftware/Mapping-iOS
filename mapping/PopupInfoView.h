//
//  PopupInfoView.h
//  SailsMyMap
//
//  Created by Eddie Hua on 2014/5/12.
//  Copyright (c) 2014年 SAILS Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopupInfoView;
@class LocationRegion;
@class POI;

@protocol PopupInfoViewDelegate <NSObject>

@optional
// 點選 Navi Button
-(void) setRouteLocationRegion:(LocationRegion*) loRegion PopupInfoView:(PopupInfoView*) view;
// 點選 Info Button
-(void) ShowDetail:(LocationRegion*) loRegion PopupInfoView:(PopupInfoView*) view;

@end

@interface PopupInfoView : UIView

@property (nonatomic, weak) id<PopupInfoViewDelegate> delegate;
@property (nonatomic, weak) POI*     extPOI;
@property (nonatomic)   UIColor*    labelColor;
@property (nonatomic)   UIColor*    buttonColor;
@property (nonatomic)   CGFloat     arrowSize;
@property (nonatomic)   CGFloat     btwArrowAndClickGap;


-(void)showInfo:(POI*)poi InView:(UIView*) view clickOn:(CGPoint) point HideNavi:(BOOL) bHidden;

- (void)showInfo:(POI *)poi Info:(NSString *)info InView:(UIView *)view clickOn:(CGPoint)point HideNavi:(BOOL)bHidden;
@end
