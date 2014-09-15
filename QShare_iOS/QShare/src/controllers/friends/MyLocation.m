//
//  MyLocation.m
//  QShare
//
//  Created by Vic on 14-7-22.
//  Copyright (c) 2014年 vic. All rights reserved.
//

#import "MyLocation.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"


@interface MyLocation ()<MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *myLocation;

@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

- (IBAction)sendMyLocation:(id)sender;
@end

@implementation MyLocation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    CLLocationCoordinate2D locationCoordinate = userLocation.location.coordinate;
    _longitude = locationCoordinate.longitude;
    _latitude = locationCoordinate.latitude;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, 500, 500);
    [_mapView setRegion:region animated:YES];
    
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if(!error && [placemarks count] > 0){
            id placeMark = [placemarks objectAtIndex:0];
            if([placeMark isKindOfClass:[CLPlacemark class]]){
                NSDictionary *addressDict = [(CLPlacemark *)placeMark addressDictionary];
                
                NSString *myAddress = [NSString stringWithFormat:@"%@%@%@%@",
                                       addressDict[@"State"] ? addressDict[@"State"] :@"",
                                       addressDict[@"City"] ? addressDict[@"City"] : @"",
                                       addressDict[@"SubLocality"] ? addressDict[@"SubLocality"]: @"",
                                       addressDict[@"Street"] ? addressDict[@"Street"] :@""];
                _myLocation.text = myAddress;

                MyAnnotation *myAnnotation = [[MyAnnotation alloc]initWithCoordinate:locationCoordinate andTitle:addressDict[@"Name"] andSubtitle:myAddress];
                [_mapView addAnnotation:myAnnotation];
                
                [self.navigationItem.rightBarButtonItem setEnabled:YES];
            }
        }
        else{
            NSLog(@"reverseGeocodeLocation Error:%@",error);
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"didFailToLocateUserWithError = %@",error);
}

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



- (IBAction)sendMyLocation:(id)sender {
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [_delegate sendLocationImage:image andLongitude:_longitude andLatitude:_latitude];
    [self.navigationController popViewControllerAnimated:YES];
    
}
@end
