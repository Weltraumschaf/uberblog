# Uberblog

Because Wordpress and PHP sucks so much I decided to use a way simpler
approach for my blog: A git repo with a bunch of Markdown files and
a view lines Ruby code which generates static html files, RSS feed
and a sitemap.xml.

## Layout
The layout is oriented by the the default theme from Wordpres.
Credits to the Wordpress theme team. See license for the header
images [Wordpress.org](http://wordpress.org).

The RSS feed icon is from [Mr. Icons](http://www.mricons.com)
shared unter Creative Commons.

All other stuff made by me (Weltraumschaf) is under the
[Beer Ware License](http://www.weltraumschaf.de/the-beer-ware-license.txt).

## Todo

- use nice features of Pathname (add strings to path w/o bothering the /)
- generate suffixed output files if duplicate (on blogposts with same title)
- keywords/description etc. in header

## Links

### Used Libs
    
    - JavaScript
        - [LABjs](http://labjs.com/)
        - [jQuery](http://jquery.com/)
        - [Raty jQuery Plugin](http://www.wbotelhos.com/raty/)
        - [Handlebars](http://handlebarsjs.com/)
    - Ruby
        - [Kramdown](http://kramdown.rubyforge.org/)
        - [Bitly](https://github.com/philnash/bitly)
        - [Twitter](http://twitter.rubyforge.org/)
        - [Data Mapper](http://datamapper.org/)
        - [Sinatra](http://www.sinatrarb.com/)

### Other    

    - [Markdown Meta Data](http://bywordapp.com/markdown/guide.html)