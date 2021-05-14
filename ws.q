<<<<<<< HEAD
/
	Workspace utilities for developers
	Copyright (c) 2015-2018 Leslie Goldsmith

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at:

	http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing,
	software distributed under the License is distributed on an
	"AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
	either express or implied.  See the License for the specific 
	language governing permissions and limitations under the 
	License.

	----------------

	Contains routines for summarizing, searching, or analyzing the
	contents of a workspace.

	Summarization routines list the names of objects of particular
	classes (functions, variables, or tables), or provide a type-
	dependent synopsis of their properties.  Names can be specified
	either explicitly or by referencing a parent namespace (in
	which case all objects in all namespaces below it are
	considered).  Object size is approximated and does not include
	attribute overhead.
	
	Function call routines perform static analysis to determine the
	functions invoked by a function, either directly or recursively.
	An annotating comment called a code tag can be used to augment
	the definition of a function with additional hints regarding its
	calling tree.  This information is also useful for locating
	veiled references through searching.
	
	The cross-reference routine performs an independent static
	analysis and cross-reference of one or more functions, as well
	as their embedded lambdas.  The cross-reference includes each
	identifier, its type, a suspicious reference indicator, and
	information about each reference.  Code tags can be used to
	provide additional hints regarding referenced objects.
	
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

	Usage information and additional documentation appears at the
	bottom of this file.

	Author:		Leslie Goldsmith
\


\d .ws

NSX:`q`Q`h`j`m`o`s`ws / Namespace exclusion list
WTH:120 / Formatting width for name lists

fns:{[nm] lst gfns nm}
vars:{[nm] lst gvars nm}
tbls:{[nm] lst gtbls nm}

fnsum:{[nm] {([Function:x] Params:`${"[",(";"sv string x 1),"]"}each i;Lines:ln each i;Size:sz each i:value each value each x)}gfns nm}
varsum:{[nm] {([Variable:x] Type:ty first each t;Rank:r*-1+count each t;Size:sz each i;Shape:{$[x;neg[0>last y]_1_y;y 1]}'[r:0h<=type each i;t:ts each i:value each x])}gvars nm}
tblsum:{[nm] {([Table:x] Type:"MSP"(0,0b)?.Q.qp each i;Keys:ky each i;Rows:count each i;Cols:count each cols each i:value each x;Size:tsz'[x;value each x])}gtbls nm}

calls:{[nm]
	d:first g:lref[0]f:value nm; / Compute globals (with leading context)
	if[1b in(p~\:".z.s")&1i=(+\)(-/)(p:-4!(2*"k)"~2#p)_p:string f)~\:/:2 1#"{}";g,:nm]; / Account for recursion via self-ref
	g@:where not(`$(1+(1_'s)?'".")#'s:string g:distinct qn[d]1_g,last ctref[d]ct p)in\:` sv'`,'NSX; / Include code tag refs and ignore excluded namespaces
	asc g where(type each value each g@:where 0h>type each key each g)in 100 104h / Retain functions and projections only, and sort
	}
	
rcalls:{[nm] asc distinct rc[()]nm}
fntree:{[nm] {-1 enl[""],rt[1#x]tr[()]x;}each gfns nm;}

fnxref:{[nm] {-1 enl["\n",string[x],":"],xr x;}each gfns nm;}

fnshow:{[nm;s] shw[;s;::;fnf]each gfns nm;}
seshow:{[nm;s] shw[;s;se;sef]each gfns nm;}


//
// Internal definitions.
//


enl:enlist
ns:{$[99h=type x;(1#.q)~1#x;0b]}
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
ts:{$[(0h<>t:type x)|0=c:count x;t,c;0h in first each i:ts each x;t,c;1=count distinct 1_'-1_'i;sm[first each i;0h],c,(1_-1_first i),sm[last each i;-1];sm[first each i;0h],c]}
ky:{$[99h=type x;{$[1=count x;first x;x]}key flip key x;::]}
lst:{sfmt[WTH]x}
tsz:{[s;x] if[0b~t:.Q.qp x:0!x;x:flip .Q.V x];$[t;psz[s;x]+sz x;$[1000>n:count x;1b;0h<(&/)type each value flip x];sz x;"j"$(n%i)*sz(0!x)neg[i:cs n]?n]}
cs:{[n;z;p;e] r:(z*z*p*1-p)%e*e;"i"$r%1+r%n}[;1.96;0.25;0.05] / Size, confidence level z score, population proportion, margin of error
tw:{4^0N 1 16 0N 1 2 4 8 4 8 1 8 8 4 4 8 8 4 4 4 abs x}

rc:{[s;nm] $[0=count g:calls nm;:1#nm;nm,/rc[s]each g except s,:nm]}
qn:{[d;x] $[`=d;x;1b in i:"."<>string[x][;0];@[x;i;:;` sv'`,'d,'x i:where i];x]}
setc:{@[`.ws;;:;].(`tl`bl`vl`ht;(".'|-";"\332\300\263\304")x);}
cref:{(,/)$[99h=t:type x;cref each x;t;();$[(t:type a:first x)in 100 104h;lref[1]a;-11h=t;a;()],cref each x where 0h=type each x]}
ctiref:{$[0h=type key x;();11h=abs t:type a:value x;a;99h<>t;();not max i:(t:type each a)in 100 104h;(,/)a where 11h=abs t;11h=type key a;` sv'x,'where i;(,/)lref[1]each a where i]}

gty:{t:type each key each x;@[count[t]#0Nh;i;:;type each value each x i:where 0h<>t]}

fnd:{x:"\n",last value value x;(x;"\n"=x:@[x;where x in "\r\t";:;" "])}
fnf:{[s;fn;se] $[count s;fn ss s;()]}
sef:{[s;fn;se] p where not se[p]|se[count[s]+p:fnf[s;fn;0]]}
qtm:{[fn] (fn="\"")<=-1_0b,@[fn="\\";1+fn ss "\\\\";:;0b]}
cmm:{[fn;ln;q] $[1b in c:(-1_0b,fn in" \n")&fn="/";[j:(cm\). 0b,ln _/:(q;c);(,/)j[;1]];1b]}
cm:{[b;q;c] i:first[b]=\q;j:first where[i<c],n:count q;(i[j-1];(j#1b),(n-j)#0b)}
ra:{[s;p] where(p>0i)&(-1_1b,s in "\n([{;")&(s=":")>1_(s in ":;)]}"),0b};

expand:{[msk;a] @[msk;where msk;:;a]}
trueAt:{@[x#0b;y;:;1b]}
porr:{i:x where x|y;((1_i,1b)where i)<=y where x}

CH:"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ.0123456789"
CTCH:"+@"
AOP:"+-*%&|<>=^!~,#_$?@."
ITY,:.[ITY:"    ",/:(0N 2#"PRLVGVFN *RCLMKW"),\:"  ";(::;6);:;"+"]
RTY:(0N 2#": [ [:  @[.["),AOP,'":"


expns:{[f;b;x]
	$[type key x;$[ns value x;f[j where not i],getn[f;0b](j:` sv'x,'k)where i:ns each x k:1_key x;`.~x;f key x;count f x,();x;0#if[b;-2 "Not a ",last[value f],": ",string x]];
		0#-2 "Invalid name: ",string x]
	}

sfmt:{[w;nm]
	u:8*l:ceiling(1+count each nm:string nm)%8; / Widths of each name
	j:{x+y z}[(_)w%8;(0,(+\)l)i:where l]\[0]; / Compute 8-char group counts at starts of lines
	j:(til[count l]i)neg[1+0N=last j]_j; / Convert to ID counts
	1` sv(,/')j _u$'nm; / Split and output lines
	}

psz:{[s;x]
	if[0=n:count x;:0];t*:11h<>t:.Q.tx each value .Q.V x;if[0h<(&/)t;:n*(+/)tw t]; / Exit if table empty or materialized types all fixed-width
	j:1+(c:(+\)k:(|).Q.pn s)binr i:cs n; / Find number of trailing partitions required to obtain statistical sample
	p:(neg[j]#.Q.pv)(j-1)-m:where 0<k:j#k; / From these, get contributing partition numbers
	k@:m;j:k&i--1_0,c m; / Corresponding counts to fetch
	"j"$(n%i)*(+/){[s;p;n;i] sz?[s;enl[(=;.Q.pf;p)],$[n>i;enl(in;`i;neg[i]?n);()];0b;()]}[s]'[p;k;j] / Fetch and scale result
	}

ct:{[p]
	if[0=count i:where(1<count each p)&(k:p[;0])in" /\t\n";3 0#()]; / Extract comments
	if[0=count j:where(c[;1]="#")&(c:(c?'"/")_'c:p i)[;2]in CTCH;3 0#()]; / From those, extract code tags (might have: /#+ a b /#@ c / Comment)
	s:{x:(0,1+x ss" /")_x:@[x;where x="\t";:;" "];(((x[;1]="#")&x[;2]in CTCH)?0b)#x}each c j; / Split into individual CTs, ignoring possible trailing comments
	(a[;2];(1+where[k="\n"]bin i j)where count each s;3_'a:(,/)s) / Code tag types, line numbers, and values
	}

ctref:{[d;c]
	if[0=count c;:2 0#()]; / No code tags
	r:{[d;t;x] x@:where not null x;$[t="+";x;t="@";(,/)ctiref each qn[d]x;0#`]}[d]'[first c;`$" "vs'last c]; / Resolve direct and indirect references
	(c[1]where count each r;(,/)r) / Affix line numbers
	}

lref:{
	t:type each f:value y;g:x _$[100h=type y;f 3;100h=first t;1#value[first f]3;1#`]; / Get direct refs (fn) and/or namespace (fn, proj)
	g,/(lref[1]each f where t in 100 104h),cref each f where t in 0 99h / Append references
	}

tr:{[s;nm]
	if[nm in s;:1 1#"+*"nm=-1#s]; / Check for recursion
	if[0=count g:calls nm;:1 1#"|"]; / And for degenerate calls
	t:(,/)tr[s,nm]each g; / Compute descendant call trees
	i:" "<>j:t[;1];if[1<n:count i:0,where((j=tl)&-1_0b,i)|i&-1_0b,j=bl;t:-1_(,/)(i _t),'n#1 1 0#""]; / The vertically aesthetic side of arboriculture
	n:count t:rt[g;t]; / Augment with subtree roots
	i:first k:where" "<>t[;0];j:last k; / Scope of descendant tree
	c:(c>1)+/(k:til c)>/:0,0|-2+c:1+j-i; / Descendant row class: 0 = solo, 1 = first, 2 = middle, 3 = last
	(@[n#" ";(_)0.5*j+i;:;ht],'@[n#" ";i+k;:;(ht,tl,vl,bl)c]),'t / Mark root position and bracket descendant group
	}

rt:{[g;t]
	j@:k:where" "<>j:t[;0]; / Locate root positions
	g:(ht," "),/:((i:1+(|/)count each g)$g:string[g],'(j in"+*")#'j),'(" ",ht)j=ht; / Pad names to align subtrees, and add recursion hints
	@[count[t]#enl(i+3)#" ";k;:;g],'1_'t / Prepend roots
	}

xr:{[nm]
	fn:last v:value value nm; / Get function defn
	fn[where fn="\t"]:" "; / Map tabs to blanks
	cr:ctref[first v 3]ct -4!(2*"k)"~2#fn)_fn; / Extract code tag information
	j:cmm[fn;0,where ln:fn="\n";q:qtm fn]; / Mark (with 0's) unescaped quote chars (may be in comments) and comments
	fn@:j:where j&q<=(=\)q>=j;ln@:j; / Mark (with 0's) quoted strings and comments and remove them
	j:where{x@:where j:i|-1_0b,i:x<>" ";i|expand[j;((("-"=1_x),0b)&-1_0b,x in")]}")|(1_k,0b)&-1_0b,k:x in CH]}fn;fn@:j;ln@:j; / Remove redundant white space
	
	b:b<>-1_0b,b:fn in CH; / Locate extremums of possible identifiers
	d:(fn[i]in -10_CH)&"`"<>fn -1+i:where b;d:(<>\)b:expand[b]d|-1_0b,d; / Inclusive mask of real identifiers (non-numeric, non-symbol)
	ia:(b&d)|p:trueAt[count fn;ra[fn;1i]]; / Compute start of each identifier and return stmt
	if[not count[first cr]|1b in ia;:enl"No references"]; / Quit if no references
	b:(-1_0b,p)|b>d; / Determine end of each reference
	ln-:til count ln:where ia where ia|ln; / Associated line numbers
	w:(|/)c:(1_c,count i)-c:where i:ia where d|:p; / Compute identifier lengths
	nl:`$(-1_0,(+\)c)_fn where d; / Extract identifier names
	
	ch:fn rz:where b; / Get character following each reference
	iz:count[ch]#0N; / Position of char following each indexed reference (in case no indexing)
	if[1b in i:ch="[";j:"]"=fn where c:fn in"[]";j:where[c]iasc j+(+\)1 -1 j;iz:@[iz;i;:;1+j 1+j?rz i:where i]]; / Find position after matching right bracket

	p:(+\)1 -1i"{}"?fn; / Cumulative function nesting level
	if[0=count lm:value each value each where[(i>-1_0b,i)j]_fn j:where i|-1_0b,i:2<=p;lm:1 4 0#`]; / Get lambda properties

	rt:rty[fn;iz;rz;ch;ia];ga:last rt;rt:first rt; / Compute reference type and global assign mask
	if[c:count first cr;nl,:last cr;ln,:first cr;rt,:c#3;ga,:c#0b;rz,:c#-2;v[3],:last cr]; / Add code tag references
	i:iasc$[c;flip(nl;ln);nl]; / Sort names (and line numbers if code tag refs)
	nl@:where m:differ nl@:i;ln@:i;rt@:i;ga@:i;rz@:i; / Keep unique names and reorder properties

	it:ity[nm;fn;nl;m;lm;v;rz]; / Compute identifier type
	sr:sref[nl;m;v;rt;ga;it]; / Calculate suspicious references
	xfmt[nl;m;it;ln;rt;sr;w] / Format table
	}

rty:{[fn;iz;rz;ch;ia]
	rt:(":"=fn iz)+":[["?ch; / Compute basic reference type (a:1, a[b], a[b]:1, a)
	i:":"=fn rz+1; / Candidates for global assign (a::1) and modified assign (a+:1)
	rt[k]:6+j k:where b:(rt=3)&i&count[AOP]>j:AOP?ch; / Modified assignment (a+:1)
	j:(rt=1)&(fn[iz]in AOP)&":"=fn iz+1; / Modified indexed assignment (a[b]+:1, a[b]+::1)
	ga:(i&rt=0)|((":"=fn iz+1)&rt=2)|(j&":"=fn iz+2)|b&":"=fn rz+2; / Global assignment (a::1, a[b]::1, a[b]+::1, a+::1)
	rt+:j; / Flip index ref to assign for modified IA
	i:where ia;j:(rt=3)&ch=";"; / Candidates for functional amend (@[a; ...], .[a; ...])
	rt[where j&i in 2+fn ss"@[[]"]:4; / At amend
	rt[where j&i in 2+fn ss".[[]"]:5; / Dot amend
	(rt;ga) / Reference type and global assign mask
	}

ity:{[nm;fn;nl;m;lm;v;rz]
	g:g@/:(where not i|null t;where i:99h<t:gty qn[d:first v 3;g:(,/)1_'enl[v 3],lm[;3]]); / Compute global type, and group vars and fns
	it:(0,(+\)count each i)bin((,/)i:(v[1],/lm[;1];v[2],/lm[;2]),g)?nl; / Compute identifier type
	it[nl?distinct(inter/)2#i]+:8; / Mark if in multiple groups
	it[where(it=4)&nl in`by`from,.Q.res,key`.q]:7; / Q/k name
	it[where(it=1)&porr[m;"{"=fn rz+1]]:6; / Lambda
	it[where nl in nm,`.z.s]:5; / Recursive function
	it[i]:4 2 3[-20 99h binr gty qn[d;nl i:where it=4]]; / Global type (if still unresolved)
	it / Identifier type
	}

sref:{[nl;m;v;rt;ga;it]
	i:rt in 1 3 4 5; / Mark references (vs. assigns)
	sr:porr[m;not rt in 1 3]&it=7; / Assignment to keywords
	sr|:nl in where 1<count each group v 1; / Duplicate parameters
	sr|:porr[m;i]<it<2; / Local identifiers with no call references
	sr|:(porr[m;ga]&it=1)|porr[m;not i|ga]&it=2; / Local/global assign inconsistency
	sr / Suspicious reference mask
	}

xfmt:{[nl;m;it;ln;rt;sr;w]
	i:4+(_)10 xlog 1|/ln; / Width of each reference
	a:1_(-':)where m,1b; / Number of references per identifier
	b:(_)0.1+((WTH,(_)(WTH-6)%2)-10+w|:15)%i; / Max references per line of output for 1- or 2-col (min 6 cols between 2 cols; it+sr = 8+2 = 10)
	b:1|b flg:last[b]>=4&(|/)a; / Choose display format and refs/line (min 4 for 2-col) accordingly

	l:(+\)k:ceiling a%b;j:trueAt[last l;-1_0,l]; / Cumulative lines, and mask with 1's for each line of output corresponding to a new identifier
	c:@[count[j]#b;where 1_j,1b;:;1+(a-1)mod b]; / Number of references per line of output

	r:(,/')((+\)0,-1_c)_((2-i)$string ln),'RTY rt; / Format references
	r:(enl[count[first i]#" "],i:(w$string nl),'ITY[it],'(2 2#"  ? ")sr)[j*1+til[count k]where k],'r; / Prepend name, type, and suspicious ref indicator
	if[flg;k:l|i:count[j]-l@:i?(&/)i:abs l-ceiling count[j]%2;r:(((_)WTH%2)$(l#r),(k-l)#enl""),'(l _r),(k-i)#enl""]; / Compose 2-col display
	r / Formatted table
	}	

shw:{[nm;s;f0;f1]
	fn:first a:fnd nm;dpy[nm;fn;where last a;(,/)f1[;fn;f0 a]each$[10h=type s;enl s;s]]
	}

se:{[fl]
	j:cmm[fn;where last fl;q:qtm fn:first fl]; / Mark (with 0's) unescaped quote chars (may be in comments) and comments
	q:j&q<=(=\)q>=j; / Mark (with 0's) quoted strings excluding quote chars and comments
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

setc "w"=first string .z.o / Use 0 for ASCII box corners and sides, 1 for graphic

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

.ws.calls`fn						/ Lists functions invoked directly by the specified function
.ws.rcalls`fn						/ Lists functions invoked directly or indirectly by the specified function, including that function
.ws.fntree`name						/ Displays full calling tree of functions in specified name (function or namespace)
.ws.fntree`name1`name2				/ Displays full calling tree of functions in specified names (functions or namespaces)

.ws.fnxref`name						/ Displays cross-reference of identifiers used in the specified function, or functions in the specified namespace
.ws.fnxref`name1`name2				/ Displays cross-reference of identifiers used in the specified functions, or functions in the specified namespaces

.ws.fnshow[`name;"str"]				/ Searches specified function or namespace for "str"
.ws.fnshow[`name1`name2;"str"]		/ Searches specified functions or namespaces for "str"
.ws.fnshow[`;"str"]					/ Searches all functions in all namespaces for "str"
.ws.fnshow[`;("str1";"str2")]		/ Searches all functions in all namespaces for "str1" or "str2"

.ws.seshow[`name;"str"]				/ Syntactically searches specified function or namespace for "str"
.ws.seshow[`name1`name2;"str"]		/ Syntactically searches specified functions or namespaces for "str"
.ws.seshow[`;"str"]					/ Syntactically searches all functions in all namespaces for "str"
.ws.seshow[`;("str1";"str2")]		/ Syntactically searches all functions in all namespaces for "str1" or "str2"


Calling trees:

<calls> or <rcalls> can be used in conjunction with the Q code profiler to profile only a
specific calling subtree.  For example:

	\l prof.q
	.prof.prof .ws.rcalls`run

In <fntree>, `*’ following a name indicates direct recursion and `+’ indicates indirect
recursion.


Cross-references:

<fnxref> performs an independent static analysis and cross-reference of one or more Q
functions, as well as their embedded lambdas.  For each specified function, each object
identifier within the function is classified according to its type, and this is followed
by a suspicious reference indicator and details about each reference.  Reference
information consists of the line number on which the reference occurred and the type of
reference.

The identifier types are as follows:

	 *		Unclassified
	PR		Parameter
	LV		Local variable
	GV		Global variable
	FN		Function
	RC		Recursive function
	LM		Lambda function
	KW		Q keyword

If an identifier's usage involves multiple types (for example, as a result of conflicting
usage in an embedded lambda), the identifier type is followed by `+’.

Aside from the symbolic identifiers used in the function, <fnxref> includes `:’ as a
special identifier and cross-references it against return statements, if any.
	
Identifiers are marked as suspicious through the presence of the ‘?’ character after the
object type.  This may or may not indicate a problem, but it frequently does.  Examples
of conditions that earn the suspicious reference indicator include the following:

	- unreferenced or duplicate local
	- local/global assignment conflict
	- local assignment to a global
	- global assignment to a local
	- assignment to a keyword

Each reference to each identifier is classified as one of the following:

  (blank)	Unclassified
	:		Assignment, e.g. a:1  or  a::1
	[		Index reference, e.g. a[2] or function call
	[:		Index assignment, e.g. a[2]:x  or  a[2]::x
	@[		At amend, e.g. @[a;0;:;10]
	.[		Dot amend, e.g. .[a;(0;2 3);:;10]
	⍫:		Modified assignment, where "⍫" is one of "+-*%&|<>=^!~,#_$?@.", e.g. a+:x  or  a-::x

Note:  Assignment vs. execution of lambdas or projections is not distinguished, and these
are reported as assignments.


Code tags:

Comments beginning with "/#" are annotations known as code tags.  These comments can be used
to provide semantic hints to programs that recognize them, as well as to surface execution
details that may not be self-evident from visual or static analysis.  The call tree and
cross-reference utilities recognize code tags.

The character immediately following "/#" identifies the type of code tag.  The following
types of code tags are supported:

	/#+ namelist	Treat names in <namelist> as if referenced on line
	/#@ namelist	Treat contents of names in <namelist> as if referenced on line

The names listed may or may not be qualified with a namespace.  For example:

	/#+ run .rep.run0
	
If a name is not qualified by a namespace, the context of the referencing function is used.

When referencing the contents of a name using "/#@", each name must refer to a defined
global variable.  For example:

	r:cmd[x] . args; /#@ cmd

This generates references to the items within the global variable "cmd", with the precise
effect depending upon the type of the variable:

	- If the value is a symbol or a list of symbols, the symbols are referenced.
	- If the value is a dictionary, then for each entry:
		- If the key is a symbol and the value is a lambda, the key symbol qualified by the
		  dictionary name is referenced.
		- If the value is a lambda, the lambda is referenced.
		- If the value is a symbol or a list of symbols, the value symbols are referenced.

An ordinary comment may appear to the right of a code tag directive, and multiple code tags
can appear on the same line:

	r:cmd[x] . args; /#@ cmd / Run command
	
	r:(`$"chk",hl)p; /#+ chkhigh chklow / Perform appropriate limit check
	
	REPTAB[c][c;x;y;.rep`stop`start b]; /#@ REPTAB /#+ .rep.start .rep.stop / Invoke report routine


Syntactic element searching:

On the line below, the following syntactic matches are found:

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


Globals:

.ws.NSX - List of namespaces to exclude; assign to change
.ws.WTH - Formatting width for name lists; assign to change