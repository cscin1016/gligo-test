//
//  EncryptUtil.h
//  JdshAPI
//
//  Created by sea_buckthorn on 2017/7/23.
//  Copyright © 2017年 Jdsh. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EncryptUtil : NSObject

+ (NSString *)encrypt:(NSString *)plain;
+ (NSData *)decrypt:(NSData *)cipher;

@end

NS_ASSUME_NONNULL_END
