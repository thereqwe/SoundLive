//
//  YKSVideoLive.m
//  SoundLive
//
//  Created by macintosh on 16/8/9.
//  Copyright © 2016年 Yue Shen. All rights reserved.
//

#import "YKSVideoLive.h"
#import "YKSVideoView.h"

@interface YKSVideoLive ()

@property (weak, nonatomic) IBOutlet YKSVideoView *videoView;
@property (strong, nonatomic) IBOutlet UILabel *ListTitle;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) UIInterfaceOrientationMask orientation;

@end

@implementation YKSVideoLive

#pragma mark - life cycle

- (void)dealloc
{
    [self removeNotification];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    [self addNotification];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self removeNotification];
}

- (void)initProperty
{
    _orientation = UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

}

#pragma mark - screen rotation

- (void)removeOtherViewsButVideoView
{
    [_ListTitle removeFromSuperview];
    [_tableView removeFromSuperview];
}

- (void)addRemovedViews
{
    [self.view insertSubview:_ListTitle belowSubview:_videoView];
    [self.view insertSubview:_tableView belowSubview:_videoView];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return _orientation > 0 ? _orientation : UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (size.width > size.height) { // 转到全屏
            _videoView.frame = CGRectMake(0, 0, size.width, size.height);
        } else { // 转回小屏
            [self addRemovedViews];
            _videoView.frame = CGRectMake(0, 0, size.width, size.width / 16 * 9);
        }
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        if (size.width > size.height) { // 转到全屏
            [self removeOtherViewsButVideoView];
        }
    }];
}

//iOS2_0-8_0
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait) { // 转回小屏
        if (self.view.bounds.size.height < self.view.bounds.size.width) {
            [self addRemovedViews];
            _videoView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width / 16 * 9);
        }
    } else { // 转到全屏
        _videoView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [self removeOtherViewsButVideoView];
    }
}

@end
