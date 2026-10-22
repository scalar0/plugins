# SysML v2 library index (standard + domain only)

Short local index of reusable libraries from:

- https://github.com/Systems-Modeling/SysML-v2-Release/tree/master/sysml.library

Scope in this index:

- `sysml.library/Systems Library` (standard SysML libraries)
- `sysml.library/Domain Libraries` (domain libraries)

Explicitly excluded:

- `sysml.library/Kernel Libraries` (KerML libraries)

## Standard SysML libraries (`Systems Library`)

Available `.sysml` libraries:

- `SysML`
- `Actions`
- `Allocations`
- `AnalysisCases`
- `Attributes`
- `Calculations`
- `Cases`
- `Connections`
- `Constraints`
- `Flows`
- `Interfaces`
- `Items`
- `Metadata`
- `Parts`
- `Ports`
- `Requirements`
- `StandardViewDefinitions`
- `States`
- `UseCases`
- `VerificationCases`
- `Views`

## Domain libraries (`Domain Libraries`)

### Analysis

- `AnalysisTooling`
- `SampledFunctions`
- `StateSpaceRepresentation`
- `TradeStudies`

### Cause and Effect

- `CauseAndEffect`
- `CausationConnections`

### Geometry

- `ShapeItems`
- `SpatialItems`

### Metadata

- `ImageMetadata`
- `ModelingMetadata`
- `ParametersOfInterestMetadata`
- `RiskMetadata`

### Quantities and Units

- `ISQ`
- `ISQAcoustics`
- `ISQAtomicNuclear`
- `ISQBase`
- `ISQCharacteristicNumbers`
- `ISQChemistryMolecular`
- `ISQCondensedMatter`
- `ISQElectromagnetism`
- `ISQInformation`
- `ISQLight`
- `ISQMechanics`
- `ISQSpaceTime`
- `ISQThermodynamics`
- `MeasurementRefCalculations`
- `MeasurementReferences`
- `Quantities`
- `QuantityCalculations`
- `SI`
- `SIPrefixes`
- `TensorCalculations`
- `Time`
- `USCustomaryUnits`
- `VectorCalculations`

### Requirement Derivation

- `RequirementDerivation`
- `DerivationConnections`

## Usage note

When generating imports, prefer these library names before inventing new namespaces. If exact member/package casing is uncertain, verify with `sysmlv2-mcp` diagnostics/symbol lookup.
