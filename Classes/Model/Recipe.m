//
//  Recipe.m
//  CollegeChef
//
//  Created by Sahil Diwan.
//

#import "Recipe.h"

#import "Ingredients.h"
#import "Picture.h"

@interface Recipe (/*Class Extension*/)
@end

@implementation Recipe

#pragma mark Properties (Core Data Attributes)
@dynamic directions;
@dynamic ingredient;
@dynamic name;
@dynamic saved;

#pragma mark Properties (Core Data Relationships)
@dynamic ingredients;
@dynamic picture;

@end
