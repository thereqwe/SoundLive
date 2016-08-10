//
//  YKSSoundLive.m
//  SoundLive
//
//  Created by macintosh on 16/8/9.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import "YKSSoundLive.h"
#import "YKLBPlayerCore.h"
#import "SVProgressHUD+YKSAddition.h"

@interface YKSSoundLive () <YKLBPlayerCoreDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *disk;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *qualityBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *preBtn;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (nonatomic) BOOL canPlay;
@property (nonatomic, strong) YKLBPlayerCore *playerCore;
@property (nonatomic) BOOL isPlaying;

@end

@implementation YKSSoundLive

#pragma mark - life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configDisk];
    [self configQualityBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self addNotification];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self removeNotification];
}

- (void)configDisk
{
    _disk.layer.borderColor = ColorRGB(54, 54, 54).CGColor;
    _disk.layer.borderWidth = 8;
    _disk.layer.cornerRadius = _disk.width * 0.5;
    _disk.layer.masksToBounds = YES;
}

- (void)configQualityBtn
{
    _qualityBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _qualityBtn.layer.borderWidth = 1;
    _qualityBtn.layer.cornerRadius = _qualityBtn.height * 0.5;
    _qualityBtn.layer.masksToBounds = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - private

- (void)startRotating
{
    CFTimeInterval pausedTime = [_disk.layer convertTime:CACurrentMediaTime() fromLayer:nil];
    _disk.layer.speed = 0.0;
    _disk.layer.timeOffset = pausedTime;
}

- (void)stopRotating
{
    CFTimeInterval pausedTime = [_disk.layer timeOffset];
    _disk.layer.speed = 1.0;
    _disk.layer.timeOffset = 0.0;
    _disk.layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [_disk.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    _disk.layer.beginTime = timeSincePause;
}

#pragma mark - event response

- (IBAction)backBtnClicked:(UIButton *)sender {
    [self.navigationController popoverPresentationController];
}

- (IBAction)switchToVideo:(UIButton *)sender {
    
}

- (IBAction)qualityBtnClicked:(UIButton *)sender {
    
}

- (IBAction)preSound:(UIButton *)sender {
    
}

- (IBAction)nextSound:(UIButton *)sender {
    
}

- (IBAction)playbtnClicked:(UIButton *)sender {
    if (sender.isSelected) {
        [self stopRotating];
        sender.selected = NO;
    } else {
        NSURL *url = [NSURL URLWithString:@""];
        if (!url) {
            
        }
        
        
        sender.selected = YES;
    }
}

#pragma mark - YKLBPlayerCoreDelegate

- (void)videoPlayerIsReadyToPlayVideo:(YKLBPlayerCore *)playerCore
{
    [self startRotating];
}

- (void)videoPlayerDidReachEnd:(YKLBPlayerCore *)playerCore
{
    
}

- (void)videoPlayer:(YKLBPlayerCore *)playerCore timeDidChange:(CMTime)cmTime
{
    
}

- (void)videoPlayer:(YKLBPlayerCore *)playerCore loadedTimeRangeDidChange:(float)duration
{
    
}

- (void)videoPlayerPlaybackBufferEmpty:(YKLBPlayerCore *)playerCore
{
    
}

- (void)videoPlayerPlaybackLikelyToKeepUp:(YKLBPlayerCore *)playerCore
{
    
}

- (void)videoPlayer:(YKLBPlayerCore *)playerCore didFailWithError:(NSError *)error
{
    [SVProgressHUD showErrorTip:@"数据加载失败" duration:0.6];
}

#pragma mark - rotation

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

#pragma mark - notification

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resignActive) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)becomeActive
{
    
}

- (void)resignActive
{
    if (_playBtn.isSelected) {
        
    }
}

#pragma mark - getter

- (YKLBPlayerCore *)playerCore
{
    if (!_playerCore) {
        _playerCore = [[YKLBPlayerCore alloc] init];
        _playerCore.delegate = self;
    }
    return _playerCore;
}

@end
