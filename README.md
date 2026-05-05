# Bark Dialogue Editor

<p align="center">
  <img width="300px" src="./assets/images/bark.png" alt="Bark logo" />
</p>

Relational JSON editor geared towards game dialogue editing built using [Haxe](https://haxe.org/) and [HaxeUI](https://haxeui.org/) 

# Why?

I've used a handful of dialogue editors in the past and I've found that they tend to be either too rigid in their structured output or they are flexible but don't have great UI/UX. I wanted to create a tool independent of any specific game engine where I could quickly define and save my own nodes to suit whatever project I'm working on.

This project uses [Lime](https://lime.openfl.org/) as its [backend](https://haxeui.org/getting-started/backends/) but can very easily be adapted to others.

# Scripts, Build & Run
### Development
```
lime test hl
```
To run the application using hashlink

```
lime build hl
```

To only build to build/openfl/hl

# Project Structure

```
.
├── assets
│   ├── components
│   ├── icons
│   ├── images
│   ├── main-view.xml
│   ├── nodes
│   │   └── builtin.json
│   ├── styles
│   │   └── style.css
│   └── views
├── build
│   └── openfl
│       ├── hl
├── module.xml
├── Project.xml
├── README.md
├── src
│   ├── core
│   │   ├── commands
│   │   ├── EditorSession.hx
│   │   ├── Graph.hx
│   │   ├── GraphSerializer.hx
│   │   ├── History.hx
│   │   └── Workspace.hx
│   ├── data
│   │   ├── ConnectionData.hx
│   │   ├── GraphData.hx
│   │   ├── NodeData.hx
│   │   ├── PortData.hx
│   │   ├── SceneData.hx
│   │   └── WorkspaceData.hx
│   ├── Main.hx
│   ├── MainView.hx
│   ├── ui
│   │   ├── canvas
│   │   ├── components
│   │   ├── connectionEditor
│   │   ├── connections
│   │   ├── dialogs
│   │   ├── EditorBinder.hx
│   │   ├── menus
│   │   ├── nodeeditor
│   │   ├── nodes
│   │   ├── notifications
│   │   ├── palette
│   │   │   ├── NodePalette.hx
│   │   │   ├── Palette.hx
│   │   │   ├── ScenePalette.hx
│   │   │   └── schema
│   │   │       ├── menus
│   │   │       ├── SchemaEditor.hx
│   │   │       ├── SchemaEditorBinder.hx
│   │   │       └── SchemaEditorPalette.hx
│   │   └── toolbar
│   │       ├── SceneMenu.hx
│   │       ├── Toolbar.hx
│   │       └── WorkspaceMenu.hx
│   └── util
│       ├── ArrayUtils.hx
│       ├── ConnectionHelpers.hx
│       ├── DragUtil.hx
│       ├── KeyCodes.hx
│       ├── StressTest.hx
│       └── WorkspaceUtils.hx

```
