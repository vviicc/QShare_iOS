//
//  LoginVC.m
//  QShare
//
//  Created by Vic on 14-4-3.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "LoginVC.h"
#import "EnrollVC.h"
#import "XMPPUtils.h"
#import "QSUtils.h"

#define SEGUE_LOGIN_ENROLL @"login2Enroll"

@interface LoginVC ()<xmppConnectDelegate>
@property (nonatomic,strong) XMPPUtils *sharedXMPP;

@end

@implementation LoginVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sharedXMPP = [XMPPUtils sharedInstance];
    _sharedXMPP.connectDelegate = self;

}

-(void)viewWillAppear:(BOOL)animated
{
    _sharedXMPP.connectDelegate = self;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)login:(id)sender
{
    NSString *userName = [_userName text];
    NSString *pass = [_password text];
    if ([QSUtils isEmpty:userName] || [QSUtils isEmpty:pass])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户名和密码不能为空" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userName forKey:XMPP_USER_NAME];
        [userDefaults setObject:pass forKey:XMPP_USER_PASS];
        [userDefaults synchronize];
        
        [_sharedXMPP connect];
    }

        
}

- (IBAction)enroll:(id)sender
{
    [self performSegueWithIdentifier:SEGUE_LOGIN_ENROLL sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_LOGIN_ENROLL]) {
        EnrollVC *enroll = segue.destinationViewController;
        enroll.isFromME = _isFromME;
    }
}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark XMPPConnectionDelegate methods
- (void)didAuthenticate
{
    if(_isFromME)
        [_backToChatDelegate backToChatTab];
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didNotAuthenticate:(NSXMLElement *)error
{
    [self clearUserDefaults];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户名或密码不正确" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)clearUserDefaults
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:XMPP_USER_NAME];
    [userDefaults removeObjectForKey:XMPP_USER_PASS];
    [userDefaults synchronize];
}
@end
