//
//  GroupChatUtils.m
//  QShare
//
//  Created by Vic on 14-7-6.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "GroupChatUtils.h"
#import "XMPPUtils.h"

@interface GroupChatUtils ()<XMPPRoomDelegate>

@property (nonatomic,strong) XMPPRoom *room;
@property (nonatomic) CreateOrJoinRoomResult result;
@property (nonatomic) BOOL isCreatingRoom;

@end

@implementation GroupChatUtils

- (void) createRoomWithName:(NSString *) roomName
{
    _isCreatingRoom = YES;
    _result = NotCreateRoom;
    
    XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",roomName,XMPP_MUC_SERVICE]];
    if (!_room) {
        if (![[XMPPUtils sharedInstance] isExistRoom:roomJID]) {
            [self setupXMPPRoom:roomJID];
        }
        else{
            [_delegate existSameRoom];

        }
    }
}

- (void)setupXMPPRoom:(XMPPJID *)roomJID
{
    XMPPRoomCoreDataStorage *sharedRoomCoreDateStorage = [XMPPRoomCoreDataStorage sharedInstance];
    _room = [[XMPPRoom alloc]initWithRoomStorage:sharedRoomCoreDateStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
    
    [_room activate:[XMPPUtils sharedInstance].xmppStream];
    [_room addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_room joinRoomUsingNickname:[XMPPUtils sharedInstance].xmppStream.myJID.user history:nil];


}



- (void) sendMessageWithBody:(NSString *) messageBody andRoomJID:(XMPPJID *)roomJID
{
    _isCreatingRoom = NO;
    _result = NotCreateRoom;
    
    if (!_room) {
        if (![[XMPPUtils sharedInstance] isExistRoom:roomJID]) {
            [self setupXMPPRoom:roomJID];
            [_room sendMessageWithBody:messageBody];

        }
        else{
            XMPPRoom *room = [[XMPPUtils sharedInstance] getExistRoom:roomJID];
            [room joinRoomUsingNickname:[XMPPUtils sharedInstance].xmppStream.myJID.user history:nil];
            [room sendMessageWithBody:messageBody];
        }
    }
    else{
        [_room joinRoomUsingNickname:[XMPPUtils sharedInstance].xmppStream.myJID.user history:nil];
        [_room sendMessageWithBody:messageBody];

    }
    

}

#pragma mark XMPPRoomDelegate

- (void)xmppRoomDidCreate:(XMPPRoom *)sender
{
    NSLog(@"Create Room Success!");
    _result = CreatedRoom;
    [sender fetchConfigurationForm];
}

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"xmppRoomDidJoin");
    
    [[XMPPUtils sharedInstance] addRoom:_room];
    
    if (_isCreatingRoom) {
        if (_result == NotCreateRoom) {
            [_delegate existSameRoom];
        }
    }
}

- (void)xmppRoomDidLeave:(XMPPRoom *)sender
{
    NSLog(@"xmppRoomDidLeave");
}

- (void)xmppRoomDidDestroy:(XMPPRoom *)sender
{
    NSLog(@"xmppRoomDidDestroy");
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm
{
    NSXMLElement *newConfig = [configForm copy];
    NSArray *fields = [newConfig elementsForName:@"field"];
    
    for (NSXMLElement *field in fields)
    {
        NSString *var = [field attributeStringValueForName:@"var"];
        // Make Room Persistent
        if ([var isEqualToString:@"muc#roomconfig_persistentroom"]) {
            [field removeChildAtIndex:0];
            [field addChild:[NSXMLElement elementWithName:@"value" stringValue:@"1"]];
        }
    }
    
    [sender configureRoomUsingOptions:newConfig];
}

- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult
{
    NSLog(@"didConfigure");
    if (_selectedJIDs) {
        for (XMPPJID *jid in _selectedJIDs) {
            NSString *inviteMessage = @"欢迎加入！";
            [sender inviteUser:jid withMessage:inviteMessage];
            [sender editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"member" jid:jid]]];

        }
    }
    
    [_delegate didInviteUserSuccess];
}

- (void)xmppRoom:(XMPPRoom *)sender didReceiveMessage:(XMPPMessage *)message fromOccupant:(XMPPJID *)occupantJID
{
    NSLog(@"didReceiveMessage");
}

- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult
{
    NSLog(@"didNotConfig result: %@",iqResult);

}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidJoin:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"occupantDidJoin");
}

- (void)xmppRoom:(XMPPRoom *)sender occupantDidLeave:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"occupantDidLeave");
}
- (void)xmppRoom:(XMPPRoom *)sender occupantDidUpdate:(XMPPJID *)occupantJID withPresence:(XMPPPresence *)presence
{
    NSLog(@"occupantDidUpdate");
}



@end
