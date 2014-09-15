//
//  EnrollVC.m
//  QShare
//
//  Created by Vic on 14-4-3.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "EnrollVC.h"
#import "XMPPUtils.h"
#import "QSUtils.h"
#import "MeMainVC.h"

#define NOTIFY_BACK_CHAT @"notify_back_chat"


@interface EnrollVC ()<xmppConnectDelegate,UIAlertViewDelegate>

@end

@implementation EnrollVC

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
    XMPPUtils *sharedXMPP = [XMPPUtils sharedInstance];
    sharedXMPP.connectDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)enroll:(id)sender
{
    NSString *userName = [_userName text];
    NSString *pass = [_password text];
    if([QSUtils isEmpty:userName] || [QSUtils isEmpty:pass])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户名和密码不能为空" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        XMPPUtils *sharedXMPP = [XMPPUtils sharedInstance];
        [sharedXMPP anonymousConnect];
    }

}


- (void)registerSuccess
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册帐号成功"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    alertView.tag = 11;
    [alertView show];
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11) {
        NSString *userName = [_userName text];
        NSString *pass = [_password text];
        
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:userName forKey:XMPP_USER_NAME];
        [userDefaults setObject:pass forKey:XMPP_USER_PASS];
        [userDefaults synchronize];
        XMPPUtils *sharedXMPP = [XMPPUtils sharedInstance];
        [sharedXMPP connect];

    }
}

- (void)registerFailed:(NSXMLElement *)error
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"注册帐号失败"
                                                        message:@"用户名冲突"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)anonymousConnected
{
    NSString *userName = [_userName text];
    NSString *pass = [_password text];
    XMPPUtils *sharedXMPP = [XMPPUtils sharedInstance];
    [sharedXMPP enrollWithUserName:userName andPassword:pass];
}

- (void)didAuthenticate
{
    [self dismissViewControllerAnimated:YES completion:nil];
    if (_isFromME) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_BACK_CHAT object:self];
    }

    
}

- (void)didNotAuthenticate:(NSXMLElement *)error
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"用户名或密码不正确" message:nil delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
    [alert show];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
