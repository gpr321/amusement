//
//  GPDownloadFileHelper.m
//  下载管理器2
//
//  Created by mac on 15-2-16.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#define fileManager [NSFileManager defaultManager]
#define GPFileSizeFromPath(filePath) [[[NSFileManager defaultManager] attributesOfItemAtPath:(filePath) error:NULL] fileSize]

#import "GPDownloadFileHelper.h"
#import "GPDownloadInfo.h"

@interface GPDownloadFileHelper ()
@property (nonatomic,strong) NSOutputStream *outputStream;
@end

@implementation GPDownloadFileHelper

- (instancetype)initWithDownloadInfo:(GPDownloadInfo *)downloadInfo{
    if ( self = [super init] ) {
        self.downloadInfo = downloadInfo;
    }
    return self;
}

+ (instancetype)downloadFileHelperWithDownloadInfo:(GPDownloadInfo *)downloadInfo{
    return [[self alloc] initWithDownloadInfo:downloadInfo];
}

- (NSOutputStream *)outputStream{
    @synchronized(self){
        if (_outputStream == nil) {
            _outputStream = [[NSOutputStream alloc] initToFileAtPath:self.downloadInfo.tempFilePath append:YES];
        }
    }
    return _outputStream;
}

- (void)removeFileFromFilePath{
    [[NSFileManager defaultManager] removeItemAtPath:self.downloadInfo.tempFilePath error:NULL];
}

- (void)startFileWriting{
    [self.outputStream open];
}

- (void)writeData:(NSData *)data{
    [self.outputStream write:data.bytes maxLength:data.length];
    self.downloadInfo.bytesHasWriten += data.length;
    self.downloadInfo.bytesToWritten = data.length;
}

- (void)finishFileWriting{
    [self.outputStream close];
    self.outputStream = nil;
}

- (BOOL)isNeedToDownLoad{
    NSRange downloadRange = self.downloadInfo.targetRange;
    if ( ![fileManager fileExistsAtPath:self.downloadInfo.tempFilePath] ) {
        self.downloadInfo.downloadRange = downloadRange;
        return YES;
    }
    unsigned long long fileSize = GPFileSizeFromPath(self.downloadInfo.tempFilePath);
   //  NSLog(@"%@--fileSize -- %tu",[self.downloadInfo.tempFilePath lastPathComponent],fileSize);
    unsigned long long downloadSize = self.downloadInfo.targetRange.length;
    if ( fileSize == downloadSize ) {
        return NO;
    }
    
    if ( self.downloadInfo.targetRange.length < fileSize ) {
        [fileManager removeItemAtPath:self.downloadInfo.tempFilePath error:NULL];
        downloadRange.length = downloadSize;
        self.downloadInfo.targetRange = downloadRange;
        return YES;
    }
    downloadRange.location = downloadRange.location + fileSize;
    downloadRange.length = downloadRange.length - fileSize;
    self.downloadInfo.downloadRange = downloadRange;
    return YES;
}

@end
