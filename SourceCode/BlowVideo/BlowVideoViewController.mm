//
//  BlowVideoViewController.m
//  BlowVideo
//
//  Created by Elvis on 14-3-5.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import "BlowVideoViewController.h"
#import "PuffMeter.h"
//#import "MeterTable.h"

@interface BlowVideoViewController ()
//@property (weak, nonatomic) IBOutlet PuffMeter *puffView;
@property (strong,nonatomic) PuffMeter *puffView;
@property (strong,nonatomic) PuffMeter *puffBreath;
@property (strong,nonatomic) NSArray *markFrameArray;
@property (nonatomic,strong) AVAudioSession *audioSession;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *levelTimer;
@property  double lowPassResults;
@property (weak, nonatomic) IBOutlet UILabel *levelNum;
@property (weak, nonatomic) IBOutlet UIButton *blowActive;

@property (strong, nonatomic) AVPlayer *moviePlayer;
@property (strong,nonatomic) AVPlayerLayer *movieLayer;
//@property const int chapCounter;
@property (nonatomic) BOOL jumpOrNot;
@property (nonatomic) BOOL blowLock;
@property (nonatomic) BOOL blowOn;
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) double maxPower;
@property (nonatomic) int timeMarkCount;
@property (nonatomic) Float64 currentSeconds;


@end

@implementation BlowVideoViewController
//MeterTable meterTable;
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
//    self.jumpOrNot = NO;
    self.blowOn = NO;
    self.blowLock = NO;
    self.isPlaying = YES;
//    self.blowActive.enabled=NO;
    self.timeMarkCount = 0;
    FcpXMLParser *timeMarks =[[FcpXMLParser alloc]init];
    self.markFrameArray = [[timeMarks loadXML:@"timeMark.fcpxml"] copy];
    [self initMoviePlayer];
    [self initBlowDetection];
    [self initPuffView];
    [self initNotifications];
}

-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
    //    [self.moviePlayer play];
    ////        [self.levelTimer fire];
    ////    self.puffView.count =1;
    //    self.blowOn =NO;
//    [self.moviePlayer play];
//    NSLog(@"blowLock when appear: %d",self.blowLock);
    [self loadPlayStatus];

}
//
-(void)viewDidDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    [self.moviePlayer pause];
//    NSLog(@"blowLock when disappear: %d",self.blowLock);
//    [self cleanBlowVideo];
    [self savePlayStatus];

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

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMoviePlayer {
    //    if (!self.moviePlayer) {
//    self.chapCounter =0;
    NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"movie" withExtension:@"m4v"];
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
    for (NSNumber *time in self.markFrameArray) {
        //        NSLog(@"%d",time.intValue);
        CMTime tmp = CMTimeMake(time.intValue, 25);
        [timeMarks addObject:[NSValue valueWithCMTime:tmp]];
    }
    //    NSLog(@"%@",timeMarks);
    
    self.moviePlayer = p;
    self.moviePlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(moviePlayBackDidFinish:) name:AVPlayerItemDidPlayToEndTimeNotification object:[self.moviePlayer currentItem]];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:p];
    self.movieLayer = layer;
    [layer  setFrame:CGRectMake(0,0, 320, 568)];
    [layer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
    [p addBoundaryTimeObserverForTimes:timeMarks queue:dispatch_get_main_queue() usingBlock:^{
        switch (self.timeMarkCount%3) {
            case 0:
//                NSLog(@"开始吹");
//                self.blowActive.enabled =YES;
                //                self.levelNum.hidden = NO;
                self.blowOn = NO;
                self.puffView.count = 1;
                self.puffBreath.hidden = NO;
                self.puffView.hidden = YES;
                [self anim_breath:nil finished:nil context:nil];
                [self.moviePlayer play];
                [self.recorder stop];
                //                self.levelNum.text = @"0";
                break;
            case 1:
//                NSLog(@"停");
                self.blowOn = YES;
                self.puffBreath.hidden = YES;
                self.puffView.hidden = NO;
                [self.moviePlayer pause] ;
                [self.view.layer removeAllAnimations];
                [self.recorder record];
                break;
            case 2:
//                NSLog(@"继续");
                [self.moviePlayer play];
//                self.blowActive.enabled =NO;
                self.maxPower = 0;
                self.blowOn = NO;
                //                self.levelNum.hidden = YES;
                self.puffView.hidden = YES;
                self.puffBreath.hidden = YES;
                [self.recorder stop];
                break;
            default:
                break;
        }
        self.timeMarkCount++;
//        NSLog(@"%d",self.timeMarkCount);
        
    }];
}

-(void)initPuffView {
    self.puffView = [[PuffMeter alloc]initWithFrame:CGRectMake(0, 0, 10, 24*4+10)];
    self.puffView.count = 1;
    self.puffView.staticMode = NO;
    self.puffView.center = CGPointMake(self.view.center.x, self.view.frame.size.height-30-self.puffView.frame.size.height/2);
    [self.view addSubview:self.puffView];
    self.puffView.hidden = YES;
    
    self.puffBreath = [[PuffMeter alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.puffBreath.count = 1;
    self.puffBreath.staticMode = YES;
    self.puffBreath.center = CGPointMake(self.view.center.x, self.view.frame.size.height-30-self.puffBreath.frame.size.height/2);
    [self.view addSubview:self.puffBreath];
    self.puffBreath.hidden = YES;
//    [self anim_breath:nil finished:nil context:nil];
}

-(void) anim_breath:(NSString *)animationID finished:(NSNumber *)finished context:(void* )context {
    self.puffBreath.alpha = 1.0f;
    self.puffBreath.transform = CGAffineTransformMakeScale(1, 1);
    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDelay:.5];
    [UIView setAnimationDuration:.5f];
    [UIView setAnimationRepeatAutoreverses:YES];
    //    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationRepeatCount:4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(anim_moveTop:finished:context:)];
    self.puffBreath.transform = CGAffineTransformMakeScale(.5, .5);
    //    self.puffView.transform = CGAffineTransformMakeTranslation(0, -100);
    self.puffBreath.alpha = 0.0f;
    [UIView commitAnimations];
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

//-(void)moviePlayBackDidFinish:(NSNotification *)notification {
//    if (self.jumpOrNot) {
//        NSLog(@"jump!");
//        [[NSNotificationCenter defaultCenter] removeObserver:self];
//        self.moviePlayer = nil;
//        //        if (theMovie == nil)
//        //        [self initMoviePlayer];
//        //        self.moviePlayer.initialPlaybackTime =10.0001;
//        //        self.moviePlayer.endPlaybackTime = 20;
//        //        [self.moviePlayer setInitialPlaybackTime:10];
//        //        [self.moviePlayer setEndPlaybackTime:20];
//        //        NSLog(@"startForm:%f to %f", self.moviePlayer.initialPlaybackTime,self.moviePlayer.endPlaybackTime);
//        self.jumpOrNot = NO;
//
//    } else {
//        return;
//    }
//    
//}

- (IBAction)blowUp:(UIButton *)sender {
//    self.jumpOrNot = !self.jumpOrNot;
//    if (self.jumpOrNot) {
//        [self.moviePlayer pause];
//    } else {
//        [self.moviePlayer play];
//    }
}

-(void)initBlowDetection {
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    NSError *error;
    NSError *setOverrideError;
    NSError *setCategoryError;
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt:kAudioFormatAppleLossless],AVFormatIDKey,
                              [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                              nil];
    self.recorder = [[AVAudioRecorder alloc]initWithURL:url settings:settings error:&error];
    self.audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &setCategoryError];
    
    if(setCategoryError){
        NSLog(@"%@", [setCategoryError description]);
    }
    [self.audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&setOverrideError];
    if(setOverrideError){
        NSLog(@"%@", [setOverrideError description]);
    }
    [self.audioSession setActive: YES error: nil];
    
    if (self.recorder) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
        [self.recorder record];
        self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(levelTimerCallBack:) userInfo:nil repeats:YES];
    } else {
//        NSLog(@"%@",[error description]);
    }
}

-(void)levelTimerCallBack:(NSTimer *)timer {
    if (self.blowLock) return;
    
    [self.recorder updateMeters];

    static BOOL breakPointHappen = NO;
    static double prevLowPassResults = 0;
    static int lableValue  =0;
    const double ALPHA = 0.05;
//    float meterPower = 0.0f;
//    meterPower = [self.recorder averagePowerForChannel:0];
//    float level = meterTable.ValueAt(meterPower);
//    NSLog(@"%f",level);
//    NSLog(@"%f",meterPower);
    double peakPowerForChannel = pow(10, 0.05*[self.recorder peakPowerForChannel:0]);
    self.lowPassResults = ALPHA * peakPowerForChannel + (1.0-ALPHA)*self.lowPassResults;
//    NSLog(@"%f",self.lowPassResults);


//    NSLog(@"Average input: %f Peak input: %f Low pass results: %f",[self.recorder averagePowerForChannel:0],[self.recorder peakPowerForChannel:0], self.lowPassResults);
    if (breakPointHappen) {
        if(self.lowPassResults<0.5) {
            breakPointHappen = NO;
        }
    }else if (self.lowPassResults >0.5 && prevLowPassResults > self.lowPassResults) {
//            NSLog(@"MAX Power is : %f",prevLowPassResults);
            self.maxPower = prevLowPassResults;
            breakPointHappen = YES;
        }
    
    if (self.blowOn) {
        if (self.lowPassResults >0.5 || self.maxPower >0.1) {
//         NSLog(@"%f",self.maxPower);
            [self.moviePlayer play];
        } else {
            [self.moviePlayer pause];
        }
//        self.levelNum.text = [NSString stringWithFormat:@"%d",lableValue];
    }

        prevLowPassResults= self.lowPassResults;
    if (self.maxPower>0) {
        self.maxPower -= 0.002;
    }

    
////    lableValue-=0.1;
//
    lableValue = (int)(self.lowPassResults *160);
    if (lableValue<=10) {
        lableValue =0;
    } else if(lableValue>=100) {
        lableValue =100;
    }
    self.puffView.count = 1+lableValue/25;
    [self.puffView setNeedsDisplay];

}

-(void)cleanBlowVideo{
//    self.blowOn =YES;
//    
//    [self.moviePlayer pause];
//    [self.levelTimer invalidate];
////    self.recorder.meteringEnabled = NO;
////    [[AVAudioSession sharedInstance] setActive:NO error:nil];
////    [self.recorder stop];
//    self.levelTimer = nil;
////    self.audioSession= nil;
//    self.recorder = nil;
//    self.lowPassResults = 0;
//    [self.moviePlayer replaceCurrentItemWithPlayerItem:nil];
//    [self.movieLayer removeFromSuperlayer ];
//    self.movieLayer.player =nil;
//    NSLog(@"remove video & blow detection!");
}

-(void) applicationDidBecomeActive:(NSNotification *)notification {
    //    [self initPuffView];
    //    [self anim_breath:nil finished:nil context:nil];
    UIViewController *currentViewController =((UIPageViewController *)[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers.firstObject).viewControllers.firstObject ;
    //    NSLog(@"this is current controller, %@", currentViewController);
    //    NSLog(@"this is page 1 controller ,%@",self);
    if (self==currentViewController) {
//    NSLog(@"this is page2 back");
//    NSLog(@"this is page2");
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
    self.blowLock = YES;
    if (self.moviePlayer.rate == 0) {
        self.isPlaying = NO;
    } else {
        self.isPlaying = YES;
        [self.moviePlayer pause];
    }
    [self.recorder stop];
    self.currentSeconds = CMTimeGetSeconds(self.moviePlayer.currentItem.currentTime);
//    NSLog(@"当前时序: %f",self.currentSeconds);
}

-(void) loadPlayStatus {
    [self.moviePlayer seekToTime:CMTimeMakeWithSeconds(self.currentSeconds, 1000000) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    self.blowLock = NO;
//    NSLog(@"currentTime :%lld", self.currentTime.value);
    if (self.isPlaying) {
        [self.moviePlayer play];
    }
    [self.recorder record];
    self.currentSeconds = CMTimeGetSeconds(self.moviePlayer.currentItem.currentTime);
//    NSLog(@"当前时序: %f",self.currentSeconds);
}

@end
