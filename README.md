# Bark Dialogue Editor

<p align="center">
  <img width="300px" src="./assets/images/bark.png" alt="Bark logo" />
</p>

[Bark](https://bark.nclarke.dev) is a relational JSON editor geared towards game dialogue editing, built using [Haxe](https://haxe.org/) and [HaxeUI](https://haxeui.org/).

## Why?

I've used a handful of dialogue editors in the past and found that they tend to be either too rigid in their structured output or they are flexible but lack a great UI/UX experience. I wanted to create a tool independent of any specific game engine where I could quickly define and save my own nodes to suit whatever project I'm working on.

This project uses [Lime](https://lime.openfl.org/) as its [backend](https://haxeui.org/getting-started/backends/) but can be very easily adapted to others.

---

## Compatibility

This project is built and verified using the following version matrix. Ensure your environment matches or exceeds these requirements:

| Dependency        | Version | Description                  |
| :---------------- | :------ | :--------------------------- |
| **Haxe**          | `4.3.6` | Language runtime             |
| **HaxeUI Core**   | `1.7.0` | UI Framework Core            |
| **HaxeUI OpenFL** | `1.7.0` | OpenFL Backend Component     |
| **OpenFL**        | `9.5.0` | Rendering framework          |
| **Lime**          | `8.3.0` | Native backend layer         |
| **HashLink**      | `git`   | Target VM for Desktop builds |

> ⚠️ **Note on Web (HTML5) Scaling:** > Due to the way browsers handle high-DPI viewport scaling on hybrid touch devices (such as the Microsoft Surface Pro), the web version may appear artificially zoomed in. For the best, most pixel-accurate experience on these devices, we highly recommend running the native **HashLink Desktop Build** (`lime test hl`).

---

## Scripts, Build & Run

### Prerequisites

Ensure you have your Haxe libraries properly installed and set up via haxelib:

```bash
haxelib install openfl
haxelib install actuate
haxelib install haxeui-core
haxelib install haxeui-openfl
```

## Development

### Desktop
To run the application locally using the HashLink VM for development:

```bash
lime test hl
```

To compile a release build without launching it immediately (outputs to build/openfl/hl):

```bash
lime build hl -dce full
```

### Web (HTML5)
To spin up a local development server and test the application inside your browser:

```bash
lime test html5
```

To compile a release build without launching it immediately (outputs to build/openfl/hl):

```bash
lime build html5 -dce full
```

# Project Structure

```

.
├── assets
│ ├── components
│ ├── icons
│ ├── images
│ ├── main-view.xml
│ ├── nodes
│ │ └── builtin.json
│ ├── styles
│ │ └── style.css
│ └── views
├── templates
├── build
│ └── openfl
│ ├── hl
│ ├── html5
├── module.xml
├── Project.xml
├── README.md
├── src
│ ├── core
│ │ ├── commands
│ │ ├── EditorSession.hx
│ │ ├── Graph.hx
│ │ ├── GraphSerializer.hx
│ │ ├── History.hx
│ │ └── Workspace.hx
│ ├── data
│ │ ├── ConnectionData.hx
│ │ ├── GraphData.hx
│ │ ├── NodeData.hx
│ │ ├── PortData.hx
│ │ ├── SceneData.hx
│ │ └── WorkspaceData.hx
│ ├── Main.hx
│ ├── MainView.hx
│ ├── ui
│ │ ├── canvas
│ │ ├── components
│ │ ├── connectionEditor
│ │ ├── connections
│ │ ├── dialogs
│ │ ├── EditorBinder.hx
│ │ ├── menus
│ │ ├── nodeeditor
│ │ ├── nodes
│ │ ├── notifications
│ │ ├── palette
│ │ │ ├── NodePalette.hx
│ │ │ ├── Palette.hx
│ │ │ ├── ScenePalette.hx
│ │ │ └── schema
│ │ │ ├── menus
│ │ │ ├── SchemaEditor.hx
│ │ │ ├── SchemaEditorBinder.hx
│ │ │ └── SchemaEditorPalette.hx
│ │ └── toolbar
│ │ ├── SceneMenu.hx
│ │ ├── Toolbar.hx
│ │ └── WorkspaceMenu.hx
│ └── util
│ ├── ArrayUtils.hx
│ ├── ConnectionHelpers.hx
│ ├── DragUtil.hx
│ ├── KeyCodes.hx
│ ├── StressTest.hx
│ └── WorkspaceUtils.hx

```

```
