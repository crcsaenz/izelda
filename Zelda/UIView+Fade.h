//
//  UIView+Fade.h
//  Zelda
//
//  Created by Cassidy Saenz on 6/5/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (Fade)

+ (void)fadeInView:(UIView *)view withTimeInterval:(NSTimeInterval)duration;
+ (void)fadeOutView:(UIView *)view withTimeInterval:(NSTimeInterval)duration;

@end
