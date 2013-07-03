//
//  ZeldaHeroViewController.h
//  Zelda
//
//  Created by Cassidy Saenz on 6/9/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZeldaHeroViewController;

@protocol ZeldaHeroViewControllerDelegate <NSObject>

- (void)zeldaHeroViewControllerDidCancel:(ZeldaHeroViewController *)zeldaHeroVC;
- (void)zeldaHeroViewController:(ZeldaHeroViewController *)zeldaHeroVC
                  didChooseName:(NSString *)name
                    andImageUrl:(NSURL *)imageUrl
                 forQuestNumber:(int)qNum;

@end


@interface ZeldaHeroViewController : UIViewController

@property (nonatomic) int questNumber;
@property (weak, nonatomic) id <ZeldaHeroViewControllerDelegate> delegate;

@end
