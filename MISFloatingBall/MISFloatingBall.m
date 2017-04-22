//
//  MISFloatingBall.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "MISFloatingBall.h"

@interface MISFloatingBall()

@end

@implementation MISFloatingBall

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 100;
        self.backgroundColor = [UIColor blueColor];
        
        UIViewController *rootVC = [[UIViewController alloc] init];
        rootVC.view.backgroundColor = [UIColor grayColor];
        self.rootViewController = rootVC;
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [self addGestureRecognizer:panGesture];
    }
    return self;
}

#pragma mark - Public Methods

- (void)show {
    [self makeKeyAndVisible];
}

#pragma mark - Private Methods

- (void)panGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self];
    
    CGPoint center = self.center;
    center.x += translation.x;
    center.y += translation.y;
    
//    CGFloat wOffset = self.bounds.size.width * 3 / 4;
//    CGFloat hOffset = self.bounds.size.height * 3 / 4;
    
    if (center.x < 0) {
        center.x = 0;
    }
    
    if (center.x > [UIScreen mainScreen].bounds.size.width) {
        center.x = [UIScreen mainScreen].bounds.size.width;
    }
    
    if (center.y < 0) {
        center.y = 0;
    }
    
    if (center.y > [UIScreen mainScreen].bounds.size.height) {
        center.y = [UIScreen mainScreen].bounds.size.height;
    }
    
    self.center = center;
    
    [panGesture setTranslation:CGPointZero inView:self];
}
@end
