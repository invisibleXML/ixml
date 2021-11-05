# ixml

## Invisible XML

Data is an abstraction: there is no essential difference between the JSON

```json
{"temperature": {"scale": "C", "value": 21}}
```

and an equivalent XML

```xml
<temperature scale="C" value="21"/>
```
or

```xml
<temperature>
   <scale>C</scale>
   <value>21</value>
</temperature>
```

since the underlying abstractions being represented are the same.

We choose which representations of our data to use, JSON, CSV, XML, or whatever, depending on habit, convenience, or the context we want to use that data in. On the other hand, having an interoperable generic toolchain such as that provided by XML to process data is of immense value. How do we resolve the conflicting requirements of convenience, habit, and context, and still enable a generic toolchain?

Invisible XML (ixml) is a method for treating non-XML documents as if they were XML, enabling authors to write documents and data in a format they prefer while providing XML for processes that are more effective with XML content. For example, it can turn CSS code like

```css
body {color: blue; font-weight: bold}
```

into XML like

```xml
<css>
   <rule>
      <simple-selector name="body"/>
      <block>
         <property>
            <name>color</name>
            <value>blue</value>
         </property>
         <property>
            <name>font-weight</name>
            <value>bold</value>
         </property>
      </block>
   </rule>
</css>
```

or

```xml
<css>
   <rule>
      <selector>body</selector>
      <block>
         <property name="color" value="blue"/>
         <property name="font-weight" value="bold"/>
      </block>
   </rule>
</css>
```

depending on choice.

This is an ongoing project to provide software that lets you treat any parsable format as if it were XML, without the need for markup.

There are currently five papers:

* [Invisible XML](http://www.cwi.nl/~steven/Talks/2013/08-07-invisible-xml/invisible-xml-3.html): Introduces the concepts, and develops a notation to support them.
* [Data just wants to be (format) neutral](http://www.cwi.nl/~steven/Talks/2016/02-12-prague/data.html): Discusses issues with automatic serialisation, and the relationship between Invisible XML grammars and data schemas.
* [Parse Earley, Parse Often: How to parse anything to XML](http://www.cwi.nl/~steven/Talks/2016/06-05-london/xml-london.html): Discusses issues around grammar design, and in particular parsing algorithms used to recognise any document, and converting the resultant parse-tree into XML, and gives a new perspective on a classic algorithm.
* [On the Descriptions of Data: The Usability of Notations](http://archive.xmlprague.cz/2017/files/xmlprague-2017-proceedings.pdf#page=155): Discusses changes to the design following experience with using it, giving examples of its use to develop data descriptions, and in passing, suggests other output formats.
* [On the Specification of Invisible XML](https://archive.xmlprague.cz/2019/files/xmlprague-2019-proceedings.pdf#page=425): Describes decisions made during the production of the specification of ixml.

Software to support ixml will be made available at a later date, at https://github.com/invisibleXML/ixml

The draft [Specification for Invisible XML](https://github.com/invisibleXML/ixml/blob/master/ixml-specification.html) is available.
