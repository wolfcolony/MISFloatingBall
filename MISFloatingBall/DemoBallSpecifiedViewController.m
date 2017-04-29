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

@end

@implementation DemoBallSpecifiedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

    
    MISFloatingBall *floatingBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 100, 100) inSpecifiedView:self.view];
    
    floatingBall.backgroundColor = [UIColor orangeColor];
    
    floatingBall.autoCloseEdge = YES;
    [floatingBall setContent:@"点我弹控制器" contentType:MISFloatingBallContentTypeText];
    [floatingBall visible];
    
    __weak typeof(self) weakSelf = self;
    [floatingBall setClickHander:^{
        
        if (weakSelf) {
            
            DemoBallSpecifiedTwoViewController *vc = [[DemoBallSpecifiedTwoViewController alloc] init];
        
            [weakSelf presentViewController:vc animated:YES completion:NULL];
        }
    }];
}

@end
