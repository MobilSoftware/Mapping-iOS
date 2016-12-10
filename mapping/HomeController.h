//
//  HomeController.h
//  mapping
//
//  Created by Richard on 2016/12/6.
//  Copyright © 2016年 sailstech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "REFrostedViewController.h"
#import "ParseUI.h"
#import "PopupInfoView.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define NO_MODE 0x0000
#define ACCURACY_VERIFICATION 0x0004


@interface HomeController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, PopupInfoViewDelegate, MFMailComposeViewControllerDelegate>


@property(nonatomic) int currentMode;

- (void)runAccVerify;

- (void)selectProjectProcedure;

- (void)logoutProcedure;
@end
