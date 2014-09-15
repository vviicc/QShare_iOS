//
//  MyAnnotation.h
//  QShare
//
//  Created by Vic on 14-7-22.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject<MKAnnotation>

@property (nonatomic,readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic,copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;


//初始化方法
-(id)initWithCoordinate:(CLLocationCoordinate2D)c andTitle:(NSString *)t andSubtitle:(NSString *)subtitle;

@end
