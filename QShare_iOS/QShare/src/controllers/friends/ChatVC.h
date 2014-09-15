//
//  ChatVC.h
//  QShare
//
//  Created by Vic on 14-4-19.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableView.h"
#import "UIBubbleTableViewDataSource.h"
#import "NSBubbleData.h"


@interface ChatVC : UIViewController
@property (nonatomic,strong) NSString *chatName;
@property (nonatomic,strong) NSData *chatWithAvatar;
@property (nonatomic,strong) NSData *myAvatar;
@property (strong, nonatomic) IBOutlet UIBubbleTableView *bubbleTable;
@property (strong, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIImageView *soundLoadingImageView;
@property (weak, nonatomic) IBOutlet UIView *recordView;
@property (weak, nonatomic) IBOutlet UIView *showMoreView;
- (IBAction)sendButton:(id)sender;
- (IBAction)beginAudio:(id)sender;
- (IBAction)endAudio:(id)sender;
- (IBAction)sendPhoto:(id)sender;
- (IBAction)sendLocation:(id)sender;
- (IBAction)showMore:(id)sender;
@end
