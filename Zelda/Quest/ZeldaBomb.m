//
//  ZeldaBomb.m
//  Zelda
//
//  Created by Cassidy Saenz on 6/7/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ZeldaBomb.h"
#import "UIView+Fade.h"

#define BOMB_EXPLODE_TIME 1.0


@interface ZeldaBomb()

@property (weak, nonatomic) UIImage *mainImage;
@property (weak, nonatomic) UIImage *explodeImage;

@end


@implementation ZeldaBomb

@synthesize delegate = _delegate;
@synthesize mainImage = _mainImage;
@synthesize explodeImage = _explodeImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    self.mainImage = [UIImage imageNamed:@"Bomb.png"];
    self.explodeImage = [UIImage imageNamed:@"BombExplode.png"];
    
    if (self) {
        self.image = self.mainImage;
    }
    return self;
}

- (void)explode
{
    // may have disappeared before explode is called
    if (self.alpha > 0.0) {
        self.image = self.explodeImage;
        [UIView fadeOutView:self withTimeInterval:BOMB_EXPLODE_TIME];
        [self.delegate zeldaBombDidExplode:self];
    }
}

@end
