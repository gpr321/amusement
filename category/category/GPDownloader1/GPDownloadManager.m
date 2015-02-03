//
//  GPDownloadManager.m
//  test
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "GPDownloadManager.h"
#import "GPDownloader.h"
#import "NSString+SandBox.h"

#define fileManager [NSFileManager defaultManager]

@interface GPFileItem : NSObject
@property (nonatomic,assign) NSRange fileRage;
@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,assign) BOOL complete;
@end
@implementation GPFileItem
- (instancetype)initWithRange:(NSRange)fileRane filePath:(NSString *)filePath{
    if ( self = [super init] ) {
        self.fileRage = fileRane;
        self.filePath = filePath;
    }
    return self;
}
+ (instancetype)fileItemWithRange:(NSRange)fileRane filePath:(NSString *)filePath{
    return [[self alloc]initWithRange:fileRane filePath:filePath];
}
@end


@interface GPDownloadManager ()<GPDownloaderDelegate>

/** 文件的总长度 */
@property (nonatomic,assign) unsigned long long fileWholeLength;

@property (nonatomic,strong) NSMutableDictionary *downLoaderPool;

@property (nonatomic,strong) NSMutableArray *fileItemArray;

@property (nonatomic,assign) NSUInteger completeLength;

@property (nonatomic,assign) unsigned long long currDownLoadSize;

@end

@implementation GPDownloadManager

#pragma mark - 初始化
+ (instancetype)downloadManagerWithURLString:(NSString *)urlString startBlock:(DownloadStartBlock)startBlock progressBlock:(DownloadUpdateProgressBlock)progressBlock completeBlock:(DownloadCompleteBlock)completeBlock errorBlock:(DownloadErrorBlock)errorBlock fileName:(NSString *)fileName{
    return  [[self alloc] initWithURLString:urlString startBlock:startBlock progressBlock:progressBlock completeBlock:completeBlock errorBlock:errorBlock fileName:fileName];
}

- (instancetype)initWithURLString:(NSString *)urlString startBlock:(DownloadStartBlock)startBlock progressBlock:(DownloadUpdateProgressBlock)progressBlock completeBlock:(DownloadCompleteBlock)completeBlock errorBlock:(DownloadErrorBlock)errorBlock fileName:(NSString *)fileName{
    if ( self = [super init] ) {
        self.url = [NSURL URLWithString:urlString];
        self.downloadStartBlock = startBlock;
        self.downloadUpdateBlock = progressBlock;
        self.downloadCompleteBlock = completeBlock;
        self.downloadErrorBlock = errorBlock;
        _fileName = fileName;
        _downLoaderCount = 1;
    }
    return self;
}

#pragma mark - 控制
- (void)pause{
    [self.downLoaderPool enumerateKeysAndObjectsUsingBlock:^(id key, GPDownloader *downloader, BOOL *stop) {
        [downloader pause];
    }];
}
- (void)resume{
    [self.downLoaderPool enumerateKeysAndObjectsUsingBlock:^(id key, GPDownloader *downloader, BOOL *stop) {
        [downloader resume];
    }];
}
- (void)stop{
    [self.downLoaderPool enumerateKeysAndObjectsUsingBlock:^(id key, GPDownloader *downloader, BOOL *stop) {
        [downloader stop];
    }];
}

- (void)startDownLoad{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self prepare];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.downLoaderPool enumerateKeysAndObjectsUsingBlock:^(id key, GPDownloader *downloader, BOOL *stop) {
                downloader.delegate = self;
                [downloader startDownloadTask];
            }];
        });
    });
}

- (NSMutableArray *)fileItemArray{
    if (_fileItemArray == nil) {
        NSInteger count = self.downLoaderPool.count;
        _fileItemArray = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 0; i < count; i++) {
            [_fileItemArray addObject:[[GPFileItem alloc] init]];
        }
    }
    return _fileItemArray;
}

- (NSMutableDictionary *)downLoaderPool{
    if (_downLoaderPool == nil) {
        _downLoaderPool = [NSMutableDictionary dictionaryWithCapacity:self.downLoaderCount];
    }
    return _downLoaderPool;
}

#pragma mark - 文件处理
- (void)mergeFileItems{
    NSString *targetName = [self.fileName tempFile];
    NSOutputStream *outPutStream = [[NSOutputStream alloc] initToFileAtPath:targetName append:YES];
    [outPutStream open];
    // 顺序融合
    for (GPFileItem *item in self.fileItemArray) {
        NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:item.filePath];
        [inputStream open];
        uint8_t buff[1024] = {0};
        NSInteger len = 0;
        NSUInteger readLength = 0;
        NSUInteger fileSize = [[fileManager attributesOfItemAtPath:item.filePath error:NULL] fileSize];
        while ( fileSize > readLength ) {
            len = [inputStream read:buff maxLength:1024];
            [outPutStream write:buff maxLength:len];
            readLength += len;
        }
        [fileManager removeItemAtPath:item.filePath error:NULL];
        [inputStream close];
    }
    [outPutStream close];
}

- (void)prepare{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
    request.HTTPMethod = @"HEAD";
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    self.fileWholeLength = response.expectedContentLength;
    if ( self.downloadStartBlock ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloadStartBlock(self.fileWholeLength);
        });
    }
    if ( _fileName == nil ) {
        _fileName = response.suggestedFilename;
    }
    [self initialDownloadersWithDownLoaderCount:self.downLoaderCount];
}

- (void)initialDownloadersWithDownLoaderCount:(NSInteger)downLoaderCount{
    unsigned long long itemSize = self.fileWholeLength / downLoaderCount;
    NSUInteger len = itemSize -1;
    for (NSInteger i = 0; i < downLoaderCount; i++) {
        NSUInteger loc = i * itemSize;
        if ( i == downLoaderCount -1 ) {
            len += self.fileWholeLength % downLoaderCount + 1;
        }
        NSRange range = NSMakeRange(loc, len);
        GPDownloader *downLoader = [GPDownloader downloaderWithURLString:self.url.absoluteString downloadRange:range fileName:self.fileName];
        downLoader.fileIndex = i;
        self.downLoaderPool[downLoader.tempFilePath] = downLoader;
    }
}

#pragma mark - GPDownloaderDelegate
- (void)downloaderDidStart:(GPDownloader *)downloader{
    @synchronized(self){
        self.currDownLoadSize += downloader.currFileSize;
    }
}

- (void)downloaderDidUpdateDataSize:(unsigned long long)receiverDataSize{
    @synchronized(self){
        self.currDownLoadSize += receiverDataSize;
    }
    if ( self.downloadUpdateBlock ) {
        double precent = (double)self.currDownLoadSize / self.fileWholeLength;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloadUpdateBlock(precent,self.currDownLoadSize);
        });
    }
}

- (void)downloaderDidComplete:(GPDownloader *)downloader{
    GPFileItem *item = self.fileItemArray[downloader.fileIndex];
    item.filePath = downloader.tempFilePath;
    item.fileRage = downloader.downloadRange;

    @synchronized(self){
        [self.downLoaderPool removeObjectForKey:downloader.tempFilePath];
        NSLog(@"count = %ld",self.downLoaderPool.count);
        if ( self.downLoaderPool.count == 0 ) {
            [self mergeFileItems];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.downloadCompleteBlock();
            });
        }
    }
}

- (void)downloader:(GPDownloader *)downloader DidDownLoadFail:(NSError *)error{
    if ( self.downloadErrorBlock ) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.downloadErrorBlock(error);
        });
    }
    [self.downLoaderPool removeObjectForKey:downloader];
}

@end
