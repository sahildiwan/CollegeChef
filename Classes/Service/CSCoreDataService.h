//
//  CSCoreDataService.h
//  CollegeChef
//
//  Created by Sahil Diwan.
//


@interface CSCoreDataService : NSObject
+ (CSCoreDataService*)sharedCoreDataService;

- (void)saveMainQueueContextWithCompletionHandler:(void(^)(BOOL success))completionHandler;

@property(nonatomic, strong, readonly) NSManagedObjectContext* mainQueueContext;
@end
