//
//  GPDownloaderManager.h
//  下载管理器2
//
//  Created by mac on 15-2-17.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^StartBlock)(unsigned long long wholeSize);
typedef void(^ProgressBlock)(unsigned long long wholeSize,unsigned long long currSize,float progress);
typedef void(^CompleteBlock)();
typedef void(^ErrorBlock)(NSError *error);

@interface GPDownloaderManager : NSObject

@property (nonatomic,strong) NSURL *url;
@property (nonatomic,assign) NSInteger taskCount;
@property (nonatomic,copy) NSString *fileName;
@property (nonatomic,assign) unsigned long long totalSize;
@property (nonatomic,assign) unsigned long long currSize;

@property (nonatomic,copy) StartBlock startBlock;
@property (nonatomic,copy) ProgressBlock progress;
@property (nonatomic,copy) CompleteBlock complete;
@property (nonatomic,copy) ErrorBlock error;

+ (instancetype)downloadFileFromURL:(NSURL *)url taskCount:(NSInteger)taskCount fileName:(NSString *)fileName start:(StartBlock)startBlock progress:(ProgressBlock)progress complete:(CompleteBlock)complete error:(ErrorBlock)error;

- (void)startDownload;
- (void)stop;

@end
