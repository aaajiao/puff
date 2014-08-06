//
//  ViewController.m
//  Puff
//
//  Created by Elvis on 14-6-12.
//  Copyright (c) 2014年 Elvis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
//    _pageTitles = @[@"page1",@"page2"];
//    _pageImages = @[@"page1.png",@"page2.png"];
    
    UIViewController *page1 = [self.storyboard instantiateViewControllerWithIdentifier:@"Page1"];
    UIViewController *page2 = [self.storyboard instantiateViewControllerWithIdentifier:@"Page2"];
//    UIViewController *page3 = [self.storyboard instantiateViewControllerWithIdentifier:@"Page3"];
    self.pages = @[page1,page2];
    NSLog(@"%@",[self viewControllerAtIndex:1 ]);
    
    //Create page view controller
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    UIViewController *startingViewController = [self viewControllerAtIndex:0 ];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];

    //Change the size of page view Controller
    self.pageViewController.view.frame = self.view.frame;
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)startWalkthrough:(id)sender {
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSInteger index = [self.pages indexOfObject:viewController];
    
    if (index==NSNotFound) {
        NSLog(@"NOT FOUND");
        return nil;
    }
    index++;
    if (index==[self.pages count]) {
        
        return nil;
    }
//    NSLog(@"page index: %d",index);
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.pages indexOfObject:viewController];
    if (index==0 ||index==NSNotFound) {
        return nil;
    }
    index--;
    return [self viewControllerAtIndex:index];
}

-(UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    return self.pages[index];
}
@end
