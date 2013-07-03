//
//  ZeldaDodongo.h
//  Zelda
//
//  Created by Cassidy Saenz on 6/7/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DODONGO_WIDTH 40.0
#define DODONGO_HEIGHT 20.0


@class ZeldaDodongo;

@protocol ZeldaDodongoDelegate <NSObject>

- (void)zeldaDodongoDidExplode:(ZeldaDodongo *)dodongo withDirectHit:(BOOL)direct;

@end


@interface ZeldaDodongo : UIImageView

@property (nonatomic) BOOL isAlive;
@property (strong, nonatomic) id <ZeldaDodongoDelegate> delegate;

- (void)explodeWithDirectHit:(NSNumber *)direct;
- (void)moveRandomDirectionWithDuration:(NSTimeInterval)duration;

@end
