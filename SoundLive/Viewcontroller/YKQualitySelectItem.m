//
//  YKQualitySelectItem.m
//  SoundLive
//
//  Created by macintosh on 16/8/9.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import "YKQualitySelectItem.h"
#import "UIView+addition.h"
#import "YKSConstConfig.h"


@implementation YKQualitySelectItem

- (instancetype)init
{
    if (self = [super init]) {
        _padding = 0;
    }
    return self;
}

- (void)setPadding:(CGFloat)padding
{
    _padding = padding;
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.titleLabel.frame = CGRectMake(kQualitySelectItemPadding, kQualitySelectItemPadding, self.width - kQualitySelectBtnWH, self.height);
    
    self.imageView.size = CGSizeMake(kQualitySelectBtnWH, kQualitySelectBtnWH);
    
    self.imageView.centerY = self.titleLabel.centerY;
}

@end
