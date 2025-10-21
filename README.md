🛰️ Space Mission Logs Contract
Overview

The Space Mission Logs Contract is a Clarity smart contract designed to record, manage, and verify space mission data on-chain — including satellite and space probe missions.
It enables trusted operators to create missions, add telemetry logs, update mission statuses, and manage authorized operators for collaborative mission operations.

🧩 Key Features
1. Mission Management

Create new missions with details such as:

Mission name

Spacecraft ID

Mission type

Launch date

Status (e.g., active, completed, failed)

Automatically tracks the mission creator as the initial operator.

2. Mission Logs

Record telemetry data for each mission, including:

Latitude, Longitude, Altitude

Speed, Temperature

Timestamp (captured using block-height)

Each log entry is uniquely identified and tied to its mission.

3. Operator Management

Add or remove mission operators who are authorized to:

Log telemetry data

Update mission status

Only the original mission operator (creator) can add or remove other operators.

4. Access Control

Prevents unauthorized users from modifying mission or log data.

Returns specific error codes for unauthorized or invalid operations:

err-owner-only → Only contract owner access

err-not-found → Mission or log not found

err-unauthorized → Unauthorized access attempt

🧠 Data Structures
Variables
Variable	Type	Description
mission-counter	uint	Tracks total number of missions created
Maps
Map	Key	Value	Purpose
missions	uint	Mission details	Stores metadata for each mission
mission-logs	{mission-id: uint, log-id: uint}	Log details	Stores telemetry and environment data
mission-log-counter	uint	uint	Counts total logs per mission
mission-operators	{mission-id: uint, operator: principal}	bool	Tracks authorized mission operators
⚙️ Public Functions
create-mission

Creates a new mission and registers the caller as the first operator.

(create-mission mission-name spacecraft-id mission-type launch-date status)


Returns:
(ok <mission-id>)

add-mission-log

Adds telemetry data to a specific mission.

(add-mission-log mission-id telemetry-data latitude longitude altitude speed temperature)


Authorization:
Must be a registered mission operator.

Returns:
(ok <log-id>)

update-mission-status

Updates the status of a given mission (e.g., from Active to Completed).

(update-mission-status mission-id new-status)


Authorization:
Must be a registered mission operator.

Returns:
(ok true)

add-mission-operator

Adds a new authorized operator for the mission.

(add-mission-operator mission-id new-operator)


Authorization:
Only the original mission creator can add operators.

Returns:
(ok true)

remove-mission-operator

Removes an operator from a mission’s authorized list.

(remove-mission-operator mission-id operator-to-remove)


Authorization:
Only the original mission creator can remove operators (except themselves).

Returns:
(ok true)

📖 Read-Only Functions
Function	Description
get-mission (mission-id)	Retrieves mission details
get-mission-log (mission-id log-id)	Retrieves a specific mission log
get-mission-log-count (mission-id)	Returns total number of logs for a mission
get-total-missions	Returns total missions created
is-mission-operator (mission-id operator)	Checks if a principal is an authorized operator
🚨 Error Codes
Code	Constant	Meaning
u100	err-owner-only	Action restricted to contract owner
u101	err-not-found	Mission or log does not exist
u102	err-unauthorized	Caller not authorized to perform action
🧪 Example Flow

Create a Mission

(create-mission "Voyager 1" "V1-001" "Probe" u19770905 "Active")


Add Mission Log

(add-mission-log u1 "Telemetry OK" i10 i20 u30000 u5000 i-15)


Update Mission Status

(update-mission-status u1 "Completed")


Add Operator

(add-mission-operator u1 'SP12345...)


View Logs

(get-mission-log u1 u1)

🧾 License

This contract is open-sourced under the MIT License.