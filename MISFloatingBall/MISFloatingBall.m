//
//  MISFloatingBall.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "MISFloatingBall.h"

#define MISSCREENW [UIScreen mainScreen].bounds.size.width
#define MISSCREENH [UIScreen mainScreen].bounds.size.height

@interface MISFloatingBall()
@property (nonatomic, assign) CGFloat wOffset;
@property (nonatomic, assign) CGFloat hOffset;

@property (nonatomic, assign) CGPoint centerOffset; /**< 中心点的最大偏移限制 */
@property (nonatomic, strong) UIViewController *containerVC;
@end

@implementation MISFloatingBall
@synthesize ballSize = _ballSize;
@synthesize originPosition = _originPosition;
@synthesize contentView = _contentView;

#pragma mark - Life Cycle

- (void)dealloc {
    NSLog(@"MISFloatingBall dealloc");
}

- (instancetype)init {
    return [self initFloatingBallWithSize:CGSizeMake(44, 44) originPosition:MISFloatingBallOriginPositionTop];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initFloatingBallWithSize:frame.size originPosition:MISFloatingBallOriginPositionTop];
}

- (instancetype)initFloatingBallWithOriginPosition:(MISFloatingBallOriginPosition)originPosition {
    return [self initFloatingBallWithSize:CGSizeMake(44, 44) originPosition:originPosition];
}

- (instancetype)initFloatingBallWithSize:(CGSize)ballSize originPosition:(MISFloatingBallOriginPosition)originPosition {
    self = [super initWithFrame:CGRectMake(0, 0, ballSize.width, ballSize.height)];
    if (self) {
        [self initialize];
        [self addGestureRecognizer];
        
        self.originPosition = originPosition;
        self.ballSize = ballSize;
    }
    return self;
}

- (void)initialize {
    self.layer.cornerRadius = 10.f;
    self.windowLevel = UIWindowLevelAlert + 100;
    self.backgroundColor = [UIColor clearColor];
    self.containerVC = [[UIViewController alloc] init];
    self.containerVC.view.backgroundColor = [UIColor redColor];
    self.rootViewController = self.containerVC;
    
    self.wOffset = self.bounds.size.width * 0.4;
    self.hOffset = self.bounds.size.height * 0.4;
    self.centerOffset = CGPointMake(MISSCREENW * 0.6, MISSCREENH * 0.6);
}

- (void)addGestureRecognizer {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    
    [self addGestureRecognizer:tapGesture];
    [self addGestureRecognizer:panGesture];
}

#pragma mark - Public Methods

- (void)show {
    [self makeKeyAndVisible];
}

#pragma mark - GestureRecognizer

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGesture {
    if (UIGestureRecognizerStateChanged == panGesture.state) {
        CGPoint translation = [panGesture translationInView:self];
        CGPoint center = self.center;
        
        center.x += translation.x;
        center.y += translation.y;
        
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
    else if (UIGestureRecognizerStateEnded == panGesture.state) {
        __block
        CGPoint center = self.center;
        
        if (center.x < self.bounds.size.width * 0.5) {
            center.x = self.bounds.size.width * 0.5;
        }
        
        if (center.x > [UIScreen mainScreen].bounds.size.width - self.bounds.size.width * 0.5) {
            [UIView animateWithDuration:0.3f animations:^{
                center.x = [UIScreen mainScreen].bounds.size.width - self.bounds.size.width * 0.5;
                self.center = center;
            }];
        }
    }
}

- (void)tapGestureRecognizer:(UIPanGestureRecognizer *)tapGesture {
    NSLog(@"tap!!!");
}

#pragma mark - Setter / Getter

- (void)setBallSize:(CGSize)ballSize {
    _ballSize = ballSize;
}

- (void)setOriginPosition:(MISFloatingBallOriginPosition)originPosition {
    _originPosition = originPosition;
    
    CGRect frame = self.frame;
    switch (originPosition) {
        case MISFloatingBallOriginPositionTop:
            frame.origin.y = 0.0f;
            frame.origin.x = self.centerOffset.x;
            self.frame = frame;
            break;
        case MISFloatingBallOriginPositionBottom:
            frame.origin.y = MISSCREENH - self.bounds.size.height;
            frame.origin.x = self.centerOffset.x;
            self.frame = frame;
            break;
        case MISFloatingBallOriginPositionLeft:
            frame.origin.x = 0.0f;
            frame.origin.y = self.centerOffset.y;
            self.frame = frame;
        case MISFloatingBallOriginPositionRight:
            frame.origin.x = MISSCREENW - self.bounds.size.width;
            frame.origin.y = self.centerOffset.y;
            self.frame = frame;
        default:
            break;
    }
}
@end
