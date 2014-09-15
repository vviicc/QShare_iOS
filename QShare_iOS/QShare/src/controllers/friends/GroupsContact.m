//
//  GroupsContact.m
//  QShare
//
//  Created by Vic on 14-7-7.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "GroupsContact.h"
#import "MyFriendCell.h"
#import "XMPPUtils.h"
#import "GroupsChatVC.h"

@interface GroupsContact ()

@property (nonatomic,strong) NSArray *roomJIDs;

@end

@implementation GroupsContact

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
    [self setupGroupsContact];
    
    self.title = @"群组";

}

- (void)setupGroupsContact
{
    _roomJIDs = [self fetchRoomJIDsFromCoreData];
}

#pragma mark - Fetch Rooms From CoreData

- (NSArray *)fetchRoomJIDsFromCoreData
{
    NSManagedObjectContext *context = [[XMPPRoomCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPRoomOccupantCoreDataStorageObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@",[[XMPPUtils sharedInstance].xmppStream.myJID bare]];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *dataArray = [context executeFetchRequest:request error:&error];
    
    NSMutableOrderedSet *orderedSet = [[NSMutableOrderedSet alloc]init];
    for (XMPPRoomOccupantCoreDataStorageObject *roomMessage in dataArray) {
        [orderedSet addObject:roomMessage.roomJID];
    }
    
    return [orderedSet array];
}


#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [_roomJIDs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Groups Contact Cell";
    MyFriendCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[MyFriendCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.name.text = [(XMPPJID *)[_roomJIDs objectAtIndex:indexPath.row] user];
    
    return cell;
}



#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

#pragma mark - Prapare For Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GroupsContact2GroupsChat"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        XMPPJID *roomJID = [_roomJIDs objectAtIndex:indexPath.row];
        [(GroupsChatVC *)segue.destinationViewController setRoomJID:roomJID];
    }
}


@end
