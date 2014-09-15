//
//  MyvCardDelegate.h
//  QShare
//
//  Created by Vic on 14-6-4.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyvCardDelegate <NSObject>

@optional

- (void)didSelectMan:(BOOL)isMan;
- (void)didEditIntroduce:(NSString *)introduce;


@end
