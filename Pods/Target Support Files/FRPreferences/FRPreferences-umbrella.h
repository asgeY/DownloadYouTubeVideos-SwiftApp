#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "FRPCell.h"
#import "FRPDeveloperCell.h"
#import "FRPLinkCell.h"
#import "FRPListCell.h"
#import "FRPreferences.h"
#import "FRPrefs.h"
#import "FRPSection.h"
#import "FRPSegmentCell.h"
#import "FRPSelectListTable.h"
#import "FRPSettings.h"
#import "FRPSliderCell.h"
#import "FRPSwitchCell.h"
#import "FRPTextFieldCell.h"
#import "FRPValueCell.h"
#import "FRPViewCell.h"
#import "FRPViewSection.h"

FOUNDATION_EXPORT double FRPreferencesVersionNumber;
FOUNDATION_EXPORT const unsigned char FRPreferencesVersionString[];

