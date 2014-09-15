//
//  AddFriends.m
//  QShare
//
//  Created by Vic on 14-4-28.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "AddFriends.h"
#import "XMPPUtils.h"

@interface AddFriends ()

@end

@implementation AddFriends

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
	// Do any additional setup after loading the view.
}


- (IBAction)addFriend:(id)sender {
    NSString *userName = [_userName text];
    
    XMPPUtils *sharedXMPP = [XMPPUtils sharedInstance];
    [sharedXMPP addFriend:userName];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
