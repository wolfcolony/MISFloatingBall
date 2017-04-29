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
    [self.floatingBall setContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
    [self.floatingBall visibleGlobally];
//    [self.floatingBall visibleSpecifiedView:self.view];
    
    __weak typeof(self) weakSelf = self;
    [self.floatingBall setClickHander:^{
        NSLog(@"hander");
        
        UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:@"点击悬浮球" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action  = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            TwoViewController *twoVC = [[TwoViewController alloc] init];
            [weakSelf presentViewController:twoVC animated:YES completion:NULL];
        }];
        [alerVC addAction:action];
        [weakSelf presentViewController:alerVC animated:YES completion:NULL];
        
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"111" message:@"222" delegate:nil cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
//        [alertView show];
    }];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"开始");
}
@end
