//
//  CSCoreDataService.m
//  CollegeChef
//
//  Created by Sahil Diwan.
//


#import "CSCoreDataService.h"


static NSString* const CSStoreName = @"CollegeChef.sqlite";

static CSCoreDataService* _singleton;


@implementation CSCoreDataService {
	NSManagedObjectContext* _parentManagedObjectContext;
	NSManagedObjectModel* _managedObjectModel;
	NSPersistentStoreCoordinator* _persistentStoreCoordinator;
}
#pragma mark Public (Context)
- (void)saveMainQueueContextWithCompletionHandler:(void(^)(BOOL success))completionHandler {
	[_mainQueueContext performBlock:^{
		NSError* error = nil;
		if(![_mainQueueContext save:&error]) {
			NSLog(@"Error saving main queue managed object context: %@", error);

			[_mainQueueContext rollback];

			if(completionHandler != nil) {
				completionHandler(NO);
			}
		}
		else {
			[_parentManagedObjectContext performBlock:^{
				NSError* error = nil;
				if(![_parentManagedObjectContext save:&error]) {
					NSLog(@"Error saving parent managed object context: %@", error);

					[_parentManagedObjectContext rollback];
					if(completionHandler != nil) {
						dispatch_async(dispatch_get_main_queue(), ^{
							completionHandler(NO);
						});
					}
				}
				else {
					if(completionHandler != nil) {
						dispatch_async(dispatch_get_main_queue(), ^{
							completionHandler(YES);
						});
					}
				}
			}];
		}
	}];
}


#pragma mark Class (Singleton)
+ (CSCoreDataService*)sharedCoreDataService {
	if(_singleton == nil) {
		_singleton = [[CSCoreDataService alloc] init]; // Redundant assign to avoid warning
	}
	
	return _singleton;
}


#pragma mark Initialization
- (id)init {
	if(_singleton == nil) {
		self = [super init];
		[self _initialize];
		
		_singleton = self;
	}
	else {
		self = _singleton;
	}
	
	return self;
}


#pragma mark Private (Initialization)
- (void)_initialize {
	// Create and configure the core data stack
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"MainModel" withExtension:@"momd"]];
	_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_managedObjectModel];
	
	NSString* documentsDirectoryPathString = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
	NSString* persistentStoreUrlString = [documentsDirectoryPathString stringByAppendingPathComponent:CSStoreName];
	NSURL* persistentStoreUrl = [NSURL fileURLWithPath:persistentStoreUrlString];
	NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
	NSError* persistentStoreError;
	if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:persistentStoreUrl options:options error:&persistentStoreError]) {
		NSLog(@"Failed adding persistent store to the persistent store coordinator: %@", [persistentStoreError localizedDescription]);
		exit(-1);
	}
	
	_parentManagedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
	_parentManagedObjectContext.persistentStoreCoordinator = _persistentStoreCoordinator;
	_parentManagedObjectContext.undoManager = nil;

	_mainQueueContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	_mainQueueContext.parentContext = _parentManagedObjectContext;
	_mainQueueContext.undoManager = nil;
}
@end
