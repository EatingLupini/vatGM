# vatGM

> **vatGM** is an implementation of the Vertex Animation Texture technique in GameMaker.

![Main Panel](screenshots/screen_blender1.png)

## Table of Contents
- [vatGM](#crosswords-generator)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Getting Started](#getting-started)
    - [Prerequisites](#prerequisites)
    - [Installation Project](#installation-project)
    - [Installation Blender](#installation-blender)
  - [Usage Project](#usage-project)
  - [Usage Blender](#usage-blender)
  - [Screenshots](#screenshots)
    - [Main Screen](#main-screen)
    - [Possible Solution](#possible-solution)
    - [Definitions](#definitions)
    - [Ouput of a run without GUI](#ouput-of-a-run-without-gui)
  - [Credits](#credits)

## Features
* Vertex Animation Texture shader.
* Blender addon to produce offsets and normal texture.
* Animation Manager to change and blend animations.
* Dynamic Batch for VAT.

## Getting Started

### Prerequisites
Ensure you have the following installed:
- [GameMaker](https://gamemaker.io/en) (2024.8+)
- [Blender](https://www.blender.org/) (3.5.1)

### Installation Project
1. Clone the repository or download as a zip file:
```bash
git clone https://github.com/EatingLupini/vatgm.git
```

2. Open the project and launch using GMS2 VM or GMS2 YYC runtime.

### Installation Blender
1. Download the [Blender addon](blender_addon/vertex_animation_gm.py).

2. Open Blender and click on Edit -> Preferences.

3. Click on the Add-ons tab

4. Click install and select the addon file "vertex_animation_gm.py"

5. Look for VAT Tools and enable it.

Now you should have an additional panel on the right as shown in the image below:

![Main Panel](screenshots/screen_blender1.png)


## Usage Project
Open the Project and launch.

## Usage Blender
1. Load a model in Blender, select it and click on "Process".
2. Choose a folder to save the images and click "Process".
3. At the end of the process, the following files are produced:
    * **model.obj** (model in a default position)
    * **model.mtl**
    * **anim_offset.png** (offsets texture, each column represents a vertex and each row represents a frame of the animation)
    * **anim_normal.png** (normals texture)
    * **info.json** (contains information about the animations, start and end frame, offsets, etc.)
4. All these files must be imported in the project as Included Files and loaded at runtime.

### Example content of a info.json file
You can manually add the attribute "tex_diffuse" which is the texture of the model.
```
{
    "animations": [
        {
            "name": "walk_forward",
            "loop": true,
            "speed": 0.5,
            "frame_start": 0,
            "frame_end": 31,
            "offset_min": -0.8262448906898499,
            "offset_max": 0.721109926700592,
            "dist": 1.547354817390442
        },
        {
            "name": "idle",
            "loop": true,
            "speed": 0.5,
            "frame_start": 381,
            "frame_end": 627,
            "offset_min": -0.7118440270423889,
            "offset_max": 0.6815999150276184,
            "dist": 1.3934439420700073
        }
    ],
    "model_name": "model.obj",
    "tex_diffuse": "tex_diffuse.png",
    "num_vertices": 7825,
    "num_frames": 628.0,
    "tex_size": 8192,
    "model_name": "model.obj",
    "offsets_tex_name": "anim_offset.png",
    "normals_tex_name": "anim_normal.png"
}
```

## Screenshots

<details>
<summary>Click to view screenshots</summary>

### 14 batches of 64 knights
![Screenshot 1](screenshots/screen_demo1.png)

### Close up
![Screenshot 2](screenshots/screen_demo2.png)

### Real Time Strategy Cam
![Screenshot 5](screenshots/screen_demo3.png)


</details>


## Credits
* [GMD3D11](https://github.com/blueburncz/GMD3D11) by **kraifpatrik**.
* [Mixamo](https://www.mixamo.com) for the free models used in this project.
* Model Importer and other useful script such as DynamicModelBatch by **SerpensSolida**.
