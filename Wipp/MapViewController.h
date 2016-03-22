//
//  MapViewController.h
//  Wipp
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>


#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;


@end
