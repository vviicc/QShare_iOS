//
//  ChatVC.m
//  QShare
//
//  Created by Vic on 14-4-19.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "ChatVC.h"
#import "XMPPUtils.h"
#import "QSUtils.h"
#import "RecordUtils.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "QBImagePickerController.h"
#import "ChatDetailVC.h"
#import "XMPPvCardTemp.h"
#import "ContactInfo.h"
#import "MyLocation.h"
#import "viewLocationVC.h"

#define MSG_IS_OUT_GOING @"isOutgoing"
#define MSG_BODY @"body"
#define MSG_TIMESTAMP @"timestamp"

@interface ChatVC ()<xmppMessageDelegate,UITextFieldDelegate,QBImagePickerControllerDelegate,UIBubbleTableViewDataSource,UIGestureRecognizerDelegate,MyLocationDelegate>
@property (nonatomic,strong) NSMutableArray *bubbleDataMessages;
@property (nonatomic,strong) NSMutableArray *rawMessages;
@property (nonatomic,strong) RecordUtils *record;
@property (nonatomic,strong) XMPPUtils *sharedXMPP;
@property (nonatomic,strong) AVAudioPlayer *player;



@end

@implementation ChatVC

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

#pragma mark - Setup

- (void)setup
{
    [XMPPUtils sharedInstance].messageDelegate = self;
    self.bubbleTable.bubbleDataSource = self;
    self.bubbleTable.snapInterval = 120;
    self.bubbleTable.showAvatars = YES;
    _bubbleDataMessages = [NSMutableArray array];
    _rawMessages = [NSMutableArray array];
    _messageTextField.delegate = self;
    
    _record = [[RecordUtils alloc]init];
    [_record setupRecordSetting];
    
    _sharedXMPP = [XMPPUtils sharedInstance];
    
    [self setupMyAvatar];
    
    [self getMessageData];
    
    if ([_bubbleDataMessages count] > 1) {
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }
    
    _recordView.hidden = YES;
    _showMoreView.hidden = YES;
    
    [self setupTapGestureRecognizer];
    
    self.navigationItem.title = self.chatName;
    
}

-(void)setupTapGestureRecognizer
{
    UIPanGestureRecognizer *tapGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(hideToolBar)];
    tapGesture.delegate = self;
    [_bubbleTable addGestureRecognizer:tapGesture];
}

- (void)setupMyAvatar{
    XMPPJID *myJid = _sharedXMPP.xmppStream.myJID;
    XMPPvCardTempModule *vCardModule = _sharedXMPP.xmppvCardTempModule;
    XMPPvCardTemp *myCard = [vCardModule vCardTempForJID:myJid shouldFetch:YES];
    NSData *avatarData = myCard.photo;
    if (avatarData) {
        _myAvatar = avatarData;
    }
}

- (void)getMessageData{
    NSManagedObjectContext *context = [[XMPPUtils sharedInstance].xmppMessageArchivingCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    NSError *error ;
    NSArray *dataArray = [context executeFetchRequest:request error:&error];
    NSString *chatwith = [NSString stringWithFormat:@"%@@%@",_chatName,XMPP_HOST_NAME];
    NSString *userName = [[NSUserDefaults standardUserDefaults] objectForKey:XMPP_USER_NAME];
    NSString *userJIDStr = [NSString stringWithFormat:@"%@@%@",userName,XMPP_HOST_NAME];
    
    [_bubbleDataMessages removeAllObjects];
    [_rawMessages removeAllObjects];
    for (XMPPMessageArchiving_Message_CoreDataObject *messageObject in dataArray) {
        if (([[messageObject bareJidStr] isEqualToString:chatwith]) && ([[messageObject streamBareJidStr] isEqualToString:userJIDStr])) {
            
            NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
            [messageDict setObject:_chatName forKey:@"chatwith"];
            [messageDict setObject:messageObject.body forKey:@"body"];
            [messageDict setObject:@(messageObject.isOutgoing) forKey:@"isOutgoing"];
            [messageDict setObject:messageObject.timestamp forKey:@"timestamp"];
            
            NSBubbleData *bubData = [self dictToBubbleData:messageDict];
            
            [_bubbleDataMessages addObject:bubData];
            [_rawMessages addObject:messageDict];
            
        }
    }
}

- (NSBubbleData *)dictToBubbleData:(NSDictionary *)dict
{
    NSBubbleData *bubbleData;
    BOOL isOutgoing = [dict[MSG_IS_OUT_GOING] boolValue];
    NSDate *msgDate = dict[MSG_TIMESTAMP];
    NSString *body = dict[MSG_BODY];
    NSBubbleType bubbleType = isOutgoing?BubbleTypeMine:BubbleTypeSomeoneElse;
    if (body) {
        if ([body hasPrefix:@"voiceBase64"]) {
//            bubbleData = [NSBubbleData dataWithText:@"[语音文件]" date:msgDate type:bubbleType];
            UIImage *image = (bubbleType == BubbleTypeSomeoneElse) ? [UIImage imageNamed:@"audio-volume-high-panel.png"] : [UIImage imageNamed:@"audio-volume-high-panel-reverse.png"];
            bubbleData = [NSBubbleData dataWithImage:image date:msgDate type:bubbleType];
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
        
        if (bubbleType == BubbleTypeMine) {
            bubbleData.avatar = _myAvatar ? [UIImage imageWithData:_myAvatar] : [UIImage imageNamed:@"avatar_default.png"];
        }
        else if (bubbleType == BubbleTypeSomeoneElse){
            bubbleData.avatar = _chatWithAvatar ? [UIImage imageWithData:_chatWithAvatar] : [UIImage imageNamed:@"avatar_default.png"];
        }

        
    }
    return bubbleData;
}

#pragma mark - UIBubbleTableViewDataSource implementation

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [_bubbleDataMessages count];
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [_bubbleDataMessages objectAtIndex:row];
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
            
            _player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
            
            if (_player == nil)
            {
                NSLog(@"ERror creating player: %@", [playerError description]);
            }else{
                [_player play];
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

#pragma mark - Segue

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:SEGUE_CHAT_DETAIL]) {
        ChatDetailVC *chatDetail = segue.destinationViewController;
        NSData *data = (NSData *)sender;
        chatDetail.data= data;
    }
    else if ([segue.identifier isEqualToString:SEGUE_CHAT_CONTACTINFO]){
        ContactInfo *contact = segue.destinationViewController;
        if (_chatName) {
            contact.contactName = _chatName;
            contact.isFromChatVC = YES;
        }
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


#pragma mark - Send Message

- (IBAction)sendButton:(id)sender
{
    //本地输入框中的信息
    NSString *message = self.messageTextField.text;
    
    if (message.length > 0) {
        
        [self sendWithType:@"text" andBody:message];
    }
    
    self.messageTextField.text = @"";

}

- (IBAction)beginAudio:(id)sender {
    [_record beginRecord:self];
}

- (IBAction)endAudio:(id)sender {
    [_record endRecord:self];
    
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"voice.aac"];
    
    NSFileManager *fileManager = [[NSFileManager alloc]init];
    if ([fileManager fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSString *voiceBase64 = [data base64EncodedString];
        [self sendWithType:@"voice" andBody:voiceBase64];
    }
    
}

- (IBAction)sendPhoto:(id)sender {
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

- (IBAction)sendLocation:(id)sender {
    [self performSegueWithIdentifier:SEGUE_CHAT_MYLOCATION sender:self];
}

- (IBAction)showMore:(id)sender {
    [self.view endEditing:YES];
    
    [self animateTextField:_messageTextField up:YES moveDistance:64.0];

    _showMoreView.hidden = NO;


}



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

#pragma mark - xmppMessageDelegate

-(void)newMessageReceived:(NSDictionary *)messageCotent{
    
    if ([[messageCotent objectForKey:@"chatwith"] isEqualToString:_chatName]) {
        
        NSBubbleData *bubData = [self dictToBubbleData:messageCotent];
        
        [_bubbleDataMessages addObject:bubData];
        [_rawMessages addObject:messageCotent];
        
        [self.bubbleTable reloadData];
        
        //重新刷新tableView
        if ([_bubbleDataMessages count] > 1) {
            [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
        }

    }
    

}

- (void)sendWithType:(NSString *)type andBody:(id)bodyObj
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    [mes addAttributeWithName:@"type" stringValue:@"chat"];
    
    NSString *chatWithUser = [NSString stringWithFormat:@"%@@%@",_chatName,XMPP_HOST_NAME];
    NSString *chatFrom =  [NSString stringWithFormat:@"%@@%@",[[NSUserDefaults standardUserDefaults] stringForKey:XMPP_USER_NAME],XMPP_HOST_NAME];
    
    [mes addAttributeWithName:@"to" stringValue:chatWithUser];
    [mes addAttributeWithName:@"from" stringValue:chatFrom];
    
    NSMutableString *sendString = [NSMutableString stringWithCapacity:40];
    
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
    
    
    [body setStringValue:sendString];
    [mes addChild:body];
    
    [[[XMPPUtils sharedInstance] xmppStream] sendElement:mes];
    
    NSMutableDictionary *messageDict = [NSMutableDictionary dictionary];
    [messageDict setObject:_chatName forKey:@"chatwith"];
    [messageDict setObject:sendString forKey:@"body"];
    [messageDict setObject:@(YES) forKey:@"isOutgoing"];
    [messageDict setObject:[NSDate dateWithTimeIntervalSinceNow:0] forKey:@"timestamp"];
    
    NSBubbleData *bubdata = [self dictToBubbleData:messageDict];
    
    [_bubbleDataMessages addObject:bubdata];
    [_rawMessages addObject:messageDict];
    
    [self.bubbleTable reloadData];
    
    //重新刷新tableView
    if ([_bubbleDataMessages count] > 1) {
        [self.bubbleTable scrollBubbleViewToBottomAnimated:YES];
    }
    
    NSMutableDictionary *notifiMessage = [messageDict mutableCopy];
    
    if (_chatWithAvatar) {
        [notifiMessage setObject:_chatWithAvatar forKey:@"chatWithAvatar"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFY_CHAT_MSG object:notifiMessage];


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
