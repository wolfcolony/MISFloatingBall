//
//  MISFloatingBall.h
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/22.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//  悬浮球

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**< 靠边策略(默认所有边框均可停靠) */
typedef NS_ENUM(NSUInteger, MISFloatingBallEdgePolicy) {
    MISFloatingBallEdgePolicyAllEdge = 0,    /**< 所有边框都可
                                             (符合正常使用习惯，滑到某一位置时候才上下停靠，参见系统的assistiveTouch) */
    MISFloatingBallEdgePolicyLeftRight,      /**< 只能左右停靠 */
    MISFloatingBallEdgePolicyUpDown,         /**< 只能上下停靠 */
};

typedef NS_ENUM(NSUInteger, MISFloatingBallContentType) {
    MISFloatingBallContentTypeImage = 0,    // 图片
    MISFloatingBallContentTypeText,         // 文字
    MISFloatingBallContentTypeCustomView    // 自定义视图
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
/**
 靠边策略
 */
@property (nonatomic, assign) MISFloatingBallEdgePolicy edgePolicy;

/**
 显示悬浮球（默认全局，整个APP可用）
 */
- (void)makeVisible;

/**
 显示悬浮球，指定View内生效

 @param view 指定的View
 */
- (void)makeVisibleAtView:(UIView *)view;

/**
 隐藏悬浮球
 */
- (void)makeDisVisible;

/**
 是否自动靠边
 */
@property (nonatomic, assign, getter=isAutoCloseEdge) BOOL autoCloseEdge;

/**
 当悬浮球靠近边缘的时候，自动像边缘缩进一段间距 (只有autoCloseEdge为YES时候才会生效)

 @param duration 缩进间隔
 @param edgeRetractConfigHander 缩进后参数的配置(如果为NULL，则使用默认的配置)
 */
- (void)autoEdgeRetractDuration:(NSTimeInterval)duration edgeRetractConfigHander:(nullable MISEdgeRetractConfig(^)())edgeRetractConfigHander;

/**
 设置ball内部的内容

 @param content 内容
 @param contentType 内容类型（存在三种文字，图片，和自定义传入视图）
 */
- (void)setContent:(id)content contentType:(MISFloatingBallContentType)contentType;

// 文字颜色
@property (nonatomic, strong) UIColor *textTypeTextColor;
@end

@protocol MISFloatingBallDelegate <NSObject>
@optional
- (void)floatingBallClick:(MISFloatingBall *)ball;

@end
NS_ASSUME_NONNULL_END
