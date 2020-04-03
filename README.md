# ConGuard
Network/connection helper for MTA:SA

This resource provides measures to deal with lagswitch / connection abuse in MTA (commonly seen in Destruction Derby servers, although you can use this resource in any environment/mode you wish).

When a player loses connection to the server, the player (and their vehicle, if it exists) will be frozen for all remote players and a "lost connection" icon will be placed above the player. Upon re-connection, the player will be unfrozen and (by default) set back to their original position before they lost connection, to avoid the teleporting exploit.

ConGuard has a few configurable options (in `settings.json`) and is also based on dimensions, which is useful for multi-gamemode servers who don't want to activate this in every room.

**Note**: all the functions and events listed below are serverside unless otherwise stated.

&nbsp;

### Getting Started

Download the repo and extract it to your server resources folder and start it, like you would with any other resource

For this example we'll assume your resource folder is called `conguard`. To create a ConGuard instance, use the following:

```lua
exports.conguard:createConnectionGuard(int dimension, [table settings])
```

You can turn a ConGuard instance on or off:

```lua
exports.conguard:setConnectionGuardEnabled(int dimension, bool state)
```

You can also destroy a ConGuard instance entirely by doing:

```lua
exports.conguard:destroyConnectionGuard(int dimension)
```

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
**source**: the player who reached the connection timeout

&nbsp;

### Settings

The default settings for ConGuard (contained in `settings.json`) look like this:

```json
{
	"max_connection_timeout": 2000,
	"max_interruptions_per_session": 3,
	"disable_collisions": false,
	"restore_position": true
}
```

**Important**: Using `disable_collisions` could potentially create a separate exploit, where players using the lagswitch would use this to be collisionless right before being hit. You probably don't want to use this in a DD setting

You can either edit `settings.json` to apply global settings for each instance that is created, or alternatively pass a table to `createConnectionGuard` with the settings you would like to change (per-dimension settings).

If you want to change the settings for a ConGuard instance that's already created, you can use:

```lua
exports.conguard:setConnectionGuardSetting(int dimension, string setting, mixed value)
```

or to get a settings current value:

```lua
exports.conguard:getConnectionGuardSetting(int dimension, string setting)
```

&nbsp;

Oh... and you can also change the "lost connection" image that floats above the player. This function is clientside only:

```lua
setCustomConnectionImage(string imagePath)
```

Make sure you use a proper external resource path (i.e: `:myResource/images/connection.png`)
