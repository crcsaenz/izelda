//
//  ZeldaDodongo.m
//  Zelda
//
//  Created by Cassidy Saenz on 6/7/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ZeldaDodongo.h"
#import "UIView+Fade.h"

#define NUM_DIRECTIONS 4 
#define MOVE_DISTANCE 10.0

#define EXPLODE_FADE_TIME 1.0


@interface ZeldaDodongo ()

@property (weak, nonatomic) UIImage *leftImage;
@property (weak, nonatomic) UIImage *upImage;
@property (weak, nonatomic) UIImage *rightImage;
@property (weak, nonatomic) UIImage *downImage;
@property (weak, nonatomic) UIImage *deadImage;
@property (weak, nonatomic) UIImage *explodeImage;

@end


@implementation ZeldaDodongo

@synthesize isAlive = _isAlive;
@synthesize delegate = _delegate;
@synthesize leftImage = _leftImage;
@synthesize upImage = _upImage;
@synthesize rightImage = _rightImage;
@synthesize downImage = _downImage;
@synthesize deadImage = _deadImage;
@synthesize explodeImage = _explodeImage;

- (void)setIsAlive:(BOOL)isAlive
{
    if (!isAlive) {
        // update image;
        self.image = self.deadImage;
        CGRect frame = self.frame;
        frame.size = CGSizeMake(DODONGO_WIDTH, DODONGO_HEIGHT);
        self.frame = frame;
    }
    _isAlive = isAlive;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    // initialize 4 directional images
    self.leftImage = [UIImage imageNamed:@"DodongoLeft.png"];
    self.upImage = [UIImage imageNamed:@"DodongoUp.png"];
    self.rightImage = [UIImage imageNamed:@"DodongoRight.png"];
    self.downImage = [UIImage imageNamed:@"DodongoDown.png"];
    self.deadImage = [UIImage imageNamed:@"DodongoDead.png"];
    self.explodeImage = [UIImage imageNamed:@"DodongoExplode.png"];
    
    if (self) {
        int direction = arc4random() % NUM_DIRECTIONS;
        // choose initial image (only left or right)
        switch (direction) {
            case 0:
            case 1:
                self.image = self.leftImage;
                break;
            case 2:
            case 3:
                self.image = self.rightImage;
                break;
            default:
                break;
        }
    }
    
    return self;
}

- (void)explodeWithDirectHit:(NSNumber *)direct
{
    self.isAlive = NO;
    // may have disappeared before explode is called
    if (self.alpha > 0.0) {
        self.image = self.explodeImage;
        [UIView fadeOutView:self withTimeInterval:EXPLODE_FADE_TIME];
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:EXPLODE_FADE_TIME];
        [self.delegate zeldaDodongoDidExplode:self withDirectHit:[direct boolValue]];
    }
}

- (void)moveRandomDirectionWithDuration:(NSTimeInterval)duration
{
    int direction = arc4random() % (NUM_DIRECTIONS + 2);
    // 1/3 chance of not moving
    if (direction != 4 && direction != 5) {
        // update frame origin
        CGRect frame = self.frame;
        [UIView beginAnimations:@"move dodongo" context:nil];
        [UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        switch (direction) {
            case 0:
                frame.origin = CGPointMake(frame.origin.x - MOVE_DISTANCE, frame.origin.y);
                self.image = self.leftImage;
                break;
            case 1:
                frame.origin = CGPointMake(frame.origin.x, frame.origin.y - MOVE_DISTANCE);
                self.image = self.upImage;
                break;
            case 2:
                frame.origin = CGPointMake(frame.origin.x + MOVE_DISTANCE, frame.origin.y);
                self.image = self.rightImage;
                break;
            case 3:
                frame.origin = CGPointMake(frame.origin.x, frame.origin.y + MOVE_DISTANCE);
                self.image = self.downImage;
                break;
            default:
                frame.origin = CGPointMake(frame.origin.x - MOVE_DISTANCE, frame.origin.y);
                self.image = self.leftImage;
                break;
        }
        self.frame = frame;
        [UIView commitAnimations];
        
        // update frame size (no animation)
        switch (direction) {
            case 0:
            case 2:
                frame.size = CGSizeMake(DODONGO_WIDTH, DODONGO_HEIGHT);
                break;
            case 1:
            case 3:
                frame.size = CGSizeMake(DODONGO_HEIGHT, DODONGO_WIDTH);
            default:
                break;
        }
        self.frame = frame;
    }
}

@end
