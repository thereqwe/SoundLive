//
//  YKLBPlayerCore.h
//  YoukuPlayer
//
//  Created by zyj on 15/12/24.
//  Copyright © 2015年 Youku. All rights reserved.
//

#import "YKLBPlayerCore.h"
#import <UIkit/UIKit.h>

#define IOSVERSION [[UIDevice currentDevice].systemVersion doubleValue]

static const float DefaultPlayableBufferLength = 2.0f;
static const float DefaultVolumeFadeDuration = 1.0f;
static const float TimeObserverInterval = 1.f;

NSString * const kPlayerErrorDomain = @"kPlayerErrorDomain";

static void *kYKLBPlayerCorerItemStatusContext = &kYKLBPlayerCorerItemStatusContext;
static void *kYKLBPlayerCorerExternalPlaybackActiveContext = &kYKLBPlayerCorerExternalPlaybackActiveContext;
static void *kYKLBPlayerCorerRateChangedContext = &kYKLBPlayerCorerRateChangedContext;
static void *kYKLBPlayerCorerItemPlaybackLikelyToKeepUp = &kYKLBPlayerCorerItemPlaybackLikelyToKeepUp;
static void *kYKLBPlayerCorerItemPlaybackBufferEmpty = &kYKLBPlayerCorerItemPlaybackBufferEmpty;
static void *kYKLBPlayerCorerItemLoadedTimeRangesContext = &kYKLBPlayerCorerItemLoadedTimeRangesContext;

@interface YKLBPlayerCore ()

@property (nonatomic, strong, readwrite) AVPlayer *player;

@property (nonatomic, assign, getter=isPlaying, readwrite) BOOL playing;
@property (nonatomic, assign, getter=isScrubbing) BOOL scrubbing;
@property (nonatomic, assign, getter=isSeeking) BOOL seeking;
@property (nonatomic, assign) BOOL isAtEndTime;
@property (nonatomic, assign) BOOL shouldPlayAfterScrubbing;

@property (nonatomic, assign) float volumeFadeDuration;
@property (nonatomic, assign) float playableBufferLength;

@property (nonatomic, assign) BOOL isTimingUpdateEnabled;
@property (nonatomic, strong) id timeObserverToken;

@property (nonatomic, strong) AVPlayerItem *item;

@end

@implementation YKLBPlayerCore

- (void)dealloc
{
    [self resetPlayerItemIfNecessary];
    
    [self removePlayerObservers];
    
    [self removeTimeObserver];
    
    NSLog(@"%@______dealloc!", [self class]);
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _volumeFadeDuration = DefaultVolumeFadeDuration;
        _playableBufferLength = DefaultPlayableBufferLength;
        
        [self setupPlayer];
        
        [self addPlayerObservers];

        [self setupAudioSession];
    }
    
    return self;
}

#pragma mark - Setup

- (void)setupPlayer
{
    self.player = [[AVPlayer alloc] init];
    if (IOSVERSION >= 7.0) {
        self.player.muted = NO;
        self.player.volume = 1.0f;
    }
    
    self.player.allowsExternalPlayback = YES;
}

- (void)setupAudioSession
{
    NSError *categoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&categoryError];
    if (!success)
    {
        NSLog(@"Error setting audio session category: %@", categoryError);
    }
    
    NSError *activeError = nil;
    success = [[AVAudioSession sharedInstance] setActive:YES error:&activeError];
    if (!success)
    {
        NSLog(@"Error setting audio session active: %@", activeError);
    }
}

#pragma mark - Public API

- (void)setURL:(NSURL *)URL
{
    if (URL == nil)
    {
        return;
    }

    [self resetPlayerItemIfNecessary];

    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:URL];
    if (!playerItem)
    {
        [self reportUnableToCreatePlayerItem];
        
        return;
    }

    [self preparePlayerItem:playerItem];
}

- (void)setPlayerItem:(AVPlayerItem *)playerItem
{
    if (playerItem == nil)
    {
        return;
    }
    
    [self resetPlayerItemIfNecessary];

    [self preparePlayerItem:playerItem];
}

- (void)setAsset:(AVAsset *)asset
{
    if (asset == nil)
    {
        return;
    }

    [self resetPlayerItemIfNecessary];
    
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithAsset:asset automaticallyLoadedAssetKeys:@[NSStringFromSelector(@selector(tracks))]];
    if (!playerItem)
    {
        [self reportUnableToCreatePlayerItem];
        
        return;
    }
    
    [self preparePlayerItem:playerItem];
}

#pragma mark - Accessor Overrides

- (void)setMuted:(BOOL)muted
{
    if (self.player && IOSVERSION >= 7.0)
    {
        self.player.muted = muted;
    }
}

- (BOOL)isMuted
{
    return self.player.isMuted;
}

#pragma mark - Playback

- (void)play
{
    if (self.player.currentItem == nil)
    {
        return;
    }
    
    self.playing = YES;
   
    if ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)
    {
        if ([self isAtEndTime])
        {
            [self restart];
        }
        else
        {
            [self.player play];
        }
    }
}

- (void)pause
{
    self.playing = NO;
    
    [self.player pause];
}

- (void)seekToTime:(float)time
      startHandler:(void(^)(void))start
 completionHandler:(void(^)(void))completion
       failedHandler:(void(^)(void))failed
{
    if (_seeking)
    {
        return;
    }
    
    if (self.player)
    {
        CMTime cmTime = CMTimeMakeWithSeconds(time, self.player.currentTime.timescale);
        
        if (CMTIME_IS_INVALID(cmTime) || self.player.currentItem.status == AVPlayerStatusFailed)
        {
            if (failed != nil) {
                failed();
            }
            return;
        }
        
        _seeking = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (start != nil) {
                start();
            }
            
            [self.player seekToTime:cmTime completionHandler:^(BOOL finished) {
                
                if (completion != nil) {
                    completion();
                }
                
                _isAtEndTime = NO;
                _seeking = NO;

                if (finished)
                {
                    _scrubbing = NO;
                }
                
            }];
        });
    }
}

- (void)reset
{
    [self pause];
    [self resetPlayerItemIfNecessary];
}

#pragma mark - Airplay

- (void)enableAirplay
{
    if (self.player)
    {
        self.player.allowsExternalPlayback = YES;
    }
}

- (void)disableAirplay
{
    if (self.player)
    {
        self.player.allowsExternalPlayback = NO;
    }
}

- (BOOL)isAirplayEnabled
{
    return (self.player && self.player.allowsExternalPlayback);
}

#pragma mark - Scrubbing

- (void)startScrubbing
{
    self.scrubbing = YES;
    
    if (self.isPlaying)
    {
        self.shouldPlayAfterScrubbing = YES;

        [self pause];
    }
}

- (void)scrub:(float)time
 startHandler:(void(^)(void))start
completionHandler:(void(^)(void))completion
failedHandler:(void(^)(void))failed
{
    if (self.isScrubbing == NO)
    {
        [self startScrubbing];
    }
    
    [self.player.currentItem cancelPendingSeeks];
    
    [self seekToTime:time startHandler:start completionHandler:completion failedHandler:failed];
}

- (void)stopScrubbing
{
    if (self.shouldPlayAfterScrubbing)
    {
        [self play];

        self.shouldPlayAfterScrubbing = NO;
    }

    self.scrubbing = NO;
}

- (void)cancelSeeking
{
    [self.player.currentItem cancelPendingSeeks];
}

#pragma mark - Time Updates

- (void)enableTimeUpdates
{
    self.isTimingUpdateEnabled = YES;
    
    [self addTimeObserver];
}

- (void)disableTimeUpdates
{
    self.isTimingUpdateEnabled = NO;
    
    [self removeTimeObserver];
}

#pragma mark - Private API

- (void)reportUnableToCreatePlayerItem
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didFailWithError:)])
    {
        NSError *error = [NSError errorWithDomain:kPlayerErrorDomain
                                             code:0
                                         userInfo:@{NSLocalizedDescriptionKey : @"Unable to create AVPlayerItem."}];
        
        [self.delegate videoPlayer:self didFailWithError:error];
    }
}

- (void)resetPlayerItemIfNecessary
{
    if (self.item)
    {
        [self removePlayerItemObservers:self.item];
        
        [self.player replaceCurrentItemWithPlayerItem:nil];
        self.item = nil;
    }
    
    _volumeFadeDuration = DefaultVolumeFadeDuration;
    _playableBufferLength = DefaultPlayableBufferLength;
    
    _playing = NO;
    _isAtEndTime = NO;
    _scrubbing = NO;
}

- (void)preparePlayerItem:(AVPlayerItem *)playerItem
{
    NSParameterAssert(playerItem);
    
    self.item = playerItem;
    
    [self addPlayerItemObservers:playerItem];
    
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
}

- (void)restart
{
    [self.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        
        _isAtEndTime = NO;
        
        if (self.isPlaying)
        {
            [self play];
        }

    }];
}

- (BOOL)isAtEndTime // TODO: this is a fucked up override, seems like something could be wrong [AH]
{
    if (self.player && self.player.currentItem)
    {
        if (_isAtEndTime)
        {
            return _isAtEndTime;
        }
        
        float currentTime = 0.0f;
        if (CMTIME_IS_INVALID(self.player.currentTime) == NO)
        {
            currentTime = CMTimeGetSeconds(self.player.currentTime);
        }
        
        float videoDuration = 0.0f;
        if (CMTIME_IS_INVALID(self.player.currentItem.duration) == NO)
        {
            videoDuration = CMTimeGetSeconds(self.player.currentItem.duration);
        }
        
        if (currentTime > 0.0f && videoDuration > 0.0f)
        {
            if (fabs(currentTime - videoDuration) <= 0.01f)
            {
                return YES;
            }
        }
    }
    
    return NO;
}

- (float)calcLoadedDuration
{
    float loadedDuration = 0.0f;
    
    if (self.player && self.player.currentItem)
    {
        NSArray *loadedTimeRanges = self.player.currentItem.loadedTimeRanges;
        
        if (loadedTimeRanges && [loadedTimeRanges count])
        {
//            NSLog(@"%@", loadedTimeRanges);
            CMTimeRange timeRange = [[loadedTimeRanges firstObject] CMTimeRangeValue];
            float startSeconds = CMTimeGetSeconds(timeRange.start);
            float durationSeconds = CMTimeGetSeconds(timeRange.duration);
            
            loadedDuration = startSeconds + durationSeconds;
        }
    }
    
    return loadedDuration;
}

#pragma mark - Player Observers

- (void)addPlayerObservers
{
    //NSStringFromSelector(@selector(isExternalPlaybackActive))
    [self.player addObserver:self
                  forKeyPath:@"externalPlaybackActive"
                     options:NSKeyValueObservingOptionNew
                     context:kYKLBPlayerCorerExternalPlaybackActiveContext];
    
    //NSStringFromSelector(@selector(rate))
    [self.player addObserver:self
                  forKeyPath:@"rate"
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:kYKLBPlayerCorerRateChangedContext];
}

- (void)removePlayerObservers
{
    @try
    {
        //NSStringFromSelector(@selector(isExternalPlaybackActive))
        [self.player removeObserver:self
                         forKeyPath:@"externalPlaybackActive"
                            context:kYKLBPlayerCorerExternalPlaybackActiveContext];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception removing observer: %@", exception);
    }
    
    @try
    {
        //NSStringFromSelector(@selector(rate))
        [self.player removeObserver:self
                         forKeyPath:@"rate"
                            context:kYKLBPlayerCorerRateChangedContext];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception removing observer: %@", exception);
    }
    
    @try
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:@"AVSystemController_SystemVolumeDidChangeNotification"
                                                      object:nil];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception removing observer: %@", exception);
    }
}

#pragma mark - PlayerItem Observers

- (void)addPlayerItemObservers:(AVPlayerItem *)playerItem
{
    //NSStringFromSelector(@selector(status))
    [playerItem addObserver:self
                 forKeyPath:@"status"
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:kYKLBPlayerCorerItemStatusContext];
    //NSStringFromSelector(@selector(isPlaybackLikelyToKeepUp))
    [playerItem addObserver:self
                 forKeyPath:@"playbackLikelyToKeepUp"
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:kYKLBPlayerCorerItemPlaybackLikelyToKeepUp];
    
    //NSStringFromSelector(@selector(isPlaybackBufferEmpty))
    [playerItem addObserver:self
                 forKeyPath:@"playbackBufferEmpty"
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:kYKLBPlayerCorerItemPlaybackBufferEmpty];
    
    //NSStringFromSelector(@selector(loadedTimeRanges))
    [playerItem addObserver:self
                 forKeyPath:@"loadedTimeRanges"
                    options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                    context:kYKLBPlayerCorerItemLoadedTimeRangesContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidPlayToEndTime:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:playerItem];
}

- (void)removePlayerItemObservers:(AVPlayerItem *)playerItem
{
    [playerItem cancelPendingSeeks];
    
    @try
    {
        //NSStringFromSelector(@selector(status))
        [playerItem removeObserver:self
                        forKeyPath:@"status"
                           context:kYKLBPlayerCorerItemStatusContext];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception removing observer: %@", exception);
    }

    @try
    {
        //NSStringFromSelector(@selector(isPlaybackLikelyToKeepUp))
        [playerItem removeObserver:self
                        forKeyPath:@"playbackLikelyToKeepUp"
                           context:kYKLBPlayerCorerItemPlaybackLikelyToKeepUp];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception removing observer: %@", exception);
    }

    @try
    {
        //NSStringFromSelector(@selector(isPlaybackBufferEmpty))
        [playerItem removeObserver:self
                        forKeyPath:@"playbackBufferEmpty"
                           context:kYKLBPlayerCorerItemPlaybackBufferEmpty];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception removing observer: %@", exception);
    }

    @try
    {
        //NSStringFromSelector(@selector(loadedTimeRanges))
        [playerItem removeObserver:self
                        forKeyPath:@"loadedTimeRanges"
                           context:kYKLBPlayerCorerItemLoadedTimeRangesContext];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception removing observer: %@", exception);
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
}

#pragma mark - Time Observer

- (void)addTimeObserver
{
    if (self.timeObserverToken || self.player == nil)
    {
        return;
    }
    
    __weak typeof (self) weakSelf = self;
    self.timeObserverToken = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(TimeObserverInterval, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        __strong typeof (self) strongSelf = weakSelf;
        if (!strongSelf)
        {
            return;
        }
        
        if ([strongSelf.delegate respondsToSelector:@selector(videoPlayer:timeDidChange:)])
        {
            [strongSelf.delegate videoPlayer:strongSelf timeDidChange:time];
        }
        
    }];
}

- (void)removeTimeObserver
{
    if (self.timeObserverToken == nil)
    {
        return;
    }
 
    if (self.player)
    {
        [self.player removeTimeObserver:self.timeObserverToken];
    }
    
    self.timeObserverToken = nil;
}

#pragma mark - Observer Response

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if (context == kYKLBPlayerCorerRateChangedContext)
    {
        if (self.isScrubbing == NO && self.isPlaying && self.player.rate == 0.0f)
        {
            // TODO: Show loading indicator
        }
    }
    else if (context == kYKLBPlayerCorerItemStatusContext)
    {
        AVPlayerStatus newStatus = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        AVPlayerStatus oldStatus = [[change objectForKey:NSKeyValueChangeOldKey] integerValue];
        
        if (newStatus != oldStatus)
        {
            switch (newStatus)
            {
                case AVPlayerItemStatusUnknown:
                {
                    NSLog(@"Video player Status Unknown");
                    break;
                }
                case AVPlayerItemStatusReadyToPlay:
                {
                    if ([self.delegate respondsToSelector:@selector(videoPlayerIsReadyToPlayVideo:)])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate videoPlayerIsReadyToPlayVideo:self];
                        });
                    }
                    
                    if (self.isPlaying)
                    {
                        [self play];
                    }
                    
                    break;
                }
                case AVPlayerItemStatusFailed:
                {
                    NSLog(@"Video player Status Failed: player item error = %@", self.player.currentItem.error);
                    NSLog(@"Video player Status Failed: player error = %@", self.player.error);
                    
                    NSError *error = self.player.error;
                    if (!error)
                    {
                        error = self.player.currentItem.error;
                    }
                    else
                    {
                        error = [NSError errorWithDomain:kPlayerErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"unknown player error, status == AVPlayerItemStatusFailed"}];
                    }
                    
                    [self reset];

                    if ([self.delegate respondsToSelector:@selector(videoPlayer:didFailWithError:)])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate videoPlayer:self didFailWithError:error];
                        });
                    }
                    
                    break;
                }
            }
        }
    }
    else if (context == kYKLBPlayerCorerItemPlaybackBufferEmpty)
    {
        if (playerItem.playbackBufferEmpty)
        {
            if (self.isPlaying)
            {
                dispatch_async(dispatch_get_main_queue(), ^
                {
                    if ([self.delegate respondsToSelector:@selector(videoPlayerPlaybackBufferEmpty:)])
                    {
                        [self.delegate videoPlayerPlaybackBufferEmpty:self];
                    }
                });
            }
        }
    }
    else if (context == kYKLBPlayerCorerItemPlaybackLikelyToKeepUp)
    {
        if (playerItem.playbackLikelyToKeepUp)
        {
            [self.delegate videoPlayerPlaybackLikelyToKeepUp:self];

            if (self.isScrubbing == NO && self.isPlaying && self.player.rate == 0.0f)
            {
                [self play];
            }
        }
    }
    else if (context == kYKLBPlayerCorerItemLoadedTimeRangesContext)
    {
        float loadedDuration = [self calcLoadedDuration];

//        NSLog(@"loadDuration:%f", loadedDuration);
        if (self.isScrubbing == NO && self.isPlaying && self.player.rate == 0.0f)
        {
            if (loadedDuration >= CMTimeGetSeconds(self.player.currentTime) + self.playableBufferLength)
            {
                self.playableBufferLength *= 2;

                if (self.playableBufferLength > 64)
                {
                    self.playableBufferLength = 64;
                }
                
                [self play];
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(videoPlayer:loadedTimeRangeDidChange:)])
        {
            [self.delegate videoPlayer:self loadedTimeRangeDidChange:loadedDuration];
        }
    }
    else if (context == kYKLBPlayerCorerExternalPlaybackActiveContext)
    {
        
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)playerItemDidPlayToEndTime:(NSNotification *)notification
{
    if (notification.object != self.player.currentItem)
    {
        return;
    }
    
    if (self.isLooping)
    {
        [self restart];
    }
    else
    {
        _isAtEndTime = YES;
        self.playing = NO;
    }
        
    if ([self.delegate respondsToSelector:@selector(videoPlayerDidReachEnd:)])
    {
        [self.delegate videoPlayerDidReachEnd:self];
    }
}

@end
