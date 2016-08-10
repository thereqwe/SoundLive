//
//  YKSQualitySelectView.m
//  SoundLive
//
//  Created by macintosh on 16/8/9.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import "YKSQualitySelectView.h"

#define kBaselineBtnTag 1001

@interface YKSQualitySelectView ()

@property (nonatomic, weak) UIButton *selectedBtn;

@property (nonatomic, strong) UIView *background;

@property (nonatomic, strong) UIView *selectView;

@end

@implementation YKSQualitySelectView

+ (instancetype)qualitySelectViewWithQualityKeys:(NSArray *)qualityKeys
{
    YKSQualitySelectView *qualityView = [[YKSQualitySelectView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    qualityView.qualityKeys = qualityKeys;
    return qualityView;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self setupSubviews];
        
        [self.background addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)]];
    }
    return self;
}

- (void)setupSubviews
{
    _background = [[UIView alloc] initWithFrame:self.bounds];
    _background.backgroundColor = [UIColor clearColor];
    [self addSubview:_background];
    
    _selectView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width, 3 * kQualitySelectItemHeight + 2)];
    _selectView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:_selectView];
}

- (void)setQualityKeys:(NSArray *)qualityKeys
{
    if (qualityKeys.count <= 0) return;
    
    _qualityKeys = qualityKeys;
    [self setupItems];
}

- (void)setupItems
{
    for (int i = 0; i < _qualityKeys.count; i ++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, i * kQualitySelectItemHeight, self.width, kQualitySelectItemHeight)];
        btn.tag = kBaselineBtnTag + i;
        [btn setBackgroundColor:[UIColor colorWithRed:33/255 green:33/255 blue:33/255 alpha:1]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"right"] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.selectView addSubview:btn];
    }
}

- (void)btnClicked:(UIButton *)btn
{
    if (self.selectedBtn.tag == btn.tag) return;
    
    self.selectedBtn.selected = NO;
    self.selectedBtn = btn;
    self.selectedBtn.selected = YES;
    _selectedIndex = self.selectedBtn.tag - kBaselineBtnTag;
}

- (void)taped:(UITapGestureRecognizer *)gesture
{
    [self hideQualitySelectView];
}

- (void)showQualitySelectView
{
    [UIView animateWithDuration:0.6 animations:^{
        self.selectView.top = [UIScreen mainScreen].bounds.size.height - self.selectView.height;
    }];
}

- (void)hideQualitySelectView
{
    [UIView animateWithDuration:0.6 animations:^{
        self.selectView.top = [UIScreen mainScreen].bounds.size.height;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
