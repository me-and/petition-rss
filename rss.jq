# Convert dates from ISO / RFC 3339 format as used by the JSON data to
# the RFC 822 format required by the RSS spec.  This also includes
# stripping the millisecond data from the RFC 3339 date.
def dateisoto822:
    sub("\\.\\d\\d\\dZ$";"Z")
    | fromdate
    | strftime("%d %b %Y %T Z")
    ;

def jsontoxml:
    type as $type |
    if $type == "object"
    then (if .key? == null
          then to_entries | jsontoxml
          else ("<"
                + ([.key]
                   + (.attributes?
                      | if . == null
                        then []
                        else to_entries
                             | map("\(.key)=\"\(.value | @html)\"")
                        end)
                      | join(" ")
                   )
                + ">"
                + (.value? | jsontoxml)
                + "</"
                + .key
                + ">"
                )
         end
        )
    elif $type == "array"
    then map(jsontoxml) | add
    elif $type == "null"
    then ""
    else @html
    end
    ;

def petitionjsontoxml:
    {item: ({title: .attributes.action,
             link: .links.self | rtrimstr(".json"),
             description: (.attributes.background + "\r\n\r\n" + .attributes.additional_details | rtrimstr(".json")),
             pubDate: .attributes.opened_at | dateisoto822,
             }
            | (.guid = .link)
            )
     }
    ;

{key: "rss",
 attributes: {version: "2.0"},
 value: {channel: ([{title: "Recent UK Government and Parliament petitions",
                     link: "https://petition.parliament.uk/petitions?state=recent",
                     description: "Recent petitions published on petition.parliament.uk",
                     language: "en-GB",
                     copyright: "Crown Copyright.  All content is available under the Open Government Licence v3.0, except where otherwise stated.",
                     generator: ($ENV.GITHUB_SERVER_URL + "/" + $ENV.GITHUB_REPOSITORY),
                     lastBuildDate: now | strftime("%d %b %Y %T Z"),
                     }]
                   + (.data | map(petitionjsontoxml))
                   )
         }
 }
| jsontoxml
