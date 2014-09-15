//
//  ChatMainVC.m
//  QShare
//
//  Created by Vic on 14-4-3.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "ChatMainVC.h"
#import "XMPPUtils.h"
#import "ChatVC.h"
#import "chatListCell.h"
#import "GroupsChatVC.h"
#import "QSUtils.h"
#import "NoChatCell.h"

@interface ChatMainVC ()<xmppConnectDelegate>


@property(nonatomic,strong) XMPPUtils *sharedXMPP;
@property(nonatomic,strong) NSMutableArray *chatArray;
@property (nonatomic,strong) NSString *chatUserName;
@property int msgNum;


@end

@implementation ChatMainVC

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
    NSLog(@"---->Location:<----%@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]);
    _chatArray = [NSMutableArray arrayWithCapacity:20];
    _sharedXMPP = [XMPPUtils sharedInstance];
    _sharedXMPP.connectDelegate = self;
    [self setupLogin];
    
    [self addNotify];
    
    

}

- (void)viewWillAppear:(BOOL)animated
{
    
    [self.parentViewController.tabBarItem setBadgeValue:nil];
    _msgNum = 0;
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:XMPP_USER_NAME];
    NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_chatRecord",userName]];
    [_chatArray removeAllObjects];
    _chatArray = [NSMutableArray arrayWithArray:array];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
//    [self removeNotify];
}


- (void)setupLogin
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userName = [userDefaults objectForKey:XMPP_USER_NAME];
    NSString *pass = [userDefaults objectForKey:XMPP_USER_PASS];
    if(userName && pass)
    {
        [_sharedXMPP connect];
    }
    else
        [self performSegueWithIdentifier:SEGUE_CHAT_LOGIN sender:self];
    
    [QSUtils setExtraCellLineHidden:self.tableView];

}

- (void)addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatNotify:) name:NOTIFY_CHAT_MSG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendsRequestNotify:) name:NOTIFY_Friends_Request object:nil];

}

- (void)removeNotify
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_CHAT_MSG object:nil];
}

- (void)chatNotify:(NSNotification *)noti
{
    NSMutableDictionary *chatDict = [noti object];
    BOOL isOutgoing = [[chatDict objectForKey:@"isOutgoing"] boolValue];
    BOOL isExist = NO;
    NSUInteger index = 0;
    if (_chatArray) {
        for (NSMutableDictionary *obj in _chatArray) {
            if ([self isGroupChatType:chatDict]) {
                if ([obj[@"chatType"] isEqualToString:@"groupchat"] && [obj[@"roomJID"] isEqualToString: chatDict[@"roomJID"]]) {
                    isExist = YES;
                    index = [_chatArray indexOfObject:obj];
                    break;
                }
            }
            else
            {
                if ([[obj objectForKey:@"chatwith"] isEqualToString:chatDict[@"chatwith"]]) {
                    isExist = YES;
                    index = [_chatArray indexOfObject:obj];
                    break;
                }
            }
            
        }
        if (isExist) {
            [_chatArray removeObjectAtIndex:index];
            [_chatArray insertObject:chatDict atIndex:0];
        }
        else{
            [_chatArray insertObject:chatDict atIndex:0];
        }
    }
    else{
        [_chatArray insertObject:chatDict atIndex:0];
    }
    
    NSUInteger selectedIndex = [(UITabBarController *)self.parentViewController.parentViewController selectedIndex];
    if (!isOutgoing && (selectedIndex != 0)) {
        [self.parentViewController.tabBarItem setBadgeValue:[NSString stringWithFormat:@"%d",++_msgNum]];
    }
    
    [self.tableView reloadData];
    
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:XMPP_USER_NAME];
    [[NSUserDefaults standardUserDefaults] setObject:_chatArray forKey:[NSString stringWithFormat:@"%@_chatRecord",userName]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)friendsRequestNotify:(NSNotification *)noti
{
    NSString *requestType = [noti object];
    if ([requestType isEqualToString:@"friendsInvite"]) {
        [[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:3] tabBarItem] setBadgeValue:@"New"];
    }
}

#pragma mark - Intermediate Methods

- (BOOL)isGroupChatType:(NSDictionary *)dict
{
    if (dict[@"chatType"] && [dict[@"chatType"] isEqualToString:@"groupchat"]) {
        return YES;
    }
    return NO;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_chatArray count] == 0){
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.scrollEnabled = NO;
        self.tableView.userInteractionEnabled = NO;
        return 1;
    }
    else{
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.scrollEnabled = YES;
        self.tableView.userInteractionEnabled = YES;
        return [_chatArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_chatArray count] == 0){
        static NSString *NoChatCellIdentifier = @"No Chat Cell";
        NoChatCell *cell = [tableView dequeueReusableCellWithIdentifier:NoChatCellIdentifier];
        if (cell == nil) {
            cell = [[NoChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoChatCellIdentifier];
        }
        cell.showMessage.text = @"没有对话...";
        return cell;
    }
    
    static NSString *CellIdentifier = @"chatList";
    chatListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[chatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *chatDict = [_chatArray objectAtIndex:indexPath.row];
    NSString *body = [chatDict objectForKey:@"body"];
    NSMutableString *bodyString = [NSMutableString stringWithCapacity:40];
    if ([body hasPrefix:@"voiceBase64"]) {
        [bodyString appendString:@"[语音]"];
    }
    else if ([body hasPrefix:@"photoBase64"]){
        [bodyString appendString:@"[图片]"];

    }
    else if ([body hasPrefix:@"locationBase64"]){
        [bodyString appendString:@"[位置]"];
    }
    else
        [bodyString appendString:body];
    
    
    NSDate *timestamp = [chatDict objectForKey:@"timestamp"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM-dd hh:mm"];
    NSString *sendDate = [dateFormatter stringFromDate:timestamp];
    
    if ([self isGroupChatType:chatDict])
    {
        cell.avatar.image = [UIImage imageNamed:@"groupContact.png"];
        cell.chatWithName.text = [[XMPPJID jidWithString:chatDict[@"roomJID"]] user] ;
        cell.chatMessage.text = [NSString stringWithFormat:@"%@:%@",chatDict[@"from"],bodyString];
    }
    else
    {
        cell.avatar.image = [chatDict objectForKey:@"chatWithAvatar"] ? [UIImage imageWithData:[chatDict objectForKey:@"chatWithAvatar"]] : [UIImage imageNamed:@"avatar_default.png"];
        cell.chatWithName.text = chatDict[@"chatwith"];
        cell.chatMessage.text = bodyString;

    }
    
    
    cell.chatDate.text = sendDate;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([_chatArray count] == 0){
        return 300.0;
    }
    else{
        return 60.0;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    NSDictionary *chatDict = [_chatArray objectAtIndex:indexPath.row];
    
    if ([self isGroupChatType:chatDict]) {
        [self performSegueWithIdentifier:@"chatMain2GroupsChat" sender:self];
    }
    else{
        _chatUserName = (NSString *)[[_chatArray objectAtIndex:[indexPath row]] objectForKey:@"chatwith"];
        
        [self performSegueWithIdentifier:@"Chat2Chat" sender:self];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"Chat2Chat"]) {
        
        ChatVC *chatController = segue.destinationViewController;
        chatController.chatName = _chatUserName;
        
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
//        NSIndexPath *path = [self.tableView indexPathForCell:sender];
        NSDictionary *chatDict = [_chatArray objectAtIndex:indexPath.row];
        
        NSData *data = [chatDict objectForKey:@"chatWithAvatar"];
        
        if (data) {
            chatController.chatWithAvatar = data;
        }
    }
    
    else if ([segue.identifier isEqualToString:@"chatMain2GroupsChat"]){
        
        GroupsChatVC *vc = segue.destinationViewController;
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        NSDictionary *chatDict = [_chatArray objectAtIndex:indexPath.row];
        vc.roomJID = [XMPPJID jidWithString:chatDict[@"roomJID"]];
    }
    
    
}

#pragma mark -xmppConnectDelegate methods

- (void)didAuthenticate
{
    NSLog(@"yanzhengtongguo!");
   
}

- (void)didNotAuthenticate:(NSXMLElement *)error
{
    [self performSegueWithIdentifier:SEGUE_CHAT_LOGIN sender:self];
}



@end
