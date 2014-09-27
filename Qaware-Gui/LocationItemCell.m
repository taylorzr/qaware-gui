//
//  LocationItemCell.m
//  Qaware-Gui
//
//  Created by Zach Taylor on 9/27/14.
//  Copyright (c) 2014 Zach Taylor. All rights reserved.
//

#import "LocationItemCell.h"

@implementation LocationItemCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.item = nil;
}

- (void)setItem:(LocationItem *)item {
    if (_item) {
        [_item removeObserver:self forKeyPath:@"lastSeenBeacon"];
    }
    
    _item = item;
    [_item addObserver:self
            forKeyPath:@"lastSeenBeacon"
               options:NSKeyValueObservingOptionNew
               context:NULL];
    
    self.textLabel.text = _item.name;
}

-(void)dealloc {
    [_item removeObserver: self forKeyPath:@"lastSeenBeacon"];
}

- (NSString *)nameForProximity:(CLProximity)proximity {
    switch (proximity) {
        case CLProximityUnknown:
            return @"Unknown";
            break;
        case CLProximityImmediate:
            return @"Immediate";
            break;
        case CLProximityNear:
            return @"Near";
            break;
        case CLProximityFar:
            return @"Far";
            break;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([object isEqual:self.item] && [keyPath isEqualToString:@"lastSeenBeacon"]) {
        NSString *proximity = [self nameForProximity:self.item.lastSeenBeacon.proximity];
        self.detailTextLabel.text = [NSString stringWithFormat:@"Location: %@", proximity];
        //self.button = YES;
    }
}

@end
