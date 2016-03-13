//
//  MapViewController.h
//  Wipp
//

#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>


@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;


@end
