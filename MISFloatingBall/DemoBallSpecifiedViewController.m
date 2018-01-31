//
//  DemoBallSpecifiedViewController.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/29.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "DemoBallSpecifiedViewController.h"
#import "MISFloatingBall.h"

#import "DemoBallSpecifiedTwoViewController.h"

@interface DemoBallSpecifiedViewController ()
@property (nonatomic, strong) MISFloatingBall *floatingBall;

@end

@implementation DemoBallSpecifiedViewController

- (void)dealloc {
    NSLog(@"DemoBallSpecifiedViewController %@", NSStringFromSelector(_cmd));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    
    UIView *view0 = [[UIView alloc] initWithFrame:CGRectMake(0, 100, 100, 100)];
    view0.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:view0];
    
    MISFloatingBall *floatingBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 100, 100) inSpecifiedView:self.view];
    
    __weak typeof(self) weakSelf = self;
    floatingBall.clickHandler = ^(MISFloatingBall * _Nonnull floatingBall) {
        DemoBallSpecifiedTwoViewController *vc = [[DemoBallSpecifiedTwoViewController alloc] init];
        [weakSelf presentViewController:vc animated:YES completion:NULL];
    };

    [floatingBall visible];
    
    floatingBall.backgroundColor = [UIColor orangeColor];
    floatingBall.autoCloseEdge = YES;
    [floatingBall setContent:@"点我弹控制器" contentType:MISFloatingBallContentTypeText];
    
    self.floatingBall = floatingBall;
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(150, 100, 100, 100)];
    view2.backgroundColor = [UIColor blueColor];
    [self.view addSubview:view2];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.floatingBall disVisible];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
}

@end
