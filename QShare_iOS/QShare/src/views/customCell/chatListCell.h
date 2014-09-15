//
//  chatListCell.h
//  QShare
//
//  Created by Vic on 14-6-25.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface chatListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *chatWithName;
@property (weak, nonatomic) IBOutlet UILabel *chatDate;
@property (weak, nonatomic) IBOutlet UILabel *chatMessage;


@end
