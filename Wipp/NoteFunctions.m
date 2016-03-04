//
//  NoteFunctions.m
//  Wipp
//
//  Created by JP Halis on 1/28/16.
//
//

#import <Foundation/Foundation.h>

// ----------------- P H O N E  N U M B E R ----------------

// Format (XXX) XXX-XXXX

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
//{
//    int length = (int)[self getLength:textField.text];
//    //NSLog(@"Length  =  %d ",length);
//    
//    if(length == 10)
//    {
//        if(range.length == 0)
//            return NO;
//    }
//    
//    if(length == 3)
//    {
//        NSString *num = [self formatNumber:textField.text];
//        textField.text = [NSString stringWithFormat:@"(%@) ",num];
//        
//        if(range.length > 0)
//            textField.text = [NSString stringWithFormat:@"%@",[num substringToIndex:3]];
//    }
//    else if(length == 6)
//    {
//        NSString *num = [self formatNumber:textField.text];
//        //NSLog(@"%@",[num  substringToIndex:3]);
//        //NSLog(@"%@",[num substringFromIndex:3]);
//        textField.text = [NSString stringWithFormat:@"(%@) %@-",[num  substringToIndex:3],[num substringFromIndex:3]];
//        
//        if(range.length > 0)
//            textField.text = [NSString stringWithFormat:@"(%@) %@",[num substringToIndex:3],[num substringFromIndex:3]];
//    }
//    
//    return YES;
//}
//
//- (NSString *)formatNumber:(NSString *)mobileNumber
//{
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
//    
//    NSLog(@"%@", mobileNumber);
//    
//    int length = (int)[mobileNumber length];
//    if(length > 10)
//    {
//        mobileNumber = [mobileNumber substringFromIndex: length-10];
//        NSLog(@"%@", mobileNumber);
//        
//    }
//    
//    return mobileNumber;
//}
//
//- (int)getLength:(NSString *)mobileNumber
//{
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"(" withString:@""];
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@")" withString:@""];
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    mobileNumber = [mobileNumber stringByReplacingOccurrencesOfString:@"+" withString:@""];
//    
//    int length = (int)[mobileNumber length];
//    
//    return length;
//}



// Insert characters in phone number

//NSMutableString *stringts = [NSMutableString stringWithString:self.ts.text];
//[stringts insertString:@"(" atIndex:0];
//[stringts insertString:@")" atIndex:4];
//[stringts insertString:@"-" atIndex:5];
//[stringts insertString:@"-" atIndex:9];
//self.ts.text = stringts;




// ----------------- L O C A T I O N ----------------

// .h file

//#import <CoreLocation/CoreLocation.h>
//
//@property (nonatomic,retain) CLLocationManager *locationManager;

// .m file

//- (NSString *)deviceLocation
//{
//    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
//    return theLocation;
//}
//
//- (void)viewDidLoad
//{
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.distanceFilter = kCLDistanceFilterNone;
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
//    [self.locationManager startUpdatingLocation];
//}
