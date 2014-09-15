//
//  viewLocationVC.m
//  QShare
//
//  Created by Vic on 14-7-23.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "viewLocationVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"

@interface viewLocationVC ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation viewLocationVC

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
    [self setupMapView];
}

- (void)setupMapView
{
    CLLocationCoordinate2D locationCoordinate = CLLocationCoordinate2DMake(_latitude, _longitude);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, 2000, 2000);
    [_mapView setRegion:region animated:YES];
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:_latitude longitude:_longitude];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(!error && [placemarks count] > 0){
            id placeMark = [placemarks objectAtIndex:0];
            if([placeMark isKindOfClass:[CLPlacemark class]]){
                NSDictionary *addressDict = [(CLPlacemark *)placeMark addressDictionary];
                
                NSString *myAddress = [NSString stringWithFormat:@"%@%@%@%@",
                                       addressDict[@"State"] ? addressDict[@"State"] :@"",
                                       addressDict[@"City"] ? addressDict[@"City"] : @"",
                                       addressDict[@"SubLocality"] ? addressDict[@"SubLocality"]: @"",
                                       addressDict[@"Street"] ? addressDict[@"Street"] :@""];
                
                MyAnnotation *myAnnotation = [[MyAnnotation alloc]initWithCoordinate:locationCoordinate andTitle:addressDict[@"Name"] andSubtitle:myAddress];
                [_mapView addAnnotation:myAnnotation];
                
            }
        }
        else{
            NSLog(@"reverseGeocodeLocation Error:%@",error);
        }
    }];

}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKPinAnnotationView *annotationView=(MKPinAnnotationView *)[_mapView dequeueReusableAnnotationViewWithIdentifier:@"PIN_ANNOTATION"];
    
    if (annotationView==nil) {
        annotationView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"PIN_ANNOTATION"];
    }
    annotationView.canShowCallout=YES;
    annotationView.pinColor=MKPinAnnotationColorRed;
    annotationView.animatesDrop=YES;
    return annotationView;
}



@end
