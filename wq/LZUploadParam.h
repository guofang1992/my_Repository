//
//  LZUploadParam.h
//  YiGangWang
//
//  Created by 开心 on 16/12/10.
//  Copyright © 2016年 开心. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LZUploadParam : NSObject
@property (nonatomic, strong) NSData *data;//二进制数据
@property (nonatomic, copy) NSString *name;//名称
@property (nonatomic, copy) NSString *fileName;//文件名称
@property (nonatomic, copy) NSString *mimeType;//文件类型(e.g image/jpeg video/mp4)
@property (nonatomic, copy) NSString *filePath;//文件地址
@property (nonatomic, copy) NSArray *fileArr;//文件数组
@end
