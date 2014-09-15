//
//  CreatOrSelectGroupChatVC.m
//  QShare
//
//  Created by Vic on 14-7-5.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "CreatOrSelectGroupChatVC.h"
#import "createGroupChatCell.h"
#import "XMPPUtils.h"
#import "GroupChatUtils.h"
#import "ChatMainVC.h"

#define USERNAME @"username"
#define AVATARDATA @"avatardata"


@interface CreatOrSelectGroupChatVC ()<xmppFriendsDelegate,UITextFieldDelegate,UIAlertViewDelegate,RoomDelegate>

@property (nonatomic,strong) NSMutableArray *friends;
@property (nonatomic,strong) XMPPUtils *sharedXMPPUtils;
@property (nonatomic) NSUInteger selectedFriendsCount;
@property (nonatomic,strong) NSMutableArray *selectFriendsJIDs;
@property (nonatomic,strong) GroupChatUtils *groupChatUtils;

@end

@implementation CreatOrSelectGroupChatVC

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
    
    [self setupFriendData];
    
}

- (void)setupFriendData
{
    _friends = [NSMutableArray array];
    _sharedXMPPUtils = [XMPPUtils sharedInstance];
    _selectFriendsJIDs = [NSMutableArray array];
    _sharedXMPPUtils.friendsDelegate = self;
    [_sharedXMPPUtils queryRoster];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)ok:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请输入群名" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"OK", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *textField = [alertView textFieldAtIndex:0];
    textField.delegate = self;
    [alertView show];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_friends count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *creatGruopChatCellIdentifier = @"Creat Group Chat";
    static NSString *selectGruopChatCellIdentifier = @"Select Group Chat";
    
    if (indexPath.row == 0) {

        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectGruopChatCellIdentifier];
        cell.textLabel.text = @"选择一个已经创建的群聊天";
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else{
        
        createGroupChatCell *cell = [tableView dequeueReusableCellWithIdentifier:creatGruopChatCellIdentifier forIndexPath:indexPath];
        if (!cell) {
            cell = [[createGroupChatCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:creatGruopChatCellIdentifier];
        }
        
        cell.name.text = [[_friends objectAtIndex:indexPath.row - 1] objectForKey:USERNAME];
        NSData *data = [[_friends objectAtIndex:indexPath.row - 1] objectForKey:AVATARDATA];
        if (data) {
            cell.avatarImage.image = [UIImage imageWithData:data];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark -UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

      
    if (indexPath.row == 0) {
        UITabBarController *tabBarController = (UITabBarController *)self.presentingViewController;
        UINavigationController *navigationController = tabBarController.viewControllers[0];
        ChatMainVC *chatMain = (ChatMainVC *)navigationController.topViewController;
        [chatMain performSegueWithIdentifier:@"CreateOrSelect Group 2 GroupContacts" sender:self];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else{
        NSString *selectFriendName = [[_friends objectAtIndex:indexPath.row - 1] objectForKey:USERNAME];
        XMPPJID *selectedFriendJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",selectFriendName,XMPP_HOST_NAME]];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        (cell.accessoryType == UITableViewCellAccessoryNone) ?
        (cell.accessoryType = UITableViewCellAccessoryCheckmark) :
        (cell.accessoryType = UITableViewCellAccessoryNone);
        (cell.accessoryType == UITableViewCellAccessoryNone) ? (_selectedFriendsCount--) : (_selectedFriendsCount++);
        (cell.accessoryType == UITableViewCellAccessoryNone) ? ([_selectFriendsJIDs removeObject:selectedFriendJID]) : ([_selectFriendsJIDs addObject:selectedFriendJID]);

        self.navigationItem.rightBarButtonItem.enabled = (_selectedFriendsCount > 0) ? YES : NO ;
        self.navigationItem.rightBarButtonItem.title = (_selectedFriendsCount > 0) ? [NSString stringWithFormat:@"OK(%d)",_selectedFriendsCount] : @"OK";
        
    }
}


#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"OK"]) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *groupName = textField.text;
        _groupChatUtils = [[GroupChatUtils alloc]init];
        _groupChatUtils.delegate = self;
        _groupChatUtils.selectedJIDs = [_selectFriendsJIDs copy];
        [_groupChatUtils createRoomWithName:groupName];
    }
    else
        return;
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    return [[alertView textFieldAtIndex:0].text length] > 0 ;
}

#pragma mark RoomDelegate

- (void) didInviteUserSuccess
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) existSameRoom
{
    [self dismissViewControllerAnimated:YES completion:nil];
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



@end
