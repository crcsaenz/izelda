//
//  ZeldaQuestLogViewController.m
//  Zelda
//
//  Created by Cassidy Saenz on 5/31/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ZeldaQuestLogViewController.h"
#import "ZeldaHeroViewController.h"
#import "ZeldaDodongoBombViewController.h"
#import "ZeldaAudio.h"
#import "UIView+Fade.h"

#define DEFAULT_ZOOM_SCALE 1.0
#define DEFAULT_MIN_ZOOM 1.0
#define DEFAULT_MAX_ZOOM 1.0

#define BACKGROUND_MOVE_RATE 15.0
#define BACKGROUND_MOVE_DELTA 1.0

#define LOGO_DELAY 5.0
#define BUTTON_DELAY 17.0

#define SLOW_FADE_DURATION 2.0
#define FAST_FADE_DURATION 1.0
#define FASTER_FADE_DURATION 0.5

#define BG_AUDIO_FILE @"FairyFountainGuitar.mp3"

#define EMPTY_FILE_STRING @"Create New File"

#define QUEST_LOG_SEGUE_ID @"Play Quest Log"
#define CREATE_FILE_SEGUE_ID @"Create New File"
#define HERO_DATA_NAME_KEY @"Hero Name"
#define HERO_DATA_IMAGE_PATH_KEY @"ImagePath"
#define HERO_DATA_HIGH_SCORE_KEY @"High Score"
#define HERO_DATA_QUEST_NUM_KEY @"Quest Number"


@interface ZeldaQuestLogViewController () <ZeldaHeroViewControllerDelegate, ZeldaDodongoBombViewControllerDelegate, UIScrollViewDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *startLabel;
@property (weak, nonatomic) IBOutlet UIButton *file1LabelButton;
@property (weak, nonatomic) IBOutlet UIButton *file2LabelButton;
@property (weak, nonatomic) IBOutlet UIButton *file3LabelButton;
@property (weak, nonatomic) IBOutlet UIButton *file1Button;
@property (weak, nonatomic) IBOutlet UIButton *file2Button;
@property (weak, nonatomic) IBOutlet UIButton *file3Button;
@property (weak, nonatomic) IBOutlet UIButton *clearLogsButton;
@property (weak, nonatomic) NSTimer *backgroundTimer;
@property (weak, nonatomic) NSTimer *logoTimer;
@property (weak, nonatomic) NSTimer *buttonTimer;
@property (strong, nonatomic) AVAudioPlayer *bgAudioPlayer;

@end


@implementation ZeldaQuestLogViewController

@synthesize scrollView = _scrollView;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize startLabel = _startLabel;
@synthesize file1LabelButton = _file1LabelButton;
@synthesize file2LabelButton = _file2LabelButton;
@synthesize file3LabelButton = _file3LabelButton;
@synthesize logoImageView = _logoImageView;
@synthesize file1Button = _file1Button;
@synthesize file2Button = _file2Button;
@synthesize file3Button = _file3Button;
@synthesize clearLogsButton = _clearLogsButton;
@synthesize backgroundTimer = _backgroundTimer;
@synthesize logoTimer = _logoTimer;
@synthesize buttonTimer = _buttonTimer;
@synthesize bgAudioPlayer = _bgAudioPlayer;

- (void)determineImageZoom
{
    CGSize imageSize = self.backgroundImageView.image.size;
    CGFloat imageAspect = imageSize.width / imageSize.height;
    CGSize scrollViewSize = self.scrollView.bounds.size;
    CGFloat scrollViewAspect = scrollViewSize.width / scrollViewSize.height;
    CGFloat scale;
    // determine current zoom
    if (imageAspect > scrollViewAspect) {
        scale = scrollViewSize.height / imageSize.height;
    } else {
        scale = scrollViewSize.width / imageSize.width;
    }
    self.scrollView.zoomScale = scale;
    self.scrollView.minimumZoomScale = scale;
    self.scrollView.maximumZoomScale = scale;
}

#pragma mark - Animations

- (void)moveBackgroundImage:(NSTimer *)timer
{
    // move until at end of background image
    if (self.scrollView.contentOffset.x + self.scrollView.frame.size.width < self.scrollView.contentSize.width - 1) {
        CGPoint contentOffset = CGPointMake(self.scrollView.contentOffset.x + BACKGROUND_MOVE_DELTA, self.scrollView.contentOffset.y);
        self.scrollView.contentOffset = contentOffset;
    } else {
        // allow scrolling once first pass is done;
        self.scrollView.scrollEnabled = YES;
    }
}

- (void)fadeInLogo:(NSTimer *)timer
{
    [UIView fadeInView:self.logoImageView withTimeInterval:FAST_FADE_DURATION];
    // no need for logoTimer anymore
    [self stopLogoTimer];
}

- (void)fadeInButtons:(NSTimer *)timer
{
    if (self.startLabel.alpha > 0.0) {
        [UIView fadeOutView:self.startLabel withTimeInterval:FASTER_FADE_DURATION];
    }
    [UIView fadeInView:self.file1LabelButton withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.file1Button withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.file2LabelButton withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.file2Button withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.file3LabelButton withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.file3Button withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.clearLogsButton withTimeInterval:FAST_FADE_DURATION];
    // no need for buttonTimer anymore
    [self stopButtonTimer];
}

- (void)fadeOutButtons
{
    [UIView fadeOutView:self.file1LabelButton withTimeInterval:FASTER_FADE_DURATION];
    [UIView fadeOutView:self.file1Button withTimeInterval:FASTER_FADE_DURATION];
    [UIView fadeOutView:self.file2LabelButton withTimeInterval:FASTER_FADE_DURATION];
    [UIView fadeOutView:self.file2Button withTimeInterval:FASTER_FADE_DURATION];
    [UIView fadeOutView:self.file3LabelButton withTimeInterval:FASTER_FADE_DURATION];
    [UIView fadeOutView:self.file3Button withTimeInterval:FASTER_FADE_DURATION];
    [UIView fadeOutView:self.clearLogsButton withTimeInterval:FASTER_FADE_DURATION];
}

#pragma mark - Timers

- (void)startBackgroundTimer
{
    self.backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/BACKGROUND_MOVE_RATE
                                                   target:self
                                                 selector:@selector(moveBackgroundImage:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void)stopBackgroundTimer
{
    [self.backgroundTimer invalidate];
    self.backgroundTimer = nil;
}

- (void)startLogoTimer
{
    self.logoTimer = [NSTimer scheduledTimerWithTimeInterval:LOGO_DELAY
                                                      target:self
                                                    selector:@selector(fadeInLogo:)
                                                    userInfo:nil
                                                     repeats:NO];
}

- (void)stopLogoTimer
{
    [self.logoTimer invalidate];
    self.logoTimer = nil;
}

- (void)startButtonTimer
{
    self.buttonTimer = [NSTimer scheduledTimerWithTimeInterval:BUTTON_DELAY
                                                        target:self
                                                      selector:@selector(fadeInButtons:)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (void)stopButtonTimer
{
    [self.buttonTimer invalidate];
    self.buttonTimer = nil;
}

#pragma mark - Target/Action

- (IBAction)playQuestLog:(UIButton *)sender
{
    if ([sender.titleLabel.text isEqualToString:EMPTY_FILE_STRING]) {
        [self performSegueWithIdentifier:CREATE_FILE_SEGUE_ID sender:sender];
    } else {
        // pass hero data to prepareForSegue
        int tag = sender.tag;
        NSString *heroKey = [NSString stringWithFormat:@"Hero%d",tag];
        NSMutableDictionary *heroData = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:heroKey] mutableCopy];
        [heroData setObject:[NSNumber numberWithInt:sender.tag] forKey:HERO_DATA_QUEST_NUM_KEY];
        [self performSegueWithIdentifier:QUEST_LOG_SEGUE_ID sender:heroData];
    }
}

- (IBAction)clearLogs
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Hero1"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Hero2"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Hero3"];
    [self setFileButtonText];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:CREATE_FILE_SEGUE_ID]) {
        // ask user for name and hero image
        ZeldaHeroViewController *zeldaHeroVC = (ZeldaHeroViewController *)segue.destinationViewController;
        zeldaHeroVC.questNumber = ((UIButton *)sender).tag;
        zeldaHeroVC.delegate = self;
    } else if ([segue.identifier isEqualToString:QUEST_LOG_SEGUE_ID]) {
        NSDictionary *data = (NSDictionary *)sender;
        if ([segue.destinationViewController isKindOfClass:[ZeldaDodongoBombViewController class]]) {
            ZeldaDodongoBombViewController *zdbVC = (ZeldaDodongoBombViewController *)segue.destinationViewController;
            zdbVC.heroName = [data objectForKey:HERO_DATA_NAME_KEY];
            zdbVC.heroPictureUrl = [NSURL fileURLWithPath:[data objectForKey:HERO_DATA_IMAGE_PATH_KEY]];
            zdbVC.highScore = [[data objectForKey:HERO_DATA_HIGH_SCORE_KEY] intValue];
            zdbVC.questNumber = [[data objectForKey:HERO_DATA_QUEST_NUM_KEY] intValue];
            zdbVC.delegate = self;
        }
    }
}

#pragma mark - ZeldaHeroViewControllerDelegate Methods

- (void)zeldaHeroViewControllerDidCancel:(ZeldaHeroViewController *)zeldaHeroVC
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)zeldaHeroViewController:(ZeldaHeroViewController *)zeldaHeroVC
                  didChooseName:(NSString *)name
                    andImageUrl:(NSURL *)imageUrl
                 forQuestNumber:(int)qNum
{
    [self dismissModalViewControllerAnimated:YES];
    
    // update NSUserDefaults with name and imageUrl data
    NSString *heroKey = [NSString stringWithFormat:@"Hero%d",qNum];
    NSMutableDictionary *heroData = [[NSMutableDictionary alloc] init];
    [heroData setObject:name forKey:HERO_DATA_NAME_KEY];
    [heroData setObject:[imageUrl path] forKey:HERO_DATA_IMAGE_PATH_KEY];
    [heroData setObject:[NSNumber numberWithInt:0] forKey:HERO_DATA_HIGH_SCORE_KEY];
    
    [[NSUserDefaults standardUserDefaults] setObject:[heroData copy] forKey:heroKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // pass hero data to prepareForSegue
    [heroData setObject:[NSNumber numberWithInt:qNum] forKey:HERO_DATA_QUEST_NUM_KEY];
    
    [self performSegueWithIdentifier:QUEST_LOG_SEGUE_ID sender:heroData];
}

#pragma mark - ZeldaDodongoBombViewControllerDelegate Methods

- (void)zeldaDodongoBombViewController:(ZeldaDodongoBombViewController *)zdbVC
                 didFinishGameWithData:(NSDictionary *)data
                        forQuestNumber:(int)qNum
{
    // update NSUserDefaults with high score data
    NSString *heroKey = [NSString stringWithFormat:@"Hero%d",qNum];
    NSMutableDictionary *heroData = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:heroKey] mutableCopy];
    [heroData setObject:[data objectForKey:HERO_DATA_HIGH_SCORE_KEY] forKey:HERO_DATA_HIGH_SCORE_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[heroData copy] forKey:heroKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // update text for file buttons
    [self setFileButtonText];
}

#pragma mark - AVAudioPlayerDelegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (player == self.bgAudioPlayer && flag)
        [ZeldaAudio playAudioPlayer:player];
    else
        [ZeldaAudio stopAudioPlayer:player withFadeOut:YES restart:YES];
}

#pragma mark - UIScrollViewDelegate Methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.backgroundImageView;
}

#pragma mark - Tap Gesture

- (void)tapToStart
{
    if (self.buttonTimer) {
        if (self.logoTimer) {
            [self fadeInLogo:nil];
            [UIView fadeOutView:self.startLabel withTimeInterval:FASTER_FADE_DURATION];
            [self fadeInButtons:nil];
        } else {
            [UIView fadeOutView:self.startLabel withTimeInterval:FASTER_FADE_DURATION];
            [self fadeInButtons:nil];
        }
    }
}

#pragma mark - View Controller Life Cycle Methods

- (void)setFileButtonText
{
    // get Hero's out of NSUserDefaults
    NSDictionary *hero1Data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Hero1"];
    if (hero1Data) {
        NSString *heroName = [hero1Data objectForKey:HERO_DATA_NAME_KEY];
        [self.file1Button setTitle:heroName forState:UIControlStateNormal];
    } else {
        [self.file1Button setTitle:EMPTY_FILE_STRING forState:UIControlStateNormal];
    }
    
    NSDictionary *hero2Data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Hero2"];
    if (hero2Data) {
        NSString *heroName = [hero2Data objectForKey:HERO_DATA_NAME_KEY];
        [self.file2Button setTitle:heroName forState:UIControlStateNormal];
    } else {
        [self.file2Button setTitle:EMPTY_FILE_STRING forState:UIControlStateNormal];
    }
    
    NSDictionary *hero3Data = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"Hero3"];
    if (hero3Data) {
        NSString *heroName = [hero3Data objectForKey:HERO_DATA_NAME_KEY];
        [self.file3Button setTitle:heroName forState:UIControlStateNormal];
    } else {
        [self.file3Button setTitle:EMPTY_FILE_STRING forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Quest Log";
    
    // set up audio session for app
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof (doChangeDefaultRoute), &doChangeDefaultRoute);
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // set up tap gesture
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToStart)];
    tap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tap];
    
    // set up scrollView
    self.scrollView.contentSize = self.backgroundImageView.image.size;
    self.scrollView.minimumZoomScale = DEFAULT_MIN_ZOOM;
    self.scrollView.maximumZoomScale = DEFAULT_MAX_ZOOM;
    self.scrollView.scrollEnabled = NO;
    self.scrollView.bounces = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    
    // set button text and fonts
    [self setFileButtonText];
    UIFont *ravennaFont = [UIFont fontWithName:@"Ravenna" size:12.0];
    self.file1LabelButton.titleLabel.font = ravennaFont;
    self.file1Button.titleLabel.font = ravennaFont;
    self.file2LabelButton.titleLabel.font = ravennaFont;
    self.file2Button.titleLabel.font = ravennaFont;
    self.file3LabelButton.titleLabel.font = ravennaFont;
    self.file3Button.titleLabel.font = ravennaFont;
    self.clearLogsButton.titleLabel.font = ravennaFont;
    
    // no user interaction for label buttons
    self.startLabel.userInteractionEnabled = NO;
    self.file1LabelButton.userInteractionEnabled = NO;
    self.file2LabelButton.userInteractionEnabled = NO;
    self.file3LabelButton.userInteractionEnabled = NO;
    
    // load backgroung audio
    self.bgAudioPlayer = [ZeldaAudio audioPlayerWithFileName:BG_AUDIO_FILE];
    self.bgAudioPlayer.delegate = self;
    
    // start timers
    [self startLogoTimer];
    [self startButtonTimer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // re-fade in views as needed (some may not have loaded yet)
    [UIView fadeInView:self.backgroundImageView withTimeInterval:SLOW_FADE_DURATION];
    if (!self.buttonTimer) {
        [self fadeInButtons:nil];
    } else {
        [UIView fadeInView:self.startLabel withTimeInterval:SLOW_FADE_DURATION];
    }
    if (!self.logoTimer) {
        [UIView fadeInView:self.logoImageView withTimeInterval:FAST_FADE_DURATION];
        // no need for logoTimer anymore
        [self stopLogoTimer];
    }
    
    [self setFileButtonText];
    
    // play background music
    [ZeldaAudio playAudioPlayer:self.bgAudioPlayer];
    
    // set up bgImage frame
    CGRect imageViewFrame;
    imageViewFrame.origin = CGPointZero;
    imageViewFrame.size = self.backgroundImageView.image.size;
    self.backgroundImageView.frame = imageViewFrame;

    // continue background panning
    [self startBackgroundTimer];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // fade out all views (so that they're prepared for fade-in on return)
    [self stopBackgroundTimer];
    [UIView fadeOutView:self.backgroundImageView withTimeInterval:FASTER_FADE_DURATION];
    [UIView fadeOutView:self.logoImageView withTimeInterval:FASTER_FADE_DURATION];
    if (self.logoTimer || self.buttonTimer)
        [UIView fadeOutView:self.startLabel withTimeInterval:FASTER_FADE_DURATION];
    
    [self fadeOutButtons];
    
    [ZeldaAudio stopAudioPlayer:self.bgAudioPlayer withFadeOut:YES restart:NO];
}

- (void)viewDidUnload {
    [self setClearLogsButton:nil];
    [super viewDidUnload];
    
    [self setScrollView:nil];
    [self setBackgroundImageView:nil];
    [self setLogoImageView:nil];
    [self setFile1Button:nil];
    [self setFile2Button:nil];
    [self setFile3Button:nil];
    [self setFile1LabelButton:nil];
    [self setFile2LabelButton:nil];
    [self setFile3LabelButton:nil];
    [self setStartLabel:nil];
}

# pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
