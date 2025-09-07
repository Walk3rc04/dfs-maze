# Maze Generator (Luau)
Freshman-level project. Builds a grid maze in Roblox by placing walls then carving paths with a DFS backtracker. Uses raycasts between adjacent cells to find and remove walls.

## Demo
See `media/demo.mp4`.

## Performance
On my machine, a 50×50 cell maze generated in ~0.23 seconds.

## Notes
- V1 uses raycasts (faster).
- Attributes on the script control width, height, cell size, wall size, random clears, etc.