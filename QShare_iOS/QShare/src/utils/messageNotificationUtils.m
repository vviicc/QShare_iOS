//
//  messageNotificationUtils.m
//  QShare
//
//  Created by Vic on 14-7-19.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "messageNotificationUtils.h"
#import "XMPPUtils.h"

@implementation messageNotificationUtils

+ (NSInteger) unsolvedFriendRequest
{
    NSString *myString = [[XMPPUtils sharedInstance].xmppStream.myJID user];
    NSString *friendDefault = [NSString stringWithFormat:@"%@_requestRoster",myString];
    
    if([[NSUserDefaults standardUserDefaults] objectForKey:friendDefault]){
        NSInteger unsolvedCount = 0;
        NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:friendDefault];
        for (NSDictionary *dict in array) {
            if (dict[@"result"] == nil) {
                unsolvedCount++;
            }
        }
        return unsolvedCount;
    }
    else{
        return 0;
    }
}

+ (NSInteger) unsolvedGroupRequest
{
    {
        NSString *myString = [[XMPPUtils sharedInstance].xmppStream.myJID user];
        NSString *groupDefault = [NSString stringWithFormat:@"%@_groupInvite",myString];
        
        if([[NSUserDefaults standardUserDefaults] objectForKey:groupDefault]){
            NSInteger unsolvedCount = 0;
            NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:groupDefault];
            for (NSDictionary *dict in array) {
                if (dict[@"result"] == nil) {
                    unsolvedCount++;
                }
            }
            return unsolvedCount;
        }
        else{
            return 0;
        }
    }
}

@end
