# [Flocking (live demo)](https://bradlyman.github.io/get-creative-with-kha/P2-Critters/4-Flocking/)

<img src="https://bradlyman.github.io/get-creative-with-kha/P2-Critters/4-Flocking/Screenshot.png" width="300" />

A demonstration of flocking with agents. 

Leverages a BinLattice index for nearest-neighbor lookups in less than quadratic time. Could be improved with a
Quadtrie, a Quadtree, or perhaps something like an R-Tree which is more optimized for the nearest neighbor
lookup.

## How To Build

### Web Target

```
> node ../../kha/make html5
```

### Native Windows Target

```
> node ../../kha/make windows --compile --run
```
