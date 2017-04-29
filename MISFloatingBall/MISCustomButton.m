//
//  MISCustomButton.m
//  MISFloatingBall
//
//  Created by Mistletoe on 2017/4/29.
//  Copyright © 2017年 Mistletoe. All rights reserved.
//

#import "MISCustomButton.h"

@implementation MISCustomButton

- (CGRect)imageRectForContentRect:(CGRect)contentRect {
    CGFloat x = (contentRect.size.width - self.imageSize.width) * 0.5;
    CGRect rect = CGRectMake(x, 0, self.imageSize.width,self.imageSize.height);
    return rect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect {
    return CGRectMake(0, self.imageSize.height, contentRect.size.width, contentRect.size.height - self.imageSize.height );
}

@end
