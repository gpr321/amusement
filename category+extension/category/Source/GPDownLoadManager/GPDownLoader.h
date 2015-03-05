//
//  GPDownLoadManager.h
//  17-实现下载管理器
//
//  Created by mac on 15-1-20.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, GPDownLoaderStatus) {
    GPDownLoaderStatusDownLoading = 1,
    GPDownLoaderStatusPause,
    GPDownLoaderStatusFinish,
    GPDownLoaderStatusBreak
};

@interface GPDownLoader : NSObject

@property (nonatomic,assign) GPDownLoaderStatus status;

- (void)downLoadWithURL:(NSURL *)url;

- (void)downLoadWithURL:(NSURL *)url progress:(void(^)(float))progressBlock complete:(void(^)())completeBlock error:(void(^)(NSError *))errorBlock;

- (void)startDownLoadTask;

- (void)resume;

- (void)pause;

@end
