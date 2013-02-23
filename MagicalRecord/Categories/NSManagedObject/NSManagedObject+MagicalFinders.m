//
//  NSManagedObject+MagicalFinders.m
//  Magical Record
//
//  Created by Saul Mora on 3/7/12.
//  Copyright (c) 2012 Magical Panda Software LLC. All rights reserved.
//

#import "NSManagedObject+MagicalFinders.h"
#import "NSManagedObject+MagicalRequests.h"
#import "NSManagedObject+MagicalRecord.h"
#import "NSManagedObjectContext+MagicalThreading.h"

@implementation NSManagedObject (MagicalFinders)

#pragma mark - Finding Data


+ (NSArray *) MR_findAllInContext:(NSManagedObjectContext *)context
{
	return [self MR_executeFetchRequest:[self MR_requestAllInContext:context] inContext:context];
}

+ (NSArray *) MR_findAll
{
	return [self MR_findAllInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSArray *) MR_findAllSortedBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortDescriptors inContext:context];
	
	return [self MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *) MR_findAllSortedBy:(NSArray *)sortDescriptors
{
	return [self MR_findAllSortedBy:sortDescriptors
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSArray *) MR_findAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortDescriptors
                                            withPredicate:searchTerm
                                                inContext:context];
	
	return [self MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *) MR_findAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm
{
	return [self MR_findAllSortedBy:sortDescriptors
                      withPredicate:searchTerm 
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}


+ (NSArray *) MR_findAllWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_createFetchRequestInContext:context];
	[request setPredicate:searchTerm];
	
	return [self MR_executeFetchRequest:request
                              inContext:context];
}

+ (NSArray *) MR_findAllWithPredicate:(NSPredicate *)searchTerm
{
	return [self MR_findAllWithPredicate:searchTerm
                               inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstInContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_createFetchRequestInContext:context];
	
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirst
{
	return [self MR_findFirstInContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context
{	
	NSFetchRequest *request = [self MR_requestFirstByAttribute:attribute withValue:searchValue inContext:context];
    //    [request setPropertiesToFetch:[NSArray arrayWithObject:attribute]];
    
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue
{
	return [self MR_findFirstByAttribute:attribute
                               withValue:searchValue 
                               inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm
{
    return [self MR_findFirstWithPredicate:searchTerm inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self MR_requestFirstWithPredicate:searchTerm inContext:context];
    
    return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortDescriptors withPredicate:searchterm inContext:context];
    
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchterm sortedBy:(NSArray *)sortDescriptors
{
	return [self MR_findFirstWithPredicate:searchterm
                                  sortedBy:sortDescriptors
                                 inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_createFetchRequestInContext:context];
	[request setPredicate:searchTerm];
	[request setPropertiesToFetch:attributes];
	
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm andRetrieveAttributes:(NSArray *)attributes
{
	return [self MR_findFirstWithPredicate:searchTerm
                     andRetrieveAttributes:attributes 
                                 inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context andRetrieveAttributes:(id)attributes, ...
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortDescriptors
                                            withPredicate:searchTerm
                                                inContext:context];
	[request setPropertiesToFetch:[self MR_propertiesNamed:attributes]];
	
	return [self MR_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (id) MR_findFirstWithPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors andRetrieveAttributes:(id)attributes, ...
{
	return [self MR_findFirstWithPredicate:searchTerm
                                  sortedBy:sortDescriptors
                                 inContext:[NSManagedObjectContext MR_contextForCurrentThread]
                     andRetrieveAttributes:attributes];
}

+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self MR_requestAllWhere:attribute isEqualTo:searchValue inContext:context];
	
	return [self MR_executeFetchRequest:request inContext:context];
}

+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue
{
	return [self MR_findByAttribute:attribute
                          withValue:searchValue 
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context
{
	NSPredicate *searchTerm = [NSPredicate predicateWithFormat:@"%K = %@", attribute, searchValue];
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortDescriptors withPredicate:searchTerm inContext:context];
	
	return [self MR_executeFetchRequest:request];
}

+ (NSArray *) MR_findByAttribute:(NSString *)attribute withValue:(id)searchValue andOrderBy:(NSArray *)sortDescriptors
{
	return [self MR_findByAttribute:attribute
                          withValue:searchValue
                         andOrderBy:sortDescriptors
                          inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}


#pragma mark -
#pragma mark NSFetchedResultsController helpers


#if TARGET_OS_IPHONE || TARGET_IPHONE_SIMULATOR

+ (NSFetchedResultsController *) MR_fetchController:(NSFetchRequest *)request delegate:(id<NSFetchedResultsControllerDelegate>)delegate useFileCache:(BOOL)useFileCache groupedBy:(NSString *)groupKeyPath inContext:(NSManagedObjectContext *)context
{
    NSString *cacheName = useFileCache ? [NSString stringWithFormat:@"MagicalRecord-Cache-%@", NSStringFromClass([self class])] : nil;
    
	NSFetchedResultsController *controller =
    [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                        managedObjectContext:context
                                          sectionNameKeyPath:groupKeyPath
                                                   cacheName:cacheName];
    controller.delegate = delegate;
    
    return controller;
}

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [self MR_requestAllSortedBy:sortDescriptors
                                            withPredicate:searchTerm
                                                inContext:context];
    
    NSFetchedResultsController *controller = [self MR_fetchController:request 
                                                             delegate:delegate
                                                         useFileCache:NO
                                                            groupedBy:group
                                                            inContext:context];
    
    [self MR_performFetch:controller];
    return controller;
}

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors delegate:(id)delegate
{
	return [self MR_fetchAllGroupedBy:group
                        withPredicate:searchTerm
                             sortedBy:sortDescriptors
                             delegate:delegate
                            inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors inContext:(NSManagedObjectContext *)context;
{
    return [self MR_fetchAllGroupedBy:group 
                        withPredicate:searchTerm
                             sortedBy:sortDescriptors
                             delegate:nil
                            inContext:context];
}

+ (NSFetchedResultsController *) MR_fetchAllGroupedBy:(NSString *)group withPredicate:(NSPredicate *)searchTerm sortedBy:(NSArray *)sortDescriptors 
{
    return [self MR_fetchAllGroupedBy:group 
                        withPredicate:searchTerm
                             sortedBy:sortDescriptors
                            inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}


+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self MR_requestAllSortedBy:sortDescriptors
                                            withPredicate:searchTerm
                                                inContext:context];
    
	NSFetchedResultsController *controller = [self MR_fetchController:request 
                                                             delegate:nil
                                                         useFileCache:NO
                                                            groupedBy:groupingKeyPath
                                                            inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
    
    [self MR_performFetch:controller];
    return controller;
}

+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath;
{
    return [self MR_fetchAllSortedBy:sortDescriptors
                       withPredicate:searchTerm
                             groupBy:groupingKeyPath
                           inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate inContext:(NSManagedObjectContext *)context
{
	NSFetchedResultsController *controller = [self MR_fetchAllGroupedBy:groupingKeyPath 
                                                          withPredicate:searchTerm
                                                               sortedBy:sortDescriptors
                                                               delegate:delegate
                                                              inContext:context];
	
	[self MR_performFetch:controller];
	return controller;
}

+ (NSFetchedResultsController *) MR_fetchAllSortedBy:(NSArray *)sortDescriptors withPredicate:(NSPredicate *)searchTerm groupBy:(NSString *)groupingKeyPath delegate:(id<NSFetchedResultsControllerDelegate>)delegate
{
	return [self MR_fetchAllSortedBy:sortDescriptors
                       withPredicate:searchTerm 
                             groupBy:groupingKeyPath 
                            delegate:delegate
                           inContext:[NSManagedObjectContext MR_contextForCurrentThread]];
}

#endif

@end
