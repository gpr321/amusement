//
//  GPDownloadManager.h
//  test
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DownloadStartBlock)(unsigned long long wholeSize);
typedef void(^DownloadUpdateProgressBlock)(float progress,unsigned long long currSize);
typedef void(^DownloadCompleteBlock)();
typedef void(^DownloadErrorBlock)(NSError *error);

@interface GPDownloadManager : NSObject

#pragma mark - 初始化
+ (instancetype)downloadManagerWithURLString:(NSString *)urlString startBlock:(DownloadStartBlock)downloadStartBlock progressBlock:(DownloadUpdateProgressBlock)downloadProgressBlock completeBlock:(DownloadCompleteBlock)downloadCompleteBlock errorBlock:(DownloadErrorBlock)downloadErrorBlock fileName:(NSString *)fileName;

- (instancetype)initWithURLString:(NSString *)urlString startBlock:(DownloadStartBlock)downloadStartBlock progressBlock:(DownloadUpdateProgressBlock)downloadProgressBlock completeBlock:(DownloadCompleteBlock)downloadCompleteBlock errorBlock:(DownloadErrorBlock)downloadErrorBlock fileName:(NSString *)fileName;

#pragma mark - 下载控制
- (void)startDownLoad;
- (void)pause;
- (void)resume;
- (void)stop;

#pragma mark - 属性
@property (nonatomic,strong) NSURL *url;
/** 文件保存的名字,如果不传值,将会使用下载下来的默认文件名字 */
@property (nonatomic,copy,readonly) NSString *fileName;
@property (nonatomic,assign) NSInteger downLoaderCount;

#pragma mark - 监听block
@property (nonatomic,copy) DownloadStartBlock downloadStartBlock;
@property (nonatomic,copy) DownloadUpdateProgressBlock downloadUpdateBlock;
@property (nonatomic,copy) DownloadCompleteBlock downloadCompleteBlock;
@property (nonatomic,copy) DownloadErrorBlock downloadErrorBlock;

@end
