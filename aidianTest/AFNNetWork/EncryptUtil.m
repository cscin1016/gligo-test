//
//  EncryptUtil.m
//  JdshAPI
//
//  Created by sea_buckthorn on 2017/7/23.
//  Copyright © 2017年 Jdsh. All rights reserved.
//

#import "EncryptUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>

@implementation EncryptUtil

+ (NSString *)encrypt:(NSString *)plain {
    NSString *md5 = [EncryptUtil MD5Encode:plain];
    
    NSMutableString *encrypted = [NSMutableString string];
    for (int i = 0; i < 5; i++) {
        int index = pow(2, i+1);
        [encrypted appendFormat:@"%c", [md5 characterAtIndex:index-1]];
    }
    
    return encrypted;
}

+ (NSData *)decrypt:(NSData *)cipher {
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:cipher.length + kCCBlockSizeAES128];
    NSString *key = @"jdshkeyirproduct";
    NSString *iv = @"jdsh.ivirproduct";
    
    char keyPtr[kCCKeySizeAES128 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCBlockSizeAES128 + 1];
    bzero(ivPtr, sizeof(ivPtr));
    if (iv) {
        [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    }
    
    ccStatus = CCCrypt( kCCDecrypt, // kCCEncrypt or kCCDecrypt
                       kCCAlgorithmAES,
                       0x0000,
                       keyPtr,
                       kCCBlockSizeAES128,
                       ivPtr,
                       cipher.bytes,
                       cipher.length,
                       dataOut.mutableBytes,
                       dataOut.length,
                       &cryptBytes);
    
    dataOut.length = cryptBytes;
    
    return dataOut;
}

+ (NSString *)MD5Encode:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
}

@end
