# Maze Generator (Luau)
Freshman-level project. Builds a grid maze in Roblox by placing walls then carving paths with a DFS backtracker. Uses raycasts between adjacent cells to find and remove walls.

## Demo
![Maze demo](media/Maze.gif)

or checkout my [Portfolio](https://walk3rc04.github.io/portfolio.html)

## Performance
On my machine, a 50×50 cell maze generated in ~0.23 seconds.

## Notes
- V1 uses raycasts to detect blocks that needed to be carved out to form the path.
- Attempted another version V2 (not listed) that utilized child lookups with naming convention to see if it was faster than raycasting, but I found it was significally slower.
- Attributes on the script control width, height, cell size, wall size, random clears, etc.