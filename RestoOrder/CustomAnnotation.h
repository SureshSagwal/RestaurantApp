//
//  CustomAnnotation.h
//  RestoOrder
//
//  Created by Suresh Kumar on 19/07/15.
//
//

#import <MapKit/MapKit.h>

@interface CustomAnnotation : NSObject<MKAnnotation>

@property(nonatomic, strong)NSString *imageUrl;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, assign)CLLocationCoordinate2D coordinate;
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, assign)double latitude;
@property(nonatomic, assign)double longitude;

-(id)createAnnotationWithLatitude:(double)lat Longitude:(double)longit Title:(NSString *)annotaionName Index:(NSInteger)annotationIndex;
@end
