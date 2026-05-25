## 📁 Repo Structure

* **`addons/`** * Third-party tools (like the Godot Git Plugin).
* **`assets/`** * **Raw files only.** This is for `.png` sprites, isometric tiles, audio (`.wav`/`.ogg`), `.ttf` fonts, and raw UI layout sketches. 
  * *Godot scenes (`.tscn`) do not belong here.*
* **`core/`** * The brains of the game. Contains our global scripts, Autoloads/Singletons, and the `SceneManager.gd`.
* **`data/`** * Custom Resources (`.tres`). 
* **`entities/`** * Anything that moves, acts, or is interacted with on the isometric grid. This includes the Player, and interactable map objects.
* **`levels/`** * The actual gameplay maps. `main_level.tscn` lives here.
* **`ui/`** * All user interface scenes (`.tscn`) and their attached scripts.

---

## ✍️ Naming Conventions

To keep our codebase readable and to keep Git happy (Git is case-sensitive!), we use the following naming conventions:

* **Folders & Directories:** `snake_case` (all lowercase, underscores for spaces).
  * *Example:* `ui/character_select/`
* **Scenes (`.tscn`):** `PascalCase` (Capitalize every word, no spaces).
  * *Example:* `PlayerCharacter.tscn`, `MainMenu.tscn`
* **Scripts (`.gd`):** `PascalCase` (Matches the scene it is attached to).
  * *Example:* `PlayerCharacter.gd`, `SceneManager.gd`
* **Raw Assets:** `snake_case`.
  * *Example:* `blue_isometric_cube.png`, `main_theme.ogg`

---

## ⚠️ Git & Workflow Rules

1. **Never commit the `.godot/` folder.** Our `.gitignore` should automatically prevent this, but double-check before pushing. This folder contains local import data specific to your computer and will break the project for others.
2. **Pull before you push.** Always fetch and pull the latest version of the `main` branch before you start working, and right before you push your new commits. 
3. **Test before committing.** Never push a broken build to the main branch. Ensure the game runs without crashing before pushing your code.

# more soon, if I'm not admitted to a mental institution by then
