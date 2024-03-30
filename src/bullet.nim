import algorithm
import os
import sequtils
import std/paths
import strutils
import strformat
import sugar

import cligen

const
    filename = ".bullet"
    filepath = string expandTilde(Path("~") / Path(filename))

proc splitItem(item: string): (string, string) =
    let s = item.split(": ", maxsplit=1)
    result = (s[0], s[1])

proc init(verbose=true): void =
    if not os.fileExists(filepath):
        echo "Initializing bullet list app"
        writeFile(filepath, "")
    elif verbose:
        echo "Bullet is already initialized"

proc readItems(): seq[string] =
    init(false)
    for line in filepath.lines:
        result.add(line)

proc writeItems(items: seq[string]): void =
    writeFile(filepath, items.join("\n"))

proc list(topics: seq[string]): void =
    let ltopics = topics.map(tolowerAscii)
    var items = readItems()
    for i, item in items:
        let (topic, text) = splitItem(item)
        if ltopics.len == 0 or topic in ltopics:
            if topic == "":
                echo fmt"[{i}] {text}"
            else:
                echo fmt"[{i}] {topic}: {text}"

proc addb(sort=true, topic="", bullets: seq[string]): void =
    var items = readItems()
    for bullet in bullets:
        items.add(fmt"{topic.tolower}: {bullet}")
    if sort:
        items.sort()
    writeItems(items)

proc rm(idxs: seq[int]): void =
    if idxs.len == 0:
        return

    let items = readItems()
    let newitems = collect:
        for i, d in items.pairs:
            if not idxs.contains(i): d
    writeItems(newitems)

proc sorti(): void =
    var items = readItems()
    items.sort()
    writeItems(items)

proc clear(all=false, notopics=false, topics: seq[string]): void =
    if all:
        writeItems(@[])
        return

    let items = readItems()
    let newitems = collect:
        for item in items:
            let (topic, _) = splitItem(item)
            if ((topic == "" and not notopics) or 
                (topic != "" and not topics.contains(topic))):
                item
    writeItems(newitems)

dispatchMulti([init], [list], [addb, cmdName="add"], [rm], [sorti, cmdName="sort"], [clear])