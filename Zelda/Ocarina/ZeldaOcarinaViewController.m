//
//  ZeldaOcarinaViewController.m
//  Zelda
//
//  Created by Cassidy Saenz on 5/31/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ZeldaOcarinaViewController.h"
#import "ZeldaAudio.h"
#import "UIView+Fade.h"

#define RECORDER_SAMPLE_RATE 44100.0
#define RECORDER_CHANNELS 1
#define RECORDER_BIT_RATE 16

#define MIC_SAMPLE_RATE 1000.0
#define MIC_POWER_WEIGHT 0.05
#define MIC_THRESHOLD 0.4

#define SLOW_FADE_DURATION 2.0
#define FAST_FADE_DURATION 1.0
#define FASTER_FADE_DURATION 0.5

#define OCARINA_NOTE_FILE_1 @"OcarinaNote1.mp3"
#define OCARINA_NOTE_FILE_2 @"OcarinaNote2.mp3"
#define OCARINA_NOTE_FILE_3 @"OcarinaNote3.mp3"
#define OCARINA_NOTE_FILE_4 @"OcarinaNote4.mp3"
#define OCARINA_NOTE_FILE_5 @"OcarinaNote5.mp3"


@interface ZeldaOcarinaViewController () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIButton *noteButton1;
@property (weak, nonatomic) IBOutlet UIButton *noteButton2;
@property (weak, nonatomic) IBOutlet UIButton *noteButton3;
@property (weak, nonatomic) IBOutlet UIButton *noteButton4;
@property (weak, nonatomic) NSString *noteFile;
@property (weak, nonatomic) NSTimer *recordingTimer;
@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AVAudioPlayer *notePlayer1;
@property (strong, nonatomic) AVAudioPlayer *notePlayer2;
@property (strong, nonatomic) AVAudioPlayer *notePlayer3;
@property (strong, nonatomic) AVAudioPlayer *notePlayer4;
@property (strong, nonatomic) AVAudioPlayer *notePlayer5;
@property (nonatomic) BOOL noteDidChange;

@end


@implementation ZeldaOcarinaViewController

@synthesize backgroundImageView = _backgroundImageView;
@synthesize playButton = _playButton;
@synthesize stopButton = _stopButton;
@synthesize noteButton1 = _noteButton1;
@synthesize noteButton2 = _noteButton2;
@synthesize noteButton3 = _noteButton3;
@synthesize noteButton4 = _noteButton4;
@synthesize noteFile = _noteFile;
@synthesize recordingTimer = _recordingTimer;
@synthesize audioRecorder = _audioRecorder;
@synthesize audioPlayer = _audioPlayer;
@synthesize notePlayer1 = _notePlayer1;
@synthesize notePlayer2 = _notePlayer2;
@synthesize notePlayer3 = _notePlayer3;
@synthesize notePlayer4 = _notePlayer4;
@synthesize notePlayer5 = _notePlayer5;
@synthesize noteDidChange = _noteDidChange;


#pragma mark - Target/Action

- (IBAction)play:(UIButton *)sender
{
    if (!self.audioRecorder.recording) {
        [ZeldaAudio startAudioRecorder:self.audioRecorder];
        self.playButton.enabled = NO;
        self.stopButton.enabled = YES;
        [self startRecordingTimer];
    }
}

- (IBAction)stop:(UIButton *)sender
{
    self.playButton.enabled = YES;
    self.stopButton.enabled = NO;
    
    if (self.audioRecorder.recording)
        [ZeldaAudio stopAudioRecorder:self.audioRecorder];
    if (self.audioPlayer.playing)
        [ZeldaAudio stopAudioPlayer:self.audioPlayer withFadeOut:YES restart:YES];
    
    [self stopRecordingTimer];
}

- (IBAction)notePressed:(UIButton *)sender
{
    self.noteDidChange = YES;
}

#pragma mark - Audio Analysis Methods

- (AVAudioPlayer *)currentNotePlayer
{
    if (self.noteButton1.isHighlighted) {
        return self.notePlayer1;
    } else if (self.noteButton2.isHighlighted) {
        return self.notePlayer2;
    } else if (self.noteButton3.isHighlighted) {
        return self.notePlayer3;
    } else if (self.noteButton4.isHighlighted) {
        return self.notePlayer4;
    } else {
        return self.notePlayer5;
    }
}

- (void)analyzeAudioInput:(NSTimer *)timer
{
    [self.audioRecorder updateMeters];
    float avgPowerForChannel = pow(10, (MIC_POWER_WEIGHT * [self.audioRecorder averagePowerForChannel:0]));
    
    if (avgPowerForChannel > MIC_THRESHOLD) {
        if (!self.audioPlayer.playing) {
            self.audioPlayer = [self currentNotePlayer];
            [ZeldaAudio playAudioPlayer:self.audioPlayer];
        } else {
            if (self.noteDidChange) {
                [ZeldaAudio stopAudioPlayer:self.audioPlayer withFadeOut:YES restart:YES];
                self.audioPlayer = [self currentNotePlayer];
                [ZeldaAudio playAudioPlayer:self.audioPlayer];
            }
        }
    } else {
        if (self.audioPlayer.volume == 1.0)
            [ZeldaAudio stopAudioPlayer:self.audioPlayer withFadeOut:YES restart:YES];
    }
    self.noteDidChange = NO;
}

#pragma mark - Timers

- (void)startRecordingTimer
{
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/MIC_SAMPLE_RATE target:self selector:@selector(analyzeAudioInput:) userInfo:nil repeats:YES];
}

- (void)stopRecordingTimer
{
    [self.recordingTimer invalidate];
    self.recordingTimer = nil;
}

#pragma mark - AVAudioPlayerDelegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [ZeldaAudio stopAudioPlayer:player withFadeOut:YES restart:YES];
}

#pragma mark - View Controller Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // set up recorder
    NSDictionary *recordSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:AVAudioQualityMin], AVEncoderAudioQualityKey,
                                    [NSNumber numberWithInt:RECORDER_BIT_RATE], AVEncoderBitRateKey,
                                    [NSNumber numberWithInt: RECORDER_CHANNELS], AVNumberOfChannelsKey,
                                    [NSNumber numberWithFloat:RECORDER_SAMPLE_RATE], AVSampleRateKey,
                                    nil];
    self.audioRecorder = [ZeldaAudio audioRecorderWithFileName:@"ocarina.caf" recordSettings:recordSettings];
    self.audioRecorder.meteringEnabled = YES;
    self.audioRecorder.delegate = self;
    
    self.noteFile = OCARINA_NOTE_FILE_5;
    
    // load noteplayers
    self.notePlayer1 = [ZeldaAudio audioPlayerWithFileName:OCARINA_NOTE_FILE_1];
    self.notePlayer2 = [ZeldaAudio audioPlayerWithFileName:OCARINA_NOTE_FILE_2];
    self.notePlayer3 = [ZeldaAudio audioPlayerWithFileName:OCARINA_NOTE_FILE_3];
    self.notePlayer4 = [ZeldaAudio audioPlayerWithFileName:OCARINA_NOTE_FILE_4];
    self.notePlayer5 = [ZeldaAudio audioPlayerWithFileName:OCARINA_NOTE_FILE_5];
    
    self.stopButton.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView fadeInView:self.backgroundImageView withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.playButton withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.stopButton withTimeInterval:FAST_FADE_DURATION];
}

- (void)viewDidUnload
{
    [self setPlayButton:nil];
    [self setStopButton:nil];
    [self setBackgroundImageView:nil];
    [self setNoteButton1:nil];
    [self setNoteButton2:nil];
    [self setNoteButton3:nil];
    [self setNoteButton4:nil];
    [super viewDidUnload];
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
