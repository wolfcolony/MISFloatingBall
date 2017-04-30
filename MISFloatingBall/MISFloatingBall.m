//
//  MISFloatingBall.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "MISFloatingBall.h"
#include <objc/runtime.h>

#pragma mark - MISFloatingBallWindow

@interface MISFloatingBallWindow : UIWindow

@end

@implementation MISFloatingBallWindow

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    __block MISFloatingBall *floatingBall = nil;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[MISFloatingBall class]]) {
            floatingBall = (MISFloatingBall *)obj;
            *stop = YES;
        }
    }];
    
    if (CGRectContainsPoint(floatingBall.bounds,
            [floatingBall convertPoint:point fromView:self])) {
        return [super pointInside:point withEvent:event];
    }
    
    return NO;
}
@end

#pragma mark - MISFloatingBallManager

@interface MISFloatingBallManager : NSObject
@property (nonatomic, assign) BOOL canRuntime;
@property (nonatomic,   weak) UIView *superView;
@end

@implementation MISFloatingBallManager

+ (instancetype)shareManager {
    static MISFloatingBallManager *ballMgr = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ballMgr = [[MISFloatingBallManager alloc] init];
    });
    
    return ballMgr;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.canRuntime = NO;
    }
    return self;
}
@end

#pragma mark - UIView (MISAddSubview)

@interface UIView (MISAddSubview)

@end

@implementation UIView (MISAddSubview)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        method_exchangeImplementations(class_getInstanceMethod(self, @selector(addSubview:)), class_getInstanceMethod(self, @selector(mis_addSubview:)));
    });
}

- (void)mis_addSubview:(UIView *)subview {
    [self mis_addSubview:subview];
    
    if ([MISFloatingBallManager shareManager].canRuntime) {
        if ([[MISFloatingBallManager shareManager].superView isEqual:self]) {
            [self.subviews enumerateObjectsUsingBlock:^(UIView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[MISFloatingBall class]]) {
                    [self insertSubview:subview belowSubview:(MISFloatingBall *)obj];
                }
            }];
        }
    }
}

@end

#pragma mark - MISFloatingBall

@interface MISFloatingBall()
@property (nonatomic, assign) CGPoint centerOffset;

@property (nonatomic,   copy) MISEdgeRetractConfig(^edgeRetractConfigHander)();
@property (nonatomic, assign) NSTimeInterval autoEdgeOffsetDuration;

@property (nonatomic, assign, getter=isAutoEdgeRetract) BOOL autoEdgeRetract;

@property (nonatomic, strong) UIView *parentView;

// globally
@property (nonatomic, strong) MISFloatingBallWindow *window;

// content
@property (nonatomic, strong) UIImageView *ballImageView;
@property (nonatomic, strong) UILabel *ballLabel;
@property (nonatomic, strong) UIView *ballCustomView;
@end

static const NSInteger minUpDownLimits = 60 * 1.5f;   // MISFloatingBallEdgePolicyAllEdge下，悬浮球到达一个界限开始自动靠近上下边缘

#ifdef DEBUG
#define MISLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define MISLog(format, ...)
#endif

@implementation MISFloatingBall

#pragma mark - Life Cycle

- (void)dealloc {
    MISLog(@"MISFloatingBall dealloc");
    [MISFloatingBallManager shareManager].canRuntime = NO;
    [MISFloatingBallManager shareManager].superView = nil;
}

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, 44, 44)];
}

- (instancetype)initWithFrame:(CGRect)frame inSpecifiedView:(UIView *)specifiedView {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initialize];
        [self addGestureRecognizer];
        [self setupSpecifiedView:specifiedView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
        [self addGestureRecognizer];
        [self setupGlobally];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
    self.autoCloseEdge = NO;   // 自动靠边
    self.autoEdgeRetract = NO;  // 自动缩进
    self.edgePolicy = MISFloatingBallEdgePolicyAllEdge;
    [self setHidden:YES];
}

- (void)setupSpecifiedView:(UIView *)specifiedView {
    [specifiedView addSubview:self];
    
    [MISFloatingBallManager shareManager].canRuntime = YES;
    [MISFloatingBallManager shareManager].superView = specifiedView;
    
    self.parentView = specifiedView;
    self.centerOffset = CGPointMake(specifiedView.bounds.size.width * 0.6, specifiedView.bounds.size.height * 0.6);
}

- (void)setupGlobally {
    self.window = [[MISFloatingBallWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelStatusBar - 1;
    
    // temp use rotate...(unfulfilment)
    self.window.rootViewController = [UIViewController new];
    self.window.rootViewController.view.backgroundColor = [UIColor clearColor];
    self.window.rootViewController.view.userInteractionEnabled = NO;
    self.parentView = self.window;
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    
    self.centerOffset = CGPointMake(self.parentView.bounds.size.width * 0.6, self.parentView.bounds.size.height * 0.6);
}

#pragma mark - Private

// 靠边
- (void)autoCloseEdge {
    [UIView animateWithDuration:0.5f animations:^{
        // center
        self.center = [self calculatePoisitionWithEndOffset:CGPointZero];//center;
    } completion:^(BOOL finished) {
        // 靠边之后自动缩进边缘处
        if (self.isAutoEdgeRetract) {
            [self performSelector:@selector(autoEdgeOffset) withObject:nil afterDelay:self.autoEdgeOffsetDuration];
        }
    }];
}

- (void)autoEdgeOffset {
    MISEdgeRetractConfig config = self.edgeRetractConfigHander ? self.edgeRetractConfigHander() : MISEdgeOffsetConfigMake(CGPointMake(self.bounds.size.width * 0.3, self.bounds.size.height * 0.3), 0.8);
    
    [UIView animateWithDuration:0.5f animations:^{
        self.center = [self calculatePoisitionWithEndOffset:config.edgeRetractOffset];
        self.alpha = config.edgeRetractAlpha;
    }];
}

- (CGPoint)calculatePoisitionWithEndOffset:(CGPoint)offset {
    CGFloat ballHalfW   = self.bounds.size.width * 0.5;
    CGFloat ballHalfH   = self.bounds.size.height * 0.5;
    CGFloat parentViewW = self.parentView.bounds.size.width;
    CGFloat parentViewH = self.parentView.bounds.size.height;
    CGPoint center = self.center;
    
    if (MISFloatingBallEdgePolicyLeftRight == self.edgePolicy) {
        // 左右
        center.x = (center.x < self.parentView.bounds.size.width  * 0.5) ? (ballHalfW - offset.x) : (parentViewW + offset.x - ballHalfW);
    }
    else if (MISFloatingBallEdgePolicyUpDown == self.edgePolicy) {
        center.y = (center.y < self.parentView.bounds.size.height * 0.5) ? (ballHalfH - offset.y) : (parentViewH + offset.y - ballHalfH);
    }
    else if (MISFloatingBallEdgePolicyAllEdge == self.edgePolicy) {
        if (center.y < minUpDownLimits) {
            center.y = ballHalfH - offset.y;
        }
        else if (center.y > parentViewH - minUpDownLimits) {
            center.y = parentViewH + offset.y - ballHalfH;
        }
        else {
            center.x = (center.x < self.parentView.bounds.size.width  * 0.5) ? (ballHalfW - offset.x) : (parentViewW + offset.x - ballHalfW);
        }
    }
    return center;
}

#pragma mark - Public Methods

- (void)visible {
    [self setHidden:NO];
}

- (void)disVisible {
    [self setHidden:YES];
}

- (void)autoEdgeRetractDuration:(NSTimeInterval)duration edgeRetractConfigHander:(MISEdgeRetractConfig (^)())edgeRetractConfigHander {
    if (self.isAutoCloseEdge) {
        // 只有自动靠近边缘的时候才生效
        self.edgeRetractConfigHander = edgeRetractConfigHander;
        self.autoEdgeOffsetDuration = duration;
        self.autoEdgeRetract = YES;
    }
}

- (void)setContent:(id)content contentType:(MISFloatingBallContentType)contentType {
    BOOL notUnknowType = (MISFloatingBallContentTypeCustomView == contentType) || (MISFloatingBallContentTypeImage == contentType) || (MISFloatingBallContentTypeText == contentType);
    NSAssert(notUnknowType, @"can't set ball content with an unknow content type");
    
    [self.ballCustomView removeFromSuperview];
    if (MISFloatingBallContentTypeImage == contentType) {
        NSAssert([content isKindOfClass:[UIImage class]], @"can't set ball content with a not image content for image type");
        [self.ballLabel setHidden:YES];
        [self.ballCustomView setHidden:YES];
        [self.ballImageView setHidden:NO];
        [self.ballImageView setImage:(UIImage *)content];
    }
    else if (MISFloatingBallContentTypeText == contentType) {
        NSAssert([content isKindOfClass:[NSString class]], @"can't set ball content with a not nsstring content for text type");
        [self.ballLabel setHidden:NO];
        [self.ballCustomView setHidden:YES];
        [self.ballImageView setHidden:YES];
        [self.ballLabel setText:(NSString *)content];
    }
    else if (MISFloatingBallContentTypeCustomView == contentType) {
        NSAssert([content isKindOfClass:[UIView class]], @"can't set ball content with a not uiview content for custom view type");
        [self.ballLabel setHidden:YES];
        [self.ballCustomView setHidden:NO];
        [self.ballImageView setHidden:YES];
        
        self.ballCustomView = (UIView *)content;
        
        CGRect frame = self.ballCustomView.frame;
        frame.origin.x = (self.bounds.size.width - self.ballCustomView.bounds.size.width) * 0.5;
        frame.origin.y = (self.bounds.size.height - self.ballCustomView.bounds.size.height) * 0.5;
        self.ballCustomView.frame = frame;
        
        self.ballCustomView.userInteractionEnabled = NO;
        [self addSubview:self.ballCustomView];
    }
}

#pragma mark - GestureRecognizer

- (void)addGestureRecognizer {
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
    
    [self addGestureRecognizer:tapGesture];
    [self addGestureRecognizer:panGesture];
}

// 手势处理
- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGesture {
    if (UIGestureRecognizerStateBegan == panGesture.state) {
        [self setAlpha:1.0f];
        
        // cancel
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoEdgeOffset) object:nil];
    }
    else if (UIGestureRecognizerStateChanged == panGesture.state) {
        CGPoint translation = [panGesture translationInView:self];
        
        CGPoint center = self.center;
        center.x += translation.x;
        center.y += translation.y;
        self.center = center;
        
        CGFloat   leftMinX = 0.0f;
        CGFloat    topMinY = 0.0f;
        CGFloat  rightMaxX = self.parentView.bounds.size.width - self.bounds.size.width;
        CGFloat bottomMaxY = self.parentView.bounds.size.height - self.bounds.size.height;
        
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
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 0.2s 之后靠边
                [self autoCloseEdge];
            });
        }
    }
}

- (void)tapGestureRecognizer:(UIPanGestureRecognizer *)tapGesture {
    if (self.clickHander) {
        self.clickHander();
    }
}

#pragma mark - Setter / Getter

- (void)setAutoCloseEdge:(BOOL)autoCloseEdge {
    _autoCloseEdge = autoCloseEdge;
    
    if (autoCloseEdge) {
        [self autoCloseEdge];
    }
}

- (void)setTextTypeTextColor:(UIColor *)textTypeTextColor {
    _textTypeTextColor = textTypeTextColor;
    
    [self.ballLabel setTextColor:textTypeTextColor];
}

- (UIImageView *)ballImageView {
    if (!_ballImageView) {
        _ballImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_ballImageView];
    }
    return _ballImageView;
}

- (UILabel *)ballLabel {
    if (!_ballLabel) {
        _ballLabel = [[UILabel alloc] initWithFrame:self.bounds];
        _ballLabel.textAlignment = NSTextAlignmentCenter;
        _ballLabel.numberOfLines = 1.0f;
        _ballLabel.minimumScaleFactor = 0.0f;
        _ballLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:_ballLabel];
    }
    return _ballLabel;
}
@end
