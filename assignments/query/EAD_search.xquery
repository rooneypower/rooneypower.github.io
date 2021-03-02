(: Assignment 6 - Daniel Rooney :)

(: EAD namespace, declare here to simplify searching :)
declare default element namespace "urn:isbn:1-931666-22-9";

(: specify other namespace for output elements to avoid EAD validation errors in resulting XML file :)
<my:report xmlns:my="dprcustom">
{
for $fa in collection("file:/C:/Users/roone/Documents/Graduate%20School/Z603%20-%20Digital%20Publishing/Assignment%206/data/?select=*.xml")/ead
let $head := $fa/eadheader, $fdesc := $head/filedesc, $dates := $fdesc/titlestmt/titleproper/date, $collection := $fa/archdesc
(: sorted by number of objects at lowest encoding level, see <volume> below :)
order by count($collection/dsc//*[@level and not(child::*[@level])]) descending
return
<my:findingAid>
    <my:ID>{data($head/eadid)}</my:ID>
    <my:title>{normalize-space(data($fdesc/titlestmt/titleproper))}</my:title>
    <my:yearsCovered>
    {
    (: split years on hyphen, convert to numeric, and subtract first from second :)
    number(substring-after(data($dates), "-")) - number(substring-before(data($dates), "-"))
    }
    </my:yearsCovered>
    <my:encoder>
    {
        (: pull from author in titlestmt if present :)
        if (contains(data($fdesc/titlestmt/author), "encoded by"))
        then normalize-space(substring-after(data($fdesc/titlestmt/author), "encoded by "))
        (: else parse creation statement; extract words between encoded by and a comma :)
        else normalize-space(substring-before(substring-after(data($fa/eadheader/profiledesc/creation), "encoded by "), ","))
    }
    </my:encoder>
    <my:revisions>{count($head/revisiondesc/change)}</my:revisions>
    <my:extent>{normalize-space(data($collection/did/physdesc/extent))}</my:extent>
    <my:accessRestrictions>{string-join($collection/accessrestrict/p, " | ")}</my:accessRestrictions>
    <my:indexingTerms>
    {
        (: loop through all items within outermost controlaccess element, 
        they may be contained in multiple subelements and lists :)
        for $term in $collection/controlaccess//item
        return <my:term>{normalize-space(data($term))}</my:term>
    }
    </my:indexingTerms>
    <my:numFiles>
    {
    (: any element with a level of file within the dsc element, 
    may be a c02 within a series or higher c0# within a subseries :)
    count($collection/dsc//*[@level="file"])
    }
    </my:numFiles>
    <my:volume>
    {
        (: The source documents are not consistent in how they approach files, items, etc. 
        Some use file as their lowest level of encoding, while others wrap items or other files
        within a file. Therefore, I decided to count terminal elements regardless of specific
        level term (i.e. every element in dsc that has a level but does not contain other elements
        that also have a level). While this may not perfectly correlate with the physical size of 
        the collection, it is at least a good measure of the volume cataloged :)
        count($collection/dsc//*[@level and not(child::*[@level])])
    }
    </my:volume>
</my:findingAid>
}
</my:report>

(: Questions and Answering Elements
What's the unique ID of each finding aid? <my:ID>
What's the title of each finding aid? <my:title>
What's the number of years each finding aid covers (e.g., 1982-2000 = 18 years)? <my:yearsCovered>
What's the name of the person who encoded each finding aid? <my:encoder>
How many times was each finding aid changed? <my:revisions>
What's the physical extent of each finding aid? <my:extent>
In a single element per collection, could you list all of the access restrictions separated by a |? <my:accessRestrictions>
What are the indexing terms used for each collection? <my:indexingTerms> Please express this in sub-elements with each term in its own element. <my:term> 
How many files are in each collection? <my:numFiles>
Could I see these returned from largest to smallest collection in terms of volume? There are a few ways you might try to calculate this based on available data, so please explain your rationale in a comment in your code. <my:volume>
:)

(: Testing - volume and c## element structure
<report>
{
for $fa in collection("file:/C:/Users/roone/Documents/Graduate%20School/Z603%20-%20Digital%20Publishing/Assignment%206/data/?select=*.xml")/ead
let $head := $fa/eadheader, $fdesc := $head/filedesc, $dates := $fdesc/titlestmt/titleproper/date, $collection := $fa/archdesc
order by count($collection/dsc//*[@level and not(child::*[@level])]) descending
return
<findingAid>
    <ID>{data($head/eadid)}</ID>
    <title>{normalize-space(data($fdesc/titlestmt/titleproper))}</title>
    <extent>{normalize-space(data($collection/did/physdesc/extent))}</extent>
    <numFiles>
    {
    (: any element with a level of file within the dsc element, 
    may be a c02 within a series or higher c0# within a subseries :)
    count($collection/dsc//*[@level="file"])
    }
    </numFiles>
    <numItems>
    {
    (: any element with a level of item within the dsc element :) 
    count($collection/dsc//*[@level="item"])
    }
    </numItems>
    <volume>
    {
        count($collection/dsc//*[@level and not(child::*[@level])])
    }
    </volume>
    <c01>{count($collection/dsc/c01)}</c01>
    <c02>{count($collection/dsc/c01/c02)}</c02>
    <c03>{count($collection/dsc/c01/c02/c03)}</c03>
    <c04>{count($collection/dsc/c01/c02/c03/c04)}</c04>
    <c05>{count($collection/dsc/c01/c02/c03/c04/c05)}</c05>
    <c06>{count($collection/dsc/c01/c02/c03/c04/c05/c06)}</c06>
    </findingAid>
}
</report>
:)