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
@property (nonatomic, assign) CGRect ballFrame; // 悬浮球的尺寸
@property (nonatomic, strong) UIView *ballView; // 悬浮球

@property (nonatomic, assign) CGPoint centerOffset;
@property (nonatomic, strong) UIViewController *containerVC;

@property (nonatomic,   copy) MISEdgeRetractConfig(^edgeRetractConfigHander)();
@property (nonatomic, assign) NSTimeInterval autoEdgeOffsetDuration;

@property (nonatomic, assign, getter=isAutoEdgeRetract) BOOL autoEdgeRetract;

@property (nonatomic, strong) UIImageView *ballImageView;
@property (nonatomic, strong) UILabel *ballLabel;
@property (nonatomic, strong) UIView *ballCustomView;
@end

@implementation MISFloatingBall
@synthesize originPosition = _originPosition;

#pragma mark - Life Cycle

- (void)dealloc {
    NSLog(@"MISFloatingBall dealloc");
}

- (instancetype)init {
    return [self initFloatingBallWithSize:CGSizeMake(44, 44) originPosition:MISFloatingBallOriginPositionTop];
}

- (instancetype)initFloatingBallWithOriginPosition:(MISFloatingBallOriginPosition)originPosition {
    return [self initFloatingBallWithSize:CGSizeMake(44, 44) originPosition:originPosition];
}

- (instancetype)initFloatingBallWithSize:(CGSize)ballSize originPosition:(MISFloatingBallOriginPosition)originPosition {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initialize];
        
        // other
        self.originPosition = originPosition;
        self.ballFrame = CGRectMake(0, 0, ballSize.width, ballSize.height);
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        [self initialize];
        
        self.ballFrame = frame;
    }
    return self;
}

//- (void)setFrame:(CGRect)frame {
//    [super setFrame:[UIScreen mainScreen].bounds];
//    self.ballView.frame = frame;
//}

#pragma marl - Touch 

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    return [hitView isEqual:self.ballView] ? hitView : nil;
}

#pragma mark - Private

- (void)initialize {
    self.layer.masksToBounds = YES;
    self.windowLevel = UIWindowLevelAlert + 100;
    self.backgroundColor = [UIColor clearColor];
    self.centerOffset = CGPointMake(MISSCREENW * 0.6, MISSCREENH * 0.6);
    self.autoCloseEdge = YES;
    self.autoEdgeRetract = NO;
    
    self.containerVC = [[UIViewController alloc] init];
    self.rootViewController = self.containerVC;
    self.rootViewController.view.backgroundColor = [UIColor clearColor];
}

- (void)autoEdgeOffset {
    MISEdgeRetractConfig config = self.edgeRetractConfigHander ? self.edgeRetractConfigHander() : MISEdgeOffsetConfigMake(CGPointMake(self.ballView.bounds.size.width * 0.5, self.ballView.bounds.size.height * 0.5), 0.8);
    
    __block CGPoint center = self.ballView.center;
    
    if (fabs(center.x - self.ballView.bounds.size.width * 0.5) < 0.000001) {
        // 当前靠近屏幕左边缘
        [UIView animateWithDuration:0.5f animations:^{
            center.x = center.x - config.edgeRetractOffset.x;
            self.ballView.center = center;
            
            self.ballView.alpha = config.edgeRetractAlpha;
        }];
    }
    else if (fabs(center.x - (MISSCREENW - self.ballView.bounds.size.width * 0.5)) < 0.000001) {
        // 当前靠近屏幕右边缘
        [UIView animateWithDuration:0.5f animations:^{
            center.x = center.x + config.edgeRetractOffset.x;
            self.ballView.center = center;
            
            self.ballView.alpha = config.edgeRetractAlpha;
        }];
    }
    else if (fabs(center.y - self.ballView.bounds.size.height * 0.5) < 0.000001) {
        // 当前靠近屏幕上边缘
        [UIView animateWithDuration:0.5f animations:^{
            center.y = center.y - config.edgeRetractOffset.y;
            self.ballView.center = center;
            
            self.ballView.alpha = config.edgeRetractAlpha;
        }];
    }
    else if (fabs(center.y - (MISSCREENH - self.ballView.bounds.size.height * 0.5)) < 0.000001) {
        // 当前靠近屏幕底边缘
        [UIView animateWithDuration:0.5f animations:^{
            center.y = center.y + config.edgeRetractOffset.y;
            self.ballView.center = center;
            
            self.ballView.alpha = config.edgeRetractAlpha;
        }];
    }
}

#pragma mark - Public Methods

- (void)visibleBall {
    [self makeKeyAndVisible];
}

- (void)disVisibleBall {
    NSLog(@"disVisibleBall");
}

- (void)autoEdgeRetractDuration:(NSTimeInterval)duration edgeRetractConfigHander:(MISEdgeRetractConfig (^)())edgeRetractConfigHander {
    if (self.isAutoCloseEdge) {
        // 只有自动靠近边缘的时候才生效
        self.edgeRetractConfigHander = edgeRetractConfigHander;
        self.autoEdgeOffsetDuration = duration;
        
        [self performSelector:@selector(autoEdgeOffset) withObject:nil afterDelay:duration];
        
        self.autoEdgeRetract = YES;
    }
}

- (void)setBallContent:(id)content contentType:(MISFloatingBallContentType)contentType {
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
        self.ballCustomView.userInteractionEnabled = NO;
        [self.ballView addSubview:self.ballCustomView];
    }
}
#pragma mark - GestureRecognizer

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)panGesture {
    if (UIGestureRecognizerStateBegan == panGesture.state) {
        [self.ballView setAlpha:1.0f];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(autoEdgeOffset) object:nil];
    }
    else if (UIGestureRecognizerStateChanged == panGesture.state) {
        CGPoint translation = [panGesture translationInView:self.ballView];
        
        CGPoint center = self.ballView.center;
        center.x += translation.x;
        center.y += translation.y;
        self.ballView.center = center;
        
        CGFloat   leftMinX = 0.0f;
        CGFloat    topMinY = 0.0f;
        CGFloat  rightMaxX = MISSCREENW - self.ballView.bounds.size.width;
        CGFloat bottomMaxY = MISSCREENH - self.ballView.bounds.size.height;
        
        CGRect frame = self.ballView.frame;
        frame.origin.x = frame.origin.x > rightMaxX ? rightMaxX : frame.origin.x;
        frame.origin.x = frame.origin.x < leftMinX ? leftMinX : frame.origin.x;
        frame.origin.y = frame.origin.y > bottomMaxY ? bottomMaxY : frame.origin.y;
        frame.origin.y = frame.origin.y < topMinY ? topMinY : frame.origin.y;
        self.ballView.frame = frame;
        
        // zero
        [panGesture setTranslation:CGPointZero inView:self.ballView];
    }
    else if (UIGestureRecognizerStateEnded == panGesture.state) {
        if (self.isAutoCloseEdge) {
            __block CGPoint center = self.ballView.center;
            // 自动靠近边缘
            if (center.y < (self.ballView.bounds.size.height * 1.5)
                || (center.y > (MISSCREENH - self.ballView.bounds.size.height * 1.5))) {
                [UIView animateWithDuration:0.3f animations:^{
                    center.y = (center.y > MISSCREENH * 0.5) ? (MISSCREENH - self.ballView.bounds.size.height * 0.5) : (self.ballView.bounds.size.height * 0.5);
                    self.ballView.center = center;
                }];
            }
            else {
                [UIView animateWithDuration:0.3f animations:^{
                    center.x = (center.x > MISSCREENW * 0.5) ? (MISSCREENW - self.ballView.bounds.size.width * 0.5) : (self.ballView.bounds.size.width * 0.5);
                    self.ballView.center = center;
                }];
            }
        }
        
        if (self.isAutoEdgeRetract) {
            [self performSelector:@selector(autoEdgeOffset) withObject:nil afterDelay:self.autoEdgeOffsetDuration];
        }
    }
}

- (void)tapGestureRecognizer:(UIPanGestureRecognizer *)tapGesture {
}

#pragma mark - Setter / Getter

- (void)setBallFrame:(CGRect)ballFrame {
    self.ballView.frame = ballFrame;
}

- (void)setTextTypeTextColor:(UIColor *)textTypeTextColor {
    _textTypeTextColor = textTypeTextColor;
    
    [self.ballLabel setTextColor:textTypeTextColor];
}

- (void)setOriginPosition:(MISFloatingBallOriginPosition)originPosition {
    _originPosition = originPosition;
    
    CGRect frame = self.ballView.frame;
    switch (originPosition) {
        case MISFloatingBallOriginPositionTop:
            frame.origin.y = 0.0f;
            frame.origin.x = self.centerOffset.x;
            self.ballView.frame = frame;
            break;
        case MISFloatingBallOriginPositionBottom:
            frame.origin.y = MISSCREENH - self.ballView.bounds.size.height;
            frame.origin.x = self.centerOffset.x;
            self.ballView.frame = frame;
            break;
        case MISFloatingBallOriginPositionLeft:
            frame.origin.x = 0.0f;
            frame.origin.y = self.centerOffset.y;
            self.ballView.frame = frame;
        case MISFloatingBallOriginPositionRight:
            frame.origin.x = MISSCREENW - self.ballView.bounds.size.width;
            frame.origin.y = self.centerOffset.y;
            self.ballView.frame = frame;
        default:
            break;
    }
}

- (UIView *)ballView {
    if (!_ballView) {
        UIView *ballView = [[UIView alloc] init];
        ballView.backgroundColor = [UIColor redColor];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizer:)];
        
        [ballView addGestureRecognizer:tapGesture];
        [ballView addGestureRecognizer:panGesture];
        [self.containerVC.view addSubview:ballView];
        
        _ballView = ballView;
    }
    return _ballView;
}

- (UIImageView *)ballImageView {
    if (!_ballImageView) {
        _ballImageView = [[UIImageView alloc] initWithFrame:self.ballView.bounds];
        [self.ballView addSubview:_ballImageView];
    }
    return _ballImageView;
}

- (UILabel *)ballLabel {
    if (!_ballLabel) {
        _ballLabel = [[UILabel alloc] initWithFrame:self.ballView.bounds];
        _ballLabel.textAlignment = NSTextAlignmentCenter;
        _ballLabel.numberOfLines = 1.0f;
        _ballLabel.minimumScaleFactor = 0.0f;
        _ballLabel.adjustsFontSizeToFitWidth = YES;
        [self.ballView addSubview:_ballLabel];
    }
    return _ballLabel;
}
@end
