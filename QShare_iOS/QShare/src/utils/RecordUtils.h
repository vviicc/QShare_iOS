//
//  RecordUtils.h
//  QShare
//
//  Created by Vic on 14-5-15.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ChatVC.h"


@interface RecordUtils : NSObject

{
    //录音器
    AVAudioRecorder *recorder;
    //播放器
    AVAudioPlayer *player;
    NSDictionary *recorderSettingsDict;
    
    //定时器
    NSTimer *timer;
    //图片组
    NSMutableArray *volumImages;
    double lowPassResults;
    
    //录音名字
    NSString *playName;

}

- (void)setupRecordSetting;
- (void)beginRecord:(ChatVC *)chatVC;
- (void)endRecord:(ChatVC *)chatVC;
- (void)playRecord;

@end
