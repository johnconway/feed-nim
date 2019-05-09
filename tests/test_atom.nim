# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import marshal

import feednim
import ../src/feednim/atom

test "Read Valid Atom Feed":
    let feed = "./tests/test_atom.xml".loadAtom()

    check feed.id == "urn:uuid:60a76c80-d399-11d9-b93C-0003939e0af6"
    check feed.title == "Bloggs's Planes Trains and Automobiles"
    check feed.updated == "2003-12-13T18:30:02Z"

    check feed.author.name == "Joe Bloggs"
    check feed.author.uri == "http://joe.bloggs"
    check feed.author.email == "mail@joe.bloggs"

    check feed.contributors[0].name == "Jane Bloggs"

    check feed.categories[0].term == "planes"
    check feed.categories[0].label == "Planes"
    check feed.categories[0].scheme == "http://awesomecategories.org"
    check feed.categories[1].term == "trains"
    check feed.categories[1].label == "Trains"
    check feed.categories[2].term == "automobiles"
    check feed.categories[2].label == "Automobiles"

    #check feed.generator.uri == "https://github.com/dom96/jester"
    check feed.generator == "Jester"

    check feed.icon == "http://joe.bloggs/mug,jpg"

    check feed.link.href == "http://joe.bloggs/atom"
    check feed.link.rel == "self"
    check feed.link.linktype == "application/xml+atom"
    check feed.link.hreflang == "en-GB"
    check feed.link.title == "Bloggs's Planes Trains and Automobiles"
    check feed.link.length == "1000000"

    check feed.logo == "http://joe.bloggs/logo.jpeg"
    check feed.rights == "Copyright Joe and Jane Bloggs"
    check feed.subtitle == "About Trains, Planes, and Automobiles."


    check feed.entries[0].id == "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a"
    check feed.entries[0].title == "Aeroplanes not Airplanes"
    check feed.entries[0].updated == "2003-12-13T18:30:02Z"
    check feed.entries[0].author.name == "Joe Bloggs"
    check feed.entries[0].author.uri == "http://joe.bloggs"
    check feed.entries[0].author.email == "mail@joe.bloggs"

    check feed.entries[0].categories[0].term == "words"
    check feed.entries[0].categories[0].label == "Words"
    check feed.entries[0].categories[0].scheme == "http://awesomecategories.org"

    var feed_0_content_textType = feed.entries[0].content.textType
    check feed_0_content_textType == "xhtml"
    var feed_0_content_text: string = feed.entries[0].content
    check feed_0_content_text == """<div xmlns="http://www.w3.org/1999/xhtml"><p><i>Aero</i>- not air-, fools!</p></div>"""

    check feed.entries[0].published == "2003-12-13T18:30:02Z"
    check feed.entries[0].rights == "Copyright Joe Bloggs"

    check feed.entries[0].source.id == "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6d"
    check feed.entries[0].source.title == "Aeroplane"
    check feed.entries[0].source.subtitle == "Aeroplanes"
    check feed.entries[0].source.updated == "1755-04-15T18:30:00Z"
    check feed.entries[0].source.author.name == "Samuel Johnson"
    check feed.entries[0].source.author.uri == "http://dictionary.com"
    check feed.entries[0].source.author.email == "sjohnson@dictionary.com"
    check feed.entries[0].source.categories[0].term == "planes"
    check feed.entries[0].source.categories[0].label == "Planes"
    check feed.entries[0].source.categories[0].scheme == "http://awesomecategories.org"
    check feed.entries[0].source.rights == "Copyright Samual Johnson"


    check feed.entries[1].id == "urn:uuid:1225c695-cfb8-4ebb-aaaa-80da344efa6a"
    check feed.entries[1].title == "Trains Are Good"
    check feed.entries[1].updated == "2003-12-13T18:30:02Z"
    check feed.entries[1].author.name == "Jane Bloggs"

    check feed.entries[1].categories[0].term == "trains"
    check feed.entries[1].categories[0].label == "Trains"
    check feed.entries[1].content.src == "http://trains.com"
    check feed.entries[1].link.href == "http://joe.bloggs/trains-full"
    check feed.entries[1].link.rel == "alternate"
    check feed.entries[1].link.linktype == "text/html"
    check feed.entries[1].link.hreflang == "en-GB"
    check feed.entries[1].link.title == "Trains!"
    check feed.entries[1].link.length == "1000000"
    check feed.entries[1].published == "2003-12-13T18:20:02Z"
    check feed.entries[1].rights == "Copyright Jane Bloggs"
    check feed.entries[1].summary == "Trains!"