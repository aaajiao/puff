//
//  IntroViewController.m
//  BlowVideo
//
//  Created by Elvis on 14-3-5.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import "IntroViewController.h"
#import "PuffMeter.h"

@interface IntroViewController ()
@property (strong, nonatomic) AVPlayer *moviePlayer;
@property (strong,nonatomic) AVPlayerLayer *movieLayer;
//@property (weak, nonatomic) IBOutlet PuffMeter *puffView;
@property (strong,nonatomic) PuffMeter *puffView;
@property (nonatomic) Float64 currentSeconds;
@property (weak, nonatomic) IBOutlet UIButton *linkButton;
@property (weak, nonatomic) IBOutlet UIView *eggView;

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
    [self initPuffView];
    [self initNotifications];
    UIImage *btnImage = [UIImage imageNamed:@"logo"];
    [self.linkButton setBackgroundImage:btnImage forState:UIControlStateNormal];
}



-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.moviePlayer play];
//    [self anim_breath:nil finished:nil context:nil];
    [self loadPlayStatus];
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    [self.moviePlayer pause];
    [self savePlayStatus];
    self.eggView.hidden = YES;
//    [self.view.layer removeAllAnimations];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(applicationEnterBackground:)
//                                                 name:UIApplicationDidEnterBackgroundNotification
//                                               object:[UIApplication sharedApplication]];
}
-(void)initNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:[UIApplication sharedApplication]];
}

-(void)initPuffView {
    self.puffView = [[PuffMeter alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
//    self.puffView = [[PuffMeter alloc]initWithFrame:CGRectMake(0, 0, 10, 24*4+10)];
    self.puffView.count = 5;
    self.puffView.staticMode = YES;
    self.puffView.center = CGPointMake(self.view.center.x, self.view.frame.size.height-30-self.puffView.frame.size.height/2);
//    [self.view addSubview:self.puffView];
    [self.view insertSubview:self.puffView belowSubview:self.eggView];
    [self anim_breath:nil finished:nil context:nil];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMoviePlayer {

//    [self.puffView setNeedsDisplay];
    //    if (!self.moviePlayer) {
    NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"intro" withExtension:@"m4v"];
//    NSLog(@"%@",movieURL);
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
    [timeMarks addObject:[NSValue valueWithCMTime:CMTimeMake(5, 10)]];
    //    NSLog(@"%@",timeMarks);
    self.moviePlayer = p;
    self.moviePlayer.volume=.6;
    self.moviePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayBackDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.moviePlayer currentItem]];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:p];
    self.movieLayer = layer;
    [layer  setFrame:CGRectMake(0,0, 320, 568)];
    [layer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
    [p addBoundaryTimeObserverForTimes:timeMarks queue:dispatch_get_main_queue() usingBlock:^{
        [self initPuffView];
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
//        NSLog(@"playing");
    }
}

-(void)moviePlayBackDidFinish:(NSNotification *)notification {
    AVPlayerItem *p = [notification object];
    [p seekToTime:kCMTimeZero];
    [self.view.layer removeAllAnimations];
    
}

-(void)cleanVideo{
    [self.moviePlayer pause];
//    [self.moviePlayer replaceCurrentItemWithPlayerItem:nil];
//    [self.movieLayer removeFromSuperlayer ];
//    self.movieLayer.player =nil;
//    NSLog(@"remove Video!");
}

-(void) anim_breath:(NSString *)animationID finished:(NSNumber *)finished context:(void* )context {
    self.puffView.alpha = 1.0f;
    self.puffView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDelay:.5];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationRepeatAutoreverses:YES];
    //    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationRepeatCount:2];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(anim_moveTop:finished:context:)];
    self.puffView.transform = CGAffineTransformMakeScale(.5, .5);
    //    self.puffView.transform = CGAffineTransformMakeTranslation(0, -100);
    self.puffView.alpha = 0.0f;
    [UIView commitAnimations];
}

-(void) anim_moveTop:(NSString *)animationID finished:(NSNumber *)finished context:(void* )context {
    self.puffView.alpha = 1.0f;
    self.puffView.transform = CGAffineTransformMakeScale(1, 1);
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelay:0];
    [UIView setAnimationDuration:.6f];
    //    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //    [UIView setAnimationBeginsFromCurrentState:YES];
    //    [UIView setAnimationDelegate:self];
    //    [UIView setAnimationDidStopSelector:@selector(anim_breath:finished:context:)];
    //    self.puffView.transform = CGAffineTransformMakeScale(.5, .5);
    self.puffView.transform = CGAffineTransformMakeTranslation(0, -100);
    self.puffView.alpha = 0.0f;
    [UIView commitAnimations];
}

-(void) applicationDidBecomeActive:(NSNotification *)notification {
    //    [self initPuffView];
    //    [self anim_breath:nil finished:nil context:nil];
    //    NSLog(@"this is page2 back");
    UIViewController *currentViewController =((UIPageViewController *)[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers.firstObject).viewControllers.firstObject ;
    //    NSLog(@"this is current controller, %@", currentViewController);
    //    NSLog(@"this is page 1 controller ,%@",self);
    if (self==currentViewController) {
        //    NSLog(@"this is page2 back");
//        NSLog(@"this is page1");
//    NSLog(@"BecomeActive!!!!!!!!!!");
    [self loadPlayStatus];
    }
    //    self.movieLayer.player = self.moviePlayer;
}

-(void) applicationEnterBackground:(NSNotification *)notification {
//    NSLog(@"enter background!!!!!!!!!!");
    [self savePlayStatus];
    //    NSLog(@"playStates: %d",self.isPlaying);
    
}

-(void) savePlayStatus {
    //    [self.view.layer removeAllAnimations];
    [self.moviePlayer pause];
    self.currentSeconds = CMTimeGetSeconds(self.moviePlayer.currentItem.currentTime);
}

-(void) loadPlayStatus {
    [self.moviePlayer seekToTime:CMTimeMakeWithSeconds(self.currentSeconds, 1000000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    self.currentSeconds = CMTimeGetSeconds(self.moviePlayer.currentItem.currentTime);
    [self.moviePlayer play];
}

- (IBAction)closeEggView:(id)sender {
    self.eggView.hidden = YES;
}

- (IBAction)showEggView:(id)sender {
    self.eggView.hidden = NO;
}

- (IBAction)openUrl:(id)sender {
    NSString *myurl= @"http://www.pegpegpegpeg.com/";
    NSURL *url = [NSURL URLWithString:myurl];
    [[UIApplication sharedApplication] openURL:url];
};

@end
