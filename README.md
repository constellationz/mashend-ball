# namatchi/gamebuilder
A template for building Rojo projects. Designed for partial Rojo management.

### Custom Loader

```lua
local Get = require(game:GetService("ReplicatedStorage"):WaitForChild("Get"))

local MyModule = Get "MyModule" -- Load the module "MyModule"
local MyEvent = Get.Remote "MyEvent" -- Get the remote "MyEvent"
local MyAsset = Get.Asset "Props/MyAsset" -- Load an asset from the "Props" folder
```

### Straightforward Rojo structure

By default, the file tree is organized as follows:

```
src
|_src/first (ReplicatedFirst)
|_src/common (ReplicatedStorage)
| |_Assets (ReplicatedStorage.Assets)
| |_Remotes (ReplicatedStorage.Remotes)
| |_Modules (ReplicatedStorage.Modules)
| |_Get.lua
|_src/server (ServerScriptService)
| |_ServerModules (ServerScriptService.ServerModules)
| |_ServerScript.server.lua
|_src/client (StarterPlayer.StarterPlayerScripts)
| |_ClientScript.client.lua
|_src/character (StarterPlayer.StarterCharacterScripts)
```

### Customizability

Gamebuilder is designed to allow integration with other libraries. The Get loader can be changed to fit your games requirements.

## Get started

1. Clone this repository to a game project folder.

    ```bash
    git clone https://github.com/namatchi/gamebuilder <project name>
    ```

2. Remove this project's GitHub link.

    ```bash
    git remote rm origin
    ```

3. Make sure [Rojo](https://github.com/rojo-rbx/rojo) is set up and added to your PATH.

4. Set up your project in dependencies in `default.project.json`

5. Build a place to open while editing.

    ```bash
    rojo build -o place.rbxlx
    ```

6. Serve your project.

    ```bash
    rojo serve
    ```

7. Activate Rojo in studio and begin working!

## Configure to your needs

### Add source from external library to the Rojo tree:

To include a Rojo tree from another GitHub repository or folder, add that directory to `default.project.json` with `$path` pointing to the correct destination. In this example, Roact is included from a folder outside of the project directory.

`default.project.json:`

```json
"ReplicatedStorage": {
  "$className": "ReplicatedStorage",
  "$path": "src/common",
  "Libraries": {
    "$className": "Folder",
    ...
    "Roact": {
      "$path": "../roact/src"
    }
    ...
  }
}
```

*Note: default.project.json has spaces left for adding external libraries*

`src/client/ClientScript.client.lua`

```lua
-- client/ClientScript.client.lua
local Get = require(game:GetService("ReplicatedStorage"):WaitForChild("Get"))
local Roact = Get "Roact" -- Roact is loaded as if require(Roact) was called.

-- Modules can be used as normally.
local element = Roact.createElement(...)
```

### Customizing the Get loader

If you decide you want to add your own loader, that can be done by changing `Get.lua`.

`Get.lua`

```lua
ListenFor("Remote", Remotes, AssertExistence) -- Get.Remote

-- Use the built-in Get listener. Searches children in DogFolder.
ListenFor("Dog", DogFolder, function (result, name)
    assert(result ~= nil, "got no result for "..name)
    return result
end
    
-- Make a custom get function.
function Get.MyWay(name)
    return Folder:FindFirstChild(name)
end
```

`ClientScript.client.lua`

```lua
local Get = require(game:GetService("ReplicatedStorage"):WaitForChild("Get"))
local MyGet = Get.Dog "Perry"
local MyGet2 = Get.MyWay "Something"
```

## Attribution

namatchi/gamebuilder is licensed under the MIT license.