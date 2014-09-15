//
//  MyAnnotation.m
//  QShare
//
//  Created by Vic on 14-7-22.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation

-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)t andSubtitle:(NSString *)subtitle
{
    self = [super init];
    if(self){
        _coordinate = c;
        _title = t;
        _subtitle = subtitle;
    }
    return self;
}
@end
