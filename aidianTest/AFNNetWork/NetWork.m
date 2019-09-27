//
//  NetWork.m
//  agintodeom
//
//  Created by apple on 2017/11/18.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "NetWork.h"
//#import "HBRSAHandler.h"
#import "AFNetworking.h"

#import "EncryptUtil.h"
//#import "EncryptTool.h"

#define BaseURL   @"http://www.pertietech.com"
 

static NetWork *manager = nil;
static AFHTTPSessionManager *afnManager = nil;

@implementation NetWork

+ (instancetype)sharedInstance {
    
    
    // 也可以使用一次性代码
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NetWork alloc] init];
        afnManager = [AFHTTPSessionManager manager];
        afnManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return manager;
    
}


/**
 *  提示信息
 *
 *  @param message 要提示的内容
 */
+ (void)showAlertViewWithMessage:(NSString *)message {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}
//GET请求
- (void)getDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure {
    
    /**
     *  可以接受的类型
     */
    afnManager.responseSerializer = [AFJSONResponseSerializer serializer];
    //设置请求超时的时间
    [afnManager.requestSerializer setTimeoutInterval:20.0];
    
    [afnManager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    [afnManager.requestSerializer setValue:[self getToken] forHTTPHeaderField:@"ywj_out_token"];
    
    //请求地址
    NSString * URLStr = [NSString stringWithFormat:@"http://120.55.182.83:8088/out/ywj/%@",url];
    if ([url isEqualToString:@"getVerifyCode.json"]) {
        URLStr = [NSString stringWithFormat:@"http://120.55.182.83:8088/out/%@",url];
    }
    /**
     *  请求队列的最大并发数
     */
    //    manager.operationQueue.maxConcurrentOperationCount = 5;
    
    // 仅仅是取消请求, 不会关闭session
    //    [afnManager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    NSMutableString * bodyStr = [NSMutableString string];
    if (paramters) {
        [paramters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            //            [bodyStr componentsSeparatedByString:@"="];
            
            [bodyStr appendString:key];
            [bodyStr appendString:@"="];
            [bodyStr appendString:obj];
            [bodyStr appendString:@"&"];
        }];
        NSString * str = [bodyStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"?!@#$^&%*+,:;='\"`<>()[]{}/\\| "]];
        URLStr = [NSString stringWithFormat:@"%@?%@",URLStr,str];
    }
    [afnManager GET:URLStr parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//        <#code#>
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        [MBProgressHUD hide];
        if (responseObject) {
            success(task,responseObject);
        }else {
            //            [[self class] showAlertViewWithMessage:@"暂无数据"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            //            [[self class] showAlertViewWithMessage:@"服务器出错了~~~~(>_<)~~~~"];
//            NSError *underError = error.userInfo[@"NSUnderlyingError"];
//            NSData *responseData = underError.userInfo[@"com.alamofire.serialization.response.error.data"];
//            NSString *result = [[NSString alloc] initWithData:responseData  encoding:NSUTF8StringEncoding];
//            NSString * str = error.userInfo[@"NSLocalizedDescription"];
            //失败
//            [MBProgressHUD showImage:kMBProgressHUDImageFail text:str];
            failure(error);
        }
    }];
     
}

//POST请求
- (void)postDataWithUrl:(NSString *)url parameters:(NSDictionary *)paramters success:(Success)success failure:(Failure)failure {
    
    afnManager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //设置请求超时的时间
    [afnManager.requestSerializer setTimeoutInterval:20.0];
    
    [afnManager.requestSerializer setValue:@"application/x-www-form-urlencoded;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    afnManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/html",@"image/png",@"text/html;charset=UTF-8",@"text/plain", nil];
    afnManager.responseSerializer.acceptableContentTypes = [afnManager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-www-form-urlencoded"];
    NSString * token = [self getToken];
    [afnManager.requestSerializer setValue:token forHTTPHeaderField:@"ywj_out_token"];
    
    // 仅仅是取消请求, 不会关闭session
    //    [afnManager.tasks makeObjectsPerformSelector:@selector(cancel)];
    //请求地址
    NSString * URLStr = [NSString stringWithFormat:@"%@/%@",BaseURL, url];
    
    [afnManager POST:URLStr parameters:paramters constructingBodyWithBlock:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        if (responseObject) {
            success(task,responseObject);
//        }else {
//            [[self class] showAlertViewWithMessage:@"暂无数据"];
//        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (error) {
            //            [[self class] showAlertViewWithMessage:@"服务器出错了~~~~(>_<)~~~~"];
//            NSError *underError = error.userInfo[@"NSUnderlyingError"];
//            NSData *responseData = underError.userInfo[@"com.alamofire.serialization.response.error.data"];
//            NSString *result = [[NSString alloc] initWithData:responseData  encoding:NSUTF8StringEncoding];
//            NSString * str = error.userInfo[@"NSLocalizedDescription"];
//            //失败
//            [MBProgressHUD showImage:kMBProgressHUDImageFail text:str];
            failure(error);
        }
    }];
    
}


#pragma mark -
- (NSString *)getToken{
    int num = (arc4random() % 1000000);
//    num = 123456;
    NSString * randomNumber = [NSString stringWithFormat:@"%.6d", num];
    
    //    NSString* enString = [handler encryptWithPublicKey:randomNumber];
    
//    NSString * enString = [[EncryptTool shareInstance] encrypt:randomNumber type:eKeyTypePublic];
    NSString * enString ;
    NSString * ywj_out_token = [NSString stringWithFormat:@"%@_%@",randomNumber,enString];
    
    NSString *str = ywj_out_token;
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return str;
}
@end
