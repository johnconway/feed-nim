# Nim Atom Syndication Format module

# Written by John Conway
# Released under the MIT open source license.

import httpclient
import strutils
import sequtils
import xmlparser
import xmltree
import streams
import sugar

type
    Atom* = object
        author: AtomAuthor          # Sugar, not in Atom spec. Returns the first author.
        id*: string                 # Required Atom field
        title*: string              # Required Atom field
        updated*: string            # Required Atom field
        authors*: seq[AtomAuthor]   # Pleuralised because the Atom spec allows more than one
        categories*: seq[string]
        contributors*: seq[AtomAuthor]
        generator*: string
        icon*: string
        link*: AtomLink
        logo*: string
        rights*: string
        subtitle*: string
        entrys*: seq[AtomEntry]

    AtomAuthor* = object
        name*: string               # Required Atom field
        uri*: string
        email*: string

    AtomLink* = object
        href*: string
        rel*: string
        linktype*: string
        hreflang*: string
        title*: string
        length*: string

    AtomEntry* = object
        id*: string                 # Required Atom field
        title*: string              # Required Atom field
        updated*: string            # Required Atom field
        author: AtomAuthor          # Sugar, not in Atom spec. Returns the first author.
        authors*: seq[AtomAuthor]   # Pleuralised because the Atom spec allows more than one
        categories*: seq[string]
        content*: string
        contentSrc*: string
        contentType*: string
        contributors*: seq[AtomAuthor]
        link*: AtomLink
        published*: string
        rights*: string
        source*: AtomSource
        summary*: string

    AtomSource* = object
        author: AtomAuthor          # Sugar, not in Atom spec. Returns the first author.
        authors: seq[AtomAuthor]
        categories*: seq[string]
        contributors*: seq[AtomAuthor]
        generator*: string
        icon*: string
        id*: string
        link*: AtomLink
        logo*: string
        rights*: string
        subtitle*: string
        title*: string
        updated*: string

proc parseAuthors ( node: XmlNode, mode="author") : seq[AtomAuthor] =
    var authors:seq[AtomAuthor]
    if node.child(mode) != nil:
        for athr_node in node.findAll(mode):
            var author: AtomAuthor = AtomAuthor()
            author.name = athr_node.child("name").innerText
            if athr_node.child("uri") != nil: author.uri = athr_node.child("uri").innerText
            if athr_node.child("email") != nil: author.email = athr_node.child("email").innerText
            authors.add(author)

    return authors

proc parseLink ( node: XmlNode ): AtomLink =
    var link: AtomLink = AtomLink()
    if node.attrs != nil:
        if node.attr("href") != "": link.href = node.attr("href")
        if node.attr("rel") != "": link.rel = node.attr("rel")
        if node.attr("type") != "": link.linktype = node.attr("type")
        if node.attr("hreflang") != "": link.rel = node.attr("hreflang")
        if node.attr("title") != "": link.rel = node.attr("title")
        if node.attr("length") != "": link.rel = node.attr("length")

    return link

proc parseEntry( node: XmlNode) : AtomEntry =
    var entry: AtomEntry = AtomEntry()

    # Fill the required fields
    entry.id = node.child("id").innerText
    entry.title = node.child("title").innerText
    entry.updated = node.child("updated").innerText

    # Fill the optinal fields
    entry.authors = node.parseAuthors()

    if node.child("category") != nil:
        entry.categories = map(node.findAll("category"), (x: XmlNode) -> string => x.innerText)

    if node.child("content") != nil:
        entry.content = node.child("content").innerText
        if node.attrs != nil:
            if node.attr("type") != "": entry.contentType = node.attr("type")
            if node.attr("src") != "": entry.contentSrc = node.attr("src")

    if node.child("contributor") != nil:
        entry.contributors = node.parseAuthors(mode="contributor")

    if node.child("link") != nil: entry.link = node.child("link").parseLink()

    if node.child("published") != nil: entry.published = node.child("published").innerText

    if node.child("rights") != nil: entry.rights = node.child("rights").innerText

    if node.child("source") != nil:
        let source = node.child("source")
        if node.child("author") != nil: entry.source.authors = source.parseAuthors()
        if node.child("category") != nil: entry.source.categories = map(source.findAll("category"), (x: XmlNode) -> string => x.innerText)
        if node.child("contributor") != nil: entry.source.contributors = source.parseAuthors(mode="contributor")
        if source.child("generator") != nil: entry.source.generator = source.child("generator").innerText
        if source.child("icon") != nil: entry.source.generator = source.child("icon").innerText
        if source.child("id") != nil: entry.source.id = source.child("id").innerText
        if source.child("link") != nil: entry.source.link = parseLink( source )
        if source.child("logo") != nil: entry.source.logo = source.child("logo").innerText
        if source.child("rights") != nil: entry.source.rights = source.child("rights").innerText
        if source.child("subtitle") != nil: entry.source.subtitle = source.child("subtitle").innerText
        if source.child("title") != nil: entry.source.title = source.child("title").innerText
        if source.child("updated") != nil: entry.source.updated = source.child("updated").innerText

    if node.child("summary") != nil: entry.summary = node.child("summary").innerText

    # SUGAR an easy way to access an author
    if entry.authors.len() > 0:
        entry.author = entry.authors[0]
    else:
        entry.author = AtomAuthor()

    return entry

proc parseAtom*(data: string): Atom =
    ## Parses the Atom from the given string.

    # Parse into XML.
    let node: XmlNode = parseXML(newStringStream(data))

    # Create the return object.
    var atom: Atom = Atom()

    # Fill in the required fields
    atom.id = node.child("id").innerText
    atom.title = node.child("title").innerText
    atom.updated = node.child("updated").innerText

    # Fill in the optional fields
    if node.child("author") != nil: atom.authors = node.parseAuthors()

    if node.child("category") != nil:
        atom.categories = map(node.findAll("category"), (x: XmlNode) -> string => x.innerText)

    if node.child("contributor") != nil: atom.contributors = node.parseAuthors(mode="contributor")

    if node.child("generator") != nil: atom.generator = node.child("generator").innerText

    if node.child("icon") != nil: atom.icon = node.child("icon").innerText

    if node.child("link") != nil: atom.link = node.child("link").parseLink()

    if node.child("logo") != nil: atom.logo = node.child("logo").innerText

    if node.child("rights") != nil: atom.rights = node.child("rights").innerText

    if node.child("subtitle") != nil: atom.subtitle = node.child("subtitle").innerText

    if atom.authors.len() > 0:
        atom.author = atom.authors[0]
    else:
        atom.author = AtomAuthor()

    # If there are no entrys:
    if node.child("entry") == nil:
        atom.entrys = @[]
        return atom

    # Otherwise, add the entrys.
    if node.child("entry") != nil:
        atom.entrys = map( node.findAll("entry"), parseEntry )

    # Return the Atom data.
    return atom


