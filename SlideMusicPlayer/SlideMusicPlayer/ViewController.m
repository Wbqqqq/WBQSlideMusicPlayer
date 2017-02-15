//
//  ViewController.m
//  SlideMusicPlayer
//
//  Created by wbq on 17/2/14.
//  Copyright © 2017年 汪炳权. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "YYWeakProxy.h"
#import "ProgressView.h"
#import "SlideGestureRecognizer.h"
@interface ViewController ()<UIGestureRecognizerDelegate>
@property (strong,nonatomic) AVPlayer *Player;
@property (strong,nonatomic) CADisplayLink *Link;//定时器
@property (strong, nonatomic) IBOutlet UIImageView *CDImageView;
@property (strong, nonatomic) IBOutlet UIButton *PlayBtn;
@property (strong, nonatomic) IBOutlet ProgressView *ProgressView;
@property (strong, nonatomic)SlideGestureRecognizer *SlideGesture;

@property(nonatomic)CGFloat NowProgress;
@property(nonatomic)CGFloat QuickOrLowProgerss;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];

    [self setUpUI];
    
    [self setUpPlayer];
    
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    //绘制圆角
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.CDImageView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:self.CDImageView.bounds.size];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    maskLayer.frame = self.CDImageView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.CDImageView.layer.mask = maskLayer;
    
}


-(void)setUpUI
{
    self.SlideGesture = [[SlideGestureRecognizer alloc]initWithTarget:self action:@selector(signalHandler:)];
    self.SlideGesture.delegate = self;
    self.CDImageView.userInteractionEnabled = YES;
    [self.CDImageView addGestureRecognizer:self.SlideGesture];

}




-(void)setUpPlayer
{
    
    [self.Player play];
    //开启定时器
    [self Link];

}

-(void)signalHandler:(SlideGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        
        NSLog(@"按下,停止定时器");
        //按下,停止定时器
        [self deallocTimer];
        
    }
    
    //根据手势不断旋转
    sender.view.transform = CGAffineTransformRotate(sender.view.transform, sender.rotation);
    
    //这里的20是比例，如果太小的话，会一下子滚的很快
    self.QuickOrLowProgerss = self.QuickOrLowProgerss + sender.rotation/(20 * M_PI);
    
    sender.rotation = 0;
    
    self.NowProgress  = self.NowProgress + self.QuickOrLowProgerss;
    
    [self.ProgressView drawProgress:self.NowProgress];
    

    if (sender.state == UIGestureRecognizerStateEnded) {
        
        
        NSLog(@"抬起,开启定时器");
        //抬起,开启定时器
        
        CGFloat showUp = self.NowProgress * CMTimeGetSeconds(self.Player.currentItem.duration);
        
        CMTime dragedCMTime = CMTimeMake(showUp, 1);
        

        if(self.Player.status == AVPlayerStatusReadyToPlay)
        {
            __weak ViewController *weakSelf = self;
            [self.Player seekToTime:dragedCMTime completionHandler:^(BOOL finished) {
                
                [weakSelf Link];
                
            }];
        }
        
        //手指抬起之后
        self.QuickOrLowProgerss = 0;

    }

}



/**
 *  播放完了
 *
 *  @param notification 通知
 */
- (void)musicPlayDidEnd:(NSNotification *)notification
{
    NSLog(@"播放结束");
    
    self.PlayBtn.selected = YES;
    
    //重置播放器
    [self removePlayer];

}


/**
 *  销毁播放器
 */
-(void)removePlayer
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.Player];
    
    self.Player = nil;
    
    [self deallocTimer];
    
}


/**
 *  销毁定时器
 */
-(void)deallocTimer
{
    
    [self.Link removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [self.Link invalidate];
    
    self.Link = nil;

}



-(void)updateUIandInfo
{
    if(!self.PlayBtn.selected)
    {
        
        self.CDImageView.transform = CGAffineTransformRotate(self.CDImageView.transform, M_PI_4 / 60);
    
        self.NowProgress = CMTimeGetSeconds(self.Player.currentItem.currentTime)/CMTimeGetSeconds(self.Player.currentItem.duration);
        
        NSLog(@"%.2f",self.NowProgress);
        
        [self.ProgressView drawProgress:self.NowProgress];
        
        [self setupLockInfoWithMP3Info];
    }
}


- (IBAction)playOrPause:(id)sender {
    
    UIButton * button = (UIButton *)sender;
    button.selected = !button.selected;
    
    if(button.selected)
    {
        [self.Player pause];
    }else
    {
        [self Link];
        [self.Player play];
    }
    
}


-(void)setupLockInfoWithMP3Info
{
    NSMutableDictionary *playingInfo = [NSMutableDictionary dictionary];
    
    //1.专辑名称
    playingInfo[MPMediaItemPropertyAlbumTitle] = @"七里香";
    
    //2.歌曲名称
    playingInfo[MPMediaItemPropertyTitle] = @"借口";
    
    //3.歌手名称
    playingInfo[MPMediaItemPropertyArtist] = @"周杰伦";
    
    //4.专辑图片
    playingInfo[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc]initWithImage:[UIImage imageNamed:@"七里香"]];
    
    //5.锁屏音乐总时间
    playingInfo[MPMediaItemPropertyPlaybackDuration] = [NSNumber numberWithInt:CMTimeGetSeconds(self.Player.currentItem.duration)];
    
    //6.锁频音乐进度
    playingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = [NSNumber numberWithInt:CMTimeGetSeconds(self.Player.currentItem.currentTime)];
    
    //设置锁屏时的播放信息
    [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = playingInfo;


}


-(CADisplayLink *)Link{
    if (!_Link) {
        
        //这里的target没有指向自己是因为如果直接指向自己，addToRunLoop之后会造成CADisplayLink的内存泄漏
        _Link = [CADisplayLink displayLinkWithTarget:[YYWeakProxy proxyWithTarget:self] selector:@selector(updateUIandInfo)];
        
        [_Link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        
        _Link.frameInterval = 2;
    }
    
    return _Link;
}


-(AVPlayer * )Player
{
    if(!_Player)
    {
        NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"周杰伦 - 借口" ofType:@"mp3"];
        
        _Player = [[AVPlayer alloc]initWithURL:[NSURL fileURLWithPath:audioPath]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(musicPlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_Player.currentItem];
        
    }
    return _Player;
}


@end
