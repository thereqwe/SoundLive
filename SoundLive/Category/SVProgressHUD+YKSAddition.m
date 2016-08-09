//
//  SVProgressHUD+YKSAddition.m
//  SoundLive
//
//  Created by macintosh on 16/8/9.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import "SVProgressHUD+YKSAddition.h"
#import "SVProgressHUD.h"

@implementation SVProgressHUD (YKSAddition)

+ (void)showErrorTip:(NSString *)errorTip duration:(NSTimeInterval)duration
{
    [self switchToTipWithDuration:duration];
    [SVProgressHUD showErrorWithStatus:errorTip];
}

+ (void)showSuccessTip:(NSString *)successTip duration:(NSTimeInterval)duration
{
    [self switchToTipWithDuration:duration];
    [SVProgressHUD showSuccessWithStatus:successTip];
}

+ (void)switchToTipWithDuration:(NSTimeInterval)duration
{
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumDismissTimeInterval:duration];
}

@end
