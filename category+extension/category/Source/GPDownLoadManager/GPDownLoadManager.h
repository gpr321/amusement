//
//  GPDownLoadManager.h
//  17-实现下载管理器
//
//  Created by mac on 15-1-20.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPDownLoadManager : NSObject

+ (instancetype)shareDownLoadManager;

- (void)downLoadWithURL:(NSURL *)url progress:(void(^)(float progress))progress complete:(void(^)())complete error:(void(^)(NSError * error))error;

- (void)pauseWithURL:(NSURL *)url;

- (void)resumeWithURL:(NSURL *)url;

@end
