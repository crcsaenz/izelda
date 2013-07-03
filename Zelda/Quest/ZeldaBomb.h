//
//  ZeldaBomb.h
//  Zelda
//
//  Created by Cassidy Saenz on 6/7/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

#define BOMB_WIDTH 20.0
#define BOMB_HEIGHT 20.0


@class ZeldaBomb;

@protocol ZeldaBombDelegate <NSObject>

- (void)zeldaBombDidExplode:(ZeldaBomb *)bomb;

@end


@interface ZeldaBomb : UIImageView

@property (strong, nonatomic) id <ZeldaBombDelegate> delegate;

- (void)explode;

@end
