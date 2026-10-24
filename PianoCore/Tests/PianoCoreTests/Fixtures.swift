import Foundation

/// Made-up test data. No real song is kept in this repo.
enum Fixtures {
    /// A small two-staff score: 3 bars, a chord, a grace note, a rest, a tie.
    static let scoreXML = #"""
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE score-partwise PUBLIC "-//Recordare//DTD MusicXML 4.0 Partwise//EN" "http://www.musicxml.org/dtds/partwise.dtd">
<score-partwise version="4.0">
  <work><work-title>Test Tune</work-title></work>
  <part-list><score-part id="P1"><part-name>Piano</part-name></score-part></part-list>
  <part id="P1">
    <measure number="1">
      <attributes>
        <divisions>2</divisions>
        <time><beats>4</beats><beat-type>4</beat-type></time>
        <staves>2</staves>
      </attributes>
      <direction><sound tempo="90"/></direction>
      <note><pitch><step>C</step><octave>4</octave></pitch><duration>2</duration><voice>1</voice><staff>1</staff></note>
      <note><pitch><step>E</step><octave>4</octave></pitch><duration>2</duration><voice>1</voice><staff>1</staff></note>
      <note><chord/><pitch><step>G</step><octave>4</octave></pitch><duration>2</duration><voice>1</voice><staff>1</staff></note>
      <note><grace/><pitch><step>F</step><alter>1</alter><octave>4</octave></pitch><voice>1</voice><staff>1</staff></note>
      <note><rest/><duration>4</duration><voice>1</voice><staff>1</staff></note>
      <backup><duration>8</duration></backup>
      <note><pitch><step>C</step><octave>3</octave></pitch><duration>8</duration><voice>5</voice><staff>2</staff></note>
    </measure>
    <measure number="2">
      <note><pitch><step>C</step><octave>5</octave></pitch><duration>8</duration><tie type="start"/><voice>1</voice><staff>1</staff></note>
    </measure>
    <measure number="3">
      <note><pitch><step>C</step><octave>5</octave></pitch><duration>4</duration><tie type="stop"/><voice>1</voice><staff>1</staff></note>
      <note><pitch><step>B</step><alter>-1</alter><octave>4</octave></pitch><duration>4</duration><voice>1</voice><staff>1</staff></note>
    </measure>
  </part>
</score-partwise>
"""#

    /// scoreXML in an .mxl zip, with META-INF/container.xml, compressed (deflate).
    static let mxlDeflated = base64("""
UEsDBBQAAAAIAJGEWF0uQhWCJAAAACIAAAAIAAAAbWltZXR5cGVLLCjIyUxOLMnMz9Mvy0vRK0pNzi9KSSxK1cstLc5MrsjNAQBQ
SwMEFAAAAAgAkYRYXTZlhO2GAAAAtgAAABYAAABNRVRBLUlORi9jb250YWluZXIueG1sTY4xDsMgEAR7vwJdG2GSLgXYXV6QPADB
2TkJ3yHAVvL7OJXdbTGrGTt+lqQ2LJWEHdz6KyjkIJF4dvB6PvQdxqGzQbh5YiyDLSJtooT1mGpaU9LZt7eDKjxXU4MU7Je1UtgF
oBaM5HX7ZnTgc04UfNuNZuPYF9zh6E/85f8xgzUnlzkSuh9QSwMEFAAAAAgAkYRYXYh5AvYJAgAARwcAABQAAABzb25ncy9zY29y
ZS5tdXNpY3htbL2VW2/aMBTH3/cpPL+HA5RKbDKuVKDTpHZDFZXWR5OcglUSR/YJbN9+di7l0tJCN/UlORef//n5yE7Exe90yVZo
nTbZgHdabc4wi02is/mA302voj6/kJ/E59HP4fR+MmYuNhajXFlaa4dscnd5/X3IeARwiz6VKIsAo+mI3RROx79urlmv1WaTej3A
+AdnfEGUfwVYr9etNCzzDC1j55BQ4qDRbnmP+9Z7HZ9Yva5PMybWxj7K8hmRpiXKKTpi0yJDAVvRyikrgli01I7kljrTyYBPOlxW
6UylKCdaZUbAJiBgUyDrRCnUyD6p+IAPpahcYZFlRTpD6wdcJ3xKEVk9KwhdE/LBRK902J6TXQEbZ7OAdKCYoSInewIqo/Qj+pNj
E6scAeXyTbUjtcJSu7YaGHhO41ksxuT7+ymZIksYYZqbAf/S5iADXZNuCjJDvmeuKV74EsJcDkMj/xYmDv0CXW352VXrksKqUiVs
uLHFyugYZUdAZQTwh4fgV4aAstfhxuOPbBwv/MGHXYBvHwkwtyrGPYCrBkAtCW0QqIxXgN7T2vq7Blt76b1/LzMVPxb5llZ/Wwvq
9PGH7eyVkfefY57vYXZfwhRQ3+gD97vLTwA8PxaQNLJwoQfcE1kK1++E0b7FfPa/mHuHmE1+IvKLKJe7Jzo65kj/87ncGV71wff/
JNj9Kcm/UEsBAhQDFAAAAAgAkYRYXS5CFYIkAAAAIgAAAAgAAAAAAAAAAAAAAIABAAAAAG1pbWV0eXBlUEsBAhQDFAAAAAgAkYRY
XTZlhO2GAAAAtgAAABYAAAAAAAAAAAAAAIABSgAAAE1FVEEtSU5GL2NvbnRhaW5lci54bWxQSwECFAMUAAAACACRhFhdiHkC9gkC
AABHBwAAFAAAAAAAAAAAAAAAgAEEAQAAc29uZ3Mvc2NvcmUubXVzaWN4bWxQSwUGAAAAAAMAAwC8AAAAPwMAAAAA
""")

    /// The same .mxl, stored without compression.
    static let mxlStored = base64("""
UEsDBBQAAAAAAJGEWF0uQhWCIgAAACIAAAAIAAAAbWltZXR5cGVhcHBsaWNhdGlvbi92bmQucmVjb3JkYXJlLm11c2ljeG1sUEsD
BBQAAAAAAJGEWF02ZYTttgAAALYAAAAWAAAATUVUQS1JTkYvY29udGFpbmVyLnhtbDw/eG1sIHZlcnNpb249IjEuMCIgZW5jb2Rp
bmc9IlVURi04Ij8+Cjxjb250YWluZXI+PHJvb3RmaWxlcz48cm9vdGZpbGUgZnVsbC1wYXRoPSJzb25ncy9zY29yZS5tdXNpY3ht
bCIgbWVkaWEtdHlwZT0iYXBwbGljYXRpb24vdm5kLnJlY29yZGFyZS5tdXNpY3htbCt4bWwiLz48L3Jvb3RmaWxlcz48L2NvbnRh
aW5lcj4KUEsDBBQAAAAAAJGEWF2IeQL2RwcAAEcHAAAUAAAAc29uZ3Mvc2NvcmUubXVzaWN4bWw8P3htbCB2ZXJzaW9uPSIxLjAi
IGVuY29kaW5nPSJVVEYtOCI/Pgo8IURPQ1RZUEUgc2NvcmUtcGFydHdpc2UgUFVCTElDICItLy9SZWNvcmRhcmUvL0RURCBNdXNp
Y1hNTCA0LjAgUGFydHdpc2UvL0VOIiAiaHR0cDovL3d3dy5tdXNpY3htbC5vcmcvZHRkcy9wYXJ0d2lzZS5kdGQiPgo8c2NvcmUt
cGFydHdpc2UgdmVyc2lvbj0iNC4wIj4KICA8d29yaz48d29yay10aXRsZT5UZXN0IFR1bmU8L3dvcmstdGl0bGU+PC93b3JrPgog
IDxwYXJ0LWxpc3Q+PHNjb3JlLXBhcnQgaWQ9IlAxIj48cGFydC1uYW1lPlBpYW5vPC9wYXJ0LW5hbWU+PC9zY29yZS1wYXJ0Pjwv
cGFydC1saXN0PgogIDxwYXJ0IGlkPSJQMSI+CiAgICA8bWVhc3VyZSBudW1iZXI9IjEiPgogICAgICA8YXR0cmlidXRlcz4KICAg
ICAgICA8ZGl2aXNpb25zPjI8L2RpdmlzaW9ucz4KICAgICAgICA8dGltZT48YmVhdHM+NDwvYmVhdHM+PGJlYXQtdHlwZT40PC9i
ZWF0LXR5cGU+PC90aW1lPgogICAgICAgIDxzdGF2ZXM+Mjwvc3RhdmVzPgogICAgICA8L2F0dHJpYnV0ZXM+CiAgICAgIDxkaXJl
Y3Rpb24+PHNvdW5kIHRlbXBvPSI5MCIvPjwvZGlyZWN0aW9uPgogICAgICA8bm90ZT48cGl0Y2g+PHN0ZXA+Qzwvc3RlcD48b2N0
YXZlPjQ8L29jdGF2ZT48L3BpdGNoPjxkdXJhdGlvbj4yPC9kdXJhdGlvbj48dm9pY2U+MTwvdm9pY2U+PHN0YWZmPjE8L3N0YWZm
Pjwvbm90ZT4KICAgICAgPG5vdGU+PHBpdGNoPjxzdGVwPkU8L3N0ZXA+PG9jdGF2ZT40PC9vY3RhdmU+PC9waXRjaD48ZHVyYXRp
b24+MjwvZHVyYXRpb24+PHZvaWNlPjE8L3ZvaWNlPjxzdGFmZj4xPC9zdGFmZj48L25vdGU+CiAgICAgIDxub3RlPjxjaG9yZC8+
PHBpdGNoPjxzdGVwPkc8L3N0ZXA+PG9jdGF2ZT40PC9vY3RhdmU+PC9waXRjaD48ZHVyYXRpb24+MjwvZHVyYXRpb24+PHZvaWNl
PjE8L3ZvaWNlPjxzdGFmZj4xPC9zdGFmZj48L25vdGU+CiAgICAgIDxub3RlPjxncmFjZS8+PHBpdGNoPjxzdGVwPkY8L3N0ZXA+
PGFsdGVyPjE8L2FsdGVyPjxvY3RhdmU+NDwvb2N0YXZlPjwvcGl0Y2g+PHZvaWNlPjE8L3ZvaWNlPjxzdGFmZj4xPC9zdGFmZj48
L25vdGU+CiAgICAgIDxub3RlPjxyZXN0Lz48ZHVyYXRpb24+NDwvZHVyYXRpb24+PHZvaWNlPjE8L3ZvaWNlPjxzdGFmZj4xPC9z
dGFmZj48L25vdGU+CiAgICAgIDxiYWNrdXA+PGR1cmF0aW9uPjg8L2R1cmF0aW9uPjwvYmFja3VwPgogICAgICA8bm90ZT48cGl0
Y2g+PHN0ZXA+Qzwvc3RlcD48b2N0YXZlPjM8L29jdGF2ZT48L3BpdGNoPjxkdXJhdGlvbj44PC9kdXJhdGlvbj48dm9pY2U+NTwv
dm9pY2U+PHN0YWZmPjI8L3N0YWZmPjwvbm90ZT4KICAgIDwvbWVhc3VyZT4KICAgIDxtZWFzdXJlIG51bWJlcj0iMiI+CiAgICAg
IDxub3RlPjxwaXRjaD48c3RlcD5DPC9zdGVwPjxvY3RhdmU+NTwvb2N0YXZlPjwvcGl0Y2g+PGR1cmF0aW9uPjg8L2R1cmF0aW9u
Pjx0aWUgdHlwZT0ic3RhcnQiLz48dm9pY2U+MTwvdm9pY2U+PHN0YWZmPjE8L3N0YWZmPjwvbm90ZT4KICAgIDwvbWVhc3VyZT4K
ICAgIDxtZWFzdXJlIG51bWJlcj0iMyI+CiAgICAgIDxub3RlPjxwaXRjaD48c3RlcD5DPC9zdGVwPjxvY3RhdmU+NTwvb2N0YXZl
PjwvcGl0Y2g+PGR1cmF0aW9uPjQ8L2R1cmF0aW9uPjx0aWUgdHlwZT0ic3RvcCIvPjx2b2ljZT4xPC92b2ljZT48c3RhZmY+MTwv
c3RhZmY+PC9ub3RlPgogICAgICA8bm90ZT48cGl0Y2g+PHN0ZXA+Qjwvc3RlcD48YWx0ZXI+LTE8L2FsdGVyPjxvY3RhdmU+NDwv
b2N0YXZlPjwvcGl0Y2g+PGR1cmF0aW9uPjQ8L2R1cmF0aW9uPjx2b2ljZT4xPC92b2ljZT48c3RhZmY+MTwvc3RhZmY+PC9ub3Rl
PgogICAgPC9tZWFzdXJlPgogIDwvcGFydD4KPC9zY29yZS1wYXJ0d2lzZT5QSwECFAMUAAAAAACRhFhdLkIVgiIAAAAiAAAACAAA
AAAAAAAAAAAAgAEAAAAAbWltZXR5cGVQSwECFAMUAAAAAACRhFhdNmWE7bYAAAC2AAAAFgAAAAAAAAAAAAAAgAFIAAAATUVUQS1J
TkYvY29udGFpbmVyLnhtbFBLAQIUAxQAAAAAAJGEWF2IeQL2RwcAAEcHAAAUAAAAAAAAAAAAAACAATIBAABzb25ncy9zY29yZS5t
dXNpY3htbFBLBQYAAAAAAwADALwAAACrCAAAAAA=
""")

    /// Raw deflate of `inflateText`, made by zlib at level 9 (dynamic Huffman blocks).
    static let inflateDynamic = base64("""
7dS7beQAEAVB/6LYEDj8LLnh6AC5kqP8cTjQ6g1BKHOcxhunvr5/Ph/L4+/nx89j+fP1/5r7mvta72u9r+2+tvva72u/ryOVZypn
Klcqr1TmbUzXTOdM90wHTRdNJy0tJbSmsyWzp3Kk8kzlTOVK5dW33sZ0zXTOdM900HTRdNLSUkJrOlsyeypHKs9UzlSuVF59621M
10znTPdMB00XTSctLSW0prMls6dypPJM5UzlSuXVt97GdM10znTPdNB00XTS0lJCazpbMnsqRyrPVM5UrlRefettTNdM50z3TAdN
F00ngQxkIAMZyEAGMpCBDGQgAxnIQAYykIEMZCADGchABjKQgQxkIAMZyEAGMpCBDGQgAxnIQAYykIEMZCADGchABjKQgQxkIAMZ
yEAGMpCBDGQgAxnIQAYykIEMZCADGchABjKQgQxkIAMZyEAGMpCBDGQgAxnIQAYykIEMZCADGchABjKQgQxkIAMZyEAGMpCBDGQg
AxnIQAYykIEMZCADGchABjKQgQxkIAMZyEAGMpCBDGQgAxnIQAYykIEMZCADGchABjKQgQxkIAMZyEAGMpCBDGQgAxnIQAYykIEM
ZL8Lsn8=
""")

    static let inflateText = (0..<3000).map { "note \($0 % 17) beat \($0 % 5)\n" }.joined()

    /// Raw deflate of "abcabcabc piano", made by zlib at level 1 (a fixed Huffman block).
    static let inflateFixed = base64("S0xKTgQjhYLMxLx8AA==")

    private static func base64(_ text: String) -> Data {
        Data(base64Encoded: text.filter { !$0.isWhitespace })!
    }
}
