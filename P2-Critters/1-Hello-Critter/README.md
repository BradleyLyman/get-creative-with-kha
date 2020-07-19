# [Hello Critter (live demo)](https://bradlyman.github.io/get-creative-with-kha/P2-Critters/1-Hello-Critter/)

<img src="https://bradlyman.github.io/get-creative-with-kha/P2-Critters/1-Hello-Critter/Screenshot.png" width="300" />

The 'hello world' of agents using the g2 graphics api layer to render agents as
a tiny triangle.

Agents move in a straght line until the encourter a boundary where they will
turn around to avoid bumping into the edge.

## How To Build

### Web Target

```
> node ../../kha/make html5
```

### Native Windows Target

```
> node ../../kha/make windows --compile --run
```
