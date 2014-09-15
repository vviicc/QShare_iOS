//
//  FriendsMainVC.m
//  QShare
//
//  Created by Vic on 14-4-3.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "FriendsMainVC.h"
#import "XMPPUtils.h"
#import "ChatVC.h"
#import "MyFriendCell.h"
#import "XMPPvCardTemp.h"
#import "QSUtils.h"

#define USERNAME @"username"
#define AVATARDATA @"avatardata"

@interface FriendsMainVC ()<xmppFriendsDelegate>

@property (nonatomic,strong) XMPPUtils *sharedXMPP;
@property (nonatomic,strong) NSString *chatUserName;



@end

@implementation FriendsMainVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_sharedXMPP queryRoster];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _friendsArray = [NSMutableArray array];
    _sharedXMPP = [XMPPUtils sharedInstance];
    _sharedXMPP.friendsDelegate = self;
    [self addFriendsBarButton];
    
    [QSUtils setExtraCellLineHidden:self.tableView];
}


- (void)addFriendsBarButton
{
    UIBarButtonItem *addFriendsBarButton = [[UIBarButtonItem alloc]initWithTitle:@"找个朋友" style:UIBarButtonItemStylePlain target:self action:@selector(addfriends)];
    self.navigationItem.rightBarButtonItem = addFriendsBarButton;
}

- (void)addfriends
{
    [self performSegueWithIdentifier:@"Friends2AddFriends" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_friendsArray count] + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"friendCell";
    MyFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[MyFriendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0) {
        cell.name.text = @"群组";
        cell.avatarImage.image = [UIImage imageNamed:@"groupContact.png"];
    }

    else if ([_friendsArray count]) {
        cell.name.text = [[_friendsArray objectAtIndex:[indexPath row] - 1] objectForKey:USERNAME];
        NSData *data = [[_friendsArray objectAtIndex:[indexPath row] - 1] objectForKey:AVATARDATA];
        if (data) {
            cell.avatarImage.image = [UIImage imageWithData:data];
        }

}
    
    //标记
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (indexPath.row == 0) {
        [self performSegueWithIdentifier:@"Friends2GroupsContact" sender:self];
    }
    else{
        _chatUserName = (NSString *)[[_friendsArray objectAtIndex:[indexPath row] - 1] objectForKey:USERNAME];
        
        [self performSegueWithIdentifier:@"Friends2Chat" sender:self];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"Friends2Chat"]) {
        ChatVC *chatController = segue.destinationViewController;
        
        chatController.chatName = _chatUserName;
        
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        NSData *chatWithdata = [[_friendsArray objectAtIndex:[indexPath row] - 1] objectForKey:AVATARDATA];
        if (chatWithdata) {
            chatController.chatWithAvatar = chatWithdata;
        }
    }
    
}

/*

#pragma mark xmppPresentDelegate implement

- (void)online:(NSString *)userName
{

    for (NSMutableDictionary *friend in _friendsArray) {
        if ([[friend objectForKey:USERNAME] isEqualToString:userName]) {
            NSMutableDictionary *onlineFriend = [friend mutableCopy];
            [_friendsArray removeObjectIdenticalTo:friend];
            present_type online_present = online;
            [onlineFriend setObject:[NSNumber numberWithInt:online_present] forKey:PRESENT];
            [_friendsArray insertObject:onlineFriend atIndex:0];
            break;
        }
    }
    [self.tableView reloadData];
}

- (void)offline:(NSString *)userName
{
    
    for (NSMutableDictionary *friend in _friendsArray) {
        if ([[friend objectForKey:USERNAME] isEqualToString:userName]) {
            NSMutableDictionary *offlineFriend = [friend mutableCopy];
            [_friendsArray removeObjectIdenticalTo:friend];
            present_type offline_present = offline;
            [offlineFriend setObject:[NSNumber numberWithInt:offline_present] forKey:PRESENT];
            [_friendsArray addObject:offlineFriend];
            break;
        }
    }
    [self.tableView reloadData];

}
 
 */

#pragma mark xmppFriendsDelegate implement

-(void)removeFriens
{
    if(_friendsArray)
        [_friendsArray removeAllObjects];
        [self.tableView reloadData];

}

- (void)friendsList:(NSDictionary *)dict
{
    NSMutableDictionary *_friendDict = [NSMutableDictionary dictionaryWithCapacity:4];
    [_friendDict setObject:dict[@"name"] forKey:USERNAME];
    if ([dict objectForKey:@"avatar"]) {
        [_friendDict setObject:dict[@"avatar"] forKey:AVATARDATA];
    }
    [_friendsArray addObject:_friendDict];
    [self.tableView reloadData];
}

@end
