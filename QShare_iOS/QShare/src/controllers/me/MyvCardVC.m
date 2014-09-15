//
//  MyvCardVC.m
//  QShare
//
//  Created by Vic on 14-6-2.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MyvCardVC.h"
#import "XMPPUtils.h"
#import "XMPPvCardTemp.h";
#import "vCard.h"
#import "MyvCardSex.h"
#import "MyvCardIntro.h"
#import "QBImagePickerController.h"


@interface MyvCardVC ()<UIActionSheetDelegate,QBImagePickerControllerDelegate,MyvCardDelegate,XMPPvCardTempModuleDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *sex;
@property (weak, nonatomic) IBOutlet UILabel *introduce;
@property (nonatomic,strong) vCard *card;
@property (nonatomic,strong) XMPPvCardTemp *myvCard;
@property (nonatomic,strong) XMPPvCardTempModule *vCardTempModule;

@end

@implementation MyvCardVC

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initUserInfo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _card = [[vCard alloc]init];
    [self setupvCardTemp];

}


- (void)setupvCardTemp
{
    _vCardTempModule = [[XMPPUtils sharedInstance] xmppvCardTempModule];
    [_vCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _myvCard = [_vCardTempModule myvCardTemp];
}


- (void)initUserInfo
{
    if (_myvCard.photo) {
        _card.avatarData = _myvCard.photo;
    }
    if (_myvCard.sex) {
        _card.sex = _myvCard.sex;
    }
    if (_myvCard.title) {
        _card.introduce = _myvCard.title;
    }
    if (_myvCard.mailer) {
        _card.location = _myvCard.mailer;
    }
    
    [self setupUserInfo];
    
}

- (void)setupUserInfo
{
    NSString *blackString = @"未填写";
    _sex.text = _card.sex ? _card.sex :blackString;
    _introduce.text = _card.introduce ? _card.introduce :blackString;
    if (_card.avatarData) {
        [_avatar setImage:[UIImage imageWithData:_card.avatarData]];
    }
}

#pragma mark -XMPPvCardTempModuleDelegate methods

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid
{
    NSLog(@"didreceivecard");
}

- (void)xmppvCardTempModuleDidUpdateMyvCard:(XMPPvCardTempModule *)vCardTempModule
{
    NSLog(@"didupdatecard");

}

- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule failedToUpdateMyvCard:(NSXMLElement *)error
{
    NSLog(@"failtoupdatecard");

}

#pragma mark -UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"更换头像" otherButtonTitles:nil, nil];
        [actionSheet showInView:self.view];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"me2Sex"]) {
        MyvCardSex *vCardSex = segue.destinationViewController;
        vCardSex.delegate = self;
        vCardSex.sex = _card.sex ? _card.sex : nil;
    }
    else if ([segue.identifier isEqualToString:@"me2Introduce"]){
        MyvCardIntro *vCardIntro = segue.destinationViewController;
        vCardIntro.delegate = self;
        vCardIntro.introduce =  _card.introduce ? _card.introduce : nil;
    }
}

#pragma mark -MyvCardDelegate methods

- (void)didSelectMan:(BOOL)isMan
{
    if (isMan) {
        _sex.text = @"男";
        _myvCard.sex = @"男";
    }
    else{
        _sex.text = @"女";
        _myvCard.sex = @"女";
    }
    
    [_vCardTempModule updateMyvCardTemp:_myvCard];
}

- (void)didEditIntroduce:(NSString *)introduce
{
    _introduce.text = introduce;
    _myvCard.title = introduce;
    
    [_vCardTempModule updateMyvCardTemp:_myvCard];

}

#pragma mark -UIActionSheetDelegate methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex) {
        if (![QBImagePickerController isAccessible]) {
            NSLog(@"Error: Source is not accessible.");
        }
        QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsMultipleSelection = NO;
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
        [self presentViewController:navigationController animated:YES completion:NULL];
    }
}

#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    CGImageRef imageRef = [[asset defaultRepresentation]fullResolutionImage];
    UIImage *image = [UIImage imageWithCGImage:imageRef];
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    
    [_avatar setImage:[UIImage imageWithData:data]];
    _myvCard.photo = data;
    [_vCardTempModule updateMyvCardTemp:_myvCard];
    
    [self dismissImagePickerController];
}

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    [self dismissImagePickerController];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    
    [self dismissImagePickerController];
}

- (void)dismissImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
