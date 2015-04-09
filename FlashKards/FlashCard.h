//
//  FlashCard.h
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-08.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FlashCardCollection;

@interface FlashCard : NSManagedObject

@property (nonatomic, retain) id back;
@property (nonatomic, retain) NSNumber * cardID;
@property (nonatomic, retain) id front;
@property (nonatomic, retain) NSNumber * last_updated;
@property (nonatomic, retain) NSNumber * time_created;
@property (nonatomic, retain) NSNumber * memorized;
@property (nonatomic, retain) FlashCardCollection *parentCollection;

@end
