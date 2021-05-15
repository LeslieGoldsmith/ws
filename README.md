# ws

Workspace utilities for developers

Contains routines for summarizing, searching, and performing static analysic on the contents of
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
(directly and/or indirectly) by a specified root function. [Code tags](#code-tags) can be used to
provide additional hints regarding referenced objects.

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

## Cross-References

`fnxref` performs an independent static analysis and cross-reference of one or more Q
functions, as well as their embedded lambdas.  [Code tags](#code-tags) can be used to
provide additional hints regarding referenced objects.

For each specified function, each object identifier within the function is classified according to its type, and this is followed
by a suspicious reference indicator and details about each reference.  Reference
information consists of the line number on which the reference occurred and the type of
reference.

The identifier types are as follows:

| Identifier Type | Description |
| :--------: | :----------- |
| ` *` | Unclassified |
| `PR` | Parameter |
|	`LV` | Local variable |
|	`GV` | Global variable |
|	`FN` | Function |
|	`RC` | Recursive function |
|	`LM` | Lambda function |
|	`KW` | Q keyword |

If an identifier's usage involves multiple types (for example, as a result of conflicting
usage in an embedded lambda), the identifier type is followed by `+`.

Aside from the symbolic identifiers used in the function, `fnxref` includes `:` as a
special identifier and cross-references it against return statements, if any.

Identifiers are marked as suspicious through the presence of the `?` character after the
object type.  This may or may not indicate a problem, but it frequently does.  Examples
of conditions that earn the suspicious reference indicator include the following:

- unreferenced or duplicate local
- local/global assignment conflict
- local assignment to a global
- global assignment to a local
- assignment to a keyword

Each reference to each identifier is classified as one of the following:

| Reference Type | Description |
| :--------: | ----------- |
| (blank)	| Unclassified |
|	`:` | Assignment, e.g. `a:1` or `a::1` |
|	`[` | Index reference, e.g. `a[2]` or function call |
|	`[:` | Index assignment, e.g. `a[2]:x` or `a[2]::x` |
|	`@[` | At amend, e.g. `@[a;0;:;10]` |
|	`.[` | Dot amend, e.g. `.[a;(0;2 3);:;10]` |
|	`⍫:` | Modified assignment, where `⍫` is one of `+` `-` `*` `%` `&` `\` `\|` `<` `>` `=` `^` `!` `~` `,` `#` `_` `$` `?` `@` `.` , e.g. `a+:x` or `a-::x` |

For example, a reference consisting of just a line number indicates a value is being sampled; a reference followed by `:` indicates a value is being assigned.

> **Note** Assignment vs. execution of lambdas or projections is not distinguished, and these
are reported as assignments.

### Example

`.ed.qed` is a line editor implemented in Q. The full source is available at ???. We use `.ed.qed` as a sample function to illustrate how the cross-reference output relates to the source. We first define a simple function to prefix function lines with ordinal numbers, to make the relationship clearer.

```
q)dfn:{-1 (5$"[",'string[til count x],'"]"),'x:"\n"vs last value value x;}
```

```
q)dfn`.ed.qed
[0]  {
[1]   if[0~v:ncsv x;:()];nm:first v;c:v 1; / Extract name (with possible namespace) and context
[2]   i:0,1+where"\n"=fn0:nm,":",last v; / Find line breaks
[3]   Lns::10000*til count Fn::i _fn0,"\n"; / Scaled line numbers and corresponding lines
[4]   Cur::0|-2+count Lns; / Current line (= insert point), before closing }
[5]   Mode::0b; / Set insert (vs. edit) mode
[6]   Ln::-1; / User-specified line number, if any
[7]   if[v 2;fn0:0]; / Kill inceptive defn if new
[8]   d:system"c";system"c 1000 2000"; / Set display size
[9]   p:system"P";system"P 10"; / Set formatting precision
[10]
[11]  dl(); / Display all lines
[12]
[13]  while[not$[[2 pr:fmtn seln[];"\\w"~s:read0 0];
[14]            [s:"";count nm:def[n;ctx[c;nm;n:name Fn];(1+fn?":")_fn:-1_(,/)Fn]];[if[i:"\\q"~s;nm:""];i]]; / Attempt to define function
[15]    r:$[0=count s:ltrim s;Cur; / No change if input empty
[16]            [Ln::-1;"["=first s];lcmd s; / Look for edit command
[17]            upd pr,s]; / Otherwise, update current line
[18]    $[r=-1;-2 "Command error";Mode&::r=Cur::r&-1+count Lns]];
[19]
[20]  if[count nm;-1 nm,(" defined";" unchanged")fn0~fn];
[21]
[22]  system"c ",.Q.s1 d;system"P ",string p; / Restore settings
[23]  }
```

```
q).ws.fnxref`.ed.qed

.ed.qed:
.Q.s1              FN     22                                n                  LV     14   14:
:                   *      1                                name               FN     14
Cur                GV      4:  15   18:                     ncsv               FN      1
Fn                 GV      3:  14   14                      nm                 LV      1:   2   14:  14   14:  20
Ln                 GV      6:  16:                                                    20
Lns                GV      3:   4   18                      not                KW     13
Mode               GV      5:  18&:                         p                  LV      9:  22
c                  LV      1:  14                           pr                 LV     13:  17
count              KW      3    4   14   15   18   20       r                  LV     15:  18   18   18
ctx                FN     14[                               read0              KW     13
d                  LV      8:  22                           s                  LV     13:  14:  14   15:  15   16
def                FN     14[                                                         16   17
dl                 FN     11                                seln               FN     13[
first              KW      1   16                           string             KW     22
fmtn               FN     13                                system             KW      8    8    9    9   22   22
fn                 LV     14   14:  20                      til                KW      3
fn0                LV      2:   3    7:  20                 upd                FN     17
i                  LV      2:   3   14:  14                 v                  LV      1:   1    1    2    7
if                 KW      1[   7[  14[  20[                where              KW      2
last               KW      2                                while              KW     13[
lcmd               FN     16                                x                  PR      1
ltrim              KW     15
```

## Code Tags

Comments beginning with `/#` are annotations known as _code tags_.  These comments can be used
to provide semantic hints to programs that recognize them, as well as to surface execution
details that may not be self-evident from visual or static analysis.  The call tree and
cross-reference utilities recognize code tags.

The character immediately following `/#` identifies the type of code tag.  The following
types of code tags are supported:

| Code Tag | Description |
| -------- | ----------- |
| `/#+ namelist` | Treat names in `namelist` as if referenced on line |
| `/#@ namelist` | Treat contents of names in `namelist` as if referenced on line |

The names listed may or may not be qualified with a namespace.  For example:

```
value r; /#+ run .rep.run0
```
  
If a name is not qualified by a namespace, the context of the referencing function is used.

When referencing the contents of a name using `/#@`, each name must refer to a defined
global variable.  For example:

```
r:cmd[x] . args; /#@ cmd
```

This generates references to the items within the global variable `cmd`, with the precise
effect depending upon the type of the variable:

- If the value is a symbol or a list of symbols, the symbols are referenced.
- If the value is a dictionary, then for each entry:
	- If the key is a symbol and the value is a lambda, the key symbol qualified by the
	  dictionary name is referenced.
	- If the value is a lambda, the lambda is referenced.
	- If the value is a symbol or a list of symbols, the value symbols are referenced.

An ordinary comment may appear to the right of a code tag directive, and multiple code tags
can appear on the same line:

```
r:cmd[x] . args; /#@ cmd / Run command
	
r:(`$"chk",hl)p; /#+ chkhigh chklow / Perform appropriate limit check
	
REPTAB[c][c;x;y;.rep`stop`start b]; /#@ REPTAB /#+ .rep.start .rep.stop / Invoke report routine
```

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
