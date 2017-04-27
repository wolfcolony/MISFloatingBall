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
@property (nonatomic, strong) MISFloatingBall *floatingBall;
@end

@implementation ViewController

- (void)viewWillLayoutSubviews {
    self.view.frame = CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height - 64);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.floatingBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
    self.floatingBall.frame = CGRectMake(30, 30, 44, 44);
    [self.floatingBall setContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
    [self.floatingBall makeVisible];
}
@end
