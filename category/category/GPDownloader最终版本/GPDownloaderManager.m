//
//  GPDownloaderManager.m
//  下载管理器2
//
//  Created by mac on 15-2-17.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_async(dispatch_get_main_queue(), block);\
}

#import "GPDownloaderManager.h"
#import "GPDownloader.h"
#import "GPDownloadInfo.h"

@interface GPDownloaderManager ()<GPDownloaderDelegate>

@property (nonatomic,strong) NSDictionary *downloaders;

@property (nonatomic,strong) NSMutableArray *tempFilePathArray;

@property (nonatomic,assign) NSInteger completeTaskCount;

@end

@implementation GPDownloaderManager

+ (instancetype)downloadFileFromURL:(NSURL *)url taskCount:(NSInteger)taskCount fileName:(NSString *)fileName start:(StartBlock)startBlock progress:(ProgressBlock)progress complete:(CompleteBlock)complete error:(ErrorBlock)error{
    GPDownloaderManager *manager = [[self alloc] init];
    manager.url = url;
    manager.fileName = fileName;
    manager.startBlock = startBlock;
    manager.taskCount = taskCount;
    manager.progress = progress;
    manager.complete = complete;
    manager.error = error;
    return manager;
}

- (NSMutableArray *)tempFilePathArray{
    if ( _tempFilePathArray == nil ) {
        _tempFilePathArray = [NSMutableArray arrayWithCapacity:self.taskCount];
        for (NSInteger i = 0; i < self.taskCount; i++) {
            _tempFilePathArray[i] = [NSNull null];
        }
    }
    return _tempFilePathArray;
}

- (NSInteger)taskCount{
    if ( _taskCount == 0 ) {
        _taskCount = 1;
    }
    return _taskCount;
}

#pragma mark - 私有方法
- (unsigned long long)getDownloadFileSize{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url cachePolicy:0 timeoutInterval:15];
    NSURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if ( error && self.error ) {
        self.error(error);
    }
    if ( self.fileName == nil ) {
        self.fileName = response.suggestedFilename;
    }
    return response.expectedContentLength;
}

- (void)setUpDownloaders{
    if ( self.downloaders == nil ) {
        unsigned long long wholeSize = [self getDownloadFileSize];
        self.totalSize = wholeSize;
        if ( self.startBlock ) {
            self.startBlock(self.totalSize);
        }
        GPLog(@"wholeSize = %tu",wholeSize);
        NSUInteger count = self.taskCount;
        NSMutableDictionary *dictM = [NSMutableDictionary dictionaryWithCapacity:count];
        unsigned long long itemSize = wholeSize / count;
        unsigned long long extraSize = wholeSize % count;
        /**
            wholeSize = 102 ,count = 4 --> itemSize = 25 extraSize = 2
            (1) 第一组
                0 ~ 25
            (1) 第一组
                26 ~ 50
             (1) 第一组
                51 ~ 75
             (1) 第一组
                76 ~ 100 + 2
         */
        NSUInteger location = 0;
        NSUInteger length = 0;
        NSRange range;
        GPDownloader *downloader = nil;
        for (NSInteger i = 0; i < count ;i++) {
            location = i * itemSize;
            length = itemSize - 1;
            if ( i == count - 1 ) {
                length += extraSize + 1;
            }
            range = NSMakeRange(location, length);
            GPLog(@"%tu -- %tu",location,location + length);
            downloader = [GPDownloader downloaderWithURL:self.url range:range];
            downloader.delegate = self;
            downloader.downloaderInfo.tempFileNum = i;
            dictM[downloader.downloaderInfo.tempFilePath] = downloader;
        }
        self.downloaders = [dictM copy];
    }
}

// 合并临时文件
- (void)mergFile{
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.fileName];
    NSOutputStream *outPutStream = [[NSOutputStream alloc] initToFileAtPath:filePath append:YES];
    [outPutStream open];
    NSUInteger len = 0;
    uint8_t buff[1024] = {0};
    NSUInteger maxLen = 1024;
    NSInputStream *inputStream = nil;
    for (NSString *itemPath in self.tempFilePathArray) {
        inputStream = [[NSInputStream alloc] initWithFileAtPath:itemPath];
        [inputStream open];
        while ( (len = [inputStream read:buff maxLength:maxLen]) != 0 ) {
            [outPutStream write:buff maxLength:len];
        }
        [inputStream close];
         [[NSFileManager defaultManager] removeItemAtPath:itemPath error:NULL];
    }
    [outPutStream close];
    GPLog(@"targetFile - %@",filePath);
}

- (void)start{
    [self.downloaders enumerateKeysAndObjectsUsingBlock:^(NSString *tempFilePath, GPDownloader *downloader, BOOL *stop) {
        [downloader start];
    }];
}

- (void)stop{
    [self.downloaders enumerateKeysAndObjectsUsingBlock:^(NSString *tempFilePath, GPDownloader *downloader, BOOL *stop) {
        [downloader stop];
    }];
}

- (void)startDownload{
    NSAssert(self.url != nil, @"url can not be nil");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self setUpDownloaders];
        dispatch_async(dispatch_get_main_queue(), ^{
           [self start];
        });
    });
}

#pragma mark - GPDownloaderDelegate
- (void)downloadDidstarted:(GPDownloadInfo *)info{

}

- (void)downloadDidUpdateProgress:(GPDownloadInfo *)info{
    if ( self.progress ) {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            self.currSize += info.bytesToWritten;
            float progress = (float)self.currSize / self.totalSize;
            self.progress(self.totalSize,self.currSize,progress);
        });
    }
}

- (void)downloadDidFinished:(GPDownloadInfo *)info{
    dispatch_barrier_sync(dispatch_get_main_queue(), ^{
        if ( self.complete ) {
            self.complete();
            self.tempFilePathArray[info.tempFileNum] = info.tempFilePath;
            self.completeTaskCount++;
            if ( self.completeTaskCount == self.taskCount ) {
                [self mergFile];
            }
        }
    });
}

- (void)downloadDidReceiveError:(NSError *)error{
    if ( self.error ) {
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            self.error(error);
        });
    }
}

@end
