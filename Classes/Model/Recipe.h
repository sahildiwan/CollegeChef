//
//  Recipe.h
//  CollegeChef
//
//  Created by Sahil Diwan.
//

@class Ingredients, Picture;

@interface Recipe : NSManagedObject

@property(nonatomic, strong) NSString* directions;
@property(nonatomic, strong) NSString* ingredient;
@property(nonatomic, strong) NSString* name;
@property(nonatomic, strong) NSString* saved;

@property(nonatomic, strong) Ingredients* ingredients;
@property(nonatomic, strong) Picture* picture;

@end
