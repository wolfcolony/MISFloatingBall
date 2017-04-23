//
//  MISFloatingBall.h
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//  悬浮球

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MISFloatingBallOriginPosition) {
    MISFloatingBallOriginPositionTop = 0,
    MISFloatingBallOriginPositionBottom,
    MISFloatingBallOriginPositionLeft,
    MISFloatingBallOriginPositionRight,
};

typedef struct MISEdgeRetractConfig {
    CGPoint edgeRetractOffset; /**< 缩进结果偏移量 */
    CGFloat edgeRetractAlpha;  /**< 缩进后的透明度 */
} MISEdgeRetractConfig;

UIKIT_STATIC_INLINE MISEdgeRetractConfig MISEdgeOffsetConfigMake(CGPoint edgeRetractOffset, CGFloat edgeRetractAlpha) {
    MISEdgeRetractConfig config = {edgeRetractOffset, edgeRetractAlpha};
    return config;
}

@interface MISFloatingBall : UIWindow

- (instancetype)initFloatingBallWithSize:(CGSize)ballSize
                          originPosition:(MISFloatingBallOriginPosition)originPosition;

@property (nonatomic, assign, readonly) CGSize ballSize;
@property (nonatomic, assign, readonly) MISFloatingBallOriginPosition originPosition;

/**
 手势结束自动靠近边缘 (默认为 YES)
 */
@property (nonatomic, assign, getter=isAutoCloseEdge) BOOL autoCloseEdge;

/**
 当悬浮球靠近边缘的时候，自动像边缘缩进一段间距 (只有autoCloseEdge为YES时候才会生效)

 @param duration 缩进间隔
 @param edgeRetractConfigHander 缩进后参数的配置(如果为NULL，则使用默认的配置)
 */
- (void)autoEdgeRetractDuration:(NSTimeInterval)duration edgeRetractConfigHander:(MISEdgeRetractConfig(^)())edgeRetractConfigHander;










///////// old
/**< 悬浮球内部视图 （可以外部添加） */
@property (nullable, nonatomic, strong, readonly) UIView *contentView;

- (void)show;
@end
NS_ASSUME_NONNULL_END
