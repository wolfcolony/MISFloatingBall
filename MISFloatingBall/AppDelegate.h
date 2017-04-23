//
//  AppDelegate.h
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MISFloatingBall.h"

@interface AppDelegateManager : NSObject

+ (instancetype)shareManager;

@property (nonatomic, strong) MISFloatingBall *floatinBall;
@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@end

