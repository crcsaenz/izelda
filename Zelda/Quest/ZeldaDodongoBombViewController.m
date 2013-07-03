//
//  ZeldaDodongoBombViewController.m
//  Zelda
//
//  Created by Cassidy Saenz on 6/4/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ZeldaDodongoBombViewController.h"
#import "ZeldaDodongo.h"
#import "ZeldaBomb.h"
#import "ZeldaAudio.h"
#import "UIView+Fade.h"

#define SLOW_FADE_DURATION 2.0
#define FAST_FADE_DURATION 1.0
#define FASTER_FADE_DURATION 0.5

#define GAME_DURATION 60.0
#define TICK_DURATION 0.1

#define DODONGO_ADD_TIME 1.0
#define DODONGO_MOVE_TIME 1.1
#define DODONGO_FADE_IN_TIME 0.5

#define BOMB_FUSE_TIME 4.0
#define DODONGO_EXPLODE_TIME 2.0

#define NUM_BOMBS_START 4

#define START_FONT_SIZE 14.0
#define HERO_FONT_SIZE 16.0
#define HIGH_SCORE_FONT_SIZE 16.0
#define CLOCK_FONT_SIZE 14.0
#define BOMB_FONT_SIZE 18.0
#define SCORE_FONT_SIZE 18.0
#define SCORE_NOTIFY_FONT_SIZE 24.0
#define SCORE_NOTIFY_OFFSET 10.0

#define DIRECT_KILL_SCORE 75
#define INDIRECT_KILL_SCORE 125
#define MISS_PENALTY -50

#define BG_AUDIO_FILE @"GerudoValley.mp3"
// song was too loud
#define BG_AUDIO_VOLUME 0.7
#define PLACE_BOMB_AUDIO_FILE @"PlaceBomb.wav"
#define EXPLODE_BOMB_AUDIO_FILE @"ExplodeBomb.wav"
#define KILL_DODONGO_AUDIO_FILE @"KillDodongo.wav"
#define END_GAME_AUDIO_FILE @"KakarikoVillage.mp3"

#define DEFAULT_HERO_IMAGE_FILE @"DefaultHero.png"

#define HERO_DATA_NAME_KEY @"Hero Name"
#define HERO_DATA_IMAGE_PATH_KEY @"ImagePath"
#define HERO_DATA_HIGH_SCORE_KEY @"High Score"
#define HERO_DATA_QUEST_NUM_KEY @"Quest Number"


@interface ZeldaDodongoBombViewController () <ZeldaBombDelegate, ZeldaDodongoDelegate, AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bgWallsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIImageView *topBarImageView;
@property (weak, nonatomic) IBOutlet UIImageView *heroImageView;
@property (weak, nonatomic) IBOutlet UILabel *heroNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bottomBarImageView;
@property (weak, nonatomic) IBOutlet UILabel *hudClockLabel;
@property (weak, nonatomic) IBOutlet UIImageView *hudBombImageView;
@property (weak, nonatomic) IBOutlet UILabel *hudBombLabel;
@property (weak, nonatomic) IBOutlet UILabel *hudScoreLabel;
@property (nonatomic) int numBombsLeft;
@property (nonatomic) int score;
@property (nonatomic) float timeLeft;
@property (nonatomic) BOOL gameOn;
@property (strong, nonatomic) NSMutableArray *bombs;
@property (strong, nonatomic) NSMutableArray *dodongos;
@property (weak, nonatomic) NSTimer *gameClockTimer;
@property (weak, nonatomic) NSTimer *dodongoAddTimer;
@property (weak, nonatomic) NSTimer *dodongoMoveTimer;
@property (strong, nonatomic) AVAudioPlayer *bgAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *placeBombAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *explodeBombAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *killDodongoAudioPlayer;
@property (strong, nonatomic) AVAudioPlayer *endGameAudioPlayer;

@end


@implementation ZeldaDodongoBombViewController

@synthesize backgroundImageView = _backgroundImageView;
@synthesize logoImageView = _logoImageView;
@synthesize bgWallsImageView = _bgWallsImageView;
@synthesize startButton = _startButton;
@synthesize backButton = _backButton;
@synthesize topBarImageView = _topBarImageView;
@synthesize bottomBarImageView = _bottomBarImageView;
@synthesize heroImageView = _heroImageView;
@synthesize heroNameLabel = _heroNameLabel;
@synthesize highScoreLabel = _highScoreLabel;
@synthesize hudClockLabel = _hudClockLabel;
@synthesize hudBombImageView = _hudBombImageView;
@synthesize hudBombLabel = _hudBombLabel;
@synthesize heroName = _heroName;
@synthesize heroPictureUrl = _heroPictureUrl;
@synthesize highScore = _highScore;
@synthesize questNumber = _questNumber;
@synthesize delegate = _delegate;
@synthesize numBombsLeft = _numBombsLeft;
@synthesize score = _score;
@synthesize timeLeft = _timeLeft;
@synthesize gameOn = _gameOn;
@synthesize hudScoreLabel = _hudScoreLabel;
@synthesize bombs = _bombs;
@synthesize dodongos = _dodongos;
@synthesize gameClockTimer = _gameClockTimer;
@synthesize dodongoAddTimer = _dodongoAddTimer;
@synthesize dodongoMoveTimer = _dodongoMoveTimer;
@synthesize bgAudioPlayer = _bgAudioPlayer;
@synthesize placeBombAudioPlayer = _placeBombAudioPlayer;
@synthesize explodeBombAudioPlayer = _explodeBombAudioPlayer;
@synthesize killDodongoAudioPlayer = _killDodongoAudioPlayer;
@synthesize endGameAudioPlayer = _endGameAudioPlayer;

- (NSMutableArray *)bombs
{
    if (!_bombs)
        _bombs = [[NSMutableArray alloc] initWithCapacity:NUM_BOMBS_START];
    return _bombs;
}

- (NSMutableArray *)dodongos
{
    if (!_dodongos)
        _dodongos = [[NSMutableArray alloc] init];
    return _dodongos;
}

- (void)updateClockLabel
{
    if (self.timeLeft < 10.0)
        self.hudClockLabel.textColor = [UIColor redColor];
    self.hudClockLabel.text = [NSString stringWithFormat:@"Time Left: %f", ABS(self.timeLeft)];
}

- (void)updateScoreLabel
{
    self.hudScoreLabel.text = [NSString stringWithFormat:@"Score: %d",self.score];
    if (self.score > self.highScore) {
        self.highScore = self.score;
        self.highScoreLabel.text = [NSString stringWithFormat:@"High: %d",self.highScore];
    }
}

#pragma mark - Collision Detection

- (BOOL)dodongo:(ZeldaDodongo *)dodongo collidesWithBomb:(ZeldaBomb *)bomb
{
    if (CGRectIntersectsRect(dodongo.frame, bomb.frame))
        return YES;
    else
        return NO;
}

- (BOOL)dodongoCollidedWithABomb:(ZeldaDodongo *)dodongo
{
    for (ZeldaBomb *bomb in self.bombs) {
        if ([self dodongo:dodongo collidesWithBomb:bomb]) {
            [bomb removeFromSuperview];
            [self.bombs removeObject:bomb];
            return YES;
        }
    }
    return NO;;
}

- (BOOL)bomb:(ZeldaBomb *)bomb collidesWithDodongo:(ZeldaDodongo *)dodongo
{
    if (CGRectIntersectsRect(bomb.frame, dodongo.frame))
        return YES;
    else
        return NO;
}

- (BOOL)bombCollidedWithADodongo:(ZeldaBomb *)bomb
{
    for (ZeldaDodongo *dodongo in self.dodongos) {
        // only collide with live dodongos
        if (dodongo.isAlive) {
            if ([self bomb:bomb collidesWithDodongo:dodongo]) {
                // dodongo is dead
                dodongo.isAlive = NO;
                [dodongo performSelector:@selector(explodeWithDirectHit:) withObject:[NSNumber numberWithBool:YES] afterDelay:DODONGO_EXPLODE_TIME];
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Animations

- (void)tickClock:(NSTimer *)timer
{
    if (self.timeLeft > 0.0)
        self.timeLeft -= TICK_DURATION;
    [self updateClockLabel];
}

- (void)setRandomLocationForView:(UIView *)view
{
    CGRect bgBounds = CGRectInset(self.backgroundImageView.bounds, view.frame.size.width/2, view.frame.size.height/2);
    CGFloat x = arc4random() % (int)bgBounds.size.width + view.frame.size.width/2;
    CGFloat y = arc4random() % (int)bgBounds.size.height + view.frame.size.height/2;
    view.center = CGPointMake(x, y);
}

- (void)addDodongo:(NSTimer *)timer
{
    ZeldaDodongo *dodongo = [[ZeldaDodongo alloc] initWithFrame:CGRectMake(0.0, 0.0, DODONGO_WIDTH, DODONGO_HEIGHT)];
    [self setRandomLocationForView:dodongo];
    dodongo.alpha = 0.0;
    dodongo.isAlive = YES;
    dodongo.delegate = self;
    [self.backgroundImageView addSubview:dodongo];
    [self.dodongos addObject:dodongo];
    [UIView fadeInView:dodongo withTimeInterval:DODONGO_FADE_IN_TIME];
}

- (void)moveDodongos:(NSTimer *)timer
{
    for (UIView *view in self.backgroundImageView.subviews) {
        // only move dodongos, not bombs
        if ([view isKindOfClass:[ZeldaDodongo class]]) {
            ZeldaDodongo *dodongo = (ZeldaDodongo *)view;
            
            // only move if the dodongo is alive
            if (dodongo.isAlive) {
                [dodongo moveRandomDirectionWithDuration:FAST_FADE_DURATION];
                
                // check for bomb collision here
                if ([self dodongoCollidedWithABomb:dodongo]) {
                    dodongo.isAlive = NO;
                    [dodongo performSelector:@selector(explodeWithDirectHit:) withObject:[NSNumber numberWithBool:NO] afterDelay:DODONGO_EXPLODE_TIME];
                } else {
                    if (!CGRectContainsRect(self.backgroundImageView.bounds, view.frame) && !CGRectIntersectsRect(self.backgroundImageView.bounds, view.frame)) {
                        [UIView fadeOutView:dodongo withTimeInterval:FASTER_FADE_DURATION];
                        [dodongo performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:FASTER_FADE_DURATION];
                        [self showScoreLabelAtLocationOfDodongo:dodongo withScore:MISS_PENALTY];
                        // decrease score
                        self.score += MISS_PENALTY;
                        [self updateScoreLabel];
                    }
                }
            }
        }
    }
}

#pragma mark - Timers

- (void)startGameClockTimer
{
    self.gameClockTimer = [NSTimer scheduledTimerWithTimeInterval:TICK_DURATION
                                                           target:self
                                                         selector:@selector(tickClock:)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void)stopGameClockTimer
{
    [self.gameClockTimer invalidate];
    self.gameClockTimer = nil;
}

- (void)startDodongoAddTimer
{
    self.dodongoAddTimer = [NSTimer scheduledTimerWithTimeInterval:DODONGO_ADD_TIME
                                                            target:self
                                                          selector:@selector(addDodongo:)
                                                          userInfo:nil
                                                           repeats:YES];
}

- (void)stopDodongoAddTimer
{
    [self.dodongoAddTimer invalidate];
    self.dodongoAddTimer = nil;
}

- (void)startDodongoMoveTimer
{
    self.dodongoMoveTimer = [NSTimer scheduledTimerWithTimeInterval:DODONGO_MOVE_TIME
                                                             target:self
                                                           selector:@selector(moveDodongos:)
                                                           userInfo:nil
                                                            repeats:YES];
}

- (void)stopDodongoMoveTimer
{
    [self.dodongoMoveTimer invalidate];
    self.dodongoMoveTimer = nil;
}

#pragma mark - Target/Action

- (void)fadeInGameDisplay
{
    [UIView fadeInView:self.backgroundImageView withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.bgWallsImageView withTimeInterval:FAST_FADE_DURATION];
    
    [UIView fadeInView:self.topBarImageView withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.heroImageView withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.heroNameLabel withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.highScoreLabel withTimeInterval:FAST_FADE_DURATION];
    
    [UIView fadeInView:self.bottomBarImageView withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.hudBombImageView withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.hudBombLabel withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.hudScoreLabel withTimeInterval:FAST_FADE_DURATION];
    [UIView fadeInView:self.hudClockLabel withTimeInterval:FAST_FADE_DURATION];
}

- (void)stopGameWithData:(NSDictionary *)data
{
    self.gameOn = NO;
    
    [self stopDodongoMoveTimer];
    [self stopDodongoAddTimer];
    [self stopGameClockTimer];
    self.timeLeft = 0;
    [self updateClockLabel];
    
    [self.view removeGestureRecognizer:[data objectForKey:@"Bomb Tap Gesture"]];
    
    // fade out all dodongos/bombs
    for (UIView *view in self.backgroundImageView.subviews) {
        [UIView fadeOutView:view withTimeInterval:FAST_FADE_DURATION];
        [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:FAST_FADE_DURATION];
    }
    
    [UIView fadeInView:self.backButton withTimeInterval:SLOW_FADE_DURATION];
    self.backButton.userInteractionEnabled = YES;
    
    [ZeldaAudio stopAudioPlayer:self.bgAudioPlayer withFadeOut:YES restart:YES];
    [ZeldaAudio stopAudioPlayer:self.placeBombAudioPlayer withFadeOut:NO restart:YES];
    [ZeldaAudio stopAudioPlayer:self.explodeBombAudioPlayer withFadeOut:NO restart:YES];
    [ZeldaAudio stopAudioPlayer:self.killDodongoAudioPlayer withFadeOut:NO restart:YES];

    [ZeldaAudio playAudioPlayer:self.endGameAudioPlayer];
}

- (IBAction)startGame
{
    self.gameOn = YES;
    
    self.placeBombAudioPlayer = [ZeldaAudio audioPlayerWithFileName:PLACE_BOMB_AUDIO_FILE];
    self.explodeBombAudioPlayer = [ZeldaAudio audioPlayerWithFileName:EXPLODE_BOMB_AUDIO_FILE];
    self.killDodongoAudioPlayer = [ZeldaAudio audioPlayerWithFileName:KILL_DODONGO_AUDIO_FILE];
    
    [UIView fadeOutView:self.startButton withTimeInterval:FASTER_FADE_DURATION];
    [UIView fadeOutView:self.logoImageView withTimeInterval:FASTER_FADE_DURATION];
    self.startButton.userInteractionEnabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    
    [ZeldaAudio stopAudioPlayer:self.endGameAudioPlayer withFadeOut:YES restart:YES];
    [ZeldaAudio playAudioPlayer:self.bgAudioPlayer];
    self.bgAudioPlayer.volume = BG_AUDIO_VOLUME; // song was too loud
    
    if (self.heroPictureUrl)
        self.heroImageView.image = [UIImage imageWithContentsOfFile:[self.heroPictureUrl path]];
    else
        self.heroImageView.image = [UIImage imageNamed:DEFAULT_HERO_IMAGE_FILE];
    
    [self fadeInGameDisplay];
    
    // set up bomb tap gesture
    UITapGestureRecognizer *bombTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(placeBomb:)];
    bombTap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:bombTap];
    
    [self startGameClockTimer];
    [self startDodongoAddTimer];
    [self startDodongoMoveTimer];
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:bombTap, @"Bomb Tap Gesture", nil];
    [self performSelector:@selector(stopGameWithData:) withObject:data afterDelay:GAME_DURATION];
}

- (IBAction)backToQuestLog:(UIButton *)sender
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:self.heroName forKey:HERO_DATA_NAME_KEY];
    [data setObject:[self.heroPictureUrl path] forKey:HERO_DATA_IMAGE_PATH_KEY];
    [data setObject:[NSNumber numberWithInt:self.highScore] forKey:HERO_DATA_HIGH_SCORE_KEY];
                          
    [self.delegate zeldaDodongoBombViewController:self didFinishGameWithData:[data copy] forQuestNumber:self.questNumber];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Tap Gestures

- (void)placeBomb:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateEnded) {
        if (self.numBombsLeft > 0) {
            // make sure touch is inside BG image
            if (CGRectContainsPoint(self.backgroundImageView.frame, [tap locationInView:self.view])) {
                ZeldaBomb *bomb = [[ZeldaBomb alloc] initWithFrame:CGRectMake(0.0, 0.0, BOMB_WIDTH, BOMB_HEIGHT)];
                bomb.center = [tap locationInView:self.backgroundImageView];
                bomb.delegate = self;
                [bomb performSelector:@selector(explode) withObject:nil afterDelay:BOMB_FUSE_TIME];
                [self.backgroundImageView addSubview:bomb];
                [ZeldaAudio playAudioPlayer:self.placeBombAudioPlayer];
                self.numBombsLeft--;
                [self.bombs addObject:bomb];
                self.hudBombLabel.text = [NSString stringWithFormat:@"x%d",self.numBombsLeft];
                // check for collision with dodongo
                if ([self bombCollidedWithADodongo:bomb]) {
                    // remove bomb
                    [bomb removeFromSuperview];
                    [self.bombs removeObject:bomb];
                }
            }
        }
    }
}

#pragma mark - ZeldaBombDelegate Methods

- (void)zeldaBombDidExplode:(ZeldaBomb *)bomb
{
    if ([self.bombs containsObject:bomb]) {
        if (self.explodeBombAudioPlayer.playing)
            [ZeldaAudio stopAudioPlayer:self.explodeBombAudioPlayer withFadeOut:NO restart:YES];
        [ZeldaAudio playAudioPlayer:self.explodeBombAudioPlayer];
        self.numBombsLeft++;
        [self.bombs removeObject:bomb];
        self.hudBombLabel.text = [NSString stringWithFormat:@"x%d",self.numBombsLeft];
    }
}

#pragma mark - ZeldaDodongoDelegate Methods

- (void)showScoreLabelAtLocationOfDodongo:(ZeldaDodongo *)dodongo withScore:(int)score
{
    UILabel *scoreLabel = [[UILabel alloc] init];
    scoreLabel.text = (score > 0) ? [NSString stringWithFormat:@"+%d",score] : [NSString stringWithFormat:@"%d",score];
    scoreLabel.textColor = (score > 0) ? [UIColor greenColor] : [UIColor redColor];
    scoreLabel.font = [UIFont systemFontOfSize:SCORE_NOTIFY_FONT_SIZE];
    scoreLabel.backgroundColor = [UIColor clearColor];
    [scoreLabel sizeToFit];
    CGRect frame = scoreLabel.frame;
    frame.origin = CGPointMake(dodongo.frame.origin.x, dodongo.frame.origin.y - SCORE_NOTIFY_OFFSET);
    scoreLabel.frame = frame;
    [self.backgroundImageView addSubview:scoreLabel];
    [UIView fadeOutView:scoreLabel withTimeInterval:SLOW_FADE_DURATION];
    [scoreLabel performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:SLOW_FADE_DURATION];
}

- (void)zeldaDodongoDidExplode:(ZeldaDodongo *)dodongo withDirectHit:(BOOL)direct
{
    if ([self.dodongos containsObject:dodongo]) {
        if (self.explodeBombAudioPlayer.playing)
            [ZeldaAudio stopAudioPlayer:self.explodeBombAudioPlayer withFadeOut:NO restart:YES];
        [ZeldaAudio playAudioPlayer:self.explodeBombAudioPlayer];
        if (self.killDodongoAudioPlayer.playing)
            [ZeldaAudio stopAudioPlayer:self.killDodongoAudioPlayer withFadeOut:NO restart:YES];
        [ZeldaAudio playAudioPlayer:self.killDodongoAudioPlayer];
        [self.dodongos removeObject:dodongo];
        self.numBombsLeft++;
        self.hudBombLabel.text = [NSString stringWithFormat:@"x%d",self.numBombsLeft];
    }
    if (direct)
        [self showScoreLabelAtLocationOfDodongo:dodongo withScore:DIRECT_KILL_SCORE];
    else
        [self showScoreLabelAtLocationOfDodongo:dodongo withScore:INDIRECT_KILL_SCORE];
    // increase score
    self.score += (direct) ? DIRECT_KILL_SCORE : INDIRECT_KILL_SCORE;
    [self updateScoreLabel];
}

#pragma mark - AVAudioPlayerDelegate Methods

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (player == self.explodeBombAudioPlayer || player == self.placeBombAudioPlayer || player == self.killDodongoAudioPlayer)
        [ZeldaAudio stopAudioPlayer:player withFadeOut:NO restart:YES];
}

#pragma mark - View Controller Lifecycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Dodongo Bomb!";
    self.backButton.userInteractionEnabled = NO;
    self.navigationController.navigationBar.userInteractionEnabled = YES;
    self.startButton.titleLabel.font = [UIFont fontWithName:@"Ravenna" size:START_FONT_SIZE];
    
    self.heroNameLabel.text = (self.heroName) ? self.heroName : @"No Name";
    self.heroNameLabel.font = [UIFont fontWithName:@"Ravenna" size:HERO_FONT_SIZE];
    self.highScoreLabel.text = [NSString stringWithFormat:@"High: %d",self.highScore];
    self.highScoreLabel.font = [UIFont fontWithName:@"Ravenna" size:HIGH_SCORE_FONT_SIZE];
    
    self.hudBombLabel.text = [NSString stringWithFormat:@"x%d",NUM_BOMBS_START];
    self.hudBombLabel.font = [UIFont fontWithName:@"Ravenna" size:BOMB_FONT_SIZE];
    self.hudScoreLabel.font = [UIFont fontWithName:@"Ravenna" size:SCORE_FONT_SIZE];
    self.hudClockLabel.font = [UIFont fontWithName:@"Ravenna" size:CLOCK_FONT_SIZE];
    
    self.numBombsLeft = NUM_BOMBS_START;
    self.score = 0;
    self.timeLeft = GAME_DURATION;
    self.gameOn = NO;
    
    self.bgAudioPlayer = [ZeldaAudio audioPlayerWithFileName:BG_AUDIO_FILE];
    self.endGameAudioPlayer = [ZeldaAudio audioPlayerWithFileName:END_GAME_AUDIO_FILE];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // if logo isn't visible (i.e. game is going)
    if (self.gameOn) {
        [self startDodongoAddTimer];
        [self startDodongoMoveTimer];
    }
    
    if (!self.gameOn) {
        [ZeldaAudio playAudioPlayer:self.endGameAudioPlayer];
    } else {
        [ZeldaAudio playAudioPlayer:self.bgAudioPlayer];
        self.bgAudioPlayer.volume = BG_AUDIO_VOLUME; // song was too loud
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopDodongoAddTimer];
    [self stopDodongoMoveTimer];
    [ZeldaAudio stopAudioPlayer:self.bgAudioPlayer withFadeOut:YES restart:NO];
    [ZeldaAudio stopAudioPlayer:self.endGameAudioPlayer withFadeOut:YES restart:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self setHudBombLabel:nil];
    [self setHudScoreLabel:nil];
    [self setBackButton:nil];
    [self setHudClockLabel:nil];
    [self setHeroImageView:nil];
    [self setHeroNameLabel:nil];
    [self setHighScoreLabel:nil];
    [self setStartButton:nil];
    [self setLogoImageView:nil];
    [self setTopBarImageView:nil];
    [self setBottomBarImageView:nil];
    [self setBgWallsImageView:nil];
    [self setHudBombImageView:nil];
    [self setBackgroundImageView:nil];
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
