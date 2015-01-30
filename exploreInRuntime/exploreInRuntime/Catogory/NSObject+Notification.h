//
//  NSObject+Notification.h
//  test
//
//  Created by mac on 15-1-30.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
    让各个对象之间建立一对多的关系,有点像观察者模式,不过观察者模式是一对一的,而这里实现的是一对多的观察者模式
 */
@interface NSObject (Notification)
#pragma mark - notifier
/**
 *  添加监听者到本对象中
 *
 *  @param observer 监听对象
 */
- (void)addNotificationObserver:(id)observer;
/**
 *  触发监听的方法
 *
 *  @param userInfo 通知者要传递的参数
 */
- (void)triggerNotificationWithUserInfo:(NSDictionary *)userInfo;
/**
 *  移除指定的监听者
 *
 *  @param observer 指定的监听者
 */
- (void)removeNotificationObserver:(id)observer;
/**
 *  移除所有的监听者
 */
- (void)removeAllNotificationObserver;

#pragma mark - observer
/**
 *  如果监听者要监听的话必须实现该方法,如果不实现无法接受到通知者发布的消息
 *
 *  @param userInfo 通知者传递过来的参数
 */
- (void)observerDidreceiveNotification:(NSDictionary *)userInfo;
/**
 *  取消监听
 */
- (void)cancelListenNotification;

@end
