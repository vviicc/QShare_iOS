//
//  MeMainVC.m
//  QShare
//
//  Created by Vic on 14-4-3.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MeMainVC.h"
#import "XMPPUtils.h"
#import "LoginVC.h"
#import "TDBadgedCell.h"
#import "messageNotificationUtils.h"
#import "QSUtils.h"

#define SEGUE_ME_LOGIN @"Me2Login"
#define NOTIFY_BACK_CHAT @"notify_back_chat"

@interface MeMainVC ()<UIActionSheetDelegate,BackToChatTabDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) XMPPUtils *sharedXMPP;
@property (weak, nonatomic) IBOutlet UITableView *settingTV;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation MeMainVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sharedXMPP = [XMPPUtils sharedInstance];
    _settingTV.dataSource = self;
    _settingTV.delegate = self;
    
    _dataArray = [NSMutableArray arrayWithObjects:@"我的名片",@"消息通知", nil];
    
    [QSUtils setExtraCellLineHidden:_settingTV];
}


- (void)viewWillAppear:(BOOL)animated
{
    [self addNotify];
    [self.parentViewController.tabBarItem setBadgeValue:nil];
    [_settingTV reloadData];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotify];
}

- (IBAction)logout:(id)sender
{
    UIActionSheet *loginAction = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"退出当前帐号" otherButtonTitles:nil, nil];
    [loginAction showInView:self.view];
}

#pragma mark - Message Notification

- (BOOL)hasUnsolvedRequest
{
    return ([messageNotificationUtils unsolvedFriendRequest] + [messageNotificationUtils unsolvedGroupRequest]) > 0;
}


#pragma mark -UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults removeObjectForKey:XMPP_USER_PASS];
        [userDefaults synchronize];
        [_sharedXMPP disconnect];
        [self performSegueWithIdentifier:SEGUE_ME_LOGIN sender:self];
    }
}

#pragma mark -UITableViewDataSource methods


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"settingCell";
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [_dataArray objectAtIndex:indexPath.row];
    if (indexPath.row == 1) {
        if ([self hasUnsolvedRequest]) {
            cell.badge.fontSize = 16.0;
            cell.badgeColor = [UIColor redColor];
            cell.badgeString = @"New";
        }
        else{
            [cell.badge setHidden:YES];
            cell.badgeColor = [UIColor whiteColor];
        }

    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_settingTV deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.row == 0){
        [self performSegueWithIdentifier:@"Me2MyVcard" sender:self];
    }
    
    else if(indexPath.row == 1){
        [self performSegueWithIdentifier:@"Me2MessageNotification" sender:self];
    }
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:SEGUE_ME_LOGIN]) {
        UINavigationController *nav = segue.destinationViewController;
        LoginVC *login = [[nav viewControllers]objectAtIndex:0];
        login.backToChatDelegate = self;
        login.isFromME = YES;
    }
   
}

-(void)addNotify
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backtochatNotify) name:NOTIFY_BACK_CHAT object:nil];
}

-(void)backtochatNotify
{
    [self backToChatTab];

}

-(void)removeNotify
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFY_BACK_CHAT object:nil];
}

#pragma mark -BackToChatTabDelegate methods

-(void)backToChatTab
{
    [(UITabBarController *)self.parentViewController.parentViewController setSelectedIndex:0];
}


@end
