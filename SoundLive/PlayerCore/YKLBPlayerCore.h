//
//  YKLBPlayerCore.h
//  YoukuPlayer
//
//  Created by zyj on 15/12/24.
//  Copyright © 2015年 Youku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AVPlayer;
@class YKLBPlayerCore;

@protocol YKLBPlayerCoreDelegate <NSObject>

@optional
- (void)videoPlayerIsReadyToPlayVideo:(YKLBPlayerCore *)playerCore;
- (void)videoPlayerDidReachEnd:(YKLBPlayerCore *)playerCore;
- (void)videoPlayer:(YKLBPlayerCore *)playerCore timeDidChange:(CMTime)cmTime;
- (void)videoPlayer:(YKLBPlayerCore *)playerCore loadedTimeRangeDidChange:(float)duration;
- (void)videoPlayerPlaybackBufferEmpty:(YKLBPlayerCore *)playerCore;
- (void)videoPlayerPlaybackLikelyToKeepUp:(YKLBPlayerCore *)playerCore;
- (void)videoPlayer:(YKLBPlayerCore *)playerCore didFailWithError:(NSError *)error;

@end

@interface YKLBPlayerCore : NSObject

@property (nonatomic, weak) id<YKLBPlayerCoreDelegate> delegate;

@property (nonatomic, strong, readonly) AVPlayer *player;

@property (nonatomic, assign, getter=isPlaying, readonly) BOOL playing;
@property (nonatomic, assign, getter=isLooping) BOOL looping;
@property (nonatomic, assign, getter=isMuted) BOOL muted;

- (void)setURL:(NSURL *)URL;
- (void)setPlayerItem:(AVPlayerItem *)playerItem;
- (void)setAsset:(AVAsset *)asset;

// Playback

- (void)play;
- (void)pause;
- (void)seekToTime:(float)time
      startHandler:(void(^)(void))start
 completionHandler:(void(^)(void))completion
     failedHandler:(void(^)(void))failed;
- (void)reset;

// AirPlay

- (void)enableAirplay;
- (void)disableAirplay;
- (BOOL)isAirplayEnabled;

// Time Updates

- (void)enableTimeUpdates; // TODO: need these? no
- (void)disableTimeUpdates;

// Scrubbing

- (void)startScrubbing;
- (void)scrub:(float)time
 startHandler:(void(^)(void))start
completionHandler:(void(^)(void))completion
failedHandler:(void(^)(void))failed;
- (void)stopScrubbing;
- (void)cancelSeeking;

@end
