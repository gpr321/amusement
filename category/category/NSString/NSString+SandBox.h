//
//  NSString+SandBox.h
//  category
//
//  Created by mac on 15-2-3.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SandBox)

- (instancetype)cachesPath;

- (instancetype)documentPath;

- (instancetype)tempFile;

@end
