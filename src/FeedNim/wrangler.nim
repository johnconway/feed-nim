import
    strUtils

import
    atom,
    jsonfeed,
    rss

type
    Feed = ref object of JSONFeed

func wrangleAtomItems( xml_feed:( Atom | Rss ) ):seq[JsonFeedItem] =
    var items: seq[JsonFeedItem] = @[]
    for atom_item in xml_feed.entries:

        var item = JsonFeedItem()

        item.author.name = atom_item.author.name
        item.author.url = atom_item.author.uri
        item.title = atom_item.title

        if atom_item.content == "":
            item.content_text = atom_item.summary
        else:
            if atom_item.content.textType == "html" or atom_item.content.textType == "xhtml":
                item.content_html =  atom_item.content
            else: item.content_text =  atom_item.content

        item.date_published = atom_item.published
        item.date_modified = atom_item.updated

        for category in atom_item.categories:
            item.tags.add( category.term )

        item.attachments[0].url = atom_item.link.href
        item.attachments[0].mime_type = atom_item.link.linktype # WONT WORK!
        item.attachments[0].title = atom_item.link.title
        item.attachments[0].size_in_bytes = atom_item.link.length

        items.add( item )

    return items

func wrangleAtom( xml_feed: Atom ): Feed =
    var feed = Feed()

    feed.author.name = xml_feed.author.name
    feed.author.url = xml_feed.author.uri
    feed.author.avatar = xml_feed.icon          # Munged!
    feed.title =  xml_feed.title
    feed.home_page_url = xml_feed.link.href    # MAYBE NOT
    feed.feed_url =  xml_feed.link.href
    feed.description = xml_feed.subtitle
    feed.icon =  xml_feed.icon
    feed.favicon =  xml_feed.icon
    feed.items =  xml_feed.wrangleAtomItems()

    return feed

func wrangleRss( xml_feed: Rss ): Feed =
    var feed = Feed()

    func rssAuthor( feild:string ): JSONFeedAuthor =
        var author = JSONFeedAuthor()
        var name = feild.split(" ")[1]                  # RSS author feilds look like this remember:
        if name.len > 3:                                # <element>joe@bloggs.com (Joe Bloggs)</element>
            author.name = name.substr[1 .. name.len()-2]
        return author

    feed.author = rssAuthor( xml_feed.managingEditor )  # Munged!
    feed.title =  xml_feed.title
    feed.home_page_url = xml_feed.link.link             # MAYBE NOT
    feed.feed_url =  xml_feed.link.href
    feed.description = xml_feed.description
    feed.icon =  xml_feed.image.url                     # Munged!
    feed.items =  xml_feed.wrangleAtomItems()

    return feed


proc wrangle*( xml_feed:( Atom | Rss ) ):Feed =
    if xml_feed.kind == Atom:
        return wrangleAtom( xml_feed )
    elif xml_feed.kind == Rss:
        return wrangleRss( xml_feed )