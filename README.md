# namatchi/gamebuilder
An easy template for building Roblox games.

### Custom Loader

```lua
local Get = require(game:GetService("ReplicatedStorage"):WaitForChild("Get"))

local MyModule = Get "MyModule" -- Load the module "MyModule"
local MyEvent = Get.Remote "MyEvent" -- Get the remote "MyEvent"
local MyAsset = Get.Asset "Props/MyAsset" -- Load an asset from the "Props" folder
```

### Straightforward Rojo tree

By default, `namatchi/gamebuilder` organizes the file tree as follows:

- ReplicatedFirst -> `src/first`
- ReplicatedStorage -> `src/common`
    - Assets -> `src/common/assets`
    - Remotes -> `src/common/remotes`
    - Modules -> `src/common/modules`
- ServerScriptService -> `src/server`
- StarterPlayerScripts -> `src/client`
- StarterCharacterScripts ->`src/character`

### Customizability



## Get started

1. Clone this respository to a game project folder.

    ```bash
    git clone https://github.com/namatchi/gamebuilder <project name>
    ```

2. Remove this project's github link.

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

## Configure namatchi/gamebuilder to your needs



## Attribution

namatchi/gamebuilder is licensed under the MIT license.