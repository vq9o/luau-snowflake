# luau-snowflake

This module provides a Snowflake ID generator for Luau, designed for use in distributed systems to generate unique IDs based on timestamp, worker ID, and a sequence number.

## Features

- Generates unique Snowflake IDs
- Parses Snowflake IDs back into their components
- Configurable worker ID and epoch
- Validates Snowflake IDs

## Installation

To use this module, simply copy the `source.lua` file into your project.

## Usage

### Importing the Module

```luau
local Snowflake = require(path.to.Snowflake)
```

### Generating a Snowflake ID

```luau
local id = Snowflake.new()
print("Generated ID:", id)
```

### Parsing a Snowflake ID

```luau
local parsed = Snowflake:parse(id)
print("Parsed ID:", parsed)
```

### Setting and Getting Worker ID

```luau
Snowflake:set_worker_id(1)
local worker_id = Snowflake:get_worker_id()
print("Worker ID:", worker_id)
```

### Setting and Getting Epoch

```luau
Snowflake:set_epoch(1704067200000) -- January 1st, 2024
local epoch = Snowflake:get_epoch()
print("Epoch:", epoch)
```

### Validating a Snowflake ID

```luau
local is_valid, message = Snowflake:validate(id)
print("Is valid:", is_valid, "Message:", message)
```

## Types

The module uses the following custom types:

```luau
export type SnowflakeId = number
export type SnowflakeParsed = {
    timestamp: number,
    worker_id: number,
    count: number,
    snowflake: SnowflakeId
}
```

## License
This project is licensed under the MIT License.
