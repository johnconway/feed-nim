<img src="logo.png" align="right" >

# Feed-Nim
A feed parsing module for [Nim](https://nim-lang.org), which parses RSS, Atom, and JSONfeed syndication formats. This has been substantially re-written and expanded from [Nim-RSS](https://github.com/achesak/nim-rss).

It has not been tested in the wild, and is mostly written by an inexperienced dope who barely understands Nim. It will probably break. Use at your own risk.

## Intallation

<code>nimble install feednim</code>

## Usage

<code>loadAtom(filename: string): Atom</code> Loads the Atom from the given _filename_<br>
<code>getAtom(url: string): Atom</code> Gets the Atom from the specified _url_<br>

<code>loadRSS(filename: string): RSS</code> Loads the RSS from the given _filename_<br>
<code>getRSS(url: string): RSS</code> Gets the RSS from the specified _url_<br>

<code>loadJsonFeed(filename: string): JSONfeed</code> Loads the JSONFeed from the given _filename_<br>
<code>getJsonFeed(url: string): JSONfeed</code> Gets the JSONfeed from the specified _url_<br>

### Accessors

Feed-Nim will give a data tree which looks very similar to the data tree of the feed, and the nodes will mostly have the same names. For example an RSS feed 'title' node will be:

`let feed = loadRSS("my_feed.xml")`<br>
`feed.title # Will hold the title`<br>
<sub>(Bet you didn't see that coming!)</sub>

There are some exeptions, elements that can be repeated according to the specifications are pluralised as follows:

*RSS*: `<item>` is accessed as `.items[index]`<br>
*RSS and Atom*: `<category>` is accessed as `.categories[index]`<br>
*Atom*: `<entry>` is accessed as `.entries[index]`<br>
*Atom*: `<author>` is accessed as `.authors[index]` (if you call just `.author`, you will return the first author of the sequence)<br>
*Atom*: `<contributor>` is accessed as `.contributors[index]` (again, calling this singular will return the first in the sequence)

Some Atom nodes have the Nim keyword 'type' as an attribute. These have been changed as follows:

`<link type="">` type is accesed with `.linkType`<br>
`<content type="">`, `<title type="">`, and `<subtitle type="">` types are accesed with `.textType`

### Limitations

Feed-Nim does not implement the full specification of any of the feed types. Notably, in Atom, the common attributes 'xml:lang' and 'xml:base' are not implemented. All three formats are extensible, but there is no support for this (extensions _should_ be ignored by Feed-Nim, but this is untested).
