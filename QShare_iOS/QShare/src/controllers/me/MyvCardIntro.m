//
//  MyvCardIntro.m
//  QShare
//
//  Created by Vic on 14-6-4.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MyvCardIntro.h"
#import "QSUtils.h"

@interface MyvCardIntro ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *myIntroduce;

@end

@implementation MyvCardIntro

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
    
    if (_introduce) {
        _myIntroduce.text = _introduce;
    }
    [_myIntroduce becomeFirstResponder];
    _myIntroduce.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -UITextFieldDelegate methods
//- (void)textFieldDidEndEditing:(UITextField *)textField
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_myIntroduce resignFirstResponder];
    if ([QSUtils isEmpty:textField.text]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"您没有写任何内容哦" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        [_delegate didEditIntroduce:textField.text];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
}



@end
