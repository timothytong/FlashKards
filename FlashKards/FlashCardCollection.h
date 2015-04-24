//
//  FlashCardCollection.h
//  
//
//  Created by Timothy Tong on 2015-04-16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CollectionHistory, FlashCard;

@interface FlashCardCollection : NSManagedObject

@property (nonatomic, retain) NSNumber * collectionID;
@property (nonatomic, retain) NSNumber * largestCardID;
@property (nonatomic, retain) NSNumber * last_updated;
@property (nonatomic, retain) NSNumber * lastReviewed;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numCards;
@property (nonatomic, retain) NSNumber * numCardsMemorized;
@property (nonatomic, retain) NSNumber * time_created;
@property (nonatomic, retain) NSSet *flashcards;
@property (nonatomic, retain) NSOrderedSet *reviewHistory;
@end

@interface FlashCardCollection (CoreDataGeneratedAccessors)

- (void)addFlashcardsObject:(FlashCard *)value;
- (void)removeFlashcardsObject:(FlashCard *)value;
- (void)addFlashcards:(NSSet *)values;
- (void)removeFlashcards:(NSSet *)values;

- (void)insertObject:(CollectionHistory *)value inReviewHistoryAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReviewHistoryAtIndex:(NSUInteger)idx;
- (void)insertReviewHistory:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReviewHistoryAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReviewHistoryAtIndex:(NSUInteger)idx withObject:(CollectionHistory *)value;
- (void)replaceReviewHistoryAtIndexes:(NSIndexSet *)indexes withReviewHistory:(NSArray *)values;
- (void)addReviewHistoryObject:(CollectionHistory *)value;
- (void)removeReviewHistoryObject:(CollectionHistory *)value;
- (void)addReviewHistory:(NSOrderedSet *)values;
- (void)removeReviewHistory:(NSOrderedSet *)values;

- (void)updateLastReviewTimeToCurrentTime;
@end
