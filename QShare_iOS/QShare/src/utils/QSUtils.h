//
//  QSUtils.h
//  QShare
//
//  Created by Vic on 14-4-18.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QSUtils : NSObject

+(BOOL) isEmpty:(NSString *) string;

+(NSString *)getCurrentTime;

+(void)setExtraCellLineHidden: (UITableView *)tableView;

@end
