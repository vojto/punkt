//
//  Column.h
//  Punkt
//
//  Created by Vojtech Rinik on 18/06/14.
//  Copyright (c) 2014 rinik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Column : NSManagedObject

@property (nonatomic, retain) NSString * labelName;
@property (nonatomic, retain) NSNumber * weight;

@end
