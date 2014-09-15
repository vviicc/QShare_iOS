//
//  MessageNotification.m
//  QShare
//
//  Created by Vic on 14-7-16.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MessageNotification.h"
#import "MessageNotificationDetail.h"
#import "TDBadgedCell.h"
#import "messageNotificationUtils.h"
#import "QSUtils.h"

@interface MessageNotification ()

@property (nonatomic,strong) NSArray *dataArray;

@end

@implementation MessageNotification

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
    
    [QSUtils setExtraCellLineHidden:self.tableView];
    
    [self setup];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

#pragma mark - setup

- (void)setup
{
    _dataArray = @[@"朋友请求",@"群组邀请"];
}



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Message Notifications Cell";
    TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = _dataArray[indexPath.row];
    if (indexPath.row == 0) {
        if ([messageNotificationUtils unsolvedFriendRequest] != 0) {
            cell.badge.fontSize = 16.0;
            cell.badgeColor = [UIColor redColor];
            cell.badgeString = [NSString stringWithFormat:@"%d",[messageNotificationUtils unsolvedFriendRequest]];
        }
        else{
            [cell.badge setHidden:YES];
            cell.badgeColor = [UIColor whiteColor];
        }

    }
    else if (indexPath.row == 1) {
        if ([messageNotificationUtils unsolvedGroupRequest] != 0) {
            cell.badge.fontSize = 16.0;
            cell.badgeColor = [UIColor redColor];
            cell.badgeString = [NSString stringWithFormat:@"%d",[messageNotificationUtils unsolvedGroupRequest]];
        }
        else{
            [cell.badge setHidden:YES];
        }
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"MessageNotification2Detail" sender:self];
    
   
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MessageNotificationDetail *vc = segue.destinationViewController;
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if (indexPath.row == 0) {
        vc.isGroupRequest = NO;
    }
    
    else if (indexPath.row == 1){
        vc.isGroupRequest = YES;
    }
}




@end
