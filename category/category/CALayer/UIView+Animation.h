//
//  UIView+Animation.h
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Animation)

/**
 *  暂停layer当前动画
 *
 *  @param layer 要暂停的layer
 */
+ (void)gp_pauseLayer:(CALayer *)layer;

/**
 *  恢复layer当前动画
 *
 *  @param layer 要恢复的layer的当前动画
 */
+ (void)gp_resumLayer:(CALayer *)layer;
@end
