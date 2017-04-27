//
//  ViewController.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "TwoViewController.h"
#import "MISFloatingBall.h"

@interface DemoWindow : UIWindow

@end

@implementation DemoWindow

- (void)dealloc {
    NSLog(@"demowindow dealloc");
}
@end


@interface ViewController ()
@end

@implementation ViewController

- (void)viewWillLayoutSubviews {
    self.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MISFloatingBall *floatingBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
    [floatingBall setContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
//    [floatingBall makeVisibleAtView:self.view];
    [floatingBall makeVisible];
//    self.floatinBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
//    [self.floatinBall setContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
//    [self.floatinBall autoEdgeRetractDuration:0.0f edgeRetractConfigHander:NULL];
//    [self.floatinBall makeVisibleAtView:self.view];
}
@end
