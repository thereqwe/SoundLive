//
//  YKSQualitySelectView.h
//  SoundLive
//
//  Created by macintosh on 16/8/9.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YKSQualitySelectView : UIView

@property (nonatomic, strong) NSArray *qualityKeys;

@property (nonatomic) NSInteger selectedIndex;

- (void)showQualitySelectView;

- (void)hideQualitySelectView;

@end
