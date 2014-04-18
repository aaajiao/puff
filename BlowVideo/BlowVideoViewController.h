//
//  BlowVideoViewController.h
//  BlowVideo
//
//  Created by Elvis on 14-3-5.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "FcpXMLParser.h"


@interface BlowVideoViewController : UIViewController
-(void)levelTimerCallBack:(NSTimer *)timer;
@end
