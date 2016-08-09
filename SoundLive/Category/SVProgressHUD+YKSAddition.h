//
//  SVProgressHUD+YKSAddition.h
//  SoundLive
//
//  Created by macintosh on 16/8/9.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>

@interface SVProgressHUD (YKSAddition)

+ (void)showErrorTip:(NSString *)errorTip duration:(NSTimeInterval)duration;
+ (void)showSuccessTip:(NSString *)successTip duration:(NSTimeInterval)duration;

@end
