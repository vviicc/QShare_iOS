//
//  MessageNotificationCell.h
//  QShare
//
//  Created by Vic on 14-7-16.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageNotificationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *requestMessage;
@property (weak, nonatomic) IBOutlet UIButton *agerrBtn;
@property (weak, nonatomic) IBOutlet UIButton *blockBtn;
@property (weak, nonatomic) IBOutlet UILabel *requestResult;
@end
