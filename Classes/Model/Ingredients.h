//
//  Ingredients.h
//  CollegeChef
//
//  Created by Sahil Diwan.
//

@interface Ingredients : NSManagedObject

@property(nonatomic, strong) NSString* ingredient;
@property(nonatomic, strong) NSNumber* count;

@property(nonatomic, strong) NSSet* recipe;

@end
