//
//  ZeldaAudio.h
//  Zelda
//
//  Created by Cassidy Saenz on 6/3/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface ZeldaAudio : NSObject

+ (AVAudioPlayer *)audioPlayerWithFileName:(NSString *)fileName;
+ (void)playAudioPlayer:(AVAudioPlayer *)player;
+ (void)stopAudioPlayer:(AVAudioPlayer *)player withFadeOut:(BOOL)fade restart:(BOOL)restart;

+ (AVAudioRecorder *)audioRecorderWithFileName:(NSString *)fileName
                                recordSettings:(NSDictionary *)settings;
+ (void)startAudioRecorder:(AVAudioRecorder *)recorder;
+ (void)stopAudioRecorder:(AVAudioRecorder *)recorder;

+ (NSURL *)fileURLWithFileName:(NSString *)fileName;

@end
