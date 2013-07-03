//
//  UIView+Fade.m
//  Zelda
//
//  Created by Cassidy Saenz on 6/5/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UIView+Fade.h"


@implementation UIView (Fade)

+ (void)fadeInView:(UIView *)view withTimeInterval:(NSTimeInterval)duration
{
    view.alpha = 0.0;
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:duration];
    view.alpha = 1.0;
    [UIView commitAnimations];
}

+ (void)fadeOutView:(UIView *)view withTimeInterval:(NSTimeInterval)duration
{
    view.alpha = 1.0;
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:duration];
    view.alpha = 0.0;
    [UIView commitAnimations];
}

@end
