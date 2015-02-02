//
//  UIView+Animation.m
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView (Animation)

/**
 *  暂停layer当前动画
 *
 *  @param layer 要暂停的layer
 */
+ (void)pauseLayer:(CALayer *)layer{
    // 获取当前播放时间
    CFTimeInterval pauseTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 设置当前layer时间轴的速度为0
    layer.speed = 0.0;
    // 设置当前layer的时间轴坐标点,来记录它停止在相对于父时间轴的时间点
    layer.timeOffset = pauseTime;
}


/**
 *  恢复layer当前动画
 *
 *  @param layer 要恢复的layer的当前动画
 */
+ (void)resumLayer:(CALayer *)layer{
    // 获取上次相对于父时间轴的停止时间
    CFTimeInterval offset = layer.timeOffset;
    // 恢复速度
    layer.speed = 1.0;
    // 设置timeOffset恢复为0
    layer.timeOffset = 0;
    // 设置开始时间为0跟父时间轴同一坐标系
    layer.beginTime = 0;
    // 计算相对于父时间轴的时间点 CACurrentMediaTime() 获取绝对时间
    //  t = (tp - begin) * speed + offset
    //  tp = t - offset
    CFTimeInterval currTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    // 给它设置绝对时间才有用
    layer.beginTime = currTime - offset;
}

@end
