//
//  GPDownloader.h
//  下载管理器2
//
//  Created by mac on 15-2-16.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#ifndef DEBUG
#define GPLog(...) NSLog(__VA_ARGS__)
#else
#define GPLog(...)
#endif

// 默认的超时时间
#define kGPDefaultTimeoutInterval 15

#import <Foundation/Foundation.h>
@class GPDownloadFileHelper,GPDownloadInfo;

@protocol GPDownloaderDelegate <NSObject>
@optional
- (void)downloadDidstarted:(GPDownloadInfo *)info;
- (void)downloadDidUpdateProgress:(GPDownloadInfo *)info;
- (void)downloadDidFinished:(GPDownloadInfo *)info;
- (void)downloadDidReceiveError:(NSError *)error;
@end

@interface GPDownloader : NSObject

/** 封装了所有关于文件的下载信息,注意文件一般保存在temp目录中 */
@property (nonatomic,strong) GPDownloadInfo *downloaderInfo;
@property (nonatomic,weak) id<GPDownloaderDelegate> delegate;

/** 默认是不指定下载范围 */
- (instancetype)initWithURL:(NSURL *)url range:(NSRange)range;
+ (instancetype)downloaderWithURL:(NSURL *)url range:(NSRange)range;

#pragma mark - 下载管理
- (void)start;
- (void)stop;

@end
