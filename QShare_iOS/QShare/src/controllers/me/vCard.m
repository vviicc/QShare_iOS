//
//  vCard.m
//  QShare
//
//  Created by Vic on 14-6-3.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "vCard.h"

@implementation vCard

+ (vCard *)vCardWithAvatar:(NSData *)avatarData andSex:(NSString *)sex andLocation:(NSString *)location andIntroduce:(NSString *)introduce
{
    vCard *card = [[vCard alloc]init];
    card.avatarData = avatarData;
    card.sex = sex;
    card.location = location;
    card.introduce = introduce;
    return card;
}

@end
