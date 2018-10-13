//
//  NetworkTablesWrapper.m
//  FrostedGlass
//
//  Created by Tim Winters on 10/4/18.
//  Copyright © 2018 Tim Winters. All rights reserved.
//

#import "NetworkTablesWrapper.h"
#import "tables/ITable.h"
#import "networktables/NetworkTable.h"
#import "networktables/NetworkTableInstance.h"

@implementation NetworkTablesWrapper
nt::NetworkTableInstance inst;
std::shared_ptr<nt::NetworkTable> table;
+ (void) initialize {
    inst = nt::NetworkTableInstance::GetDefault();
    inst.StartClient("130.215.125.64", nt::NetworkTableInstance::kDefaultPort);
    table = inst.GetTable("/");
    table->PutNumber("number", 1.5);
}
+ (int) getValue{
    if (!inst.IsConnected()){
        return 1;
    }
    return table->GetEntry("x").GetDouble(1);
}
@end
