//
//  FlashCardCollection.h
//  FlashKards
//
//  Created by Timothy Tong on 2015-04-08.
//  Copyright (c) 2015 Timothy Tong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FlashCard;

@interface FlashCardCollection : NSManagedObject

@property (nonatomic, retain) NSNumber * collectionID;
@property (nonatomic, retain) NSNumber * last_updated;
@property (nonatomic, retain) NSNumber * lastReviewed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numCards;
@property (nonatomic, retain) NSNumber * time_created;
@property (nonatomic, retain) NSNumber * numCardsMemorized;
@property (nonatomic, retain) NSNumber * largestCardID;
@property (nonatomic, retain) NSSet *flashcards;
@end

@interface FlashCardCollection (CoreDataGeneratedAccessors)

- (void)addFlashcardsObject:(FlashCard *)value;
- (void)removeFlashcardsObject:(FlashCard *)value;
- (void)addFlashcards:(NSSet *)values;
- (void)removeFlashcards:(NSSet *)values;

@end
