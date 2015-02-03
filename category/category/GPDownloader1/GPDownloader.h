//
//  GPDownloader.h
//  test
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GPDownloader;

typedef NS_ENUM(NSUInteger, GPDownloaderStatus) {
    GPDownloaderStatusReady,
    GPDownloaderStatusDownLoading,
    GPDownloaderStatusPause,
    GPDownloaderStatusFinish,
    GPDownloaderStatusDestory,
    GPDownloaderStatusError
};

// 这些block都不在主线程中执行
typedef void(^StartTaskBlock)(GPDownloader * downloader);
typedef void(^ProgressBlock)(unsigned long long currDownloadSize);
typedef void(^CompleteBlock)(GPDownloader *downloader);
typedef void(^ErrorBlock)(GPDownloader *mdownloader,NSError *error);

// 代理，注意代理方法运行在子线程中
@protocol GPDownloaderDelegate <NSObject>
- (void)downloaderDidStart:(GPDownloader *) downloader;
- (void)downloaderDidUpdateDataSize:(unsigned long long)currDownloadSize;
- (void)downloaderDidComplete:(GPDownloader *) downloader;
- (void)downloader:(GPDownloader *)downloader DidDownLoadFail:(NSError *)error;
@end

@interface GPDownloader : NSObject

#pragma mark - 初始化
+ (instancetype)downloaderWithURLString:(NSString *)urlString downloadRange:(NSRange)downloadRange fileName:(NSString *)fileName;

- (instancetype)initWithURLString:(NSString *)urlString downloadRange:(NSRange)downloadRange fileName:(NSString *)fileName;

+ (instancetype)downloaderWithURLString:(NSString *)urlString downloadRange:(NSRange)downloadRange startBlock:(StartTaskBlock)startBlock progressBlock:(ProgressBlock)progressBlock completeBlock:(CompleteBlock)completeBlock errorBlock:(ErrorBlock)errorBlock fileName:(NSString *)fileName;


- (instancetype)initWithURLString:(NSString *)urlString downloadRange:(NSRange)downloadRange startBlock:(StartTaskBlock)startBlock progressBlock:(ProgressBlock)progressBlock completeBlock:(CompleteBlock)completeBlock errorBlock:(ErrorBlock)errorBlock fileName:(NSString *)fileName;

@property (nonatomic,copy) NSString *urlString;

@property (nonatomic,assign) NSRange downloadRange;

@property (nonatomic,strong) NSString *fileName;

/** 用来标志下载文件的顺序,以便以后拼接文件方便 */
@property (nonatomic,assign) NSInteger fileIndex;

/** 当连接失败的时候会尝试重新连接,默认重新尝试连接次数为3 */
@property (nonatomic,assign) NSInteger maxRestartCount;

/** 已经下载的长度 */
@property (nonatomic,assign) unsigned long long currFileSize;

/** 代理 */
@property (nonatomic,weak) id<GPDownloaderDelegate> delegate;

/** 超时时间,默认为5秒*/
@property (nonatomic,assign) NSTimeInterval timeOut;

/** 临时文件的名字,用于标识一个 GPDownloader 的唯一标识 */
@property (nonatomic,copy,readonly) NSString *tempFilePath;

#pragma mark - 监听下载状态
//@property (nonatomic,assign) GPDownloaderStatus state;
@property (nonatomic,copy) StartTaskBlock startBlock;
@property (nonatomic,copy) ProgressBlock progressBlock;
@property (nonatomic,copy) CompleteBlock completeBlock;
@property (nonatomic,copy) ErrorBlock errorBlock;

#pragma mark - 下载器状态管理
- (void)startDownloadTask;

- (void)pause;

- (void)resume;

- (void)stop;

- (void)destoryDownloader;

@end



