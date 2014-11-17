ENTRY
  { address
    archive
    author
    booktitle
    chapter
    collaboration
    doi
    edition
    editor
    eid
    eprint
    howpublished
    institution
    isbn
    journal
    key
    language
    note
    number
    numpages
    organization
    pages
    publisher
    school
    series
    title
    type
    url
    volume
    year
  }
  {}
  {}
INTEGERS { i j }
STRINGS { s t }

FUNCTION {str.to.int$}
{
  't :=
  #0 'j :=
  #0 'i :=
  { #0 j = }
  {
    i int.to.str$ 's :=
    t s =
    { #1 'j := }
    { i #1 + 'i := }
	if$
  }
  while$
  i #1 +
}

FUNCTION {format.bibitem}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn~ID! }" write$
  }
  {
    newline$
    "\bibitem{" swap$ "}" * * write$ newline$
  }
  if$
}

FUNCTION {format.address}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn\bstaddress~Adresse}" write$
  }
  { "{\bstaddress " swap$ "}" * * write$ }
  if$
}

INTEGERS { numnames }
STRINGS  { namelist }
FUNCTION {author.write}
{
  'namelist :=
  namelist num.names$ 'numnames :=
  numnames #9 <
  {
    #0 'i :=
    { i numnames < }
    {
      namelist i #1 + "{f.~}{vv~}{ll}{, jj}" format.name$ "{\bstauthor " swap$ "}" * * write$
      i numnames #2 - <
      { ", " write$ }
      {}
      if$
      i numnames #2 - =
      { " \bbland~" write$ }
      {}
      if$
      i #1 + 'i :=
    }
    while$
  }
  {
    namelist #1 "{f.~}{vv~}{ll}{, jj}" format.name$ "{\bstauthor " swap$ "}" * * write$
	" {\bstetal et al.}" write$
  }
  if$
}

FUNCTION {format.author}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn\bstauthor~Autor}" write$
  }
  {
    author.write
  }
  if$
}

FUNCTION {format.booktitle}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn\bsttitle~Buchtitel}" write$
  }
  { "{\bsttitle " swap$ "}" * * write$ }
  if$
}

FUNCTION {format.doiurl}
{
  duplicate$ empty$
  { % url nicht vorhanden
    pop$ duplicate$ empty$
    { pop$ }
    { "{\bstdoi , doi: " swap$ "}" * * write$ }
    if$
  }
  { % url vorhanden
    swap$ duplicate$ empty$
    { pop$ ", \url{" swap$ "}" * * write$ }
    { swap$ "{\bstdoi , doi: }\href{" swap$ * "}{" * swap$ "}" * * write$ }
    if$
  }
  if$
}

FUNCTION {format.doiisbn}
{
  duplicate$ empty$
  { % isbn nicht vorhanden
    pop$ duplicate$ empty$
    { pop$ }
    { "{\bstdoi , doi: " swap$ "}" * * write$ }
    if$
  }
  { % isbn vorhanden
    swap$ duplicate$ empty$
    { pop$ ", ISBN~\bstisbn{" swap$ "}" * * write$ }
    { swap$ "{\bstdoi , doi: }\href{" swap$ * "}{" * swap$ "}" * * write$ }
    if$
  }
  if$
}

FUNCTION {format.edition}
{
  duplicate$ empty$
  { pop$ "{\bstwarn\bstedition~Ausgabe}" write$ }
  {
    duplicate$ "1" =
    { pop$ }
    { ", {\bstedition " swap$ ". \bbledition}" * * write$ }
    if$
  }
  if$
}

FUNCTION {format.journal}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn\bstjournal~Journal}" write$
  }
  { "{\bstjournal " swap$ "}" * * write$ }
  if$
}

FUNCTION {format.numpages}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn\bstnumpages~(Seitenanzahl)}" write$
  }
  { "{\bstnumpages (" swap$ "~\bblpages)}" * * write$ }
  if$
}

INTEGERS { strlen pos }
STRINGS { p p1 p2}
FUNCTION {page.write}
{
  duplicate$ text.length$ 'strlen :=
  #0 'pos :=
  #0 'i :=
  { i strlen < }
  {
    duplicate$ i #1 + #1 substring$ "-" =
    { i #1 + 'pos := }
    {}
    if$
	i #1 + 'i :=
  }
  while$
  pos #0 =
  {
    "{\bstpage \bblarticle~" swap$ "}" * * write$
    " " write$
    format.numpages
  }
  {
	"{\bstpage \bblpage~" swap$ "}" * * write$
	pop$
    %duplicate$ #1 pos #1 - substring$ 'p1 :=
    %duplicate$ pos #1 + strlen pos - substring$ 'p2 :=
  %"{\bstpage \bblpage~" p1 "}" * * write$
    %"{\bstnumpages (" p2 str.to.int$ p1 str.to.int$ - int.to.str$ ")}" * * write$
	%pop$ pop$
  }
  if$
}

FUNCTION {format.page}
{
  duplicate$ empty$
  { pop$ "{\bstwarn\bstpage~Seite}" write$ }
  { page.write }
  if$
}

FUNCTION {format.publisher}
{
  duplicate$ empty$
  { pop$ "{\bstwarn\bstpublisher~Herausgeber}" write$ }
  { "{\bstpublisher " swap$ "}" * * write$ }
  if$
}

FUNCTION {format.school}
{
  duplicate$ empty$
  { pop$ "{\bstwarn\bstschool~Hochschule}" write$ }
  { "{\bstschool " swap$ "}" * * write$ }
  if$
}

FUNCTION {format.series}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn\bstjournal~Buchserie}" write$
  }
  { "{\bstjournal " swap$ "}" * * write$ }
  if$
}

FUNCTION {format.title}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn\bsttitle~Titel}" write$
  }
  { "{\bsttitle " swap$ "}" * * write$ }
  if$
}

FUNCTION {format.volume}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn\bstvolume~Volume}" write$
  }
  { "{\bstvolume " swap$ "}" * * write$ }
  if$
}

FUNCTION {format.year}
{
  duplicate$ empty$
  {
    pop$ 
    "{\bstwarn\bstyear~(Jahr)}" write$
  }
  { "{\bstyear (" swap$ ")}" * * write$ }
  if$
}

FUNCTION {format.disstype}
{
  duplicate$ empty$
  {
    pop$ 
    "Dissertation" write$
  }
  { "{" swap$ "}" * * write$ }
  if$
}

FUNCTION {article}
{
  cite$ format.bibitem
  author format.author
  ": " write$
  title format.title
  ", " write$
  journal format.journal
  " " write$
  volume format.volume
  " " write$
  year format.year
  ", " write$
  numpages pages format.page
  doi url format.doiurl
  "." write$
  newline$
}

FUNCTION {book}
{
  cite$ format.bibitem
  author format.author
  ": " write$
  title format.title
  " " write$
  year format.year
  edition format.edition
  ", " write$
  publisher format.publisher
  ", " write$
  address format.address
  doi isbn format.doiisbn
  "." write$
  newline$
}

FUNCTION {incollection}
{
  cite$ format.bibitem
  author format.author
  ": " write$
  title format.title
  " \bblfrom~" write$
  booktitle format.booktitle
  ", " write$
  series format.series
  " " write$
  volume format.volume
  " " write$
  year format.year
  edition format.edition
  ", " write$
  numpages pages format.page
  ", " write$
  publisher format.publisher
  ", " write$
  address format.address
  "." write$
  newline$
}

FUNCTION {manual}
{
  cite$ format.bibitem
  author format.author
  ": " write$
  title format.title
  " " write$
  year format.year
  doi url format.doiurl
  "." write$
  newline$
}

FUNCTION {phdthesis}
{
  cite$ format.bibitem
  author format.author
  ": " write$
  title format.title
  ", " write$
  type format.disstype
  ", " write$
  school format.school
  " " write$
  year format.year
  doi isbn format.doiisbn
  "." write$
  newline$
}

FUNCTION {inproceedings}
{
  cite$ format.bibitem
  author format.author
  ": " write$
  title format.title
  doi url format.doiurl
  " " write$
  year format.year
  "." write$
  newline$
}

FUNCTION {patent}
{
  cite$ format.bibitem
  author format.author
  ": " write$
  title format.title
  ", Patent" write$
  doi url format.doiurl
  " " write$
  year format.year
  "." write$
  newline$
}

FUNCTION {misc}
{
  cite$ format.bibitem
  author format.author
  ": " write$
  title format.title
  doi url format.doiurl
  " " write$
  year format.year
  "." write$
  newline$
}

FUNCTION {standard}
{
  cite$ format.bibitem
  title format.title
  doi url format.doiurl
  "." write$
  newline$
}

FUNCTION {begin.bib}
{
  "\begin{thebibliography}{99}" write$ newline$
}
FUNCTION {end.bib}
{
  newline$
  "\end{thebibliography}" write$ newline$
}

READ
EXECUTE {begin.bib}
ITERATE {call.type$}
EXECUTE {end.bib}
