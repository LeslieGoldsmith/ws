# ws

Workspace utilities for developers

Contains routines for summarizing and searching the contents of
a workspace.

# Usage

## Summarization Routines

Summarization routines list the names of objects of particular
classes (functions, variables, or tables), or provide a type-
dependent synopsis of their properties.  Names can be specified
either explicitly or by referencing a parent namespace (in
which case all objects in all namespaces below it are
considered).  Object size is approximated and does not include
attribute overhead.

The summarization routines are listed below.

| Name and Syntax | Description |
| -------- | ----------- |
| `.ws.fns[names]` | Displays the names of functions contained in the specified namespaces, or in all namespaces if the argument is \` |
| `.ws.vars[names]` | Displays the names of variables (excluding tables) contained in the specified namespaces, or in all namespaces if the argument is \` |
| `.ws.tbls[names]` | Displays the names of tables contained in the specified namespaces, or in all namespaces if the argument is \` |
| `.ws.fnsum[names]` | Summarizes functions in the argument, expanding namespaces as appropriate. If the argument is \`, all functions in all namespaces are included.  The function summary includes the function name, its parameter list, line count, and size |
| `.ws.varsum[names]` | Summarizes variables (excluding tables) in the argument, expanding namespaces as appropriate. If the argument is \`, all variables in all namespaces are included.  The variable summary includes the variable name, its type, rank, size, and shape.  Type is represented by the Q type character, with uppercase indicating a nonscalar value (e.g. a vector or higher-dimensional array); `l` and `L` indicate an enumerated value, `Y` a dictionary, and `-` a heterogeneous object.  Rank is the number of leading uniform axes (where a scalar is 0) |
| `.ws.tblsum[names]` | Summarizes tables in the argument, expanding namespaces as appropriate. If the argument is \`, all tables in all namespaces are included.  The table summary includes the table name, its type, keys, row count, column count, and size. Type is `M` for an in-memory table, `S` for a splayed table, or `P` for a partitioned table  |

`fnsum`, `varsum`, and `tblsum` return keyed tables as results so that one can, for example, compare two samples.

### Examples

```
q).ws.fns`.
assert  assertz buildIrMap      cciao   chkp    chkres  chktbl  ciao
corroborate     cs0     cutByID defer   defp    dpy     eflag   enc
expand  expp    falseAt fmt     getNewRz        getRa   getRd   getRz
getvg   minToSpan       mkvg    pen     ps      pub     recutByID
..
```

```
q).ws.fnsum`.
Function   | Params                Lines Size
-----------| --------------------------------
assert     | [x;y]                 1     202
assertz    | [x;y]                 1     264
buildIrMap | [dc;lts]              14    2433
cciao      | [chanID;ts;c]         1     295
chkp       | [s;p;q]               3     854
chkres     | [r;s]                 5     1021
chktbl     | [r]                   5     1470
ciao       | [t;c]                 1     525
corroborate| [fn;dc;ii]            43    5802
cs0        | [x]                   1     194
cutByID    | [chType]              4     831
defer      | [t;f;req;x]           5     926
defp       | [s;d]                 3     514
..
```

```
q).ws.varsum`.mdb`g`w`.misc.ZR
Variable               | Type Rank Size Shape
-----------------------| --------------------
.mdb.cfg.del           | c    0    10   1
.mdb.cfg.destroyMountNS| b    0    10   1
.mdb.cfg.eodTS         | p    0    17   1
.mdb.cfg.mountNS       | s    0    11   1
.mdb.cfg.ns            | s    0    14   1
.mdb.cfg.ops           | Y    1    76   ,4
.mdb.cfg.tableOrder    | S    1    14   ,0
.mdb.cts               | p    0    17   1
.mdb.hdbPurview        | j    0    17   1
.mdb.nsday             | j    0    17   1
.mdb.purviews          | P    1    30   ,2
.mdb.rdbPurview        | j    0    17   1
.mdb.updLUT            | Y    1    404  ,11
.misc.ZR               | C    2    337  ,19
g                      | C    2    32   2 3
w                      | L    1    18   ,2
```

```
q).ws.tblsum`.
Table        | Type Keys         Rows      Cols Size
-------------| --------------------------------------------
ADU          | S    ::           0         6    98
Account      | S    ::           340166    12   31295436
Channel      | S    ::           1010938   19   68744069
ImportLog    | P    ::           18        12   2833
Location     | S    ::           392443    18   36610666
MP           | S    ::           392487    14   21586725
MPParam      | M    ::           392443    2    7914267
Organization | M    ::           66        15   13435
Reading      | P    ::           793531105 14   50785990843
Tool         | S    ::           392471    17   31967213
ToolParam    | M    ::           392443    2    74489224
ToolType     | M    ::           26        7    3729
TimeZone     | S    ::           589       2    11380
User         | S    ::           38        11   2641
attr         | M    `id`createTS 392443    7    16482726
```

## Calling Trees

Call tree routines provide a way to interrogate and graphically display the functions invoked
(directly and/or indirectly) by a specified root function.

| Name and Syntax | Description |
| -------- | ----------- |
| `.ws.calls[fn]` | Lists the names of functions invoked directly by the specified root function |
| `.ws.rcalls[fn]` | Lists the names of functions invoked directly or indirectly by the specified root function |
| `.ws.fntree[names]` | Displays the full calling tree of functions in the argument, expanding namespaces as appropriate |

### Examples

```
q).ws.NSX:-1_.ws.NSX / For example purposes, allow workspace routines to operate on own namespace

q)count 0N!.ws.calls`.ws.fntree
`s#`.ws.gfns`.ws.rt`.ws.tr
3

q)count .ws.rcalls`.ws.fntree
16
```

The `calls` and `rcalls` routines can be used in conjunction with the [Q code profiler](https://github.com/LeslieGoldsmith/qprof) to profile
only a specific calling subtree. For example:

```
q)\l prof.q
q).prof.prof .ws.rcalls`run
```

The example below shows the output of computing a call tree of the `fntree` function itself.

```
q).ws.fntree`.ws.fntree

                           ┌─ .ws.getn ─── .ws.expns ─┌─ .ws.getn+
              ┌─ .ws.gfns ─│                          └─ .ws.ns
              │            │─ .ws.mt
              │            └─ .ws.val
              │─ .ws.rt
              │                          ┌─ .ws.ct
─ .ws.fntree ─│                          │                                         ┌─ .ws.cref  ─┌─ .ws.cref*
              │                          │             ┌─ .ws.ctiref ─── .ws.lref ─│             └─ .ws.lref+
              │                          │─ .ws.ctref ─│                           └─ .ws.lref*
              │            ┌─ .ws.calls ─│             └─ .ws.qn
              │            │             │
              │            │             │             ┌─ .ws.cref  ─┌─ .ws.cref*
              └─ .ws.tr   ─│             │─ .ws.lref  ─│             └─ .ws.lref+
                           │             │             └─ .ws.lref*
                           │             └─ .ws.qn
                           │─ .ws.rt
                           └─ .ws.tr*
```

In the output of `fntree`, `*` following a name indicates direct recursion, and `+` indicates indirect recursion.

## Searching Routines

Searching routines provide a way to search functions within a workspace for one
or more substrings.  As with the summarization routines, names
to search can be specified explicitly or by namepsace.

Searching can be either context-free or context-sensitive.
Context-sensitive searches treat certain constructs as
*syntactic elements*; these constructs are identifier names,
numeric constants (e.g. `1`, `-0.5`, `1b`), symbols (e.g. \``price`),
and character constants (e.g. `"Error"`).  Context-sensitive
searching allows a match of a syntactic element only if the
entire element is matched.

Hits are reported by displaying the entire line on which a
match occurred, with a caret (`^`) pointing to the first
character of each match on the line.  Results are written to
`stdout`.

The searching routines are listed below.

| Name and Syntax | Description |
| -------- | ----------- |
| `.ws.fnshow[names;strs]` | Searches the specified functions or namespaces for one or more strings |
| `.ws.seshow[names;strs]` | Searches the specified functions or namespaces for one or more strings, matching only syntactic elements |

### Syntactic Element Searching

On the line below, the following syntactic matches are found:

```
a+b;"a+b";a_b:1;1_b;-1_-1,b;abc-1;101b;4+1 2 3i-1;1i_b;`bid
^                                                           / "a"
  ^               ^       ^                          ^      / "b"
^                                                           / "a+b"
              ^ ^               ^               ^           / "1"
                    ^  ^       ^               ^            / "-1"
                                         ^                  / "1 2 3i"
    ^                                                       / "\"a+b\""
                                                        ^   / "bid"
                                                            / "i" (no matches)
a+b;"a+b";a_b:1;1_b;-1_-1,b;abc-1;101b;4+1 2 3i-1;1i_b;`bid
```

### Examples

```
q).ws.fnshow[`.;"misc"]
usec  (1 occurrence)

{use`.misc`enl`assert`assertz`use`usec,$[x~(::);();x]}
      ^
```

```
q).ws.fnshow[`.misc.mkwdist`.misc.sqz`.misc.zpad;("i";"b";"abs")]
.misc.mkwdist  (2 occurrences)

{[p;x;y] (sum each abs[x-\:y]xexp p)xexp 1f%p}
                   ^^

.misc.sqz  (3 occurrences)

{-1_x where i|-1_0b,i:" "<>x," "}
            ^     ^ ^

.misc.zpad  (4 occurrences)

{[w;i] $[count i;"0"^neg[w]$string i;0#""]}
    ^          ^               ^   ^
```

```
q).ws.seshow[`.misc.mkwdist`.misc.sqz`.misc.zpad;("i";"b";"abs")]
.misc.mkwdist  (1 occurrence)

{[p;x;y] (sum each abs[x-\:y]xexp p)xexp 1f%p}
                   ^

.misc.sqz  (2 occurrences)

{-1_x where i|-1_0b,i:" "<>x," "}
            ^       ^

.misc.zpad  (3 occurrences)

{[w;i] $[count i;"0"^neg[w]$string i;0#""]}
    ^          ^                   ^
```

# Author

Leslie Goldsmith
