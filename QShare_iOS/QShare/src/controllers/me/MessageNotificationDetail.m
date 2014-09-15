//
//  MessageNotificationDetail.m
//  QShare
//
//  Created by Vic on 14-7-16.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MessageNotificationDetail.h"
#import "XMPPUtils.h"
#import "MessageNotificationCell.h"


@interface MessageNotificationDetail ()

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) XMPPRoom *room;

- (IBAction)agree:(id)sender;
- (IBAction)block:(id)sender;
@end

@implementation MessageNotificationDetail

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

}

-(void)setup{
    _dataArray = [NSMutableArray array];
    
    NSString *myString = [[XMPPUtils sharedInstance].xmppStream.myJID user];
    NSString *defaultName;
    if (_isGroupRequest) {
        defaultName = [NSString stringWithFormat:@"%@_groupInvite",myString];

    }
    else{
       defaultName = [NSString stringWithFormat:@"%@_requestRoster",myString];
    }
    
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:defaultName]) {
        
        _dataArray = [[[NSUserDefaults standardUserDefaults] objectForKey:defaultName] mutableCopy];
    }
}


#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Message Notification Detail";
    MessageNotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[MessageNotificationCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *dict = [_dataArray objectAtIndex:indexPath.row];
    if(_isGroupRequest){
        if (dict[@"result"]) {
            cell.agerrBtn.hidden = YES;
            cell.blockBtn.hidden = YES;
            cell.requestResult.hidden = NO;
            cell.requestResult.text = [NSString stringWithFormat:@"已%@",dict[@"result"]];
        }
        else{
            cell.requestResult.hidden = YES;
        }
        NSString *fromString = dict[@"from"];
        NSString *fromUser = [[XMPPJID jidWithString:fromString]user];
        NSString *roomName = dict[@"room"];
        NSString *reason = dict[@"reason"];
        
        cell.requestMessage.text = [NSString stringWithFormat:@"%@邀请您加入%@群:%@",fromUser,roomName,reason];
    }
    else{
        if (dict[@"result"]) {
            cell.agerrBtn.hidden = YES;
            cell.blockBtn.hidden = YES;
            cell.requestResult.hidden = NO;
            cell.requestResult.text = [NSString stringWithFormat:@"已%@",dict[@"result"]];
        }
        else{
            cell.requestResult.hidden = YES;
        }
        NSString *fromString = dict[@"from"];
        NSString *fromUser = [[XMPPJID jidWithString:fromString]user];
        cell.requestMessage.text = [NSString stringWithFormat:@"%@请求加您为好友",fromUser];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 60.0;
}



#pragma mark - UI Actions

- (IBAction)agree:(id)sender {
    // Group Invite
    if (_isGroupRequest) {
        UIButton *button = (UIButton *)sender;
        CGRect buttonFrame = [button convertRect:button.bounds toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
        NSMutableDictionary *dict = [[_dataArray objectAtIndex:indexPath.row] mutableCopy];
        XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",dict[@"room"],XMPP_MUC_SERVICE]];
        if ([[XMPPUtils sharedInstance]isExistRoom:roomJID]) {
            XMPPRoom *room = [[XMPPUtils sharedInstance]getExistRoom:roomJID];
            [room joinRoomUsingNickname:[XMPPUtils sharedInstance].xmppStream.myJID.user history:nil];
        }
        else{
            XMPPRoomCoreDataStorage *sharedRoomCoreDateStorage = [XMPPRoomCoreDataStorage sharedInstance];
            _room = [[XMPPRoom alloc]initWithRoomStorage:sharedRoomCoreDateStorage jid:roomJID dispatchQueue:dispatch_get_main_queue()];
            [_room activate:[XMPPUtils sharedInstance].xmppStream];
            [_room addDelegate:self delegateQueue:dispatch_get_main_queue()];
            [_room joinRoomUsingNickname:[XMPPUtils sharedInstance].xmppStream.myJID.user history:nil];
        }
        
        
        [dict setObject:@"接受" forKey:@"result"];
        [_dataArray setObject:dict atIndexedSubscript:indexPath.row];
        
        NSString *myString = [[XMPPUtils sharedInstance].xmppStream.myJID user];
        NSString *defaultName = [NSString stringWithFormat:@"%@_groupInvite",myString];
        [[NSUserDefaults standardUserDefaults] setObject:_dataArray forKey:defaultName];
        [[NSUserDefaults standardUserDefaults]synchronize];

    }
    // Request Roster
    else{
        XMPPRoster *sharedRoster = [XMPPUtils sharedInstance].xmppRoster;
        UIButton *button = (UIButton *)sender;
        CGRect buttonFrame = [button convertRect:button.bounds toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
        
        NSMutableDictionary *dict = [[_dataArray objectAtIndex:indexPath.row] mutableCopy];
        XMPPJID *fromJID = [XMPPJID jidWithString:dict[@"from"]];
        
        [sharedRoster acceptPresenceSubscriptionRequestFrom:fromJID andAddToRoster:YES];
        
        [dict setObject:@"同意" forKey:@"result"];
        [_dataArray setObject:dict atIndexedSubscript:indexPath.row];
        
        NSString *myString = [[XMPPUtils sharedInstance].xmppStream.myJID user];
        NSString *requestRosterDefault = [NSString stringWithFormat:@"%@_requestRoster",myString];
        [[NSUserDefaults standardUserDefaults] setObject:_dataArray forKey:requestRosterDefault];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    
    
    [self.tableView reloadData];
}

- (IBAction)block:(id)sender {
    // Group invite
    if (_isGroupRequest) {
        UIButton *button = (UIButton *)sender;
        CGRect buttonFrame = [button convertRect:button.bounds toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonFrame.origin];
        NSMutableDictionary *dict = [[_dataArray objectAtIndex:indexPath.row] mutableCopy];
        [dict setObject:@"拒绝" forKey:@"result"];
        [_dataArray setObject:dict atIndexedSubscript:indexPath.row];
        
        NSString *myString = [[XMPPUtils sharedInstance].xmppStream.myJID user];
        NSString *defaultName = [NSString stringWithFormat:@"%@_groupInvite",myString];
        [[NSUserDefaults standardUserDefaults] setObject:_dataArray forKey:defaultName];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    // Request Roster
    else{
        XMPPRoster *sharedRoster = [XMPPUtils sharedInstance].xmppRoster;
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSMutableDictionary *dict = [[_dataArray objectAtIndex:indexPath.row] mutableCopy];
        XMPPJID *fromJID = [XMPPJID jidWithString:dict[@"from"]];
        
        [sharedRoster rejectPresenceSubscriptionRequestFrom:fromJID];
        
        [dict setObject:@"拒绝" forKey:@"result"];
        [_dataArray setObject:dict atIndexedSubscript:indexPath.row];
        
        NSString *myString = [[XMPPUtils sharedInstance].xmppStream.myJID user];
        NSString *requestRosterDefault = [NSString stringWithFormat:@"%@_requestRoster",myString];
        [[NSUserDefaults standardUserDefaults] setObject:_dataArray forKey:requestRosterDefault];
        [[NSUserDefaults standardUserDefaults]synchronize];

    }

    
    [self.tableView reloadData];
}

#pragma mark - XMPPRoomDelegate

- (void)xmppRoomDidJoin:(XMPPRoom *)sender
{
    NSLog(@"xmppRoomDidJoin");
    
    [[XMPPUtils sharedInstance] addRoom:_room];
}

@end
