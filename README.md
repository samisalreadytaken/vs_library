# VScript Library (HLVR)

This also fixes the a1_intro_world transition issue.

## Installation

1. Download [vs_library.lua](https://raw.githubusercontent.com/samisalreadytaken/vs_library/hlvr/src/vs_library.lua).

2. Place `vs_library.lua` in your addon vscripts directory `/steamapps/common/Half-Life Alyx/game/hlvr_addons/<addonid>/scripts/vscripts/`

3. Rename the file name to something unique. I suggest adding the version number to the end of the file. For example version 0.1.0 file name becomes `vs_library-010.lua`.

This renaming will ensure different versions of the library can exist in the server at the same time. File name does not matter as long as it is unique, as the version control is done inside the library, and not dependant on lua packages.

## Usage

```lua
local VS = require "vs_library-010"
```

## Includes

### Constants

```
MAX_COORD_FLOAT
MAX_TRACE_LENGTH
DEG2RAD
RAD2DEG
PI
RAND_MAX
```

### Functions

```cpp
bool VS.OnPlayerSpawn(closure callback [, string|closure|nil error [, params ...]])
```

Execute `callback` on player spawn. Optionally print string `error` or execute function `error` on failure. Optionally pass arbitrary amount of parameters to `callback`.

`callback` can return `nil` or `true` to indicate successful execution, or `false` for failure, in which case the function will keep being executed every second for the next 10 seconds after player spawn. After this time ends and callback has not returned success, `error` will be printed.

Only one event can be added from each file to avoid duplications.

*Example:*

```lua
local function Init(p1)

	if InitialiseScript(p1) then
		return true
	end

	return false

end
```

```lua
VS.OnPlayerSpawn(Init)
```

```lua
VS.OnPlayerSpawn(Init, nil, 1)
```

```lua
VS.OnPlayerSpawn(Init, "failed to initialise script", 1)
```
________________________________

```cpp
bool VS.IsAddonEnabled(string addonid)
```
```lua
table.unpack(list [, i [, j]])
```
```lua
table.pack(...)
```

### Modified for better performance

`Deg2Rad`

`Rad2Deg`

`VectorDistanceSq`

`VectorDistance`

`VectorLerp`


## License
You are free to use, modify and share this library under the terms of the MIT License. The only condition is keeping the copyright notice, and state whether or not the code was modified. See [LICENSE](LICENSE) for details.

[![](http://hits.dwyl.com/samisalreadytaken/vs_library.svg)](https://hits.dwyl.com/samisalreadytaken/vs_library)
