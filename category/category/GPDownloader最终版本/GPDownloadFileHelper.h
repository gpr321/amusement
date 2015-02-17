//
//  GPDownloadFileHelper.h
//  下载管理器2
//
//  Created by mac on 15-2-16.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GPDownloadInfo;

@interface GPDownloadFileHelper : NSObject

@property (nonatomic,strong) GPDownloadInfo *downloadInfo;

- (instancetype)initWithDownloadInfo:(GPDownloadInfo *)downloadInfo;
+ (instancetype)downloadFileHelperWithDownloadInfo:(GPDownloadInfo *)downloadInfo;

- (BOOL)isNeedToDownLoad;
- (void)startFileWriting;
- (void)writeData:(NSData *)data;
- (void)finishFileWriting;

@end
