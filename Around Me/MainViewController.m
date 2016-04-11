//
//  MainViewController.m
//  Around Me
//
//  Created by Jean-Pierre Distler on 30.01.13.
//  Copyright (c) 2013 Jean-Pierre Distler. All rights reserved.
//

#import "MainViewController.h"

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "PlacesLoader.h"
#import "Place.h"
#import "PlaceAnnotation.h"
#import "DetailViewController.h"
#import "HotspotsViewController.h"
NSString * const kNameKey = @"name";
NSString * const kReferenceKey = @"reference";
NSString * const kAddressKey = @"vicinity";
NSString * const kLatiudeKeypath = @"geometry.location.lat";
NSString * const kLongitudeKeypath = @"geometry.location.lng";
NSString * const kLatiudeKeypath2 = @"latitude";
NSString * const kLongitudeKeypath2 = @"longitude";
NSString * const kNameKey2 = @"location";
NSString * const kReferenceKey2 = @"wifiaccess";
NSString * const kAddressKey2 = @"address";

@interface MainViewController () <CLLocationManagerDelegate, MKMapViewDelegate,UIPopoverPresentationControllerDelegate,UIPopoverControllerDelegate>
{
    BOOL waitConfirm;

}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) UIPopoverController*popover;
@property (nonatomic, strong) UIPopoverPresentationController*popover8;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_locationManager = [[CLLocationManager alloc] init];
    if ([_locationManager respondsToSelector:
         @selector(requestWhenInUseAuthorization)]) {
        [_locationManager requestWhenInUseAuthorization];
    }
    [_locationManager setDelegate:self];
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self requestCurrentLocation];
    }
    else
    {
        waitConfirm=YES;
    }
    self.popoverPresentationController.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CLLocationManager Delegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
	CLLocation *lastLocation = [locations lastObject];
	
	CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];
	
	NSLog(@"Received location %@ with accuracy %f", lastLocation, accuracy);
	
//	if(accuracy < 100.0) {
//		MKCoordinateSpan span = MKCoordinateSpanMake(0.14, 0.14);
//		MKCoordinateRegion region = MKCoordinateRegionMake([lastLocation coordinate], span);
//		
//		[_mapView setRegion:region animated:YES];
//        
//		[[PlacesLoader sharedInstance] loadPOIsForLocation:[locations lastObject] radius:1000 successHanlder:^(NSDictionary *response) {
//			NSLog(@"Response: %@", response);
//			if([[response objectForKey:@"status"] isEqualToString:@"OK"]) {
//				id places = [response objectForKey:@"results"];
//				NSMutableArray *temp = [NSMutableArray array];
//				
//				if([places isKindOfClass:[NSArray class]]) {
//					for(NSDictionary *resultsDict in places) {
//						CLLocation *location = [[CLLocation alloc] initWithLatitude:[[resultsDict valueForKeyPath:kLatiudeKeypath] floatValue] longitude:[[resultsDict valueForKeyPath:kLongitudeKeypath] floatValue]];
//						Place *currentPlace = [[Place alloc] initWithLocation:location reference:[resultsDict objectForKey:kReferenceKey] name:[resultsDict objectForKey:kNameKey] address:[resultsDict objectForKey:kAddressKey]];
//						[temp addObject:currentPlace];
//						
//						PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:currentPlace];
//						[_mapView addAnnotation:annotation];
//					}
//				}
//
//				_locations = [temp copy];
//				
//				NSLog(@"Locations: %@", _locations);
//			}
//		} errorHandler:^(NSError *error) {
//			NSLog(@"Error: %@", error);
//		}];
//		
//		
//	}
    [manager stopUpdatingLocation];
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
		[[segue destinationViewController] setLocations:_locations];
		[[segue destinationViewController] setUserLocation:[_mapView userLocation]];
    }
}
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    
    static NSString *identifier = @"MyLocation";
    if ([annotation isKindOfClass:[PlaceAnnotation class]]) {
        
        MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (annotationView == nil) {
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        } else {
            annotationView.annotation = annotation;
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.image=[UIImage imageNamed:@"pin_blue.png"];//here we use a nice image instead of the default pins
        
        return annotationView;
    }
    
    return nil;
}
- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    [mapView deselectAnnotation:view.annotation animated:YES];
    if(![view.annotation isKindOfClass:[PlaceAnnotation class]])
    {
        return;
    }
    DetailViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailPopover"];
    controller.annotation = view.annotation;
//    PlaceAnnotation*an = view.annotation;
//    controller.lblAddress.text=an.place.address;
//    controller.lblName.text=an.place.placeName;
//    [controller.btnPassword setTitle:an.place.reference forState:UIControlStateNormal];
    controller.preferredContentSize = CGSizeMake(320.0f, 180.0f);
    controller.modalPresentationStyle = UIModalPresentationPopover;
    _popover8 = controller.popoverPresentationController;
    _popover8.delegate = self;
    _popover8.sourceView = self.view;
    _popover8.sourceRect = [view frame];
    
    [self presentViewController:controller animated:YES completion:nil];
}
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if(waitConfirm)
    {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
            authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
            authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            waitConfirm=NO;
            [self requestCurrentLocation];
        }
    }
}
- (void)requestCurrentLocation
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [_locationManager startUpdatingLocation];
    CLLocation*loc=[_locationManager location];
//    loc = [[CLLocation alloc] initWithLatitude:43.849998 longitude:-76.000000];//NewYork
    if(loc.coordinate.latitude==0)
    {
        NSLog(@"wrong check");
        [self performSelector:@selector(requestCurrentLocation) withObject:nil afterDelay:2.0];
        return;
    }
    NSString *url = [NSString stringWithFormat:@"http://www.wifiget.com/statusWiFi.php?msgtype=LOC_FIND&scale=2&lat=%f&long=%f",loc.coordinate.latitude,loc.coordinate.longitude ];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    NSLog(@"url=%@",url);
    [request setHTTPMethod:@"GET"];
    NSString*userAgent=@"An-Finder/1.1 CFNetwork/711.1.12 Darwin/14.0.0";
    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *urlResponse, NSData *data, NSError *error)
     {
         NSHTTPURLResponse *httpresponse = (NSHTTPURLResponse *)urlResponse;
         NSLog(@"feedback response: status code %ld, error=%@, data=%@",
               httpresponse.statusCode, error, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
         
         if (httpresponse.statusCode == 200)
         {
             MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
             MKCoordinateRegion region = MKCoordinateRegionMake(_mapView.userLocation.coordinate, span);
//             MKCoordinateRegion region = MKCoordinateRegionMake(loc.coordinate, span);
             
             [_mapView setRegion:region animated:YES];
             _mapView.rotateEnabled=NO;
             NSDictionary*dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves|NSJSONReadingAllowFragments error:&error];
             if (error)
                 NSLog(@"JSONObjectWithData error: %@", error);
             NSDictionary*root = dict[@"responseData"];
             NSArray* places = root[@"results"];
             NSMutableArray *temp = [NSMutableArray array];
             for(NSDictionary* resultsDict in places)
             {
                 if([[resultsDict valueForKey:kLatiudeKeypath2] isEqual:[NSNull null]]||[[resultsDict valueForKey:kLongitudeKeypath2] isEqual:[NSNull null]])
                 {
                     continue;
                 }
                 CLLocation *location = [[CLLocation alloc] initWithLatitude:[[resultsDict valueForKeyPath:kLatiudeKeypath2] floatValue] longitude:[[resultsDict valueForKeyPath:kLongitudeKeypath2] floatValue]];
                 CLLocationDistance dist = [_mapView.userLocation.location distanceFromLocation:location];
                 
                 Place *currentPlace = [[Place alloc] initWithLocation:location reference:[resultsDict objectForKey:kReferenceKey2] name:[resultsDict objectForKey:kNameKey2] address:[resultsDict objectForKey:kAddressKey2] distance:dist];
                 [temp addObject:currentPlace];
                 
                 PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithPlace:currentPlace];
                 [_mapView addAnnotation:annotation];
                 
             }
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             _locations = [temp copy];
             return;
         }
         else
         {
         }
     }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(waitConfirm)
    {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
            authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
            authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
            waitConfirm=NO;
            [self requestCurrentLocation];
        }
    }
}
//-(UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
//{
//    return UIModalPresentationNone;
//}
//-(UIViewController*)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style
//{
//    return self;
//}
-(void)hideIOS8PopOver
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)btnHotspotClicked:(id)sender {
    HotspotsViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"hotspotVC"];
    controller.allData=self.mapView.annotations;
    controller.modalPresentationStyle = UIModalPresentationPopover;
    _popover8 = controller.popoverPresentationController;
    _popover8.delegate = self;
    _popover8.sourceView = self.view;
    _popover8.sourceRect = [sender frame];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)btnRefreshClicked:(id)sender {
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    
    if (authorizationStatus == kCLAuthorizationStatusAuthorized ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedAlways ||
        authorizationStatus == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self requestCurrentLocation];
    }
    else
    {
        UIAlertView*alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You should enable Location Service in Settings>Privacy>Location Services" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        waitConfirm=YES;
    }
}
@end
