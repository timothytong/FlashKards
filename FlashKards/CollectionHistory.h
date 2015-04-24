//
//  CollectionHistory.h
//  
//
//  Created by Timothy Tong on 2015-04-16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FlashCardCollection;

@interface CollectionHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * totalNumCards;
@property (nonatomic, retain) NSNumber * rememberedCards;
@property (nonatomic, retain) NSNumber * timeUsed;
@property (nonatomic, retain) NSNumber * completed;
@property (nonatomic, retain) NSNumber * time;
@property (nonatomic, retain) NSNumber * historyID;
@property (nonatomic, retain) FlashCardCollection *collection;

@end
