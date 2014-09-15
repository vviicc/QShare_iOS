//
//  vCard.h
//  QShare
//
//  Created by Vic on 14-6-3.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface vCard : NSObject

@property (nonatomic,strong) NSData *avatarData;
@property (nonatomic,strong) NSString *sex;
@property (nonatomic,strong) NSString *location;
@property (nonatomic,strong) NSString *introduce;

+ (vCard *)vCardWithAvatar:(NSData *)avatarData andSex:(NSString *)sex andLocation:(NSString *)location andIntroduce:(NSString *)introduce;
@end
