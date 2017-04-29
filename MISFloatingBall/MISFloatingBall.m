//
//  MISFloatingBall.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "MISFloatingBall.h"

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

- (void)setupSpecifiedView:(UIView *)specifiedView; {
    [specifiedView addSubview:self];
    self.parentView = specifiedView;
    self.centerOffset = CGPointMake(specifiedView.bounds.size.width * 0.6, specifiedView.bounds.size.height * 0.6);
}

- (void)setupGlobally {
    self.window = [[MISFloatingBallWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.windowLevel = UIWindowLevelStatusBar + 100;
    self.window.rootViewController = [UIViewController new];//self.rootVC;
    self.window.rootViewController.view.backgroundColor = [UIColor clearColor];
    self.window.rootViewController.view.userInteractionEnabled = NO;
    self.parentView = self.window;
    [self.window addSubview:self];
    [self.window makeKeyAndVisible];
    
    self.centerOffset = CGPointMake(self.parentView.bounds.size.width * 0.6, self.parentView.bounds.size.height * 0.6);
}

#pragma mark - Private

- (void)autoEdgeOffset {
    MISEdgeRetractConfig config = self.edgeRetractConfigHander ? self.edgeRetractConfigHander() : MISEdgeOffsetConfigMake(CGPointMake(self.bounds.size.width * 0.3, self.bounds.size.height * 0.3), 0.8);
    
    __block CGPoint center = self.center;
    
    CGFloat ballHalfW   = self.bounds.size.width * 0.5;
    CGFloat ballHalfH   = self.bounds.size.height * 0.5;
    CGFloat parentViewW = self.parentView.bounds.size.width;
    CGFloat parentViewH = self.parentView.bounds.size.height;
    
    [UIView animateWithDuration:0.5f animations:^{
        if (MISFloatingBallEdgePolicyLeftRight == self.edgePolicy) {
            // 左右
            center.x = (center.x < self.parentView.bounds.size.width  * 0.5) ? (ballHalfW - config.edgeRetractOffset.x) : (parentViewW + config.edgeRetractOffset.x - ballHalfW);
        }
        else if (MISFloatingBallEdgePolicyUpDown == self.edgePolicy) {
            center.y = (center.y < self.parentView.bounds.size.height * 0.5) ? (ballHalfH - config.edgeRetractOffset.y) : (parentViewH + config.edgeRetractOffset.y - ballHalfH);
        }
        else if (MISFloatingBallEdgePolicyAllEdge == self.edgePolicy) {
            if (center.y < minUpDownLimits) {
                center.y = ballHalfH - config.edgeRetractOffset.y;
            }
            else if (center.y > parentViewH - minUpDownLimits) {
                center.y = parentViewH + config.edgeRetractOffset.y - ballHalfH;
            }
            else {
                center.x = (center.x < self.parentView.bounds.size.width  * 0.5) ? (ballHalfW - config.edgeRetractOffset.x) : (parentViewW + config.edgeRetractOffset.x - ballHalfW);
            }
        }
        
        self.center = center;
        self.alpha = config.edgeRetractAlpha;
    }];
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
        
        [self performSelector:@selector(autoEdgeOffset) withObject:nil afterDelay:duration];
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
        self.isAutoEdgeRetract ? [self performSelector:@selector(autoEdgeOffset) withObject:nil afterDelay:self.autoEdgeOffsetDuration] : [self setAutoCloseEdge:self.isAutoCloseEdge];
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
        [self autoEdgeRetractDuration:0.0f edgeRetractConfigHander:^MISEdgeRetractConfig{
            return MISEdgeOffsetConfigMake(CGPointZero, 1.0f);
        }];
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
