# SysML v2 construct patterns

## Packages

### Package definition and imports

```sysml
package VehicleModel {
    public import VehicleParts;
    private import ISQ::MassValue;
    private import SI::*;
}
```

### Alias

```sysml
alias MV for ISQ::MassValue;
```

Use packages to create a clear modeling namespace and to keep imports close to the declarations that depend on them.

## Parts

### Part definition

```sysml
part def Engine;

part def Vehicle {
    attribute mass : MassValue;
    attribute wheels : Integer;
}
```

### Specialization

```sysml
part def SportsCar :> Vehicle {
    :>> wheels = 4;
}
```

### Part usage

```sysml
part vehicle : Vehicle {
    :>> mass = 1500 [kg];
    part engine : Engine;
}
```

## Items

### Item definition

```sysml
item def Fuel {
    attribute fuelMass :> ISQ::mass;
}
```

Use items for thing-like exchanged elements, especially in examples involving ports or connections.

## Connections

### Connection definition

```sysml
connection def DeviceConn {
    end part hub : Hub;
    end part device : Device;
    attribute bandwidth : Real;
}
```

### Connection usage

```sysml
item mainSwitch : MainSwitch;
item sensorFeed : SensorFeed;

connection conn : DeviceConn {
    end part hub ::> mainSwitch;
    end part device ::> sensorFeed;
}
```

When writing connection usages, make sure the referenced endpoints already exist in scope.

## Ports

### Port definition

```sysml
port def FuelingPort {
    attribute flowRate : Real;
    out fuelOut : Fuel;
    in fuelIn : Fuel;
}
```

### Port usage

```sysml
port fuelTankPort : FuelingPort;
```

Use `in` and `out` directions explicitly when the cheat-sheet pattern depends on flow direction.

## Actions and states

### Action definition

```sysml
action def StartEngine {
    in ignitionSignal : Boolean;
    out status : EngineStatus;
}
```

### Composite action

```sysml
action def Drive {
    action accelerate : Accelerate;
    first start then accelerate;
}
```

### Perform action

```sysml
part vehicle : Vehicle {
    perform action driveVehicle : Drive;
}
```

### State definition

```sysml
state def EngineStates {
    state Off;
    state Running;
}
```

If sequencing is shown, keep it readable and avoid inventing extra control syntax not grounded in the provided pattern.

## Constraints

### Constraint definition

```sysml
constraint def IsFull {
    in tank : FuelTank;
    tank.fuelLevel == tank.maxFuelLevel
}
```

### Constraint usage

```sysml
part def VehicleWithConstraint {
    part fuelTank : FuelTank;
    constraint tankIsFull : IsFull {
        in tank = fuelTank;
    }
}
```

Make bindings explicit inside constraint usages.

## Requirements

### Requirement definition

```sysml
requirement def MassRequirement {
    subject vehicle : Vehicle;
    attribute massActual : ISQ::MassValue;
    attribute massLimit : ISQ::MassValue;
    require constraint { massActual <= massLimit }
}
```

### Requirement usage

```sysml
requirement <R1> vehicleMass : MassRequirement {
    attribute :>> massActual = vehicle.mass;
    attribute :>> massLimit = 1800 [kg];
}
```

### Satisfy requirement

```sysml
satisfy R1 by vehicle;
```

## Pattern selection guide

- Need a reusable structural type → `part def`, `item def`, `port def`, `connection def`
- Need a typed declared element → `<kind> <name> : <Type>`
- Need behavior → `action def`, `perform action`, `state def`
- Need a rule over bound inputs → `constraint def` plus a typed constraint usage
- Need compliance intent → `requirement def`, requirement usage, optionally `satisfy`
