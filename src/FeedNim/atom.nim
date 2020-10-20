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
    AtomCommon = ref object of RootObj  # These properties aren't'gathered
        xmlbase*: string
        xmllang*: string

    Atom* = ref object of AtomCommon
        author*: AtomAuthor             # Sugar, not in Atom spec. Refers to the first author.
        id*: string                     # Required Atom field
        title*: AtomText                # Required Atom field
        updated*: string                # Required Atom field
        authors*: seq[AtomAuthor]       # Pleuralised because the Atom spec allows more than one
        categories*: seq[AtomCategory]
        contributors*: seq[AtomAuthor]
        generator*: AtomGenerator
        icon*: string
        link*: AtomLink
        logo*: string
        rights*: string
        subtitle*: AtomText
        entries*: seq[AtomEntry]

    AtomText* = ref object of AtomCommon
        textType*: string
        text*: string

    AtomGenerator* = ref object of AtomText
        uri*: string

    AtomAuthor* = ref object of AtomCommon
        name*: string                    # Required Atom field
        uri*: string
        email*: string

    AtomCategory* = ref object of AtomCommon
        term*: string
        label*: string
        scheme*: string

    AtomContent* = ref object of AtomText
        src*: string

    AtomLink* = ref object of AtomCommon
        href*: string
        rel*: string
        linktype*: string
        hreflang*: string
        title*: string
        length*: int

    AtomEntry* = ref object of AtomCommon
        id*: string                     # Required Atom field
        title*: AtomText                # Required Atom field
        updated*: string                # Required Atom field
        author*: AtomAuthor             # Sugar, not in Atom spec. Returns the first author.
        authors*: seq[AtomAuthor]       # Pleuralised because the Atom spec allows more than one
        categories*: seq[AtomCategory]
        content*: AtomContent
        contributors*: seq[AtomAuthor]
        link*: AtomLink
        published*: string
        rights*: string
        source*: AtomSource
        summary*: string

    AtomSource* = ref object of AtomCommon
        author*: AtomAuthor          # Sugar, not in Atom spec. Returns the first author.
        authors*: seq[AtomAuthor]
        categories*: seq[AtomCategory]
        contributors*: seq[AtomAuthor]
        generator*: AtomGenerator
        icon*: string
        id*: string
        link*: AtomLink
        logo*: string
        rights*: string
        subtitle*: string
        title*: string
        updated*: string


# Promotes text node to the top of an AtomText object if caller expects a string
converter toString*(obj: AtomText): string =
    return obj.text


func parseAuthors ( node: XmlNode, mode="author" ) : seq[AtomAuthor] =
    var authors:seq[AtomAuthor]
    if node.child(mode) != nil:
        for athr_node in node.findAll(mode):
            var author: AtomAuthor = AtomAuthor()
            author.name = athr_node.child("name").innerText
            if athr_node.child("uri") != nil: author.uri = athr_node.child("uri").innerText
            if athr_node.child("email") != nil: author.email = athr_node.child("email").innerText
            authors.add(author)
    if authors.len == 0: return @[]
    return authors

func parseCategories ( node: XmlNode ) : seq[AtomCategory] =
    var categories:seq[AtomCategory]
    if node.child("category") != nil:
        for cat_node in node.findAll("category"):
            var category: AtomCategory = AtomCategory()
            if cat_node.attr("term") != "": category.term = cat_node.attr("term")
            if cat_node.attr("label") != "": category.label = cat_node.attr("label")
            if cat_node.attr("scheme") != "": category.scheme = cat_node.attr("scheme")

            categories.add(category)

    if categories.len == 0: return @[]
    return categories

func parseGenerator ( node: XmlNode ): AtomGenerator =
    var generator = AtomGenerator()
    let generator_node = node.child("generator")
    generator.text = generator_node.innerText
    if node.attrs != nil: generator.uri = generator_node.attr("uri")
    return generator

func parseLink ( node: XmlNode ): AtomLink =
    var link: AtomLink = AtomLink()
    if node.attrs != nil:
        if node.attr("href") != "": link.href = node.attr("href")
        if node.attr("rel") != "": link.rel = node.attr("rel")
        if node.attr("type") != "": link.linktype = node.attr("type")
        if node.attr("hreflang") != "": link.hreflang = node.attr("hreflang")
        if node.attr("title") != "": link.title = node.attr("title")
        if node.attr("length") != "": link.length = node.attr("length").parseInt()
    return link

func parseText ( node: XmlNode ): string =
    if node.len == 0:
        return $node
    else:
        var content = ""
        for item in node.items:
            case item.kind
            of xnText: content.add(item.innerText)
            of xnCData: content.add(item.text)
            else: discard
        return content

func parseEntry( node: XmlNode ) : AtomEntry =
    var entry: AtomEntry = AtomEntry()

    # Fill the required fields
    entry.id = node.child("id").innerText
    entry.title = AtomText()
    if node.attrs != nil: entry.title.textType = node.attr("type")
    entry.title.text = node.child("title").parseText()
    entry.updated = node.child("updated").innerText

    # Fill the optinal fields
    entry.authors = node.parseAuthors()

    if node.child("category") != nil: entry.categories = node.parseCategories()

    if node.child("content") != nil:
        let content_node = node.child("content")
        entry.content = AtomContent()
        entry.content.text = content_node.innerText

        if content_node.attrs != nil:
            entry.content.src = content_node.attr("src")
            entry.content.texttype = content_node.attr("type")
            entry.content.text = content_node.parseText()

    if node.child("contributor") != nil:
        entry.contributors = node.parseAuthors(mode="contributor")

    if node.child("link") != nil: entry.link = node.child("link").parseLink()

    if node.child("published") != nil: entry.published = node.child("published").innerText

    if node.child("rights") != nil: entry.rights = node.child("rights").innerText

    if node.child("source") != nil:
        let source = node.child("source")
        entry.source = AtomSource()
        if source.child("author") != nil: entry.source.authors = source.parseAuthors()
        if source.child("category") != nil: entry.source.categories = source.parseCategories()
        if source.child("contributor") != nil: entry.source.contributors = source.parseAuthors(mode="contributor")
        if source.child("generator") != nil: entry.source.generator = source.parseGenerator()
        if source.child("icon") != nil: entry.source.icon = source.child("icon").innerText
        if source.child("id") != nil: entry.source.id = source.child("id").innerText
        if source.child("link") != nil: entry.source.link = source.child("link").parseLink()
        if source.child("logo") != nil: entry.source.logo = source.child("logo").innerText
        if source.child("rights") != nil: entry.source.rights = source.child("rights").innerText
        if source.child("subtitle") != nil: entry.source.subtitle = source.child("subtitle").parseText()
        if source.child("title") != nil: entry.source.title = source.child("title").parseText()
        if source.child("updated") != nil: entry.source.updated = source.child("updated").innerText

        entry.source.author = entry.source.authors[0]

    if node.child("summary") != nil: entry.summary = node.child("summary").parseText()

    # SUGAR an easy way to access an author
    if entry.authors.len() > 0:
        entry.author = entry.authors[0]
    else:
        entry.author = AtomAuthor()

    return entry

proc parseAtom* ( data: string ): Atom =
    ## Parses the Atom from the given string.

    # Parse into XML.
    let node: XmlNode = parseXML(newStringStream(data))

    # Create the return object.
    var atom: Atom = Atom()

    # Fill in the required fields
    atom.id = node.child("id").innerText

    atom.title = AtomText()
    atom.title.text = node.child("title").parseText()
    atom.updated = node.child("updated").innerText

    # Fill in the optional fields
    if node.child("author") != nil: atom.authors = node.parseAuthors()

    if node.child("category") != nil: atom.categories = node.parseCategories()

    if node.child("contributor") != nil: atom.contributors = node.parseAuthors(mode="contributor")

    if node.child("generator") != nil: atom.generator = node.parseGenerator()

    if node.child("icon") != nil: atom.icon = node.child("icon").innerText

    if node.child("link") != nil: atom.link = node.child("link").parseLink()

    if node.child("logo") != nil: atom.logo = node.child("logo").innerText

    if node.child("rights") != nil: atom.rights = node.child("rights").innerText

    if node.child("subtitle") != nil:
        atom.subtitle = AtomText()
        atom.subtitle.text = node.child("subtitle").innerText

    if atom.authors.len() > 0:
        atom.author = atom.authors[0]
    else:
        atom.author = AtomAuthor()


    if node.child("entry") == nil:    # If there are no entries:
        atom.entries = @[]
        return atom

    if node.child("entry") != nil:    # Otherwise, add the entries.
        atom.entries = map( node.findAll("entry"), parseEntry )

    # Return the Atom data.
    return atom
