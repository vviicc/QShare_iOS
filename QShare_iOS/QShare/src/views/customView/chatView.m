//
//  chatView.m
//  QShare
//
//  Created by Vic on 14-7-18.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "chatView.h"

@implementation chatView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    BOOL isInside = [super pointInside:point withEvent:event];
    
    // identify the button view subclass
//    UIButton *b = (UIButton *)[self viewWithTag:22];
    UIView *b = (UIView *)[self viewWithTag:22];
    CGPoint inButtonSpace = [self convertPoint:point toView:b];
    
    BOOL isInsideButton = [b pointInside:inButtonSpace withEvent:nil];
    
    if (isInsideButton) {
        
        return isInsideButton;
        
    } // if (YES == isInsideButton)
    
    return isInside;        
}




@end
