# Asset Usage Detector

Asset Usage Detector is an editor plugin for Godot 4.6 that helps you find where scene nodes, scripts, scenes, resources, and file paths are referenced.

## Features

- Find references to selected scene nodes in the current open scene.
- Optionally include selected node children in current-scene searches.
- Find references to project files across scenes, resources, and text-based source files.
- Open the location of a result with a double click.
- Open the referenced target from the Target column with a double click.
- Copy a cell or an entire row from the results list.
- Inspect the full selected result in a dedicated preview area.

## Installation

Copy the `addons/asset_usage_detector` folder into your project, then enable the plugin in:

`Project > Project Settings > Plugins`

## Usage

### Search references for scene nodes

1. Open a scene.
2. In the Scene dock, right click one or more selected nodes.
3. Choose:
   - `Find References in Current Scene`
   - or `Find References in Current Scene (Include Children)`

### Search references for project files

1. In the FileSystem dock, right click a file.
2. Choose `Find References in Project`.

## Notes

- Current-scene searches inspect serialized scene data and signal connections.
- Project-wide searches inspect scenes, resources, and supported text-based files.
- Runtime-only references created entirely by code are not guaranteed to be detected.

## Tested with

- Godot 4.6.1

## License

See `LICENSE`.
