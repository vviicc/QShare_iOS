//
//  InviteGroupContacts.m
//  QShare
//
//  Created by Vic on 14-7-14.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "InviteGroupContacts.h"
#import "MyFriendCell.h"
#import "XMPPUtils.h"
#import "XMPPRoom.h"

#define USERNAME @"username"
#define AVATARDATA @"avatardata"

@interface InviteGroupContacts ()<xmppFriendsDelegate,UITextFieldDelegate>

@property (nonatomic,strong) XMPPUtils *sharedXMPPUtils;
@property (nonatomic,strong) NSMutableArray *friends;
@property (nonatomic,strong) NSMutableArray *selectFriendsJIDs;
@property (nonatomic) NSUInteger selectedFriendsCount;
@property (nonatomic,strong) XMPPRoom *room;
@property (nonatomic,strong) NSString *inviteMessage;

- (IBAction)invite:(id)sender;
- (IBAction)cancel:(id)sender;


@end

@implementation InviteGroupContacts

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

#pragma mark - Setup

- (void)setup
{
    _friends = [NSMutableArray array];
    _sharedXMPPUtils = [XMPPUtils sharedInstance];
    _selectFriendsJIDs = [NSMutableArray array];
    _sharedXMPPUtils.friendsDelegate = self;
    [_sharedXMPPUtils queryRoster];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Invite Group Contacts";
    MyFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(cell == nil){
        cell = [[MyFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSString *userName = [[_friends objectAtIndex:indexPath.row] objectForKey:USERNAME];
    cell.name.text = userName;
    NSData *data = [[_friends objectAtIndex:indexPath.row] objectForKey:AVATARDATA];
    if (data) {
        cell.avatarImage.image = [UIImage imageWithData:data];
    }
    
    if ([self isJoinedGroup:userName]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = NO;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark - Intermediate Methods

- (BOOL)isJoinedGroup:(NSString *)friendName
{
    for (NSXMLElement *element in _joinedFriends) {
        XMPPJID *jid = [XMPPJID jidWithString:[element attributeStringValueForName:@"jid"]];
        NSString *nickName = [element attributeStringValueForName:@"nick"];
        if (!nickName) {
            nickName = [jid user];
        }
        if ([nickName isEqualToString:friendName]) {
            return true;
        }
    }
    return false;
}

#pragma mark -UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *selectFriendName = [[_friends objectAtIndex:indexPath.row] objectForKey:USERNAME];
    XMPPJID *selectedFriendJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",selectFriendName,XMPP_HOST_NAME]];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    (cell.accessoryType == UITableViewCellAccessoryNone) ?
    (cell.accessoryType = UITableViewCellAccessoryCheckmark) :
    (cell.accessoryType = UITableViewCellAccessoryNone);
    (cell.accessoryType == UITableViewCellAccessoryNone) ? (_selectedFriendsCount--) : (_selectedFriendsCount++);
    (cell.accessoryType == UITableViewCellAccessoryNone) ? ([_selectFriendsJIDs removeObject:selectedFriendJID]) : ([_selectFriendsJIDs addObject:selectedFriendJID]);
    
    self.navigationItem.rightBarButtonItem.enabled = (_selectedFriendsCount > 0) ? YES : NO ;
    self.navigationItem.rightBarButtonItem.title = (_selectedFriendsCount > 0) ? [NSString stringWithFormat:@"邀请(%d)",_selectedFriendsCount] : @"邀请";
}

#pragma mark xmppFriendsDelegate methods

-(void)removeFriens
{
    if(_friends)
        [_friends removeAllObjects];
    
}

-(void)friendsList:(NSDictionary *)dict
{
    NSMutableDictionary *_friendDict = [NSMutableDictionary dictionaryWithCapacity:4];
    [_friendDict setObject:dict[@"name"] forKey:USERNAME];
    if ([dict objectForKey:@"avatar"]) {
        [_friendDict setObject:dict[@"avatar"] forKey:AVATARDATA];
    }
    [_friends addObject:_friendDict];
    [self.tableView reloadData];
}

#pragma mark - UI Action

- (IBAction)invite:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"邀请" message:@"请输入邀请内容" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.delegate = self;
    [alertView show];
}

- (IBAction)cancel:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        _inviteMessage = textField.text;
        
        [self inviteFriend];
    }
    else
        return;
}

#pragma mark - XMPP Room

- (void)inviteFriend
{
    if([[XMPPUtils sharedInstance]isExistRoom:_roomJID]){
        _room = [[XMPPUtils sharedInstance]getExistRoom:_roomJID];
        [_room addDelegate:self delegateQueue:dispatch_get_main_queue()];
        [_room joinRoomUsingNickname:[XMPPUtils sharedInstance].xmppStream.myJID.user history:nil];
        
        if (_selectFriendsJIDs) {
            for (XMPPJID *jid in _selectFriendsJIDs) {
                [_room inviteUser:jid withMessage:_inviteMessage];
                [_room editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"member" jid:jid]]];
                
            }
        }
        
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
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
    
    if (_selectFriendsJIDs) {
        for (XMPPJID *jid in _selectFriendsJIDs) {
            [sender inviteUser:jid withMessage:_inviteMessage];
            [sender editRoomPrivileges:@[[XMPPRoom itemWithAffiliation:@"member" jid:jid]]];

        }
    }
    
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)xmppRoom:(XMPPRoom *)sender didEditPrivileges:(XMPPIQ *)iqResult
{
    NSLog(@"didEditPrivileges");
    NSLog(@"%@",iqResult);
}


@end

