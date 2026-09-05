<img width="2727" height="978" alt="KinemiumFull" src="https://github.com/user-attachments/assets/1792beb7-d877-453d-ab3f-2d86cd434239" />

<p align="center">
  <a href="https://kinemiumengine.discourse.group/">
    <img src="https://img.shields.io/badge/Forum-Discourse-orange?logo=discourse&logoColor=white" alt="Discourse Forum" /></a>
  &nbsp;
  <a href="https://discord.gg/hv6hKfKjk5">
    <img src="https://img.shields.io/discord/1442958989863157927?logo=discord&logoColor=white&label=Discord&color=5865F2" alt="Chat on Discord" /></a>
  &nbsp;
  <a href="https://kinemium-docs.vercel.app/docs">
    <img src="https://img.shields.io/badge/Docs-kinemium-blue?logo=readthedocs&logoColor=white" alt="Documentation" /></a>
  &nbsp;
  <a href="https://kinemium.ftp.sh/">
    <img src="https://img.shields.io/badge/Website-kinemium.ftp.sh-informational?logo=firefox&logoColor=white" alt="Website" /></a>
  &nbsp;
  <a href="https://kinemium.ftp.sh/marketplace/">
    <img src="https://img.shields.io/badge/Marketplace-plugins-success?logo=lua&logoColor=white" alt="Marketplace" /></a>
  &nbsp;
  <a href="https://kinemium.ftp.sh/articles/">
    <img src="https://img.shields.io/badge/Articles-blog-blueviolet?logo=hashnode&logoColor=white" alt="Articles" /></a>
</p>

## Introduction
Kinemium is a sandbox engine written in Luau (Zune Runtime). It includes a custom scripting language called Kilang, with Luau-style syntax and additional features.

# Notice
Kinemium is an independent project not affiliated with, endorsed by, 
or connected to Roblox Corporation. Roblox is a trademark of Roblox Corporation

API features such as Instances and data types are implemented solely for developer familiarity, platform portability, and software interoperability under applicable fair use law including but not limited to the Copyright Act of 1976, 17 U.S.C. § 107.

# Features
## Datatypes
<details>
  <summary>Click to expand/collapse all of Kinemium's Datatypes</summary>

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
</details>

## Default Services
<details>
  <summary>Click to expand/collapse all of Kinemium's Default Services</summary>

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
</details>

## Kinemium Custom Services
<details>
  <summary>Click to expand/collapse all of Kinemium's Custom Services</summary>

  - KinemiumFFIService
  - KinemiumFontService
  - KinemiumIconLoader
  - KinemiumModService
  - KinemiumPhysicsService
  - KinemiumRaylib
  - KinemiumShaderService
</details>

# That's cool.. But how do I use this?
You can check out the guide here:
https://forums.quadigen.com/t/guide-to-running-kinemium-engine/25
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
<img width="1460" height="750" alt="image" src="https://github.com/user-attachments/assets/587c0765-c09d-48da-8dba-9c53c8e8c9dd" />
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
- [Raylib](https://github.com/raysan5/raylib)
- [Manifold](https://github.com/elalish/manifold)
- [GameNetworkingSockets](https://github.com/valvesoftware/gamenetworkingsockets)
- [Box2D](https://github.com/erincatto/box2d)
- [Jolt Physics](https://github.com/amerkoleci/joltc)
- [Native File Dialog](https://github.com/btzy/nativefiledialog-extended)
- [Filament](https://github.com/google/filament)
- and most importantly.. [Zune](https://zune.sh/)

# Do you like cats?
<img width="444" height="200" alt="Silly Cat.... Hello.... Random Person...." src="https://github.com/user-attachments/assets/21672df2-d59e-4a6d-aee1-3b89c9263627" />
