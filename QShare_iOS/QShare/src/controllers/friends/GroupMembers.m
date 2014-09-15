//
//  GroupMembers.m
//  QShare
//
//  Created by Vic on 14-7-14.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "GroupMembers.h"
#import "XMPPUtils.h"
#import "MyFriendCell.h"
#import "XMPPvCardTemp.h"

@interface GroupMembers ()<XMPPRoomDelegate>

@property (nonatomic,strong) XMPPRoom *room;
@property (nonatomic,strong) NSMutableArray *membersArray;

@end

@implementation GroupMembers

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

    [self setup];
    [self fetchMembers];
}



#pragma mark - Set up

- (void)setup
{
    self.title = @"成员信息";
    _membersArray = [NSMutableArray array];
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
   
    [self.tableView reloadData];

}



#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_membersArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Group Members";
    MyFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil)
        cell = [[MyFriendCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    XMPPJID *jid = [XMPPJID jidWithString:[[_membersArray objectAtIndex:indexPath.row] attributeStringValueForName:@"jid"]];
    NSString *nickName = [[_membersArray objectAtIndex:indexPath.row] attributeStringValueForName:@"nick"];
    if (!nickName) {
        nickName = [jid user];
    }
    [[XMPPUtils sharedInstance].xmppvCardTempModule fetchvCardTempForJID:jid];
    XMPPvCardTemp *vCard = [[XMPPUtils sharedInstance].xmppvCardTempModule vCardTempForJID:jid shouldFetch:YES];
    NSData *avatarData = vCard.photo;
    
    cell.name.text = nickName;
    cell.avatarImage.image = avatarData ? [UIImage imageWithData:avatarData] :[UIImage imageNamed:@"avatar_default.png"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


@end
