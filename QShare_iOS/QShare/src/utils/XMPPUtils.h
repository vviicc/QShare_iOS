//
//  XMPPUtils.h
//  QShare
//
//  Created by Vic on 14-4-16.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol xmppConnectDelegate <NSObject>

@optional

- (void)didAuthenticate;
- (void)didNotAuthenticate:(NSXMLElement *)error;
- (void)anonymousConnected;
- (void)registerSuccess;
- (void)registerFailed:(NSXMLElement *)error;

@end



@protocol xmppMessageDelegate <NSObject>

-(void)newMessageReceived:(NSDictionary *)messageContent;

@end

@protocol xmppFriendsDelegate <NSObject>

-(void)friendsList:(NSDictionary *)dict;
-(void)removeFriens;

@end


@interface XMPPUtils : NSObject

@property (nonatomic,readonly) XMPPStream *xmppStream;
@property (nonatomic,strong) XMPPRoster *xmppRoster;
@property (nonatomic,strong) XMPPRosterCoreDataStorage *xmppRosterDataStorage;
@property (nonatomic,strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchivingModule;
@property (nonatomic,strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic,strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic,strong) XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage;
@property (nonatomic,strong) XMPPMUC *xmppMUC;
@property (nonatomic,strong) XMPPReconnect *xmppReconnect;

@property (nonatomic,strong) NSMutableSet *rooms;


@property (nonatomic,weak) id<xmppConnectDelegate> connectDelegate;
@property (nonatomic,weak) id<xmppMessageDelegate> messageDelegate;
@property (nonatomic,weak) id<xmppFriendsDelegate> friendsDelegate;



+ (XMPPUtils *) sharedInstance;

//设置XMPPStream
-(void)setupStream;
//上线
-(void)goOnline;
//下线
-(void)goOffline;

//连接服务器
-(BOOL)connect;
//匿名连接服务器
- (void)anonymousConnect;
//断开连接
-(void)disconnect;

//注册用户
-(void)enrollWithUserName:(NSString *)userName andPassword:(NSString *)pass;

//获取好友列表
- (void)queryRoster;

//添加朋友
-(void)addFriend:(NSString *)userName;
//删除朋友
-(void)delFriend:(NSString *)userName;

-(void)addRoom:(XMPPRoom *)room;
-(BOOL)isExistRoom:(XMPPJID *)roomJID;
-(XMPPRoom *)getExistRoom:(XMPPJID *)roomJID;
@end
