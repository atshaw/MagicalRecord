//
//  NSManagedObject+MagicalFinders.h
//  Magical Record
//
//  Created by Saul Mora on 3/7/12.
//  Copyright (c) 2012 Magical Panda Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (MagicalFinders)

+ (NSArray *) MR_findAll;
+ (NSArray *) MR_findAllInContext:(NSManagedObjectContext *)context;
+ (NSArray *) MR_findAllSortedBy:(NSArray *)sortDescriptors;
+ (NSArray *) MR_findAllSortedBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;
+ (NSArray *) MR_findAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm;
+ (NSArray *) MR_findAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (NSArray *) MR_findAllWithPredicate:(NSPredicate *)searchTerm;
+ (NSArray *) MR_findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;

+ (id) MR_findFirst;
+ (id) MR_findFirstInContext:(NSManagedObjectContext *)context;
+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm;
+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context;
+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSArray *)sortDescriptors;
+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;
+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes;
+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes inContext:(NSManagedObjectContext *)context;
+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors andRetrieveAttributes:(id)attributes, ...;
+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context andRetrieveAttributes:(id)attributes, ...;

+ (id) MR_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue;
+ (id) MR_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue;
+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;
+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSArray *)sortDescriptors;
+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;

#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate;
+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context;

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors;
+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors delegate:(id<NSFetchedResultsControllerDelegate>)delegate;
+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context;

#endif

@end
