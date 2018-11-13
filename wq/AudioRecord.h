//
//  AudioRecord.h
//  YiGangWang
//
//  Created by kaixin on 2017/4/28.
//  Copyright © 2017年 开心. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface AudioRecord : NSObject<AVAudioRecorderDelegate, AVAudioPlayerDelegate>
/**
 *  获取单例对象
 *
 *  @return 返回数据库对象
 */
+(AudioRecord *)shareAudioRecord;
-(NSData*)getRecord;
/**
 *  将要录音
 *
 *  @return <#return value description#>
 */
- (BOOL)canRecord;

/**
 *  停止录音
 */
- (void)stopRecord;

/**
 *  开始录音
 */
- (void)onStatrRecord;

/**
 *  初始化音频检查
 */
-(void)initRecordSession;
/**
 *  初始化文件存储路径
 *
 *  @return <#return value description#>
 */
- (NSString *)audioRecordingPath;
/**
 *  录音器
 */
@property (nonatomic, retain) AVAudioRecorder *audioRecorder;
/**
 *  录音播放器
 */
@property (nonatomic, retain) AVAudioPlayer *audioPlayer;
@end
