# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import marshal

import FeedNim
import ../src/FeedNim/jsonfeed

test "Read Valid JsonFeed":
    let feed = "./tests/test_jsonfeed.json".loadJsonFeed()

    check feed.version == "https://jsonfeed.org/version/1"
    check feed.title == "Bloggs's Planes Trains and Automobiles"
    check feed.home_page_url == "http://joe.bloggs"
    check feed.feed_url == "http://joe.bloggs/feed.json"
    check feed.description == "About Trains, Planes, and Automobiles."
    check feed.next_url == "http://joe.bloggs/feed.json/02"
    check feed.icon == "http://joe.bloggs/mug.jpg"
    check feed.favicon == "http://joe.bloggs/little_mug.jpg"
    check feed.author.name == "Joe Bloggs"
    check feed.author.url == "http://joe.bloggs"
    check feed.author.avatar == "http://joe.bloggs/mug.jpg"
    check feed.expired == false

    check feed.items[0].title == "Aeroplanes not Airplanes"
    check feed.items[0].id == "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a"
    check feed.items[0].content_html == "<p><i>Aero</i>- not air-, fools!</p>"
    check feed.items[0].url == "http://joe.bloggs/01-item"
    check feed.items[0].summary == "Americans wrong!"
    check feed.items[0].external_url == "http://american-airplanes.awesome"
    check feed.items[0].attachments[0].url == "http://learntowordgood.com/aeroplane"
    check feed.items[0].attachments[0].mime_type == "audio/mpeg"
    check feed.items[0].attachments[0].title == "Learn How to say Aeroplane"
    check feed.items[0].attachments[0].size_in_bytes == 6000
    check feed.items[0].attachments[0].duration_in_seconds == 5
    check feed.items[0].date_published == "2010-02-07T14:04:00-04:00"

    check feed.items[1].id == "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6d"
    check feed.items[1].author.name == "Jane Bloggs"
    check feed.items[1].image == "http://joe.bloggs/images/big-train.jpg"
    check feed.items[1].banner_image == "http://joe.bloggs/images/big-train-banner.jpg"
    check feed.items[1].content_text == "Trains!"
    check feed.items[1].url == "http://joe.bloggs/02-item"
    check feed.items[1].date_published == "2010-02-07T14:04:00-05:00"
    check feed.items[1].tags[0] == "trains"
    check feed.items[1].tags[1] == "photos"

test "Fetch JsonFeed from JsonFeed.org":
    let feed = getJsonFeed("https://jsonfeed.org/feed.json")
    check feed.title != ""
    check feed.home_page_url == "https://www.jsonfeed.org/"
    check feed.items[0].title == "JSON Feed version 1.1"
    check feed.items[0].date_published != ""
    check feed.items[0].id != ""
