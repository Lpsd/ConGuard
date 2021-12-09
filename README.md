# ConGuard
Network/connection helper for MTA:SA

This resource provides measures to deal with lagswitch / connection abuse in MTA (commonly seen in Destruction Derby servers, although you can use this resource in any environment/mode you wish).

When a player loses connection to the server, the player (and their vehicle, if it exists) will be frozen for all remote players and a "lost connection" icon will be placed above the player. Upon re-connection, the player will be unfrozen and (by default) set back to their original position before they lost connection, to avoid the teleporting exploit.

ConGuard has a few configurable options (in `settings.json`) and is also based on dimensions, which is useful for multi-gamemode servers who don't want to activate this in every room.

**Note**: all the functions and events listed below are serverside unless otherwise stated.

&nbsp;

## Getting Started

Download the repo and extract it to your server resources folder and start it, like you would with any other resource.

&nbsp;

For this example we'll assume your resource folder is called `conguard`. To create a ConGuard instance, use the following:

```lua
exports.conguard:createConnectionGuard(int dimension [, table settings])
```

&nbsp;

You can turn a ConGuard instance on or off, temporarily:

```lua
exports.conguard:setConnectionGuardEnabled(int dimension, bool state)
```

&nbsp;

You can also destroy a ConGuard instance entirely by doing:

```lua
exports.conguard:destroyConnectionGuard(int dimension)
```

**Note**: If you want to create a global instance (running in all dimensions) then pass `-1` as the dimension. 
If an instance already exists in a specific dimension, it will take precedence over the global instance.

&nbsp;

### Events

The following event will be fired when `max_connection_timeout` is reached:
```
onPlayerNetworkTimeout
```
**source**: the player who reached the connection timeout

&nbsp;

The following event will be fired when `max_interruptions_per_session` is reached:
```
onPlayerNetworkInterruptionLimitReached
```
**source**: the player who reached the maximum amount of network interruptions allowed per session

&nbsp;

### Settings

The default settings for ConGuard (contained in `settings.json`) look like this:

```json
{
	"max_connection_timeout": 5000,
	"max_interruptions_per_session": 5,
	"disable_collisions": false,
	"restore_position": true,
	"kick_on_max_interruptions": false,
	"kick_message": "Please fix your connection, or disable your lagswitch!",
	"lost_connection_image": {
		"path": "assets/images/nosignal.png",
		"size": 0.5,
		"height": 1,
		"max_distance": 20
	}
}
```

**Important**: Using `disable_collisions` could potentially create a separate exploit, where players using the lagswitch would use this to be collisionless right before being hit. You probably don't want to use this in a DD setting

&nbsp;

The settings defined in `settings.json` will be used as the default settings for each ConGuard instance. You can also optionally pass a table of specific settings to overwrite when creating an instance (via `createConnectionGuard`).

If you want to change the settings for a ConGuard instance:

```lua
exports.conguard:setConnectionGuardSetting(int dimension, string setting, mixed value)
```

or to get a settings current value:

```lua
exports.conguard:getConnectionGuardSetting(int dimension, string setting)
```

Settings are synced with all clients (ConGuard instances exist on the client to sync basic data like settings).

&nbsp;

For example, if you want to set the "lost connection" image for a specific instance, after it has been created:

```lua
local imageSettings = exports.conguard:getConnectionGuardSetting(1, "lost_connection_image")
imageSettings.path = ":myResource/images/connection.png"

exports.conguard:setConnectionGuardSetting(1, "lost_connection_image", imageSettings)
```

Make sure to use a proper external resource path (i.e: `:myResource/images/connection.png`)
