//
//  YKSVideoView.m
//  SoundLive
//
//  Created by macintosh on 16/8/9.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import "YKSVideoView.h"
#import <AVFoundation/AVFoundation.h>

@interface YKSVideoView ()

@property (weak, nonatomic) IBOutlet UIButton *fullScreenbtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

@end

@implementation YKSVideoView

+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

- (void)awakeFromNib
{
    
}

- (IBAction)backBtnClicked:(UIButton *)sender {
}
- (IBAction)soundSwitchClicked:(UIButton *)sender {
}
- (IBAction)fullScreenBtnClicked:(UIButton *)sender {
}
- (IBAction)playBtnClicked:(UIButton *)sender {
}

@end
