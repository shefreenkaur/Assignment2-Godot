# COMP 360 Assignment 2 - 3D Glider Flight System

## Team Members and Actual Contributions

### Paramvir
- Implemented initial circular path system in `flight_system.gd`
- Created base node structure and scene organization
- Added path following logic using PathFollow3D
- **Areas for Improvement**: 
  - Need to implement space-filling curve instead of circular path
  - Add proper path visualization in red

### Shefreen
- Worked on glider movement mechanics in `flight_system.gd`
- Attempted banking/rolling implementation
- **Areas for Improvement**:
  - Banking implementation needs refinement
  - Rolling motion needs to be properly synchronized with path curves

### Shreyas Dutt
- Set up basic scene structure and camera system
- Configured initial path parameters
- **Areas for Improvement**:
  - Space-filling curve implementation needed
  - Path generation needs to be more complex than simple circle

### Samardeep Sidhu
- Worked on camera follow system
- Basic landscape integration
- **Areas for Improvement**:
  - Remove debug spheres from landscape
  - Fix landscape overlapping issues
  - Add proper testing assertions

### Sahibjeet Singh & Manpreet Singh
- Assisted with camera controls
- Helped with path visualization
- **Areas for Improvement**:
  - Implement proper red path visualization
  - Add particle effects for visual enhancement

## Actual Implementation Status

### Completed Features
1. Basic circular path implementation
2. Simple camera following system
3. Basic glider movement along path
4. Initial scene setup and organization

### Missing/Incomplete Features
1. Space-filling curve implementation
2. Red path visualization
3. Proper glider rolling/banking
4. Particle effects
5. Strategic assert function calls for testing
6. Proper landscape fixes from Assignment 1

## Technical Details

### Current Implementation
```gdscript
# Example of current path creation
func create_circular_path():
    path = Path3D.new()
    var curve = Curve3D.new()
    # Current implementation uses simple circular path
    # TODO: Replace with space-filling curve
```

### Required Improvements
```gdscript
# Example of needed testing implementation
func test_path_generation():
    assert(path != null, "Path should be created")
    assert(path.curve.get_point_count() > 0, "Path should have points")
```

## Development Process

### Version Control
- Git repository: (https://github.com/shefreenkaur/Assignment2-Gadot)
- Commit history tracks individual contributions
- Branch structure for feature development

### Testing Protocol (To Be Implemented)
```gdscript
# Required test cases
func test_glider_movement():
    assert(glider.position.y >= minimum_height, "Glider should stay above terrain")
    assert(path_follow.loop, "Path should be looping")
```

## Current Issues and Required Fixes

### Critical Issues
1. **Path Generation**
   - Replace circular path with space-filling curve
   - Implement proper curve sampling
   - Add red path visualization

2. **Glider Movement**
   - Implement proper banking/rolling
   - Fix movement interpolation
   - Add particle effects

3. **Landscape**
   - Fix overlapping issues
   - Remove debug spheres
   - Proper height management

4. **Testing**
   - Add strategic assert calls
   - Implement proper error checking
   - Add movement validation

## Setup and Installation

1. **Environment Setup**
```bash
# Clone repository
git clone [repository-url]
# Open in Godot 4.x
# Run main scene
```

2. **Required Files**
- `flight_system.gd`
- `glider.tscn`
- `main.tscn`

## Testing Procedures (To Be Implemented)

```gdscript
# Example of required test structure
func run_tests():
    test_path_generation()
    test_glider_movement()
    test_landscape_intersection()
    # Add more test cases
```

## Git Integration Status

### Current Structure
- Main development branch
- Feature branches for:
  - Path generation
  - Glider movement
  - Camera system

### Required Improvements
- Regular commits with meaningful messages
- Proper branch management
- Code review process
- Issue tracking

## Task Division Verification
- Each commit linked to specific team member
- Clear documentation of individual contributions
- Trackable progress through git history

## Plan for Completion
1. Implement space-filling curve
2. Add proper testing assertions
3. Fix landscape issues
4. Add missing features (particle effects, rolling)
5. Proper documentation
6. Complete test coverage
