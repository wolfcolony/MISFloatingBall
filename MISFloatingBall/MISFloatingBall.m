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

#pragma mark - Private

- (void)initialize {
    self.layer.cornerRadius = 10.f;
    self.windowLevel = UIWindowLevelAlert + 100;
    self.backgroundColor = [UIColor clearColor];
    self.containerVC = [[UIViewController alloc] init];
    self.containerVC.view.backgroundColor = [UIColor redColor];
    self.rootViewController = self.containerVC;
    
    self.wOffset = 0.0f; //self.bounds.size.width * 0.4;
    self.hOffset = 0.0f; //self.bounds.size.height * 0.4;
    self.centerOffset = CGPointMake(MISSCREENW * 0.6, MISSCREENH * 0.6);
    
    self.retractDuration = 5.0f;
    self.autoRetract = NO;
    
    self.autoCloseEdge = YES;
}

- (void)addGestureRecognizer {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    
    [self addGestureRecognizer:tapGesture];
    [self addGestureRecognizer:panGesture];
}

- (void)autoRetract {
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.frame;
        switch (self.originPosition) {
            case MISFloatingBallOriginPositionTop: {
                frame.origin.y = -self.hOffset;
                self.frame = frame;
                break;
            }
            case MISFloatingBallOriginPositionBottom: {
                frame.origin.y = MISSCREENH - self.bounds.size.height + self.hOffset;
                self.frame = frame;
                break;
            }
            case MISFloatingBallOriginPositionLeft: {
                frame.origin.x = -self.wOffset;
                self.frame = frame;
                break;
            }
            case MISFloatingBallOriginPositionRight: {
                frame.origin.x = MISSCREENW - self.bounds.size.width + self.wOffset;
                self.frame = frame;
                break;
            }
            default:
                break;
        }
    }];
}

#pragma mark - Public Methods

- (void)show {
    [self makeKeyAndVisible];
}

#pragma mark - GestureRecognizer

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGesture {
    if (UIGestureRecognizerStateBegan == panGesture.state) {
        
    }
    else if (UIGestureRecognizerStateChanged == panGesture.state) {
        CGPoint translation = [panGesture translationInView:self];
        
        CGPoint center = self.center;
        center.x += translation.x;
        center.y += translation.y;
        self.center = center;
        
        CGFloat   leftMinX = -self.wOffset;
        CGFloat    topMinY = -self.hOffset;
        CGFloat  rightMaxX = MISSCREENW - self.bounds.size.width + self.wOffset;
        CGFloat bottomMaxY = MISSCREENH - self.bounds.size.height + self.hOffset;
        
        CGRect frame = self.frame;
        frame.origin.x = frame.origin.x > rightMaxX ? rightMaxX : frame.origin.x;
        frame.origin.x = frame.origin.x < leftMinX ? leftMinX : frame.origin.x;
        frame.origin.y = frame.origin.y > bottomMaxY ? bottomMaxY : frame.origin.y;
        frame.origin.y = frame.origin.y < topMinY ? topMinY : frame.origin.y;
        self.frame = frame;
        
        // zero
        [panGesture setTranslation:CGPointZero inView:self];
    }
    else if (UIGestureRecognizerStateEnded == panGesture.state) {
        if (self.isAutoCloseEdge) {
            __block CGPoint center = self.center;
            // 自动靠近边缘
            if (center.y < (self.bounds.size.height * 1.5)
                || (center.y > (MISSCREENH - self.bounds.size.height * 1.5))) {
                [UIView animateWithDuration:0.3f animations:^{
                    center.y = (center.y > MISSCREENH * 0.5) ? (MISSCREENH - self.bounds.size.height * 0.5) : (self.bounds.size.height * 0.5);
                    self.center = center;
                }];
            }
            else {
                [UIView animateWithDuration:0.3f animations:^{
                    center.x = (center.x > MISSCREENW * 0.5) ? (MISSCREENW - self.bounds.size.width * 0.5) : (self.bounds.size.width * 0.5);
                    self.center = center;
                }];
            }
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

- (void)setAutoRetract:(BOOL)autoRetract {
    _autoRetract = autoRetract;
    
    if (autoRetract) {
        [self performSelector:@selector(autoRetract) withObject:nil afterDelay:self.retractDuration];
    }
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
