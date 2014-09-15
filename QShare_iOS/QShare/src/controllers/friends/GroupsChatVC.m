//
//  GroupsChatVC.m
//  QShare
//
//  Created by Vic on 14-7-7.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "GroupsChatVC.h"
#import "UIBubbleTableView.h"
#import "GroupChatUtils.h"
#import "XMPPUtils.h"
#import "NSBubbleData.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "XMPPvCardTemp.h"
#import "QBImagePickerController.h"
#import "GroupInfoVC.h"
#import "RecordUtils.h"
#import "ChatDetailVC.h"
#import "MyLocation.h"
#import "viewLocationVC.h"



@interface GroupsChatVC ()<UITextFieldDelegate,UIBubbleTableViewDataSource,xmppMessageDelegate,QBImagePickerControllerDelegate,UIGestureRecognizerDelegate,MyLocationDelegate>
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIBubbleTableView *bubbleTableView;
@property (weak, nonatomic) IBOutlet UIView *showMoreView;

@property (strong,nonatomic) NSData *myAvatar;
@property (strong,nonatomic) GroupChatUtils *groupChatUtils;
@property (strong,nonatomic) XMPPUtils *sharedXMPP;
@property (strong,nonatomic) NSMutableArray *bubbleMessages;
@property (strong,nonatomic) NSMutableArray *rawMessages;

#define MSG_BODY @"body"
#define MSG_TIMESTAMP @"timestamp"
#define MSG_AVATAR @"chatWithAvatar"
#define MSG_ISOUTGOING @"isOutgoing"

- (IBAction)sendButton:(id)sender;
- (IBAction)sendPhoto:(id)sender;
- (IBAction)showMore:(id)sender;
- (IBAction)sendLocation:(id)sender;


@end

@implementation GroupsChatVC

#pragma mark - ViewController Lifetime

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
     [self setup];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self addKeyboardNotification];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [_messageTextField resignFirstResponder];
    [self removeKeyboardNotification];
}



#pragma mark - Keyboard Notification

- (void)addKeyboardNotification{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)removeKeyboardNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShown:(NSNotification *)notification
{
    if (_showMoreView.isHidden == NO) {
        _showMoreView.hidden = YES;
    }
    
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    CGFloat keyboardHeight = keyboardSize.height;
    [self animateTextField:_messageTextField up:YES moveDistance:keyboardHeight];
    
}

- (void)keyboardWillHidden:(NSNotification *)notification
{
    
    
    [self animateTextField:_messageTextField up:NO moveDistance:0];
    
}


#pragma mark - Set Up

- (void)setup
{
    self.title = [_roomJID user];
    _messageTextField.delegate = self;
    _bubbleMessages = [NSMutableArray array];
    _rawMessages = [NSMutableArray array];
    _groupChatUtils = [[GroupChatUtils alloc]init];
    _sharedXMPP = [XMPPUtils sharedInstance];
    _sharedXMPP.messageDelegate = self;
    
    _showMoreView.hidden = YES;
    [self setupTapGestureRecognizer];
    [self setupMyAvatar];
    [self setupBubbleTableView];
    [self getMessageData];
}

-(void)setupTapGestureRecognizer
{
    UIPanGestureRecognizer *tapGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(hideToolBar)];
    tapGesture.delegate = self;
    [_bubbleTableView addGestureRecognizer:tapGesture];
}

- (void)setupMyAvatar
{
    XMPPJID *myJid = _sharedXMPP.xmppStream.myJID;
    XMPPvCardTempModule *vCardModule = _sharedXMPP.xmppvCardTempModule;
    XMPPvCardTemp *myCard = [vCardModule vCardTempForJID:myJid shouldFetch:YES];
    NSData *avatarData = myCard.photo;
    if (avatarData) {
        _myAvatar = avatarData;
    }

}

- (void)setupBubbleTableView
{
    self.bubbleTableView.bubbleDataSource = self;
    self.bubbleTableView.snapInterval = 120;
    self.bubbleTableView.showAvatars = YES;
}

#pragma mark - Get Data From CoreData

- (void)getMessageData{
    NSManagedObjectContext *context = [[XMPPRoomCoreDataStorage sharedInstance] mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(roomJIDStr == %@) AND (streamBareJidStr == %@)",_roomJID,[_sharedXMPP.xmppStream.myJID bare]];
    [request setPredicate:predicate];
    NSError *error ;
    NSArray *dataArray = [context executeFetchRequest:request error:&error];
   
    [_bubbleMessages removeAllObjects];
    [_rawMessages removeAllObjects];
    
    for (XMPPRoomMessageCoreDataStorageObject *messageObject in dataArray) {
        if ([[messageObject jid] isFull]) {
            
            NSString *sendString = [messageObject body];
            NSDate *sendDate = [messageObject localTimestamp];
            BOOL isFromMe = [[messageObject fromMe] boolValue];
            XMPPJID *fromJID = [messageObject jid];
            XMPPJID *sendJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",[fromJID resource],XMPP_HOST_NAME]];
            
            NSData *avatarData = nil;
            if (isFromMe) {
                avatarData = _myAvatar;
            }
            else{
                [_sharedXMPP.xmppvCardTempModule fetchvCardTempForJID:sendJID];
                XMPPvCardTemp *vCard = [_sharedXMPP.xmppvCardTempModule vCardTempForJID:sendJID shouldFetch:YES];
                avatarData = vCard.photo;
            }
           
            
            NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
            [messageDict setObject:sendString forKey:MSG_BODY];
            [messageDict setObject:sendDate forKey:MSG_TIMESTAMP];
            [messageDict setObject:@(YES) forKey:MSG_ISOUTGOING];
            
            if (avatarData) {
                [messageDict setObject:avatarData forKey:MSG_AVATAR];
            }
            
            NSBubbleData *bubdata = [self dictToBubbleData:messageDict];
            
            [_bubbleMessages addObject:bubdata];
            [_rawMessages addObject:messageDict];
            
            [self.bubbleTableView reloadData];
            
            if ([_bubbleMessages count] > 1) {
                [self.bubbleTableView scrollBubbleViewToBottomAnimated:YES];
            }

            

            
        }
    }
}



#pragma mark - UI Actions

- (IBAction)sendButton:(id)sender
{
    NSString *messageBody = [_messageTextField text];
    [self sendWithType:@"text" andBody:messageBody];
    _messageTextField.text = @"";
}

- (IBAction)sendPhoto:(id)sender
{
    if (![QBImagePickerController isAccessible]) {
        NSLog(@"Error: Source is not accessible.");
    }
    QBImagePickerController *imagePickerController = [[QBImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 6;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imagePickerController];
    [self presentViewController:navigationController animated:YES completion:NULL];

}

- (IBAction)showMore:(id)sender {
    [self.view endEditing:YES];
    
    [self animateTextField:_messageTextField up:YES moveDistance:64.0];
    
    _showMoreView.hidden = NO;
}

- (IBAction)sendLocation:(id)sender {
    [self performSegueWithIdentifier:SEGUE_CHAT_MYLOCATION sender:self];
}

#pragma mark - Sugue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"GroupsChat2GroupInfo"]) {
        GroupInfoVC *vc = segue.destinationViewController;
        vc.roomJID = _roomJID;
    }
    else if ([segue.identifier isEqualToString:SEGUE_CHAT_DETAIL]) {
        ChatDetailVC *chatDetail = segue.destinationViewController;
        NSData *data = (NSData *)sender;
        chatDetail.data= data;
    }
    
    else if ([segue.identifier isEqualToString:SEGUE_CHAT_MYLOCATION]){
        MyLocation *myLocation = segue.destinationViewController;
        myLocation.delegate = self;
    }
    else if ([segue.identifier isEqualToString:SEGUE_CHAT_VIEWLOCATION]){
        NSDictionary *locationDict = (NSDictionary *)sender;
        double longitude = [locationDict[@"longitude"] doubleValue];
        double latitude = [locationDict[@"latitude"] doubleValue];
        
        viewLocationVC *vc = segue.destinationViewController;
        vc.longitude = longitude;
        vc.latitude = latitude;
    }
}

#pragma mark - Dismiss ImagePicker

- (void)dismissImagePickerController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}


#pragma mark - QBImagePickerControllerDelegate

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAsset:(ALAsset *)asset
{
    NSLog(@"*** imagePickerController:didSelectAsset:");
    NSLog(@"%@", asset);
    
    [self dismissImagePickerController];
}

- (void)imagePickerController:(QBImagePickerController *)imagePickerController didSelectAssets:(NSArray *)assets
{
    for (ALAsset *asset in assets) {
        CGImageRef imageRef = [[asset defaultRepresentation]fullResolutionImage];
        UIImage *image = [UIImage imageWithCGImage:imageRef];
        NSData *data = UIImageJPEGRepresentation(image, 1.0f);
        NSString *imageBase64Str = [data base64EncodedString];
        [self sendWithType:@"photo" andBody:imageBase64Str];
    }
    [self dismissImagePickerController];
}

- (void)imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    
    [self dismissImagePickerController];
}

#pragma mark - UIBubbleTableViewDataSource

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [_bubbleMessages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [_bubbleMessages objectAtIndex:row];
}

- (void)didSelectBubbleRowAtIndexRow:(NSInteger)indexRow
{
    NSDictionary *msgDict = [_rawMessages objectAtIndex:indexRow];
    if ([msgDict objectForKey:MSG_BODY]) {
        if ([msgDict[MSG_BODY]  hasPrefix:@"voiceBase64"]) {
            NSString *voiceBase64Str = [msgDict[MSG_BODY] substringFromIndex:11];
            NSData *data = [voiceBase64Str base64DecodedData];
            
            NSError *playerError;
            
            //播放
            AVAudioPlayer *player = nil;
            player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
            
            if (player == nil)
            {
                NSLog(@"ERror creating player: %@", [playerError description]);
            }else{
                [player play];
            }
        }
        
        else if ([msgDict[MSG_BODY]  hasPrefix:@"photoBase64"]){
            NSString *photoBase64Str = [msgDict[MSG_BODY] substringFromIndex:11];
            NSData *data = [photoBase64Str base64DecodedData];
            [self performSegueWithIdentifier:SEGUE_CHAT_DETAIL sender:data];
        }
        
        else if ([msgDict[MSG_BODY]  hasPrefix:@"locationBase64"]){
            NSArray *array = [msgDict[MSG_BODY] componentsSeparatedByString:@"locationBase64"];
            double longitude = [[array objectAtIndex:1] doubleValue];
            double latitude = [[array objectAtIndex:2] doubleValue];
            NSDictionary *locationDict = @{@"longitude":[NSNumber numberWithDouble:longitude] , @"latitude":[NSNumber numberWithDouble:latitude]};
            [self performSegueWithIdentifier:SEGUE_CHAT_VIEWLOCATION sender:locationDict];
        }
    }
    
    
}



#pragma mark - xmppMessageDelegate

-(void)newMessageReceived:(NSDictionary *)messageContent
{
    if ([self isMessageOfTheRoom:messageContent]) {
        
        NSBubbleData *bubdata = [self dictToBubbleData:messageContent];
        
        [_bubbleMessages addObject:bubdata];
        [_rawMessages addObject:messageContent];
        
        [self.bubbleTableView reloadData];
        
        if ([_bubbleMessages count] > 1) {
            [self.bubbleTableView scrollBubbleViewToBottomAnimated:YES];
        }
    }
}

#pragma mark - MyLocationDelegate

-(void)sendLocationImage:(UIImage *)image andLongitude:(double)longitude andLatitude:(double)latitude
{
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *imageBase64Str = [data base64EncodedString];
    
    NSString *locationBase64 = @"locationBase64";
    NSString *locationString = [NSString stringWithFormat:@"%@%f%@%f%@%@",locationBase64,longitude,locationBase64,latitude,locationBase64,imageBase64Str];
    
    [self sendWithType:@"location" andBody:locationString];
}

#pragma mark - Intermediate Methods

- (void)sendWithType:(NSString *)type andBody:(id)bodyObj
{
    NSMutableString *sendString = [NSMutableString stringWithCapacity:20];
    
    if ([type isEqualToString:@"text"]) {
        [sendString appendString:(NSString *)bodyObj];
    }
    else if ([type isEqualToString:@"voice"]){
        [sendString appendFormat:@"%@%@",@"voiceBase64",(NSString *)bodyObj];
    }
    else if ([type isEqualToString:@"photo"]){
        [sendString appendFormat:@"%@%@",@"photoBase64",(NSString *)bodyObj];
    }
    else if ([type isEqualToString:@"location"]){
        [sendString appendString:(NSString *)bodyObj];
    }
    
    [_groupChatUtils sendMessageWithBody:sendString andRoomJID:_roomJID];

//    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
//    [messageDict setObject:sendString forKey:MSG_BODY];
//    [messageDict setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:MSG_TIMESTAMP];
//    [messageDict setObject:@(YES) forKey:MSG_ISOUTGOING];
//
//    if (_myAvatar) {
//        [messageDict setObject:_myAvatar forKey:MSG_AVATAR];
//    }
//    
//    NSBubbleData *bubdata = [self dictToBubbleData:messageDict];
//    
//    [_bubbleMessages addObject:bubdata];
//    [_rawMessages addObject:messageDict];
//    
//    [self.bubbleTableView reloadData];
//    
//    if ([_bubbleMessages count] > 1) {
//        [self.bubbleTableView scrollBubbleViewToBottomAnimated:YES];
//    }
    
//    NSMutableDictionary *notifiMessage = [messageDict mutableCopy];
//    
//    [notifiMessage setObject:@"groupchat" forKey:@"chatType"];
//    [notifiMessage setObject:[_roomJID bare] forKey:@"roomJID"];
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CHAT_MSG object:notifiMessage];
    
    
}

- (NSBubbleData *)dictToBubbleData:(NSDictionary *)dict
{
    NSBubbleData *bubbleData;
    NSDate *msgDate = dict[MSG_TIMESTAMP];
    NSString *body = dict[MSG_BODY];
    NSBubbleType bubbleType = BubbleTypeSomeoneElse;
    if (body) {
        if ([body hasPrefix:@"voiceBase64"]) {
            bubbleData = [NSBubbleData dataWithText:@"[语音文件]" date:msgDate type:bubbleType];
        }
        else if ([body hasPrefix:@"photoBase64"]){
            NSString *photoBase64Str = [body substringFromIndex:11];
            NSData *data = [photoBase64Str base64DecodedData];
            UIImage *image = [UIImage imageWithData:data];
            bubbleData = [NSBubbleData dataWithImage:image date:msgDate type:bubbleType];
        }
        else if ([body hasPrefix:@"locationBase64"]){
            NSArray *array = [body componentsSeparatedByString:@"locationBase64"];
            NSString *locationImageBase64Str = [array lastObject];
            NSData *data = [locationImageBase64Str base64DecodedData];
            UIImage *image = [UIImage imageWithData:data];
            bubbleData = [NSBubbleData dataWithImage:image date:msgDate type:bubbleType];
            
        }
        else{
            bubbleData = [NSBubbleData dataWithText:body date:msgDate type:bubbleType];
        }
        
        bubbleData.avatar = dict[MSG_AVATAR] ? [UIImage imageWithData:dict[MSG_AVATAR]] : [UIImage imageNamed:@"avatar_default.png"] ;
        
        
    }
    return bubbleData;
}

- (BOOL)isMessageOfTheRoom:(NSDictionary *)messageDict
{
    if ([messageDict[@"chatType"] isEqualToString:@"groupchat"] && [messageDict[@"roomJID"] isEqualToString:[_roomJID bare]]) {
        return YES;
    }
    return NO;
}

#pragma mark - Hide ToolBar

-(void)hideToolBar
{
    [_messageTextField resignFirstResponder];
    [self animateTextField:_messageTextField up:NO moveDistance:0.0];
}

#pragma mark - UITextFieldDelegate methods



- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendButton:self];
    return YES;
}

- (void)animateTextField:(UITextField *)textField up:(BOOL)dir moveDistance:(CGFloat)distance
{
    
    CGFloat movementDistance = distance;
    CGFloat movementDuration = 0;
    CGRect viewFrame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
    
    int movement = (dir ? -movementDistance : movementDistance);
    
    [UIView animateWithDuration:movementDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.view.frame = CGRectOffset(viewFrame, 0, movement);
    } completion:nil];
}

#pragma mark -UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
