//
//  FlashCard.h
//  
//
//  Created by Timothy Tong on 2015-04-16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FlashCardCollection;

@interface FlashCard : NSManagedObject

@property (nonatomic, retain) id back;
@property (nonatomic, retain) NSNumber * cardID;
@property (nonatomic, retain) id front;
@property (nonatomic, retain) NSNumber * last_updated;
@property (nonatomic, retain) NSNumber * memorized;
@property (nonatomic, retain) NSNumber * time_created;
@property (nonatomic, retain) FlashCardCollection *parentCollection;

@end
