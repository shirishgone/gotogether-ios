//
//  GTMapViewTransition.m
//  GTMap
//
//  Created by Shirish Gone on 12/24/13.
//  Copyright (c) 2013 Shirish Gone. All rights reserved.
//

#import "GTMapViewTransition.h"
#import "GTRideDetailsViewController.h"
#import "GTGoogleMapsRouteViewController.h"
#import "GTEventDetailsHeaderView.h"

#define kAnimationDuration 0.65

@interface GTMapViewTransition ()
@property (nonatomic, assign) id <UIViewControllerContextTransitioning> transitionContext;
@end

@implementation GTMapViewTransition

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.reverse == NO) {
        [self presentingAnimation:transitionContext];
    } else {
        [self dismissAnimation:transitionContext];
    }
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (UIImage *)imageForNavigationControllerView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0.0f);
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(c, 0, -[[UIApplication sharedApplication]statusBarFrame].size.height);
    [view drawViewHierarchyInRect:view.frame afterScreenUpdates:YES];
    UIImage *viewLayerAsImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewLayerAsImage;
}

#pragma mark - MapTransitions


- (GTRideDetailsViewController *)rideDetailsViewControllerFromTransitionContext:(id)transitionContext{
    
    id controller = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        
        UINavigationController *detailsNavController = (UINavigationController *)[tabBarController selectedViewController];
        GTRideDetailsViewController *fromVC = (GTRideDetailsViewController *)[[detailsNavController viewControllers] lastObject];
        return fromVC;
    }else if ([controller isKindOfClass:[UINavigationController class]]){
        UINavigationController* navController = (UINavigationController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        GTRideDetailsViewController *fromVC = (GTRideDetailsViewController *)[[navController viewControllers] lastObject];
        return fromVC;

    }else {
        return nil;
    }
}

- (GTGoogleMapsRouteViewController *)googleMapViewControllerFromTransitionContext:(id)transitionContext{
    GTGoogleMapsRouteViewController* toViewController = (GTGoogleMapsRouteViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    return toViewController;
}

- (void)presentingAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    self.transitionContext = transitionContext;
    
    GTGoogleMapsRouteViewController *googleController =
    [self googleMapViewControllerFromTransitionContext:transitionContext];

    GTRideDetailsViewController *rideDetailsController =
    [self rideDetailsViewControllerFromTransitionContext:transitionContext];
    
    
    GTEventDetailsHeaderView *tableHeaderView = (GTEventDetailsHeaderView *)rideDetailsController.tableView.tableHeaderView;
    GTRouteMapView *mapView = [tableHeaderView mapView];
    
    CGRect mapFrame = mapView.frame;
    CGFloat yPos = [[UIApplication sharedApplication] statusBarFrame].size.height;
    yPos = yPos+ [rideDetailsController.navigationController.navigationBar frame].size.height;
    mapFrame = CGRectMake(mapFrame.origin.x, yPos, mapFrame.size.width, mapFrame.size.height);
    
    CGRect finalFrame = [transitionContext finalFrameForViewController:googleController];
    
    [googleController.view setFrame:mapFrame];
    googleController.view.clipsToBounds = YES;
    [[transitionContext containerView] addSubview:googleController.view];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kAnimationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationComplete)];
        [googleController.view setFrame:finalFrame];
        [UIView commitAnimations];
    });

}

- (void)animationComplete{
    [self.transitionContext completeTransition:YES];
}

- (void)dismissAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    self.transitionContext = transitionContext;
    GTGoogleMapsRouteViewController* googleController = (GTGoogleMapsRouteViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    [googleController dismissViewControllerAnimated:NO completion:nil];
    
    GTRideDetailsViewController *rideDetailsController = nil;
    id controller = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController *)controller;
        UINavigationController *detailsNavController = (UINavigationController *)[tabBarController selectedViewController];
        rideDetailsController = (GTRideDetailsViewController *)[[detailsNavController viewControllers] lastObject];
    }else if ([controller isKindOfClass:[UINavigationController class]]){
        UINavigationController *detailsNavController = (UINavigationController *)controller;
        rideDetailsController = (GTRideDetailsViewController *)[[detailsNavController viewControllers] lastObject];
    }
    
    
    GTEventDetailsHeaderView *tableHeaderView = (GTEventDetailsHeaderView *)rideDetailsController.tableView.tableHeaderView;
    GTRouteMapView *mapView = [tableHeaderView mapView];
    
    CGRect mapFrame = mapView.frame;
    CGFloat yPos = [[UIApplication sharedApplication] statusBarFrame].size.height;
    yPos = yPos+ [rideDetailsController.navigationController.navigationBar frame].size.height;
    mapFrame = CGRectMake(mapFrame.origin.x, yPos, mapFrame.size.width, mapFrame.size.height);
    
    googleController.view.clipsToBounds = YES;
    
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)controller;
        [[transitionContext containerView] addSubview:tabBarController.view];
    }else if ([controller isKindOfClass:[UINavigationController class]]){
        UINavigationController *navController = (UINavigationController *)controller;
        [[transitionContext containerView] addSubview:navController.view];
    }
    
    [[transitionContext containerView] addSubview:googleController.view];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kAnimationDuration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationComplete)];
        [googleController.view setFrame:mapFrame];
        [googleController.mapView setFrame:mapFrame];
        [UIView commitAnimations];
    });
}

@end
