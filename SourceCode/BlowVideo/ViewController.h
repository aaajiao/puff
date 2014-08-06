//
//  ViewController.h
//  Puff
//
//  Created by Elvis on 14-6-12.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IntroViewController.h"
#import "BlowVideoViewController.h"

@interface ViewController : UIViewController <UIPageViewControllerDataSource>
- (IBAction)startWalkthrough:(id)sender;
@property (strong,nonatomic)UIPageViewController *pageViewController;
//@property (strong,nonatomic) NSArray *pageTitles;
//@property (strong,nonatomic) NSArray *pageImages;
@property (strong,nonatomic)NSArray *pages;

@end
