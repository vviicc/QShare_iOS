//
//  LoginVC.h
//  QShare
//
//  Created by Vic on 14-4-3.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BackToChatTabDelegate <NSObject>

@optional
-(void)backToChatTab;

@end


@interface LoginVC : UIViewController<XMPPStreamDelegate>


@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak,nonatomic) id<BackToChatTabDelegate> backToChatDelegate;
@property (nonatomic) BOOL isFromME;

- (IBAction)login:(id)sender;
- (IBAction)enroll:(id)sender;

@end
