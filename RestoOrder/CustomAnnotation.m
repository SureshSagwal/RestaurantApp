//
//  CustomAnnotation.m
//  RestoOrder
//
//  Created by Suresh Kumar on 19/07/15.
//
//

#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize latitude, longitude, name, imageUrl, index, coordinate;

-(id)createAnnotationWithLatitude:(double)lat Longitude:(double)longit Title:(NSString *)annotaionName Index:(NSInteger)annotationIndex
{
    self.latitude = lat;
    self.longitude = longit;
    self.name = annotaionName;
    self.index = annotationIndex;
    self.coordinate = CLLocationCoordinate2DMake(lat, longit);
    return self;
}


@end
