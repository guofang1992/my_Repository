//
//  NetWorkManager.m
//  YiGangWang
//
//  Created by 开心 on 16/11/7.
//  Copyright © 2016年 开心. All rights reserved.
//

#import "NetWorkManager.h"
#define TIMEOUT 10
#define KLog(...) NSLog(__VA_ARGS__)
#define kServerUrl @"http://yigangweb.cyweb.net/api/index.php?"
@implementation NetWorkManager
+(NetWorkManager *)sharedManager{
    static NetWorkManager *sharedNetworkSingleton = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate,^{
        sharedNetworkSingleton = [[self alloc] init];
    });
    return sharedNetworkSingleton;
}
+ (NSString*)getFullPathWithOldPath:(NSString*)path{
    NSString* defaltPath = kServerUrl;
    defaltPath =[defaltPath stringByAppendingString:path];
    return defaltPath;
}
-(AFHTTPSessionManager *)baseHtppRequest{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //header 设置
    [manager.requestSerializer setValue:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] forHTTPHeaderField:@"appversion"];
    //设置返回格式
    AFJSONResponseSerializer *jsonRes = [AFJSONResponseSerializer serializer];
    jsonRes.removesKeysWithNullValues=YES;
    manager.responseSerializer = jsonRes;
    //超时时间
    [manager.requestSerializer setTimeoutInterval:TIMEOUT];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    return manager;
}
#pragma mark - POST
+(void)post:(NSString *)url params:(NSDictionary *)parameter  success:(SuccessBlock)successBlock failure:(FailureBlock)failureBlock{
    [[[self class] sharedManager] postResultWithParameter:parameter url:url progress:nil successBlock:successBlock failureBlock:failureBlock];
}

-(void)postResultWithParameter:(NSDictionary *)parameter url:(NSString *)url  progress:(ProgressBlock)progressBlock successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
    AFHTTPSessionManager *manager  =[self baseHtppRequest];
    NSString* defaltPath = kServerUrl;
    defaltPath =[defaltPath stringByAppendingString:url];
    KLog(@"请求地址:\n%@\n参数:%@",url,parameter);
    [manager POST:defaltPath parameters:parameter progress:^(NSProgress * _Nonnull downloadProgress) {
        if (progressBlock) {
            progressBlock(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        KLog(@"返回结果:\n%@", responseObject);
        if ([responseObject[@"code"] isEqualToString:@"1000"]) {
                if (successBlock) {
                    successBlock(task,responseObject[@"data"]);
                }
        }else{
            NSError *error = [[NSError alloc] initWithDomain:@"self" code:[[responseObject objectForKey:@"code"] intValue] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[responseObject objectForKey:@"message"],NSLocalizedDescriptionKey, nil]];
            failureBlock(task,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        KLog(@"%@\n返回结果:%@",url,[error.userInfo objectForKey:@"NSLocalizedDescription"]);
        if (failureBlock) {
            failureBlock(task,error);
        }
    }];
}
#pragma mark upLoad
-(void)upLoadFileWithModel:(LZUploadParam *)uploadModel Parameter:(NSDictionary *)parameter Url:(NSString *)urlStr  Progress:(ProgressBlock)progressBlock
              successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
    AFHTTPSessionManager *manager = [self baseHtppRequest];
    NSString* defaltPath = kServerUrl;
    defaltPath =[defaltPath stringByAppendingString:urlStr];
    [manager POST:defaltPath parameters:parameter constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (int i=0; i<uploadModel.fileArr.count; i++) {
         [formData appendPartWithFileData:uploadModel.fileArr[i] name:uploadModel.name fileName:[NSString stringWithFormat:@"%ld%@",random(),uploadModel.fileName] mimeType:uploadModel.mimeType];
        }

    } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"code"] isEqualToString:@"1000"]) {
            if (successBlock) {
                successBlock(task,responseObject[@"data"]);
            }
        }else{
            NSError *error = [[NSError alloc] initWithDomain:@"self" code:[[responseObject objectForKey:@"code"] intValue] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[responseObject objectForKey:@"message"],NSLocalizedDescriptionKey, nil]];
            failureBlock(task,error);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(task,error);
        
        }
    }];

}

@end
