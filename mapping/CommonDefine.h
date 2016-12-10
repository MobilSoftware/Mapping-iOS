//
// Created by Richard on 2016/12/6.
// Copyright (c) 2016 sailstech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonDefine : NSObject
+ (void)showPleaseWaitHudToView:(UIView *)view;

+ (void)showPleaseWaitHudToView:(UIView *)view withMSG:(NSString *)msg;

+ (void)hidePleaseWaitHudForView:(UIView *)view;

+ (void)showErrorDialog;

+ (void)showErrorDialogWithMsg:(NSString *)msg;
@end

NSString* ZpLocalizedString(NSString* key);
