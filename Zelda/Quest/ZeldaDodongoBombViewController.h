//
//  ZeldaDodongoBombViewController.h
//  Zelda
//
//  Created by Cassidy Saenz on 6/4/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ZeldaDodongoBombViewController;

@protocol ZeldaDodongoBombViewControllerDelegate <NSObject>

- (void)zeldaDodongoBombViewController:(ZeldaDodongoBombViewController *)zdbVC
                 didFinishGameWithData:(NSDictionary *)data
                        forQuestNumber:(int)qNum;

@end

@interface ZeldaDodongoBombViewController : UIViewController

@property (strong, nonatomic) NSString *heroName;
@property (strong, nonatomic) NSURL *heroPictureUrl;
@property (nonatomic) int highScore;
@property (nonatomic) int questNumber;
@property (weak, nonatomic) id <ZeldaDodongoBombViewControllerDelegate> delegate;

@end
