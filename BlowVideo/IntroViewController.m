//
//  IntroViewController.m
//  BlowVideo
//
//  Created by Elvis on 14-3-5.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()
@property (strong, nonatomic) AVPlayer *moviePlayer;
@property (strong,nonatomic) AVPlayerLayer *movieLayer;

@end

@implementation IntroViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self initMoviePlayer];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self cleanVideo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMoviePlayer {
    //    if (!self.moviePlayer) {
    NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"intro" withExtension:@"m4v"];
    NSLog(@"%@",movieURL);
    AVURLAsset* asset = [AVURLAsset URLAssetWithURL:movieURL options:nil];
    AVPlayerItem* item = [AVPlayerItem playerItemWithAsset:asset];
    AVPlayer* p = [AVPlayer playerWithPlayerItem:item];
    [p play];
    //    CMTime time1 = CMTimeMakeWithSeconds(5.00, 25);
    //    CMTime time2 = CMTimeMakeWithSeconds(10.00, 25);
    //    CMTime time3 = CMTimeMakeWithSeconds(15.00, 25);
    //    CMTime time4 = CMTimeMakeWithSeconds(20.00, 25);
    //    CMTime time5 = CMTimeMakeWithSeconds(25.00, 25);
    //    CMTime time6 = CMTimeMakeWithSeconds(30.00, 25);
    //    NSArray *markFrameArray = @[@37,@186,@297,@397,@470,@614,@707,@784,@855,@907,@995,@1112,@1185,
    //                                @1359,@1558,@1746,@1818,@1890,@2101,@2204,@2315,@2397
    //                                ];
    //    NSLog(@"%@",self.markFrameArray);
    NSMutableArray *timeMarks = [[NSMutableArray alloc]init];
    [timeMarks addObject:[NSValue valueWithCMTime:CMTimeMake(5, 25)]];
    //    NSLog(@"%@",timeMarks);
    self.moviePlayer = p;
    self.moviePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayBackDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.moviePlayer currentItem]];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:p];
    self.movieLayer = layer;
    [layer  setFrame:CGRectMake(0,0, 320, 568)];
    [layer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
    [p addBoundaryTimeObserverForTimes:timeMarks queue:dispatch_get_main_queue() usingBlock:^{
        NSLog(@"Hello，you should show the attention now！");
    }];
    //    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"readyForDisplay"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self finishConstructingInterface];
        });
    }
}

-(void)finishConstructingInterface {
    if (!self.movieLayer.readyForDisplay) {
        return; }
    else {
        [self.movieLayer removeObserver:self forKeyPath:@"readyForDisplay"];
        //        [self.view.layer addSublayer:self.movieLayer];
        [self.view.layer insertSublayer:self.movieLayer atIndex:0];
        [self.moviePlayer play];
        NSLog(@"playing");
    }
}

-(void)moviePlayBackDidFinish:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
}

-(void)cleanVideo{
    [self.moviePlayer replaceCurrentItemWithPlayerItem:nil];
    [self.movieLayer removeFromSuperlayer ];
    self.movieLayer.player =nil;
    NSLog(@"remove Video!");
}


@end
