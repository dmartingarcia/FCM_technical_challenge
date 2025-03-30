# FCM Technical Challenge Solution

## Problem Analysis

### Problem Statement
Transform raw travel reservation data into organized trips grouped by destination, maintaining chronological order and considering 24-hour connections as part of the same trip.

### Key Inputs/Outputs
- **Input**: Text file with `RESERVATION` blocks containing flights, hotels, and trains
- **Output**: Grouped trips with formatted chronological segments
- **Constraints**:
  - IATA codes (3-letter capitals)
  - Non-overlapping segments
  - 24-hour connection threshold

### Edge Cases
- Overnight segments crossing midnight
- Multiple trips to same destination
- Malformed input lines
- Empty input files

---

## Solution Design

### Architectural Patterns
#### Hexagonal Architecture
```
                +----------------+
                |    Use Cases   |
                | (GroupSegments)|
                +-------+--------+
                        |
           +------------+------------+
           |                         |
+----------v----------+    +----------v----------+
|   Core Entities     |    |   Ports/Adapters    |
| (Travel, Flight...) |    | (Repositories,      |
+---------------------+    |  Printers)          |
                           +---------------------+
```
- **Core**: Business logic isolation
- **Adapters**: Swappable I/O components

#### Applying the SOLID Principles
1. **Single Responsibility**: Dedicated classes for parsing/printing and handling the business logic
2. **Open/Closed**: Extensible via new adapters
3. **Liskov**: Uniform transport interfaces
4. **Interface Segregation**: Narrow printer/repo contracts
5. **Dependency Inversion**: Core depends on abstractions

### Steps required:
1. **Parse Segments** → Structured objects
2. **Group Trips**:
   - Start with base departure
   - Chain segments until 24h+ gap
3. **Sort** → Trips by start time

---

## Implementation Plan

### Folder Structure
```
├── core/               # Business logic
│   ├── entities/       # Flight.rb, Hotel.rb, Travel.rb...
│   ├── repositories/  # Repository interface
│   └── use_cases/     # Use Case Services
├── adapters/           # I/O implementations
│   ├── repositories/  # Input File Repository
│   └── printers/      # Output to console
├── config/             # Timezone/validation rules
├── spec/               # RSpec tests
```

### Phases
1. **Containerization**
   - Docker setup
2. **Create and set all tooling (spec/rubocop/brakeman)**
   - Entities, validation, time handling
3. **Implement DTO/Entities**
   - Create all required entities identified (Flight/Hotel/Train/Travel/Segment)
4. **Adapter Development**
   - Text parser/printer, error handling
5. **Develop Grouping feature**
   - To code the main logic using the previous components
3. **Resilience Engineering**
   - Implement Circuit breakers, retry logic and any other mechanism to ensure it has a successful result.
5. **Quality Automation** (Day 9)
   - Coverage checks, CI/CD integration, Git Hooks..

### Tools
- Ruby 3.4.0
- RSpec/SimpleCov (testing)
- Docker (containerization)

---

## Testing Strategy

### Test Pyramid
1. **Unit Tests**
   - Entity validation
   - Parser edge cases
2. **Integration Tests**
   - Full trip grouping
   - Error recovery paths
3. **Performance/Load Tests**
   - 10k segments benchmark
4. **Quality Gates**:
    Implement Git hooks -> Block commits if coverage <90%

---