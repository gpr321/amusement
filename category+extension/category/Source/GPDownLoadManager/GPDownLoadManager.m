//
//  GPDownLoadManager.m
//  17-实现下载管理器
//
//  Created by mac on 15-1-20.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "GPDownLoadManager.h"
#import "GPDownLoader.h"

@interface GPDownLoadManager ()

@property (nonatomic,strong) NSMutableDictionary *downLoaderCache;

@end

@implementation GPDownLoadManager


+ (instancetype)shareDownLoadManager{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GPDownLoadManager alloc] init];
    });
    return instance;
}

//+ (instancetype)allocWithZone:(struct _NSZone *)zone{
//    static id instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        instance = [self allocWithZone:zone];
//    });
//    return instance;
//}

#pragma mark - downLoaderCache
- (NSMutableDictionary *)downLoaderCache{
    if ( _downLoaderCache == nil ) {
        _downLoaderCache = [NSMutableDictionary dictionary];
    }
    return _downLoaderCache;
}


- (void)downLoadWithURL:(NSURL *)url progress:(void(^)(float progress))progress complete:(void(^)())complete error:(void(^)(NSError * error))error{
    GPDownLoader *downLoader = self.downLoaderCache[url.path];
    if ( downLoader == nil ) {
        downLoader = [[GPDownLoader alloc] init];
        self.downLoaderCache[url.path] = downLoader;
    }
    [downLoader downLoadWithURL:url progress:progress complete:^{
        [self.downLoaderCache removeObjectForKey:url.path];
        complete();
    } error:error];
}

- (void)pauseWithURL:(NSURL *)url{
    GPDownLoader *downLoader = self.downLoaderCache[url.path];
    if ( downLoader == nil ) {
        NSLog(@"没有要暂停的下载任务");
        return;
    }
    [downLoader pause];
}


- (void)resumeWithURL:(NSURL *)url{
    GPDownLoader *downLoader = self.downLoaderCache[url.path];
    if ( downLoader == nil ) {
        NSLog(@"没有要继续的下载任务");
        return;
    }
    [downLoader resume];
}


@end
