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
        author: AtomAuthor          #Sugar, not in Atom spec. Returns the first author.
        authors*: seq[AtomAuthor]   #Pleuralised because the Atom spec allows more than one
        category*: seq[string]
        generator*: string
        icon*: string
        id*: string
        link*: AtomLink
        logo*: string
        rights*: string
        subtitle*: string
        title*: string
        updated*: string
        entrys*: seq[AtomEntry]

    AtomAuthor* = object
        name*: string
        url*: string
        email*: string

    AtomImage* = object
        url*: string
        title*: string
        link*: string
        width*: string
        height*: string
        description*: string

    AtomLink* = object
        href*: string
        rel*: string
        linktype*: string
        hreflang*: string
        title*: string
        length*: string

    AtomEntry* = object
        author: AtomAuthor         #Sugar, not in Atom spec. Returns the first author.
        authors*: seq[AtomAuthor]  #Pleuralised because the Atom spec allows more than one
        category*: seq[string]
        content*: string
        contentSrc*: string
        contentType*: string
        id*: string
        link*: AtomLink
        published*: string
        rights*: string
        source*: string
        summary*: string
        title*: string
        updated*: string


proc parseEntry( node: XmlNode) : AtomEntry =
    var entry: AtomEntry = AtomEntry()

    if node.child("author") != nil:
        for con_node in node.findAll("author"):
            var author: AtomAuthor = AtomAuthor()
            if con_node.child("name") != nil: author.name = con_node.child("name").innerText
            if con_node.child("url") != nil: author.url = con_node.child("url").innerText
            if con_node.child("email") != nil: author.email = con_node.child("email").innerText
            entry.authors.add(author)

    if node.child("category") != nil:
        entry.category = map(node.findAll("category"), (x: XmlNode) -> string => x.innerText)

    if node.child("content") != nil:
        entry.content = node.child("content").innerText
        if node.attrs != nil:
            if node.attr("type") != "": entry.contentType = node.attr("type")
            if node.attr("src") != "": entry.contentSrc = node.attr("src")

    if node.child("contributer") != nil:
        for con_node in node.findAll("author"):
            var author: AtomAuthor = AtomAuthor()
            if con_node.child("name") != nil: author.name = con_node.child("name").innerText
            if con_node.child("url") != nil: author.url = con_node.child("url").innerText
            if con_node.child("email") != nil: author.email = con_node.child("email").innerText
            entry.authors.add(author)

    if node.child("id") != nil: entry.id = node.child("id").innerText

    if node.child("link") != nil:
        if node.attrs != nil:
            if node.attr("href") != "": entry.link.href = node.attr("href")
            if node.attr("rel") != "": entry.link.rel = node.attr("rel")
            if node.attr("type") != "": entry.link.linktype = node.attr("type")
            if node.attr("hreflang") != "": entry.link.rel = node.attr("hreflang")
            if node.attr("title") != "": entry.link.rel = node.attr("title")
            if node.attr("length") != "": entry.link.rel = node.attr("length")

    if node.child("published") != nil: entry.published = node.child("published").innerText

    if node.child("rights") != nil: entry.rights = node.child("rights").innerText

    if node.child("summary") != nil: entry.summary = node.child("summary").innerText

    if node.child("title") != nil: entry.title = node.child("title").innerText

    if node.child("updated") != nil: entry.updated = node.child("updated").innerText

    # SUGAR

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

    if node.child("author") != nil:
        for con_node in node.findAll("author"):
            var author: AtomAuthor = AtomAuthor()
            if con_node.child("name") != nil: author.name = con_node.child("name").innerText
            if con_node.child("url") != nil: author.url = con_node.child("url").innerText
            if con_node.child("email") != nil: author.email = con_node.child("email").innerText
            atom.authors.add(author)

    if node.child("category") != nil:
        atom.category = map(node.findAll("category"), (x: XmlNode) -> string => x.innerText)

    if node.child("generator") != nil: atom.generator = node.child("generator").innerText

    if node.child("icon") != nil: atom.icon = node.child("icon").innerText

    if node.child("id") != nil: atom.id = node.child("id").innerText

    if node.child("link") != nil:
        if node.attrs != nil:
            if node.attr("href") != "": atom.link.href = node.attr("href")
            if node.attr("rel") != "": atom.link.rel = node.attr("rel")
            if node.attr("type") != "": atom.link.linktype = node.attr("type")
            if node.attr("hreflang") != "": atom.link.rel = node.attr("hreflang")
            if node.attr("title") != "": atom.link.rel = node.attr("title")
            if node.attr("length") != "": atom.link.rel = node.attr("length")

    if node.child("logo") != nil: atom.logo = node.child("logo").innerText

    if node.child("rights") != nil: atom.rights = node.child("rights").innerText

    if node.child("title") != nil: atom.title = node.child("title").innerText

    if node.child("subtitle") != nil: atom.subtitle = node.child("subtitle").innerText

    if node.child("updated") != nil: atom.updated = node.child("updated").innerText

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


