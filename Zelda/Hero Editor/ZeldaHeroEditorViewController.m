//
//  ZeldaHeroEditorViewController.m
//  Zelda
//
//  Created by Cassidy Saenz on 5/31/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ZeldaHeroEditorViewController.h"
#import "ZeldaAudio.h"
#import "UIView+Fade.h"

#define BG_AUDIO_FILE @"MainThemeMedley.mp3"
#define SLOW_FADE_DURATION 2.0

@interface ZeldaHeroEditorViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;
@property (strong, nonatomic) AVAudioPlayer *bgAudioPlayer;

@end


@implementation ZeldaHeroEditorViewController

@synthesize bgImageView = _bgImageView;
@synthesize bgAudioPlayer = _bgAudioPlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    self.bgAudioPlayer = [ZeldaAudio audioPlayerWithFileName:BG_AUDIO_FILE];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView fadeInView:self.bgImageView withTimeInterval:SLOW_FADE_DURATION];
    
    [ZeldaAudio playAudioPlayer:self.bgAudioPlayer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [UIView fadeOutView:self.bgImageView withTimeInterval:SLOW_FADE_DURATION];
    
    [ZeldaAudio stopAudioPlayer:self.bgAudioPlayer withFadeOut:YES restart:NO];
}

- (void)viewDidUnload
{
    [self setBgImageView:nil];
    [super viewDidUnload];
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
