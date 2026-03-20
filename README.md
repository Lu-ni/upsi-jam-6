# Project README

Welcome to the project! This document outlines our core technical stack and the strict architectural guidelines we follow to keep our codebase clean, modular, and scalable.

## 🛠 Tech Stack
* **Engine:** Godot 4.6.1
* **Version Control:** Git 

## 🏗 Core Architecture: Decoupling & Signals
**Decoupling is key.** We build our game using highly independent, modular components that do not strictly rely on each other's specific paths or direct method calls. 

To achieve this, we **massively rely on global signals** (via an Event Bus/Signal Manager Autoload). 
* **Rule of Thumb:** If Component A needs Component B to do something, Component A emits a global signal. Component B listens for that signal and reacts.
* **Benefits:** You can safely delete, move, or modify a node without breaking references in other scripts.

## ⌨️ Input Management
* **Unique Key Bindings:** We actively try *not* to reuse the same key input for different actions. Keep the Input Map clean and ensure every action has a distinct, dedicated trigger to prevent overlapping behaviors and input conflicts.

## 🚫 Strictly Forbidden
* **`switch_scene` (or `change_scene_to_file` / `change_scene_to_packed`):** Do **NOT** use hard scene switching. Because our architecture relies on decoupling and global states, destroying the active scene tree to load a new one disrupts the flow. Instead, handle level transitions dynamically (e.g., instantiating and freeing sub-scenes within a persistent main World/Manager node).