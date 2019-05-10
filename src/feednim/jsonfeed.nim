# Nim JSONFeed Syndication module

# Written by John Conway
# Released under the MIT open source license.

import strutils
import sequtils
import json
import streams
import sugar

type
    JSONFeed* = object
        author*: JSONFeedAuthor
        version*: string
        title*: string
        home_page_url*: string
        feed_url*: string
        description*: string
        next_url*: string
        icon*: string
        favicon*: string
        expired*: bool
        hubs*: seq[JSONFeedHub]
        items*: seq[JSONFeedItem]

    JSONFeedHub* = object
        hubType: string
        url: string

    JSONFeedAuthor* = object
        name*: string
        url*: string
        avatar*: string

    JSONFeedItem* = object
        author*: JSONFeedAuthor
        id*: string
        url*: string
        external_url*: string
        title*: string
        content_html*: string
        content_text*: string
        summary*: string
        image*: string
        banner_image*: string
        date_published*: string
        date_modified*: string
        tags*: seq[string]
        attachments*: seq[JSONFeedAttachment]

    JSONFeedAttachment* = object
        url*: string
        mime_type*: string
        title*: string
        size_in_bytes*: int
        duration_in_seconds*: int

proc parseItem( node: JsonNode) : JSONFeedItem =
    var item: JSONFeedItem = JSONFeedItem()

    if node.getOrDefault( "author" ) != nil:
        let author = node["author"]
        item.author.name = getStr( author.getOrDefault "name" )
        item.author.url = getStr( author.getOrDefault "url" )
        item.author.avatar = getStr( author.getOrDefault "avatar" )

    item.id = getStr( node.getOrDefault "id" )
    item.url = getStr( node.getOrDefault "url" )
    item.external_url = getStr( node.getOrDefault "external_url" )
    item.title = getStr( node.getOrDefault "title" )
    item.content_html = getStr( node.getOrDefault "content_html" )
    item.content_text = getStr( node.getOrDefault "content_text" )
    item.summary = getStr( node.getOrDefault "summary" )
    item.image = getStr( node.getOrDefault "image" )
    item.banner_image = getStr( node.getOrDefault "banner_image" )
    item.date_published = getStr( node.getOrDefault "date_published" )
    item.date_modified = getStr( node.getOrDefault "date_modified" )

    if node.getOrDefault( "tags" ) != nil:
        for tag in node["tags"]:
            item.tags.add( tag.to(string) )

    if node.getOrDefault( "attachments" ) != nil:
        for jattach in node["attachments"]:
            var attachment: JSONFeedAttachment = JSONFeedAttachment()
            attachment.url = getStr( jattach.getOrDefault "url" )
            attachment.mime_type = getStr( jattach.getOrDefault "mime_type" )
            attachment.title = getStr( jattach.getOrDefault "title" )
            attachment.size_in_bytes = getInt( jattach.getOrDefault "size_in_bytes" )
            attachment.duration_in_seconds = getInt( jattach.getOrDefault "duration_in_seconds" )

            item.attachments.add( attachment )

    return item

proc parseJSONFeed*(data: string): JSONFeed =
    let node = data.parseJson()
    var feed: JSONFeed = JSONFeed()

    if node.getOrDefault( "author" ) != nil:
        let author = node["author"]
        feed.author.name = getStr( author.getOrDefault "name" )
        feed.author.url = getStr( author.getOrDefault "url" )
        feed.author.avatar = getStr( author.getOrDefault "avatar" )

    feed.version = getStr( node.getOrDefault "version" )
    feed.title = getStr( node.getOrDefault "title" )
    feed.home_page_url = getStr( node.getOrDefault "home_page_url" )
    feed.feed_url = getStr( node.getOrDefault "feed_url" )
    feed.description = getStr( node.getOrDefault "description" )    # What is this?
    feed.next_url = getStr( node.getOrDefault "next_url" )
    feed.icon = getStr( node.getOrDefault "icon" )
    feed.favicon = getStr( node.getOrDefault "favicon" )

    if node.getOrDefault( "expired" ) != nil:
        feed.expired = node["expired"].getBool()

    if node.getOrDefault( "hubs" ) != nil:
        for jhub in node["hubs"]:
            var hub: JSONFeedHub = JSONFeedHub()
            hub.hubType = getStr( jhub.getOrDefault "url" )
            hub.url = getStr( jhub.getOrDefault "mime_type" )

            feed.hubs.add( hub )

    feed.items = @[]
    if node.getOrDefault( "items" ) != nil:
        for item in node["items"]:
           feed.items.add item.parseItem()


    return feed