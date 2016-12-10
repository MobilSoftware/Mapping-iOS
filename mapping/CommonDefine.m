//
// Created by Richard on 2016/12/6.
// Copyright (c) 2016 sailstech. All rights reserved.
//

#import "CommonDefine.h"
#import "MBProgressHUD.h"


NSString *ZpLocalizedString(NSString *string);

@implementation CommonDefine {

}
#pragma mark - Wait Hud -
+ (void) showPleaseWaitHudToView:(UIView*) view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = ZpLocalizedString(@"Msg.PleaseWait");
}
+ (void) showPleaseWaitHudToView:(UIView*) view withMSG:(NSString*) msg
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.label.text = msg;
}
+ (void) hidePleaseWaitHudForView:(UIView*) view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}
+ (void) showErrorDialog
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:ZpLocalizedString(@"cannot connect to server or server error!")
                                                   delegate:nil
                                          cancelButtonTitle:ZpLocalizedString(@"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

+ (void) showErrorDialogWithMsg:(NSString*) msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:msg
                                                   delegate:nil
                                          cancelButtonTitle:ZpLocalizedString(@"OK")
                                          otherButtonTitles:nil];
    [alert show];
}
@end

NSString *ZpLocalizedString(NSString *key) {
    NSString* str = NSLocalizedString(key, nil);
    if (str == nil)
    {
        // 讀不到時，用哪一國？
        // 先顯示 Key好了
        str = [key copy];
    }
//    if (![[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:en]
//        && [str isEqualToString:key])
//    {
//        NSString * path = [[NSBundle mainBundle] pathForResource:en ofType:@"lproj"];
//        if (path != nil)
//        {
//            NSBundle * languageBundle = [NSBundle bundleWithPath:path];
//            str = [languageBundle localizedStringForKey:key value:@"" table:nil];
//        } else {
//            return key;
//        }
//    }
    return str;

}