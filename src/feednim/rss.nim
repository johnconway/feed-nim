# Nim RSS (Really Simple Syndication) module

# Orginally written by Adam Chesak.
# Rewritten by John Conway

# Released under the MIT open source license.

import httpclient
import strutils
import sequtils
import xmlparser
import xmltree
import streams
import sugar

type
    RSS* = object
        title*: string
        link*: string
        description*: string
        language*: string
        copyright*: string
        managingEditor*: string
        webMaster*: string
        pubDate*: string
        lastBuildDate*: string
        categories*: seq[RSSCategory]
        generator*: string
        docs*: string
        cloud*: RSSCloud
        ttl*: int
        image*: RSSImage
        rating*: string
        textInput*: RSSTextInput
        skipHours*: seq[int]
        skipDays*: seq[string]
        items*: seq[RSSItem]

    RSSText = ref object of RootObj
        text*: string

    RSSCategory = ref object of RSSText
        domain*: string

    RSSEnclosure* = object
        url*: string
        length*: string
        enclosureType*: string

    RSSCloud* = object
        domain*: string
        port*: string
        path*: string
        registerProcedure*: string
        protocol*: string

    RSSImage* = object
        url*: string
        title*: string
        link*: string
        width*: string
        height*: string
        description*: string

    RSSTextInput* = object
        title*: string
        description*: string
        name*: string
        link*: string

    RSSSource* = ref object of RSSText
        url*: string

    RSSItem* = object
        title*: string
        link*: string
        description*: string
        author*: string
        categories*: seq[RSSCategory]
        comments*: string
        enclosure*: RSSEnclosure
        guid*: string
        pubDate*: string
        source*: RSSSource

converter rssToString*(obj: RSSText): string =
    return obj.text

func parseCategories( node: XmlNode ): seq[RSSCategory] =
    var categories:seq[RSSCategory]
    for cat_node in node.findAll("category"):
        var category: RSSCategory = RSSCategory()
        if cat_node.attr("domain") != "": category.domain = cat_node.attr("domain")
        category.text = cat_node.innerText
        categories.add(category)
    if categories.len == 0: return @[]
    return categories


func parseItem( node: XmlNode) : RSSItem =
    var item: RSSItem = RSSItem()
    if node.child("title") != nil: item.title = node.child("title").innerText

    if node.child("link") != nil: item.link = node.child("link").innerText

    if node.child("description") != nil: item.description = node.child("description").innerText

    for key in @["author", "dc:creator"]:
        if node.child(key) != nil: item.author = node.child(key).innerText

    if node.child("category") != nil: item.categories = node.parseCategories()

    if node.child("comments") != nil: item.comments = node.child("comments").innerText

    if node.child("enclosure") != nil:
        var encl: RSSEnclosure = RSSEnclosure()
        encl.url = node.child("enclosure").attr("url")
        encl.length = node.child("enclosure").attr("length")
        encl.enclosureType = node.child("enclosure").attr("type")
        item.enclosure = encl

    if node.child("guid") != nil: item.guid = node.child("guid").innerText

    if node.child("pubDate") != nil: item.pubDate = node.child("pubDate").innerText

    if node.child("source") != nil:
        item.source = RSSSource()
        item.source.url = node.child("source").attr("url")
        item.source.text = node.child("source").innerText

    return item

proc parseRSS*(data: string): RSS =
    ## Parses the RSS from the given string.

    # Parse into XML.
    let root: XmlNode = parseXML(newStringStream(data))
    let channel: XmlNode = root.child("channel")

    # Create the return object.
    var rss: RSS = RSS()

    # Fill the required fields.
    rss.title = channel.child("title").innerText
    rss.link = channel.child("link").innerText
    rss.description = channel.child("description").innerText

    # Fill the optional fields.
    for key in @["language", "dc:language"]:
        if channel.child(key) != nil:
            rss.language = channel.child(key).innerText

    if channel.child("copyright") != nil: rss.copyright = channel.child("copyright").innerText

    if channel.child("managingEditor") != nil: rss.managingEditor = channel.child("managingEditor").innerText

    if channel.child("webMaster") != nil: rss.webMaster = channel.child("webMaster").innerText

    for key in @["pubDate", "dc:date"]:
        if channel.child(key) != nil:
            rss.pubDate = channel.child(key).innerText

    if channel.child("lastBuildDate") != nil: rss.lastBuildDate  = channel.child("lastBuildDate").innerText

    if channel.child("category") != nil: rss.categories = channel.parseCategories()

    for key in @["generator", "dc:publisher"]:
        if channel.child(key) != nil: rss.generator = channel.child(key).innerText

    if channel.child("docs") != nil: rss.docs = channel.child("docs").innerText

    if channel.child("cloud") != nil:
        var cloud: RSSCloud = RSSCloud()
        cloud.domain = channel.child("cloud").attr("domain")
        cloud.port = channel.child("cloud").attr("port")
        cloud.path = channel.child("cloud").attr("path")
        cloud.registerProcedure = channel.child("cloud").attr("registerProcedure")
        cloud.protocol = channel.child("cloud").attr("protocol")
        rss.cloud = cloud

    if channel.child("ttl") != nil: rss.ttl = channel.child("ttl").innerText.parseInt()

    if channel.child("image") != nil:
        var image: RSSImage = RSSImage()
        let img = channel.child("image")
        if img.child("url") != nil:  image.url = img.child("url").innerText
        if img.attr("rdf:resource") != "" and img.attr("rdf:resource") != "": image.url = img.attr("rdf:resource")
        if img.child("title") != nil: image.title = img.child("title").innerText
        if img.child("link") != nil:  image.link = img.child("link").innerText
        if img.child("width") != nil: image.width = img.child("width").innerText
        if img.child("height") != nil: image.height = img.child("height").innerText
        if img.child("description") != nil: image.description = img.child("description").innerText
        rss.image = image

    if channel.child("rating") != nil: rss.rating = channel.child("rating").innerText

    if channel.child("textInput") != nil:
        var textInput: RSSTextInput = RSSTextInput()
        textInput.title = channel.child("textInput").child("title").innerText
        textInput.description = channel.child("textInput").child("description").innerText
        textInput.name = channel.child("textInput").child("name").innerText
        textInput.link = channel.child("textInput").child("link").innerText
        rss.textInput = textInput

    if channel.child("skipHours") != nil:
        rss.skipHours = map(channel.findAll("hour"), (x: XmlNode) -> int => x.innerText.parseInt() )
    if channel.child("skipDays") != nil:
        rss.skipDays = map(channel.findAll("day"), (x: XmlNode) -> string => x.innerText)

    # If there are no items:
    if channel.child("item") == nil and root.child("item") == nil:
        rss.items = @[]
        return rss

    # Otherwise, add the items.
    if channel.child("item") != nil: rss.items = map(channel.findAll("item"), parseItem)
    else: rss.items = map(root.findAll("item"), parseItem)

    # Return the RSS data.
    return rss