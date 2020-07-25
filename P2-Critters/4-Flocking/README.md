# [Flocking (live demo)](https://bradlyman.github.io/get-creative-with-kha/P2-Critters/4-Flocking/)

<img src="https://bradlyman.github.io/get-creative-with-kha/P2-Critters/4-Flocking/Screenshot.png" width="300" />

A demonstration of flocking with agents.

This demo inadvertently became an excuse to explore different spatial indexing
tools. There are four indexs implemented for experimentation:

- BruteForceIndex
  - This index doesn't bother to actually do any indexing. Instead, when queried
    it just searches every critter in the simulation
- PointQuadtreeIndex
  - This index arranges critters into a 4-way binary tree with one critter at
    each node. The lookup time is faster than the brute force index, but is
    variable depending on where critters are on the screen.
- PRQuadtrieIndex
  - This index arranges and subdivides the world space to keep buckets of
    critters. The lookup time and tree structure are not dependent on the
    insertion order so it provides a more consistent experience than the
    PointQuadtreeIndex.
- BinLatticeIndex
  - This index arranges and subdivides the world space into a fixed-size grid.
    With careful selection of the grid size, this index outperforms all of the
    others with it's simple construction and lookups.

The result surprised me. Why are Quadtrees so prevalant when a fixed grid is so much better? The answer is that a fixed grid only *happens* to be better in this case because everything is trivially of uniform size.

Add variable sized entities or a much more sparse dataset (making the BinLattice phrohibitively memory intensive) and the story changes.

As always, measure, test, and pick the right tool
for the job.

## How To Build

### Web Target

```
> node ../../kha/make html5
```

### Native Windows Target

```
> node ../../kha/make windows --compile --run
```
