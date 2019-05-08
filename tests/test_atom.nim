# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import marshal

import feednim

test "Read Valid Atom Feed":
    let feed = "./tests/test_atom.xml".loadAtom()

    echo $$feed

    check feed.title != ""
    check feed.generator != ""
    check feed.authors[0].name == "Joe Bloggs"
    check feed.authors[0].uri == "http://joe.bloggs"
    check feed.authors[0].email == "mail@joe.bloggs"