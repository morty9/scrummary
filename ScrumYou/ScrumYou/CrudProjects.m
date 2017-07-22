//
//  CrudProjects.m
//  Scrummary
//
//  Created by Bérangère La Touche on 06/07/2017.
//  Copyright © 2017 Bérangère La Touche. All rights reserved.
//

#import "CrudProjects.h"
#import "APIKeys.h"
#import "Project.h"
#import "SynchronousMethod.h"

@implementation CrudProjects {
    SynchronousMethod* synchronousMethod;
}

@synthesize project = _project;

- (instancetype) init {
    self = [super init];
    
    if (self != nil) {
        self.projects_list = [[NSMutableArray<Project*> alloc] init];
        self.project = [[Project alloc] init];
        synchronousMethod = [[SynchronousMethod alloc] init];
    }
    return self;
}


/*
 *  POST -> add project to database
 */
- (void) addProjecTitle:(NSString*)title members:(NSMutableArray*)members sprints:(NSMutableArray*)sprints id_creator:(NSNumber*)id_creator token:(NSString*)token status:(BOOL)status callback:(void (^)(NSError *error, BOOL success))callback {
    
    NSURL* url = [NSURL URLWithString:kProject_api];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    NSDictionary* jsonData =
    @{@"title" : title,
      @"id_members" : members,
      @"id_sprint" : sprints,
      @"id_creator" : id_creator,
      @"status" : [NSString stringWithFormat:@"%d", status]};
    
    NSData* postData = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:nil];
    [request setHTTPBody:postData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        
        if (data == nil) {
            return;
        }
        
        if (response == nil) {
            return;
        }
        
        if ([jsonDict valueForKey:@"type"] != nil) {
            _dict_error = jsonDict;
        }
        
        callback(error, true);
        
    }] resume];
}


/*
 *  GET -> Get all projects from database
 */
- (void) getProjects:(void (^)(NSError *error, BOOL success))callback {
    
    NSURL* url = [NSURL URLWithString:kProject_api];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSError *error;
    NSURLResponse *response;
    NSData *data = [synchronousMethod sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data) {
        NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        for (NSDictionary* projects in jsonDict) {
            NSString* tmp_id = [projects valueForKey:@"id"];
            NSString* tmp_title = [projects valueForKey:@"title"];
            NSString* tmp_id_creator = [projects valueForKey:@"id_creator"];
            NSMutableArray* tmp_id_members = [projects valueForKey:@"id_members"];
            NSMutableArray* tmp_id_sprints = [projects valueForKey:@"id_sprint"];
            NSString* tmp_status = [projects valueForKey:@"status"];
            
            Project* p = [[Project alloc] initWithId:tmp_id title:tmp_title id_creator:tmp_id_creator id_members:tmp_id_members id_sprints:tmp_id_sprints status:tmp_status];
            
            [self.projects_list addObject:p];
            
        }
        
        callback(error, true);
    } else {
        NSLog(@"Error: %@", error.localizedDescription);
        return;
    }
}


/*
 *  GET -> get project by id
 */
- (void) getProjectById:(NSString*)id_project callback:(void (^)(NSError *error, BOOL success))callback {
    
    NSURL *url = [NSURL URLWithString:[kProject_api stringByAppendingString:[@"/" stringByAppendingString:id_project]]];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSError *error;
    NSURLResponse *response;
    NSData *data = [synchronousMethod sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if(data){
        NSLog(@"data");
        NSString* jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        
        NSString* tmp_id = [jsonDict valueForKey:@"id"];
        NSString* tmp_title = [jsonDict valueForKey:@"title"];
        NSString* tmp_id_creator = [jsonDict valueForKey:@"id_creator"];
        NSMutableArray* tmp_id_members = [jsonDict valueForKey:@"id_members"];
        NSMutableArray* tmp_id_sprints = [jsonDict valueForKey:@"id_sprint"];
        NSString* tmp_status = [jsonDict valueForKey:@"status"];
        
        self.project = [[Project alloc] initWithId:tmp_id title:tmp_title id_creator:tmp_id_creator id_members:tmp_id_members id_sprints:tmp_id_sprints status:tmp_status];
        
        callback(error, true);
    }
    else{
        NSLog(@"Error: %@", error.localizedDescription);
        return;
    }
    
}


/*
 * UPDATE -> update project with id
 */
- (void) updateProjectId:(NSString*)id_project title:(NSString*)title id_creator:(NSString*)id_creator members:(NSMutableArray*)members token:(NSString*)token id_sprints:(NSMutableArray*)id_sprints status:(BOOL)status callback:(void (^)(NSError *error, BOOL success))callback {
    
    NSLog(@"ID_PROJECT %@", id_project);
    NSLog(@"TITLE %@", title);
    NSLog(@"MEMBERS %@", members);
    
    NSURL *url = [NSURL URLWithString:[kProject_api stringByAppendingString:[@"/" stringByAppendingString:id_project]]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"PUT"];
    
    NSDictionary<NSString*, NSString*> *jsonData = @{@"title" : title,
                                                     @"id_creator" : id_creator,
                                                     @"id_members" : members,
                                                     @"id_sprint" : id_sprints,
                                                     @"status" : [NSString stringWithFormat:@"%d", status]};
    
    NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonData options:0 error:nil];
    [request setHTTPBody:postData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        
        if (data == nil) {
            return;
        }
        
        if (response == nil) {
            return;
        }
        
        callback(error, true);
        
    }] resume];
    
}


/*
 *  DELETE -> delete project by id
 */
- (void) deleteProjectWithId:(NSString*)id_project token:(NSString*)token callback:(void (^)(NSError *error, BOOL success))callback {
    
    NSURL* url = [NSURL URLWithString:[kProject_api stringByAppendingString:[@"/" stringByAppendingString:id_project]]];
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url];
    [request setHTTPMethod:@"DELETE"];
    [request setValue:token forHTTPHeaderField:@"Authorization"];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            return;
        }
        
        if (data == nil) {
            return;
        }
        
        if (response == nil) {
            return;
        }
        
        callback(error, true);
        
    }] resume];
    
}


@end
