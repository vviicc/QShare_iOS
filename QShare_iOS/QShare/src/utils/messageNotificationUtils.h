//
//  messageNotificationUtils.h
//  QShare
//
//  Created by Vic on 14-7-19.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface messageNotificationUtils : NSObject

+ (NSInteger) unsolvedFriendRequest;
+ (NSInteger) unsolvedGroupRequest;

@end
