If you want to host your own custom Meme Captain site but do not want to set
up the ruby backend you can use the memecaptain.com backend. In this scenario,
the HTML, Javscript and CSS are hosted on your web server and the meme images
are created on and hosted on memecaptain.com.

This is an option if you are on shared hosting and do not have access to
ruby or MongoDB or do not want to deal with setting them up.

Download the files at these locations and save them in your document root:

* http://memecaptain.com/
* http://memecaptain.com/css/screen.css
* http://memecaptain.com/js/fabric.min.js
* http://memecaptain.com/source_images.json

The css in js should go in css and js directories in your document root so
that they match the url paths.

Find this line in index.html

```
genUrl : '/g'
```

and change it to

```
genUrl : 'http://memecaptain.com/g'
```

Coming soon: how to change the default source images on your server.
