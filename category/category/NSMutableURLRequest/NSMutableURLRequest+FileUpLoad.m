//
//  NSMutableURLRequest+FileUpLoad.m
//  10-POST文件上传
//
//  Created by mac on 15-1-17.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSMutableURLRequest+FileUpLoad.h"

@implementation NSMutableURLRequest (FileUpLoad)

static NSString *boundaryName = @"boundaryName";
+ (instancetype)gp_requestWithURL:(NSURL *)URL fileName:(NSString *)fileName{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    
    [request setValue:[NSString stringWithFormat:@"multipart/form-data;boundary=%@",boundaryName] forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *bodyData = [NSMutableData data];
    
    NSString *bodyStr = [NSString stringWithFormat:@"\n--%@\n",boundaryName];
    [bodyData appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    bodyStr = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\n",fileName];
    [bodyData appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    bodyStr = @"Content-Type: application/stream\n\n";
    [bodyData appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    [bodyData appendData:fileData];
    
    bodyStr = [NSString stringWithFormat:@"\n--%@--\n",boundaryName];
    [bodyData appendData:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    request.HTTPBody = bodyData;
    return request;
    
}

@end
