//
//  InviteGroupContacts.h
//  QShare
//
//  Created by Vic on 14-7-14.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteGroupContacts : UITableViewController

@property (nonatomic,strong) XMPPJID *roomJID;
@property (nonatomic,strong) NSArray *joinedFriends;

@end
