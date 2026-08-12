<img width="2727" height="978" alt="KinemiumFull" src="https://github.com/user-attachments/assets/1792beb7-d877-453d-ab3f-2d86cd434239" />

[<img width="50" height="50" alt="image" src="https://github.com/user-attachments/assets/83c3a863-d290-487f-b073-fed9caa6832f" />
](https://discord.gg/7byuxfYtAP)

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/Qquaded/Kinemium-Engine)
## Introduction
Kinemium is a sandbox engine written in Luau (Zune Runtime). It includes a custom scripting language called Kilang, with Luau-style syntax and additional features.

# Notice
Kinemium is an independent project not affiliated with, endorsed by, 
or connected to Roblox Corporation. Roblox is a trademark of Roblox Corporation

# Another notice
This is the renderer-agnostic branch, it contains unstable code that can change anytime, it is
advised to run the main branch instead.

# Features
## Datatypes
- Axes
- BoundingBox
- BrickColor
- CFrame
- Color3
- Color4
- ColorSequence
- ColorSequenceKeypoint
- CustomPhysicalProperties
- NumberSequence
- NumberSequenceKeypoint
- Random
- Ray
- Region
- Spring
- UDim
- UDim2
- Vector2
- Vector3
- Enum
- Faces / NormalId
- Rect / Region3
- And a whole lot more..

## Default Services
- Debris
- GuiSelectionService
- HttpService
- Lighting
- LogService
- Players
- ReplicatedStorage
- RunService
- Selection
- ServerScriptService
- ServerStorage
- StarterGui
- TweenService
- UserInputService
- Workspace

## Kinemium Custom Services
*(All custom services start with Kinemium.)*
- KinemiumFFIService
- KinemiumFontService
- KinemiumIconLoader
- KinemiumModService
- KinemiumPhysicsService
- KinemiumRaylib
- KinemiumShaderService

# That's cool.. But how do I use this?
Fortunately theres a tutorial:

- Clone the repo:
```git clone --depth 1 https://github.com/Qquaded/Kinemium-Engine.git```

- Get zune *(skip this step if you have it already installed.)*<br>
https://zune.sh/guides/install

- Run the engine<br>
```zune run engine```<br>
*This tutorial works with both Linux and Windows, MacOS support is coming soon.*

# Commands
Kinemium provides with several flags you can run with ```zune run game```<br>
- headless (lets you run the engine without graphics)<br>
- server (lets you run a server version of the engine, this is used for games and such)<br>
- client (lets you run a client, it removes all the core UI only)<br>
- kilang (lets you run kilang code in the terminal, you can add this flag with any other flag and it will still work)<br>
- editor (enables studio UI)

# Multiplayer
Kinemium provides multiplayer support with the ```server``` and ```client``` flags:

Making a server with an address and port:<br>
```zune run game --server --address 0.0.0.0 --port 1234 --auth_token your_token```<br>

Connecting a client:<br>
```zune run game --client --address server_ip --port 1234 --auth_token your_token```<br>

You can also just do --server and --client without any arguments and it will run on localhost.

Running live on localhost:<br>
```zune run game --server```<br>
Connect a client:<br>
```zune run game --client```<br>

# Editor
Kinemium has a built-in editor GUI that lets you playtest, script, build, and edit objects.

Enabling Editor mode:<br>
```zune run game --editor```<br>
Running server with editor mode<br>
```zune run game --server --editor```<br>

# Examples
example command with a flag:<br>
```zune run game --client```<br>
```zune run game --client --kilang```<br>
```zune run game --server --kilang```<br>
```zune run game --headless```<br>

# Preview
<img width="991" height="800" alt="image" src="https://github.com/user-attachments/assets/7e29dc74-0518-465a-a502-ea6ae0972bc3" />
<img width="1391" height="944" alt="image" src="https://github.com/user-attachments/assets/419b7324-5586-467b-a8f5-774217e87ed7" />

# How do I add scripts?
Once you clone the github repo, you will find a folder called ```sandboxed``` inside the engine *(src)*<br>
There are a set of predefined scripts in there as examples, but you can change any of them.

# Can I make my games have modding support?
Yes! there is a modding service called KinemiumModService (said up there)<br>
This lets you add mods to your game, and you can set the environment of your said mods!

# How do I spell Kinemium?
Ki-nem-yum!!

# This project uses
- SDL3
- Google Filament
- Google Skia
- Manifold
- Box2D
- Jolt Physics
- Luau
- and most importantly.. Zune Runtime
kv1.10.7

# Do you like cats?
<img width="444" height="200" alt="Silly Cat.... Hello.... Random Person...." src="https://github.com/user-attachments/assets/21672df2-d59e-4a6d-aee1-3b89c9263627" />
