//
//  ViewController.m
//  wq
//
//  Created by kaixin on 2017/3/28.
//  Copyright © 2017年 kaixin. All rights reserved.
//
 #define NSEaseLocalizedString(key, comment) [[NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"EaseUIResource" withExtension:@"bundle"]] localizedStringForKey:(key) value:@"" table:nil]
#define kSetValueForKey(value,key) if (value)[paraDic setObject:value forKey:key]
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DeviceHelper-master/VoiceConvert/EMVoiceConverter.h"
#import "NetWorkManager.h"
#import "LZUploadParam.h"
#import "EMCDDeviceManager.h"
#import "AudioRecord.h"
@interface ViewController ()<AVAudioRecorderDelegate,AVAudioPlayerDelegate>
{
    AVAudioRecorder *recorder;//录音
    AVAudioPlayer *play;//播放
    
    
    
    AudioRecord *record;
}
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic)   AVAudioPlayer    *player;
@property (strong, nonatomic)   NSString         *recordFileName;
@property (strong, nonatomic)   NSString         *recordFilePath;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.player=[[AVAudioPlayer alloc]init];
    _label.text=@"哈哈放寒假啊三家分18864458996晋福克斯卡夫卡师傅的说法快";
    _label.lineBreakMode=NSLineBreakByCharWrapping;
    _label.numberOfLines=0;
}
- (IBAction)Record:(UIButton *)sender {
   
    //[self initRecord];
    record=[AudioRecord shareAudioRecord];
    [record canRecord];
    [record onStatrRecord];
    //http://yigangweb.cyweb.net/api//upload/imgupload/5b935a3b4c80ff0dd2a5bf3e6aab89de.aac?kwWilA
}
- (IBAction)play:(UIButton *)sender {

//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://yigangweb.cyweb.net/api//upload/imgupload/93cb5920e819c3f0245f2d83c5e4b89f.amr?WyPTOH"]];
//    //    //把data写入文件中，取名AudioTempFile
//    self.recordFileName=[ViewController GetCurrentTimeString];
//    NSString *amrPath = [ViewController GetPathByFileName:self.recordFileName ofType:@"amr"];
//    [data writeToFile:amrPath atomically:YES];
//    NSLog(@"path----%@",amrPath);
//    // 如果本地语音文件不存在，使用服务器语音
//     [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:@"https://a1.easemob.com/784799679/paocai/chatfiles/371564b0-152d-11e7-a35e-efc41bb7a087" completion:^(NSError *error) {
//        
//        NSLog(@"语音播放完成 %@",error);
//        // 移除动画
//       
//    }];
    
    
}
//网络请求
- (void)requestDataWithFileName:(NSString*)fileName{
    NSMutableDictionary *paraDic=[[NSMutableDictionary alloc]init];
    kSetValueForKey(@"2", @"typeid");
    kSetValueForKey(@"0", @"quantity");
    kSetValueForKey(@"6482XnCATN81eFT+lqK0/9ZH2+5eQwqfj2SMOKKAXaAqKA", @"user_id");
    kSetValueForKey(@"0", @"is_dazong");
    //获取录音时长
    AVURLAsset* audioAsset =[AVURLAsset URLAssetWithURL:[NSURL URLWithString:fileName] options:nil];
    CMTime audioDuration = audioAsset.duration;
    float audioDurationSeconds =CMTimeGetSeconds(audioDuration);
    kSetValueForKey(@(audioDurationSeconds), @"quantity");
    kSetValueForKey(fileName, @"content");
    
    [NetWorkManager post:@"app=default&act=send_xuqiu" params:paraDic success:^(NSURLSessionDataTask *task, id responseBody) {
        
        NSLog(@"response===%@",responseBody);
       
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}


-(void)uploadFileRequestWithData:(NSArray*)dataArr{
    LZUploadParam *model=[[LZUploadParam alloc]init];
    model.fileArr=dataArr;
    model.name=@"files[]";
    //model.data=data;
    //语音
    model.fileName=@"sound1.aac";
    model.mimeType=@"sound/mp3/amr/aac";
    [[NetWorkManager sharedManager] upLoadFileWithModel:model Parameter:@{} Url:@"app=backend.setting&act=uploadfile" Progress:nil successBlock:^(NSURLSessionDataTask *task, id responseBody) {
        //上传成功，获得文件路径
        NSLog(@"responsePathWWWWW===%@",responseBody);
        
    } failureBlock:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
}

- (IBAction)Stop:(UIButton *)sender {
    NSData *data=[record getRecord];
    NSLog(@"amrPath---%@---%@",self.recordFilePath,data);
    NSArray *dataArr=[NSArray arrayWithObjects:data, nil];
    [self uploadFileRequestWithData:dataArr];
    
    
//    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
//        if (!error) {
//            //获取到的录音地址，自己存起来。也可以写入FileManage中，这里我写入了沙盒中。
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.recordFilePath]];
//                NSLog(@"amrPath---%@---%@",self.recordFilePath,data);
//                NSArray *dataArr=[NSArray arrayWithObjects:data, nil];
//                [self uploadFileRequestWithData:dataArr];
//            });
//        }
//    }];
//    [recorder stop];

    [record stopRecord];
}

//结束录制
- (void)endPress {
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    play = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:self.recordFilePath] error:nil];
    [play play];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.recordFilePath]];
    NSLog(@"amrPath---%@---%@",self.recordFilePath,data);
    NSArray *dataArr=[NSArray arrayWithObjects:data, nil];
    [self uploadFileRequestWithData:dataArr];
    //转换格式
    NSDate *date = [NSDate date];
    NSString *amrPath = [ViewController GetPathByFileName:self.recordFileName ofType:@"amr"];
    if ([EMVoiceConverter wavToAmr:self.recordFilePath amrSavePath:amrPath]){
        //设置label信息
        
        date = [NSDate date];
        NSString *convertedPath = [ViewController GetPathByFileName:[self.recordFileName stringByAppendingString:@"_AmrToWav"] ofType:@"wav"];
        //上传
//        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.recordFilePath]];
//        NSArray *dataArr=[NSArray arrayWithObjects:data, nil];
//        [self uploadFileRequestWithData:dataArr];
        NSLog(@"data===%@",dataArr);
        //    NSArray *dataArr=[NSArray arrayWithObject:data];
        //    [self uploadFileRequestWithData:dataArr];
#warning amr转wav
        if ([EMVoiceConverter amrToWav:amrPath wavSavePath:convertedPath]){
            //设置label信息
            NSLog(@"amr转wav成功");
        }else
            NSLog(@"amr转wav失败");
        
    }else{
        NSLog(@"wav转amr失败");
    }

//    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
//        if ([uploadType isEqualToString:@"2"]) {//发布语音
//            if ([Default_FileManager fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingString:@"RecordedFile"]]) {
//                //上传文件
//                NSData *data=[NSData dataWithContentsOfURL:recordedFile];
//                NSArray *dataArr=[NSArray arrayWithObjects:data, nil];
//                [self uploadFileRequestWithData:dataArr];
//            }else{
//                [KPublicTool showAlertWithController:self WithMsg:@"发布内容不能为空！"];
//            }
//        }
//        
//    }];
    
    
    
}
-(void)initRecord{
    
    //根据当前时间生成文件名
    self.recordFileName = [ViewController GetCurrentTimeString];
    NSLog(@"initPath===%@",self.recordFilePath);
    //获取路径
    self.recordFilePath = [ViewController GetPathByFileName:self.recordFileName ofType:@"wav"];
//    recorder=[[AVAudioRecorder alloc]initWithURL:[NSURL URLWithString:self.recordFilePath] settings:nil error:nil];
////    [recorder prepareToRecord];
////    recorder.delegate=self;
//    recorder.meteringEnabled=YES;//如果要监控声波则必须设置为YES
//    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
//    [[AVAudioSession sharedInstance] setActive:YES error:nil];
//    [recorder record];
    //开启定时器，音量监测
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc]init];
    //设置录音格式
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    //设置录音采样率(Hz) 如：AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:44100] forKey:AVSampleRateKey];
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];

    recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:self.recordFilePath] settings:recordSetting error:nil];
    //准备录音
    [recorder record];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:self.recordFilePath completion:^(NSError *error)
     {
         if (error) {
             NSLog(@"%@",NSEaseLocalizedString(@"message.startRecordFail", @"failure to start recording"));
         }
         
     }];
}
+ (NSString*)GetPathByFileName:(NSString *)_fileName ofType:(NSString *)_type{
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];;
    NSString* fileDirectory = [[[directory stringByAppendingPathComponent:_fileName]
                                stringByAppendingPathExtension:_type]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"fildPath===%@",fileDirectory);
    return fileDirectory;
}
+ (NSString*)GetCurrentTimeString{
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
