//
//  eggViewController.m
//  Puff!
//
//  Created by Elvis on 14-7-16.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import "eggViewController.h"

@interface eggViewController ()
@property (weak, nonatomic) IBOutlet UIButton *linkButton;

@end

@implementation eggViewController

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
    UIImage *btnImage = [UIImage imageNamed:@"logo"];
    [self.linkButton setBackgroundImage:btnImage forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)openUrl:(id)sender {
    NSString *myurl= @"http://www.pegpegpegpeg.com/";
    NSURL *url = [NSURL URLWithString:myurl];
    [[UIApplication sharedApplication] openURL:url];
};


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
