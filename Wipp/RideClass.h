//
//  RideClass.h
//

#import <Foundation/Foundation.h>


@interface RideClass : NSObject

@property (nonatomic, retain) NSString *rideId;
@property (nonatomic, retain) NSString *user;
@property (nonatomic, retain) NSString *driver;
@property (nonatomic, retain) NSString *status_verbose;
@property (nonatomic, retain) NSString *pick_up_interval;
@property (nonatomic, retain) NSString *start_amount;
@property (nonatomic, retain) NSString *final_amount;
@property (nonatomic, retain) NSString *start_long;
@property (nonatomic, retain) NSString *start_lat;
@property (nonatomic, retain) NSString *start_address;
@property (nonatomic, retain) NSString *destination_address;

@end
