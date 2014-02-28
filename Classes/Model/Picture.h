//
//  Picture.h
//  CollegeChef
//
//  Created by Sahil Diwan.
//

@class Recipe;

@interface Picture : NSManagedObject

@property(nonatomic, strong) NSData* data;

@property(nonatomic, strong) Recipe* recipe;

@end
