# UK Government petitions RSS feed

It annoyed me that there was no RSS feed for the UK Government petitions
website at <https://petition.parliament.uk>.  I decided to fix that.

You should be able to access the RSS feed at
<https://rss.dinwoodie.org/petitions.rss>.  Just point your preferred RSS feed
reader to that address and it should work everything else out for you.  Don't
have an RSS feed reader?  Try putting "RSS client" into your favourite search
engine.

## Implementation

This was a quick hack; I've aimed for "good enough", not "good".

Every hour, a GitHub Action runs, which fetches the first page of a
JSON-formatted list of most recently published petitions, as published at
<https://petition.parliament.uk/petitions.json?page=1&state=recent>.  This is
reformatted into RSS XML using `jq`, which GitHub Actions then publishes as a
static file.
