//
//  FlashCardCollection.m
//  
//
//  Created by Timothy Tong on 2015-04-16.
//
//

#import "FlashCardCollection.h"
#import "CollectionHistory.h"
#import "FlashCard.h"


@implementation FlashCardCollection

@dynamic collectionID;
@dynamic largestCardID;
@dynamic last_updated;
@dynamic lastReviewed;
@dynamic name;
@dynamic numCards;
@dynamic numCardsMemorized;
@dynamic time_created;
@dynamic flashcards;
@dynamic reviewHistory;

- (void)updateLastReviewTimeToCurrentTime {
    self.lastReviewed = [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSError *error;
    if([context save:&error]){
        NSLog(@"Updated last review time successfully");
    }
    else{
        NSLog(@"Update last review time failed");
    }
}

@end
