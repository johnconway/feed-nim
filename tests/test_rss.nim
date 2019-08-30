# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import marshal

import FeedNim
import ../src/FeedNim/rss

test "Read Valid Rss Feed":
    let feed = "./tests/test_rss.xml".loadRss()

    check feed.title == "Bloggs's Planes Trains and Automobiles"

    check feed.link == "http://joe.bloggs"

    check feed.description == "About Trains, Planes, and Automobiles."

    check feed.language == "en-uk"
    check feed.copyright == "Copyright Joe and Jane Bloggs"
    check feed.managingEditor == "mail@joe.bloggs (Joe Bloggs)"
    check feed.webMaster == "master@joe.bloggs (Joe Bloggs)"
    check feed.pubDate == "Sat, 07 Sep 2002 00:00:01 GMT"
    check feed.lastBuildDate == "Sat, 07 Sep 2002 00:00:01 GMT"

    var feed_categories_0:string = feed.categories[0]
    var feed_categories_1:string = feed.categories[1]
    var feed_categories_2:string = feed.categories[2]
    check feed.categories[0].domain == "http://awesomecategories.org"
    check feed_categories_0 == "Planes"
    check feed_categories_1 == "Trains"
    check feed_categories_2 == "Automobiles"

    check feed.generator == "Jester"
    check feed.docs == "http://blogs.law.harvard.edu/tech/rss"

    check feed.cloud.domain == "rpc.sys.com"
    check feed.cloud.port == "80"
    check feed.cloud.path == "/RPC2"
    check feed.cloud.registerProcedure == "pingMe"
    check feed.cloud.protocol == "soap"

    check feed.ttl == 60

    check feed.image.url == "http://joe.bloggs/mug.jpg"
    check feed.image.title == "Bloggs's Planes Trains and Automobiles"
    check feed.image.link == "http://joe.bloggs"

    check feed.rating == "AO"

    check feed.skipHours[0] == 0
    check feed.skipHours[1] == 1
    check feed.skipHours[2] == 2
    check feed.skipHours[3] == 3
    check feed.skipHours[4] == 4

    check feed.skipDays[0] == "Saturday"
    check feed.skipDays[1] == "Sunday"

    check feed.textInput.title == "Search"
    check feed.textInput.description == "Search for Trains!"
    check feed.textInput.name == "Search Term"
    check feed.textInput.link == "http://joe.bloggs/search.cgi"

    check feed.items[0].title == "Aeroplanes not Airplanes"
    check feed.items[0].link == "http://joe.bloggs/posts/1"
    check feed.items[0].pubDate == "Sat, 07 Sep 2002 00:00:01 GMT"
    check feed.items[0].description == "Aero- not air-, fools!"
    check feed.items[0].author == "jane@joe.bloggs (Jane Bloggs)"

    var feed_items_0_category_0:string = feed.items[0].categories[0]
    check feed.items[0].categories[0].domain == "http://awesomecategories.org"
    check feed_items_0_category_0 == "Words"

    check feed.items[0].comments == "http://joe.bloggs/posts/1/comments"
    check feed.items[0].enclosure.url == "http://www.scripting.com/mp3s/weatherReportSuite.mp3"
    check feed.items[0].enclosure.length == "12216320"
    check feed.items[0].enclosure.enclosureType == "audio/mpeg"
    check feed.items[0].guid == "http://joe.bloggs/posts/1"

    var feed_items_0_source:string = feed.items[0].source
    check feed.items[0].source.url == "http://dictionary.com"
    check feed_items_0_source == "The Dictionary"
