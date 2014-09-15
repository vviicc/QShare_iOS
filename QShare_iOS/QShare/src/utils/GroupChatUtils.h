//
//  GroupChatUtils.h
//  QShare
//
//  Created by Vic on 14-7-6.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RoomDelegate <NSObject>

- (void) didInviteUserSuccess;
- (void) existSameRoom;

@end

typedef enum
{
    CreatedRoom,
    NotCreateRoom
}CreateOrJoinRoomResult;

@interface GroupChatUtils : NSObject<XMPPRoomDelegate>


@property (nonatomic,strong) NSArray *selectedJIDs;
@property (nonatomic,weak) id<RoomDelegate> delegate;

- (void) createRoomWithName:(NSString *) roomName;
- (void) sendMessageWithBody:(NSString *) messageBody andRoomJID:(XMPPJID *)roomJID;


@end
