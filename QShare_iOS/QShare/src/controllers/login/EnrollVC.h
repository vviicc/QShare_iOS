//
//  EnrollVC.h
//  QShare
//
//  Created by Vic on 14-4-3.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EnrollVC : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *userName;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (nonatomic) BOOL isFromME;

- (IBAction)enroll:(id)sender;

@end
