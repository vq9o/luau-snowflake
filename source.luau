-- Copyright (c) 2024 RAMPAGE Interactive
-- Written by vq9o

-- License: MIT
-- GitHub: https://github.com/vq9o/luau-snowflake/tree/main

local Snowflake = {}

export type SnowflakeId = number
export type SnowflakeParsed = {
	timestamp: number,
	worker_id: number,
	count: number,
	snowflake: SnowflakeId,
}

-- Constants for bit shifts and masks
local EPOCH: number = 1420070400000 -- Default epoch is January 1st, 2015
local WORKER_ID_BITS: number = 5
local COUNT_BITS: number = 12
local MAX_COUNT: number = (2 ^ COUNT_BITS) - 1
local WORKER_ID_SHIFT: number = COUNT_BITS
local TIMESTAMP_SHIFT: number = WORKER_ID_SHIFT + WORKER_ID_BITS

-- Variables
local worker_id: number = 0
local count: number = 0
local last_timestamp: number = -1

-- Helper function to get the current timestamp in milliseconds
local function get_current_timestamp(): number
	return math.floor(tick() * 1000)
end

-- Helper function to wait for the next millisecond
local function wait_for_next_millisecond(timestamp: number): number
	while timestamp == last_timestamp do
		timestamp = get_current_timestamp()
	end

	return timestamp
end

function Snowflake.new(): SnowflakeId
	local timestamp: number = get_current_timestamp()

	if timestamp < last_timestamp then
		error("Clock moved backwards. Refusing to generate id")
	end

	if timestamp == last_timestamp then
		count = (count + 1) % (MAX_COUNT + 1)
		if count == 0 then
			timestamp = wait_for_next_millisecond(timestamp)
		end
	else
		count = 0
	end

	last_timestamp = timestamp

	local id: SnowflakeId = ((timestamp - EPOCH) * (2 ^ TIMESTAMP_SHIFT)) + (worker_id * (2 ^ WORKER_ID_SHIFT)) + count

	return id
end

function Snowflake:parse(snowflake: SnowflakeId): SnowflakeParsed
	local timestamp: number = math.floor(snowflake / (2 ^ TIMESTAMP_SHIFT)) + EPOCH
	local worker_id: number = math.floor(snowflake / (2 ^ WORKER_ID_SHIFT)) % (2 ^ WORKER_ID_BITS)
	local count: number = snowflake % (2 ^ COUNT_BITS)

	return {
		timestamp = timestamp,
		worker_id = worker_id,
		count = count,
		snowflake = snowflake,
	}
end

-- Function to set the worker ID
function Snowflake:set_worker_id(new_worker_id: number)
	if new_worker_id < 0 or new_worker_id >= (2 ^ WORKER_ID_BITS) then
		error("Worker ID out of bounds")
	end
    
	worker_id = new_worker_id
end

-- Function to get the current worker ID
function Snowflake:get_worker_id(): number
	return worker_id
end

-- Function to set the epoch
function Snowflake:set_epoch(new_epoch: number)
	EPOCH = new_epoch
end

-- Function to get the current epoch
function Snowflake:get_epoch(): number
	return EPOCH
end

-- Function to validate a snowflake ID
function Snowflake:validate(snowflake: SnowflakeId): (boolean, string)
	if type(snowflake) ~= "number" or snowflake < 0 then
		return false, "Invalid snowflake format"
	end

	local timestamp: number = math.floor(snowflake / (2 ^ TIMESTAMP_SHIFT)) + EPOCH
	if timestamp < EPOCH then
		return false, "Timestamp out of range"
	end

	local worker_id: number = math.floor(snowflake / (2 ^ WORKER_ID_SHIFT)) % (2 ^ WORKER_ID_BITS)
	if worker_id < 0 or worker_id >= (2 ^ WORKER_ID_BITS) then
		return false, "Worker ID out of range"
	end

	local count: number = snowflake % (2 ^ COUNT_BITS)
	if count < 0 or count > MAX_COUNT then
		return false, "Count out of range"
	end

	return true, "Valid snowflake"
end

return Snowflake
