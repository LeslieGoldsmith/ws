/
	Workspace utilities for developers
	Copyright (c) 2015 Affinity Systems

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License as
	published by the Free Software Foundation; either version 2 of
	the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	----------------

	Contains routines for searching functions within a workspace
	for one or more substrings.  Functions can be specified
	explicitly or by referencing a parent namespace (in which
	case all functions in all namespaces below it are examined).

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

	Author:		Leslie Goldsmith, Affinity Systems
\


\d .ws

NSX:`q`Q`h`j`o`ws / Namespace exclusion list

fnshow:{[nm;s] shw[;s;::;fnf]each fns nm;}

seshow:{[nm;s] shw[;s;se;sef]each fns nm;}


//
// Internal definitions.
//


enl:enlist
ns:~[1#.q]1#
mt:{(x~`)|x~(::)}
fns:{$[mt x;ff(key`.),getn ` sv'`,'(key`)except NSX;getn x]}
ff:{x where 100h=type each value each x}
getn:{(,/)getns each x}
getns:{$[type key x;$[ns value x;ff(j where not i),getn(j:` sv'x,'k)where i:ns each x k:1_key x;x];x]}
fnd:{x:"\n",last value value x;(x;"\n"=x:@[x;where x in "\r\t";:;" "])}
fnf:{[s;fn;se] $[count s;fn ss s;()]}
sef:{[s;fn;se] p where not se[p]|se[count[s]+p:fnf[s;fn;0]]}
expand:{[msk;a] @[msk;where msk;:;a]}

CH:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."


shw:{[nm;s;f0;f1]
	$[100h<>$[type key nm;type value nm;0h];-2 "Not a function: ",string nm;[
		se:f0 fn:first a:fnd nm;dpy[nm;fn;where last a;(,/)f1[;fn;se]each $[10h=type s;enl s;s]]]]
	}
	
se:{[fn]
	q<:(=\)(q:fn="\"")<=-1_0b,@[fn="\\";1+fn ss "\\\\";:;0b]; / Mark (with 0's) quoted strings
	i:q&fn in CH;se:(<>\)i:i<>-1_0b,i; / Mark unquoted identifiers and constants
	b:fn in -11#CH; / Possible numeric constants
	j:q&i<fn="-";se|:j&1_b,0b; / Turn on "-" if no ID to left and token to right is numeric
	j:i&(fn="_")|u:fn=" ";se|:u<expand[j;not t:b[(0,k)where j k:where i]]; / Turn on "_" if token to left is non-numeric ID
	se|:u&expand[j;t]&1_b,0b; / Turn on " " if tokens to left and right are numeric IDs
	se&-1_0b,se:se>=q / One-element spanning set for syntactic matches
	}

dpy:{[nm;fn;ln;p]
	if[not n:count p;:(::)];
	i:((+\)count each fn:ln _fn)binr p:asc p; / Lines on which hits occur
	j:where i<>-1_-1,i; / Starts of line groups
	h:string[nm],"  (",string[n]," occurrence",(n=1)_"s)\n"; / Header
	-1 h,(,/){[fn;p] fn,"\n",@[#[1+last p]" ";p;:;"^"]}'[fn i j;j _p-1+ln i],"\n";
	}

\d .

\

Usage:

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

.prof.NSX - List of namespaces to exclude; assign to change