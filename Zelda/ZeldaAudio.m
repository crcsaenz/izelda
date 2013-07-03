//
//  ZeldaAudio.m
//  Zelda
//
//  Created by Cassidy Saenz on 6/3/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ZeldaAudio.h"


#define MAX_VOLUME 1.0

#define FADE_THRESHOLD 0.01
#define AUDIO_FADE_RATE 0.01
#define AUDIO_FADE_TIME 0.001


@interface ZeldaAudio ()

@end


@implementation ZeldaAudio

+ (AVAudioPlayer *)audioPlayerWithFileName:(NSString *)fileName
{
    NSURL *url = [ZeldaAudio fileURLWithFileName:fileName];
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player.volume = MAX_VOLUME;
    [player prepareToPlay];
    return player;
}

+ (void)playAudioPlayer:(AVAudioPlayer *)player
{
    if (player != nil) {
        player.volume = MAX_VOLUME;
        [player play];
    }
}

+ (void)fadeOutAudioPlayer:(NSDictionary *)playerDict
{
    AVAudioPlayer *player = [playerDict objectForKey:@"player"];
    BOOL restart = [[playerDict objectForKey:@"restart"] doubleValue];
    if (player.volume > FADE_THRESHOLD) {
        player.volume = player.volume - AUDIO_FADE_RATE;
        [self performSelector:@selector(fadeOutAudioPlayer:)
                   withObject:playerDict
                   afterDelay:AUDIO_FADE_TIME];
    } else {
        [player pause];
        if (restart)
            player.currentTime = 0.0;
    }
}

+ (void)stopAudioPlayer:(AVAudioPlayer *)player withFadeOut:(BOOL)fade restart:(BOOL)restart
{
    if (player != nil) {
        // store args in NSDictionary to pass to "recursive" performSelector: when fading
        NSDictionary *playerDict = [[NSDictionary alloc] initWithObjectsAndKeys:player,@"player",[NSNumber numberWithBool:restart],@"restart", nil];
        if (fade) {
            [ZeldaAudio fadeOutAudioPlayer:playerDict];
        } else {
            [player pause];
            if (restart)
                player.currentTime = 0.0;
        }
    }
}

+ (AVAudioRecorder *)audioRecorderWithFileName:(NSString *)fileName
                                recordSettings:(NSDictionary *)settings
{
    NSURL *url = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                        inDomain:NSUserDomainMask
                                               appropriateForURL:nil
                                                          create:YES
                                                           error:NULL];
    url = [url URLByAppendingPathComponent:fileName];
    
    AVAudioRecorder *audioRecorder = [[AVAudioRecorder alloc] initWithURL:url
                                                     settings:settings
                                                        error:nil];
    [audioRecorder prepareToRecord];
    
    return audioRecorder;
}

+ (void)startAudioRecorder:(AVAudioRecorder *)recorder
{
    if (recorder != nil) {
        [recorder record];
    }
}

+ (void)stopAudioRecorder:(AVAudioRecorder *)recorder
{
    if (recorder != nil) {
        [recorder stop];
        [recorder deleteRecording];
    }
}

+ (NSURL *)fileURLWithFileName:(NSString *)fileName
{
    NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], fileName]];
    return url;
}

@end
