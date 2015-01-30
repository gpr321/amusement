//
//  NSObject+Notification.m
//  test
//
//  Created by mac on 15-1-30.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSObject+Notification.h"
#import <objc/runtime.h>

static char *notifierKey = "notifierKey";

#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wincomplete-implementation"
@implementation NSObject (Notification)
#pragma clang diagnostic pop


- (void)addNotificationObserver:(id)observer{
    self.oberserverKeyDict[[observer pointerString]] = observer;
    objc_setAssociatedObject(observer, notifierKey, self, OBJC_ASSOCIATION_ASSIGN);
}

- (NSString *)pointerString{
    return [NSString stringWithFormat:@"%p",self];
}

- (NSMutableDictionary *)oberserverKeyDict{
    NSMutableDictionary *dict = objc_getAssociatedObject(self, @selector(oberserverKeyDict));
    if ( dict == nil ) {
        dict = [NSMutableDictionary dictionary];
        objc_setAssociatedObject(self, @selector(oberserverKeyDict), dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return dict;
}

- (void)triggerNotificationWithUserInfo:(NSDictionary *)userInfo{
    [self.oberserverKeyDict enumerateKeysAndObjectsUsingBlock:^(id key, id receiver, BOOL *stop) {
        if ( [receiver respondsToSelector:@selector(observerDidreceiveNotification:)] ) {
            [receiver observerDidreceiveNotification:userInfo];
        }
    }];
}


- (void)removeAllNotificationObserver{
    [self.oberserverKeyDict removeAllObjects];
}

- (void)removeNotificationObserver:(id)observer{
    [self.oberserverKeyDict removeObjectForKey:[observer pointerString]];
}

- (void)cancelListenNotification{
    id notigfier = objc_getAssociatedObject(self, notifierKey);
    [notigfier removeNotificationObserver:self];
}

@end
