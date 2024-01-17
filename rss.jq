# Convert dates from ISO / RFC 3339 format as used by the JSON data to
# the RFC 822 format required by the RSS spec.  This also includes
# stripping the millisecond data from the RFC 3339 date.
def dateisoto822:
    sub("\\.\\d\\d\\dZ$";"Z")
    | fromdate
    | strftime("%d %b %Y %T Z")
    ;

def formatattributes:
        .attributes
        | to_entries
        | map("\(.key)=\"\(.value | @html)\"")
        | join(" ")
        ;

# Convert JSON items to an XML-formatted string.
#
# - Objects get converted in different ways depending on their keys:
#   - If an object has a "key" key, the key becomes the element name.  If
#     there's an "attributes" key, it must be an object, where keys are the
#     attribute names on the element, and the values are the attribute values.
#     If there's a "value" key, its value becomes the element content.
#   - If the object does not have a "key" key, it's converted into a list of
#     objects using `to_entries`, which means it will be taken as a list of XML
#     elements and their contents.  This is essentially a more compact way of
#     achieving the previous approach for XML elements that don't have
#     attributes.
# - Arrays are converted element-by-element, then concatenated together.
# - The null object is converted to an empty string.
# - Anything else is converted to a string.
def jsontoxml:
    if type == "object" and has("key") and has("attributes")
    then "<\(.key) \(formatattributes)>\(.value? | jsontoxml)</\(.key)>"
    elif type == "object" and has("key")
    then "<\(.key)>\(.value? | jsontoxml)</\(.key)>"
    elif type == "object"
    then to_entries | jsontoxml
    elif type == "array"
    then map(jsontoxml) | add
    elif type == "null"
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

# vim: ts=8 expandtab
