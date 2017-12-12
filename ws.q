/
	Workspace utilities for developers
	Copyright (c) 2015-2017 First Derivatives

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	----------------

	Contains routines for summarizing or searching the contents of
	a workspace.

	Summarization routines list the names of objects of particular
	classes (functions, variables, or tables), or provide a type-
	dependent synopsis of their properties.  Names can be specified
	either explicitly or by referencing a parent namespace (in
	which case all objects in all namespaces below it are
	considered).  Object size is approximated and does not include
	attribute overhead.
	
	Searching routines search functions within a workspace for one
	or more substrings.  As with the summarization routines, names
	to search can be specified explicitly or by namepsace.

	Searching can be either context-free or context-sensitive.
	Context-sensitive searches treat certain constructs as
	syntactic elements; these constructs are identifier names,
	numeric constants (e.g. 1, -0.5, 1b), symbols (e.g. `price),
	and character constants (e.g. "Error").  Context-sensitive
	searching allows a match of a syntactic element only if the
	entire element is matched.

	Hits are reported by displaying the entire line on which a
	match occurred, with a caret (^) pointing to the first
	character of each match on the line.  Results are written to
	stdout.

	Usage information appears at the bottom of this file.

	Author:		Leslie Goldsmith, First Derivatives
\


\d .ws

NSX:`q`Q`h`j`o`ws / Namespace exclusion list
WTH:79 / Formatting width for name lists

fns:{[nm] lst gfns nm}
vars:{[nm] lst gvars nm}
tbls:{[nm] lst gtbls nm}

fnsum:{[nm] {([Function:x] Params:`${"[",(";"sv string x 1),"]"}each i;Lines:ln each i;Size:sz each i:value each value each x)}gfns nm}
varsum:{[nm] {([Variable:x] Type:ty first each t;Rank:r*-1+count each t;Size:sz each i;Shape:{$[x;neg[0>last y]_1_y;y 1]}'[r:0h<=type each i;t:ts each i:value each x])}gvars nm}
tblsum:{[nm] {([Table:x] Type:"MSP"(0,0b)?.Q.qp each i;Keys:ky each i;Rows:count each i;Cols:count each cols each i:value each x;Size:tsz'[x;value each x])}gtbls nm}

fnshow:{[nm;s] shw[;s;::;fnf]each gfns nm;}
seshow:{[nm;s] shw[;s;se;sef]each gfns nm;}


//
// Internal definitions.
//


enl:enlist
ns:~[1#.q]1#
mt:{(x~`)|x~(::)}

nms:{[f;x] asc$[mt x;f[key`.],getn[f;0b]` sv'`,'(key`)except NSX;getn[f;1b]x]}
getn:{[f;b;x] (,/)expns[f;b]each x}
val:{@[value;x;{-2 "Invalid name: ",string y;}[;x]]}
gfns:nms{y where 100h=type each val each y}"function"
gvars:nms{y where not[.Q.qt each i]&100h>type each i:val each y}"variable"
gtbls:nms{y where .Q.qt each val each y}"table"

sz:@[-22!;;{~}]
ln:{$["locked"~j:last i:` vs last x;~;count[i]-" }"~j]}
ty:@[(58#"l"),reverse[ty],"-",upper[ty:1_-1_.Q.t],(58#"L"),(20#"-"),"AY",13#":"]77+
sm:{$[0b in x=first x;y;first x]}
ts:{$[(0h<>t:type x)|0=c:count x;t,c;0h in first each i:ts each x;t,c;1=count distinct 1_'-1_'i;sm[first each i;0h],c,sm[last each i;-1];sm[first each i;0h],c]}
ky:{$[99h=type x;{$[1=count x;first x;x]}key flip key x;::]}
lst:{sfmt[WTH]x}
tsz:{[s;x] if[0b~t:.Q.qp x:0!x;x:flip .Q.V x];$[t;psz[s;x]+sz x;$[1000>n:count x;1b;0h<(&/)type each value flip x];sz x;"j"$(n%i)*sz(0!x)neg[i:cs n]?n]}
cs:{[n;z;p;e] r:(z*z*p*1-p)%e*e;"i"$r%1+r%n}[;1.96;0.25;0.05] / Size, confidence level z score, population proportion, margin of error
tw:{4^0N 1 16 0N 1 2 4 8 4 8 1 8 8 4 4 8 8 4 4 4 abs x}

fnd:{x:"\n",last value value x;(x;"\n"=x:@[x;where x in "\r\t";:;" "])}
fnf:{[s;fn;se] $[count s;fn ss s;()]}
sef:{[s;fn;se] p where not se[p]|se[count[s]+p:fnf[s;fn;0]]}
qtm:{[fn] (fn="\"")<=-1_0b,@[fn="\\";1+fn ss "\\\\";:;0b]}
cmm:{[fn;ln;q] $[1b in c:(fn in" \n")&1_(fn="/"),0b;[j:(cm\). 0b,ln _/:(q;c);(,/)j[;1]];1b]}
cm:{[b;q;c] i:first[b]=(=\)q;j:first where[i<c],n:count q;(i[j-1];(j#1b),(n-j)#0b)}
expand:{[msk;a] @[msk;where msk;:;a]}
trueAt:{@[x#0b;y;:;1b]}

CH:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."


expns:{[f;b;x]
	$[type key x;$[ns value x;f[j where not i],getn[f;0b](j:` sv'x,'k)where i:ns each x k:1_key x;`.~x;f key x;count f x,();x;0#if[b;-2 "Not a ",last[value f],": ",string x]];
		0#-2 "Invalid name: ",string x]
	}

sfmt:{[w;nm]
	u:8*l:ceiling(1+count each nm:string nm)%8; / Widths of each name
	j:{x+y z}[(_)w%8;(0,(+\)l)i:where l]\[0]; / Compute 8-char group counts at starts of lines
	j:(til[count l]i)neg[1+0N=last j]_j; / Convert to ID counts
	1` sv(,/)each j _u$'nm; / Split and output lines
	}

psz:{[s;x]
	if[0=n:count x;:0];t*:11h<>t:.Q.tx each value .Q.V x;if[0h<(&/)t;:n*(+/)tw t]; / Exit if table empty or materialized types all fixed-width
	j:1+(c:(+\)k:(|).Q.pn s)binr i:cs n; / Find number of trailing partitions required to obtain statistical sample
	p:(neg[j]#.Q.pv)(j-1)-m:where 0<k:j#k; / From these, get contributing partition numbers
	k@:m;j:k&i--1_0,c m; / Corresponding counts to fetch
	"j"$(n%i)*(+/){[s;p;n;i] sz?[s;enl[(=;`int;p)],$[n>i;enl(in;`i;neg[i]?n);()];0b;()]}[s]'[p;k;j] / Fetch and scale result
	}

shw:{[nm;s;f0;f1]
	se:f0 fn:first a:fnd nm;dpy[nm;fn;where last a;(,/)f1[;fn;se]each $[10h=type s;enl s;s]]
	}

se:{[fn]
	j:cmm[fn;where fn="\n";q:qtm fn]; / Mark (with 0's) unescaped quote chars (may be in comments) and comments
	q&:j&(=\)q>=j; / Mark (with 0's) quoted strings and comments
	i:q&fn in CH;se:(<>\)i:i<>-1_0b,i; / Mark unquoted identifiers and constants
	b:fn in -11#CH; / Possible numeric constants
	j:q&i<fn="-";se|:j&1_b,0b; / Turn on "-" if no ID to left and token to right is numeric
	j:i&(fn="_")|u:fn=" ";se|:u<expand[j;not t:b[(0,k)where j k:where i]]; / Turn on "_" if token to left is non-numeric ID
	se|:u&expand[j;t]&1_b,0b; / Turn on " " if tokens to left and right are numeric IDs
	se&-1_0b,se:se>=q / One-element spanning set for syntactic matches
	}

dpy:{[nm;fn;ln;p]
	if[not n:count p;:()];
	i:((+\)count each fn:ln _fn)binr p:asc p; / Lines on which hits occur
	j:where i<>-1_-1,i; / Starts of line groups
	h:string[nm],"  (",string[n]," occurrence",(n=1)_"s)\n"; / Header
	-1 h,/{[fn;p] fn,"\n",@[#[1+last p]" ";p;:;"^"]}'[fn i j;j _p-1+ln i],"\n";
	}

\

Usage:

.ws.fns`.							/ Lists names of functions in root namespace
.ws.fns`name						/ Lists names of functions in specified namespace
.ws.fns`name1`name2					/ Lists names of functions in specified namespaces
.ws.fns`							/ Lists names of functions in all namespaces

.ws.vars | .ws.tbls					/ As above, but for variables or tables

.ws.fnsum`.							/ Summarizes functions in root namespace
.ws.fnsum`name						/ Summarizes functions in specified name (function or namespace)
.ws.fnsum`name1`name2				/ Summarizes functions in specified names (functions or namespaces)
.ws.fnsum`							/ Summarizes functions in root namespace

.ws.varsum | .ws.tblsum				/ As above, but for variables or tables

.ws.fnshow[`name;"str"]				/ Searches specified function or namespace for "str"
.ws.fnshow[`name1`name2;"str"]		/ Searches specified functions or namespaces for "str"
.ws.fnshow[`;"str"]					/ Searches all functions in all namespaces for "str"
.ws.fnshow[`;("str1";"str2")]		/ Searches all functions in all namespaces for "str1" or "str2"

.ws.seshow[`name;"str"]				/ Syntactically searches specified function or namespace for "str"
.ws.seshow[`name1`name2;"str"]		/ Syntactically searches specified functions or namespaces for "str"
.ws.seshow[`;"str"]					/ Syntactically searches all functions in all namespaces for "str"
.ws.seshow[`;("str1";"str2")]		/ Syntactically searches all functions in all namespaces for "str1" or "str2"

Syntactic element searching:

On the line below, the following syntactic matches are found:

a+b;"a+b";a_b:1;1_b;-1_-1,b;abc-1;101b;4+1 2 3i-1;1i_b;`bid
^															/ "a"
  ^               ^       ^                          ^		/ "b"
^															/ "a+b"
              ^ ^               ^               ^			/ "1"
                    ^  ^       ^               ^			/ "-1"
                                         ^					/ "1 2 3i"
    ^														/ "\"a+b\""
                                                        ^	/ "bid"
															/ "i" (no matches)
a+b;"a+b";a_b:1;1_b;-1_-1,b;abc-1;101b;4+1 2 3i-1;1i_b;`bid

Globals:

.ws.NSX - List of namespaces to exclude; assign to change
.ws.WTH - Formatting width for name lists; assign to change