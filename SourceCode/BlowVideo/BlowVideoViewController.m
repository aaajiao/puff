//
//  BlowVideoViewController.m
//  BlowVideo
//
//  Created by Elvis on 14-3-5.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import "BlowVideoViewController.h"

@interface BlowVideoViewController ()
@property (strong,nonatomic) NSArray *markFrameArray;
@property (nonatomic,strong) AVAudioSession *audioSession;
@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSTimer *levelTimer;
@property  double lowPassResults;
@property (weak, nonatomic) IBOutlet UILabel *levelNum;
@property (weak, nonatomic) IBOutlet UIButton *blowActive;
@property (strong, nonatomic) AVPlayer *moviePlayer;
@property (strong,nonatomic) AVPlayerLayer *movieLayer;
@property const int chapCounter;
@property (nonatomic) BOOL jumpOrNot;
@property (nonatomic) BOOL blowOn;
@property (nonatomic) double maxPower;
@property (nonatomic) int timeMarkCount;
@end

@implementation BlowVideoViewController

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
    self.jumpOrNot = NO;
    self.blowOn = NO;
    self.blowActive.enabled=NO;
    self.timeMarkCount = 0;
    FcpXMLParser *timeMarks =[[FcpXMLParser alloc]init];
    self.markFrameArray = [[timeMarks loadXML:@"timeMark.fcpxml"] copy];
    [self initMoviePlayer];
    [self initBlowDetection];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self cleanBlowVideo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initMoviePlayer {
    //    if (!self.moviePlayer) {
    self.chapCounter =0;
    NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"movie" withExtension:@"m4v"];
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
    for (NSNumber *time in self.markFrameArray) {
//        NSLog(@"%d",time.intValue);
        CMTime tmp = CMTimeMake(time.intValue, 25);
        [timeMarks addObject:[NSValue valueWithCMTime:tmp]];
    }
//    NSLog(@"%@",timeMarks);
    
    self.moviePlayer = p;
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:p];
    self.movieLayer = layer;
    [layer  setFrame:CGRectMake(0,0, 320, 568)];
    [layer addObserver:self forKeyPath:@"readyForDisplay" options:0 context:nil];
    [p addBoundaryTimeObserverForTimes:timeMarks queue:dispatch_get_main_queue() usingBlock:^{
//        if (self.jumpOrNot == NO) {
//            
//            if (self.chapCounter ==0) {
//                [self.moviePlayer seekToTime:CMTimeMakeWithSeconds(0, 1)] ;
//                //                NSLog(@"jump to 0 ~ 5");
//            } else {
//                CMTime timeJumpMaker =[[timeMarks objectAtIndex:(self.chapCounter-1)] CMTimeValue];
//                CMTime compareTime = CMTimeAdd(timeJumpMaker,CMTimeMakeWithSeconds(5, 1));
//                if (CMTIME_COMPARE_INLINE(self.moviePlayer.currentTime , >=, compareTime)
//                    ) {
//                    
//                    [self.moviePlayer seekToTime:timeJumpMaker];
//                    //                    CMTimeShow(timeJumpMaker);
//                    //                    CMTimeShow([[timeMarks objectAtIndex:(self.chapCounter) ]CMTimeValue]);
//                }
//            }
//            
//        } else {
//            self.chapCounter++;
//            NSLog(@"chapCounter=%d!",self.chapCounter);
//            self.jumpOrNot = NO;
//
//        }
        switch (self.timeMarkCount%3) {
            case 0:
                NSLog(@"开始吹");
                self.blowActive.enabled =YES;
                self.levelNum.hidden = NO;
                self.levelNum.text = @"0";
                break;
            case 1:
                NSLog(@"停");
                self.blowOn = YES;
                [self.moviePlayer pause] ;
                break;
            case 2:
                NSLog(@"继续");
                [self.moviePlayer play];
                self.blowActive.enabled =NO;
                self.maxPower = 0;
                self.blowOn = NO;
                self.levelNum.hidden = YES;
                break;
            default:
                break;
        }
//        self.blowOn = !self.blowOn;
//        NSLog(@"%@",self.blowOn?@"YES":@"NO");
//        
//            if (self.blowOn) {
////                [self.moviePlayer pause] ;
//
//                self.maxPower = 0;
//                self.levelNum.textColor = [UIColor redColor];
//                //                NSLog(@"jump to 0 ~ 5");
//            } else {
////                [self.moviePlayer play];
//                self.blowActive.enabled =NO;
//                self.levelNum.textColor = [UIColor blackColor];
//            }
        self.timeMarkCount++;
        
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
    if (self.jumpOrNot) {
        NSLog(@"jump!");
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.moviePlayer = nil;
        //        if (theMovie == nil)
        //        [self initMoviePlayer];
        //        self.moviePlayer.initialPlaybackTime =10.0001;
        //        self.moviePlayer.endPlaybackTime = 20;
        //        [self.moviePlayer setInitialPlaybackTime:10];
        //        [self.moviePlayer setEndPlaybackTime:20];
        //        NSLog(@"startForm:%f to %f", self.moviePlayer.initialPlaybackTime,self.moviePlayer.endPlaybackTime);
        
        self.jumpOrNot = NO;

    } else {
        return;
    }
    
}
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
    
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat:44100.0], AVSampleRateKey,
                              [NSNumber numberWithInt:kAudioFormatAppleLossless],AVFormatIDKey,
                              [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
                              [NSNumber numberWithInt:AVAudioQualityMax], AVEncoderAudioQualityKey,
                              nil];
    NSError *error;
    self.audioSession = [AVAudioSession sharedInstance];
    [self.audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error: &error];
    [self.audioSession setActive: YES error: nil];
    self.recorder = [[AVAudioRecorder alloc]initWithURL:url settings:settings error:&error];
    
    if (self.recorder) {
        [self.recorder prepareToRecord];
        self.recorder.meteringEnabled = YES;
        [self.recorder record];
        self.levelTimer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(levelTimerCallBack:) userInfo:nil repeats:YES];
    } else {
        NSLog(@"%@",[error description]);
    }
}

-(void)levelTimerCallBack:(NSTimer *)timer {
    [self.recorder updateMeters];

    static BOOL breakPointHappen = NO;
    static double prevLowPassResults = 0;
    static int lableValue  =0;
    const double ALPHA = 0.05;
    double peakPowerForChannel = pow(10, 0.05*[self.recorder peakPowerForChannel:0]);
    self.lowPassResults = ALPHA * peakPowerForChannel + (1.0-ALPHA)*self.lowPassResults;
//    NSLog(@"%f",self.lowPassResults);
    
//    NSLog(@"Average input: %f Peak input: %f Low pass results: %f",[self.recorder averagePowerForChannel:0],[self.recorder peakPowerForChannel:0], self.lowPassResults);
    if (breakPointHappen) {
        if(self.lowPassResults<0.5) {
            breakPointHappen = NO;
        }
    }else if (self.lowPassResults >0.5 && prevLowPassResults > self.lowPassResults) {
            NSLog(@"MAX Power is : %f",prevLowPassResults);
            self.maxPower = prevLowPassResults;
            breakPointHappen = YES;
        }
    
    if (self.blowOn) {
        if (self.lowPassResults >0.5 || self.maxPower >0.1) {
            //            NSLog(@"%f",self.maxPower);
            [self.moviePlayer play];
        } else {
            [self.moviePlayer pause];
        }
        self.levelNum.text = [NSString stringWithFormat:@"%d",lableValue];
    }

        prevLowPassResults= self.lowPassResults;
    if (self.maxPower>0) {
        self.maxPower -= 0.002;
    }

    
////    lableValue-=0.1;
//
    lableValue = (int)(self.lowPassResults *100);
    if (lableValue<=0) {
        lableValue =0;
    } else if(lableValue>=100) {
        lableValue =100;
    }

}

-(void)cleanBlowVideo{
    [self.levelTimer invalidate];
//    self.recorder.meteringEnabled = NO;
//    [[AVAudioSession sharedInstance] setActive:NO error:nil];
//    [self.recorder stop];
    self.levelTimer = nil;
//    self.audioSession= nil;
    self.recorder = nil;
    self.lowPassResults = 0;
    [self.moviePlayer replaceCurrentItemWithPlayerItem:nil];
    [self.movieLayer removeFromSuperlayer ];
    self.movieLayer.player =nil;
    NSLog(@"remove video & blow detection!");
}

@end
