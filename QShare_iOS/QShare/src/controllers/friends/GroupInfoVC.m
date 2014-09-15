//
//  GroupInfoVC.m
//  QShare
//
//  Created by Vic on 14-7-14.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "GroupInfoVC.h"
#import "GroupMembers.h"
#import "InviteGroupContacts.h"
#import "XMPPUtils.h"


@interface GroupInfoVC ()

@property (nonatomic,strong) XMPPRoom *room;
@property (nonatomic,strong) NSMutableArray *membersArray;
@property (nonatomic) BOOL isSelectMember;
- (IBAction)inviteFriends:(id)sender;

@end

@implementation GroupInfoVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _membersArray = [NSMutableArray array];
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GroupInfo2GroupMembers"]) {
        GroupMembers *vc = segue.destinationViewController;
        vc.roomJID = _roomJID;
        _isSelectMember = YES;
    }
    
    else if ([segue.identifier isEqualToString:@"GroupInfo2InviteGroupContact"]){
        UINavigationController *navi = segue.destinationViewController;
        InviteGroupContacts *vc = (InviteGroupContacts *)navi.topViewController;
        vc.roomJID = _roomJID;
        vc.joinedFriends = [_membersArray copy];
    }
}

#pragma mark - XMPP Room

- (void)fetchMembers
{
    if([[XMPPUtils sharedInstance]isExistRoom:_roomJID]){
        _room = [[XMPPUtils sharedInstance]getExistRoom:_roomJID];
        [_room addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_room joinRoomUsingNickname:[XMPPUtils sharedInstance].xmppStream.myJID.user history:nil];
        [_room fetchModeratorsList];
        [_room fetchMembersList];
    }
    else{
        XMPPRoomCoreDataStorage *sharedRoomCoreDateStorage = [XMPPRoomCoreDataStorage sharedInstance];
        _room = [[XMPPRoom alloc]initWithRoomStorage:sharedRoomCoreDateStorage jid:_roomJID dispatchQueue:dispatch_get_main_queue()];
        [_room activate:[XMPPUtils sharedInstance].xmppStream];
        [_room addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_room joinRoomUsingNickname:[XMPPUtils sharedInstance].xmppStream.myJID.user history:nil];
    }
    
    
}

#pragma mark XMPPRoomDelegate

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"xmppRoomDidJoin");
    
    [[XMPPUtils sharedInstance] addRoom:_room];
    
    [_room fetchModeratorsList];
    [_room fetchMembersList];
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchModeratorsList:(NSArray *)items
{
    NSLog(@"didFetchModeratorsList");
    
    if([items count] > 0){
        for(NSXMLElement *element in items){
            [_membersArray addObject:element];
        }
    }
    
}

- (void)xmppRoom:(XMPPRoom *)sender didFetchMembersList:(NSArray *)items
{
    NSLog(@"didFetchMembersList");
    
    if([items count] > 0){
        for(NSXMLElement *element in items){
            [_membersArray addObject:element];
        }
    }
    if (!_isSelectMember) {
        [self performSegueWithIdentifier:@"GroupInfo2InviteGroupContact" sender:self];
    }
    
}


#pragma mark - Invite Friends

- (IBAction)inviteFriends:(id)sender {
    [self fetchMembers];
    _isSelectMember = NO;
}
@end
