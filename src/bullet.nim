import os
import strutils
import strformat
import std/paths

import cligen

const
    filename = ".bullet"
    filepath = string expandTilde(Path("~") / Path(filename))

proc init(verbose=true): void =
    if not os.fileExists(filepath):
        echo "Initializing bullet list app"
        writeFile(filepath, "")
    elif verbose:
        echo "Bullet is already initialized"

proc list(): void =
    init(false)

    let f = readFile(filepath)
    if f != "":
        let items = f.splitLines()
        for i, item in items:
            if item != "":
                echo fmt"[{i}] {item}"

proc addi(items: seq[string]): void =
    init(false)

    let f = open(filepath, fmAppend)
    defer: f.close()

    for item in items:
        f.writeLine(item)

proc rm(idxs: seq[int]): void =
    init(false)

    if idxs.len == 0:
        return

    let f = readFile(filepath)
    var items: seq[string]
    if f != "":
        let lines = f.splitLines()
        for i, line in lines:
            if line != "":
                items.add(line)

    let fnew = open(filepath, fmWrite)
    defer: fnew.close()

    for i, item in items:
        if not idxs.contains(i):
            fnew.writeLine(item)

proc clear(): void =
    init(false)

    writeFile(filepath, "")

dispatchMulti([init], [list], [addi, cmdName="add"], [rm], [clear])