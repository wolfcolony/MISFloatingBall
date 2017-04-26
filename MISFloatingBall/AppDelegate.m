//
//  AppDelegate.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegateManager

+ (instancetype)shareManager {
    static AppDelegateManager *mgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mgr = [[AppDelegateManager alloc] init];
    });
    return mgr;
}

@end

@interface AppDelegate ()
@property (nonatomic, strong) MISFloatingBall *floatinBall;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.floatinBall = [[MISFloatingBall alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
//    self.floatinBall.backgroundColor = [UIColor lightGrayColor];
//    self.floatinBall.autoCloseEdge = NO;
    
    /*
    [self.floatinBall setBallContent:@"悬浮球哈哈哈" contentType:MISFloatingBallContentTypeText];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [button setTitle:@"测试" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.floatinBall setBallContent:button contentType:MISFloatingBallContentTypeCustomView];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [button1 setTitle:@"测试2" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    [self.floatinBall setBallContent:button1 contentType:MISFloatingBallContentTypeCustomView];
    
    UIButton *button3 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    [button3 setTitle:@"测试2" forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.floatinBall setBallContent:button3 contentType:MISFloatingBallContentTypeCustomView];
    
    */
    [self.floatinBall visibleBall];
    [self.floatinBall setBallContent:[UIImage imageNamed:@"apple"] contentType:MISFloatingBallContentTypeImage];
    [AppDelegateManager shareManager].floatinBall = self.floatinBall;
    
    return YES;
}

- (id)floatingBall:(MISFloatingBall *)floatingBall clickJumpKind:(NSString *)kind {
    return nil;
}

- (void)test {
    NSLog(@"test");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
