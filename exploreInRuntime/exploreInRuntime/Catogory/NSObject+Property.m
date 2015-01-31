//
//  NSObject+Property.m
//  exploreInRuntime
//
//  Created by mac on 15-1-30.
//  Copyright (c) 2015年 gpr. All rights reserved.
//

#import "NSObject+Property.h"

@implementation NSObject (Property)

- (void)enumerateProperNameAndValueUsingBlock:(void(^)(NSString *name,id value,NSString *typeEncode))block{
    unsigned int count = 0;
    Class clazz = [self class];
    Ivar *ivars = 0;
    const char *ivarName = 0;
    Ivar temp;
    NSString *proName = nil;
    NSString *typeEncode = nil;
    id value = nil;
    do{
        ivars = class_copyIvarList(clazz, &count);
        for (NSInteger i = 0; i < count; i++) {
            temp = ivars[i];
            ivarName = ivar_getName(temp);
            proName = [NSString stringWithUTF8String:ivarName];
            typeEncode = [NSString stringWithUTF8String:ivar_getTypeEncoding(temp)];
            value = [self valueForKeyPath:proName];
            
//            if ( [[[value class] description] isEqualToString:@"__NSCFBoolean"] || [[[value class] description] isEqualToString:@"__NSCFNumber"]) {
//                typeEncode = baseType;
//            }
            
            block(proName,value,typeEncode);
        }
        free(ivars);
    } while ((clazz = [clazz superclass]) != [NSObject class]);
    
}

- (NSDictionary *)propertitesDictionary{
    NSDictionary *dict = objc_getAssociatedObject(self, @selector(propertitesDictionary));
    if (dict) return dict;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    [self enumerateProperNameAndValueUsingBlock:^(NSString *name, id value,NSString *typeEncode) {
        if ( [name hasPrefix:@"_"] ) {
            name = [name substringFromIndex:1];
        }
        dictM[name] = value;
    }];
    dict = [dictM copy];
    objc_setAssociatedObject(self,  @selector(propertitesDictionary), dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return dict;
}

- (NSDictionary *)privatePropertitesDictionary{
    NSDictionary *dict = objc_getAssociatedObject(self, @selector(privatePropertitesDictionary));
    if (dict) return dict;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    [self enumerateProperNameAndValueUsingBlock:^(NSString *name, id value,NSString *typeEncode) {
        dictM[name] = value;
    }];
    dict = [dictM copy];
    objc_setAssociatedObject(self,  @selector(privatePropertitesDictionary), dict, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return dict;
}


+ (NSArray *)privatePropertitesList{
    NSMutableArray *proList = [NSMutableArray array];
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    const char *ivarName = 0;
    Ivar temp;
    NSString *proName = nil;
    for (NSInteger i = 0; i < count; i++) {
        temp = ivars[i];
        ivarName = ivar_getName(temp);
        proName = [NSString stringWithUTF8String:ivarName];
        [proList addObject:proName];
    }
    free(ivars);
    return proList;
}

+ (NSArray *)propertitesList{
    unsigned int count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    NSMutableArray *proList = [NSMutableArray arrayWithCapacity:count];
    const char *ivarName = 0;
    Ivar temp;
    NSString *proName = nil;
    for (NSInteger i = 0; i < count; i++) {
        temp = ivars[i];
        ivarName = ivar_getName(temp);
        proName = [NSString stringWithUTF8String:ivarName];
        if ( [proName hasPrefix:@"_"] ) {
            proName = [proName substringFromIndex:1];
        }
        [proList addObject:proName];
    }
    free(ivars);
    return proList;
}

- (void)setProperty:(id)property WithName:(NSString *)name policy:(objc_AssociationPolicy)policy{
    if ( [self propertyWithName:name] ) return;
    const char *nameKey = [name cStringUsingEncoding:NSUTF8StringEncoding];
    objc_setAssociatedObject(self, nameKey, property, policy);
}

- (id)propertyWithName:(NSString *)name{
    const char *nameKey = [name cStringUsingEncoding:NSUTF8StringEncoding];
    return objc_getAssociatedObject(self, nameKey);
}

@end
