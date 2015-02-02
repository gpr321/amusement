//
//  NSMutableURLRequest+FileUpLoad.h
//  10-POST文件上传
//
//  Created by mac on 15-1-17.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableURLRequest (FileUpLoad)

/**
 *  创建一个上传文件的HTTP Request
 *
 *  @param URL      Http资源路径
 *  @param fileName 上传后保存的名字
 *  @param filePath 从什么地方加载文件
 *
 *  @return request
 */
+ (instancetype)requestWithURL:(NSURL *)URL fileName:(NSString *)fileName;


@end
