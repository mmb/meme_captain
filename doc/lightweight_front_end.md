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
* http://memecaptain.com/js/meme_captain.js
* http://memecaptain.com/source_images.json

The css in js should go in css and js directories in your document root so
that they match the url paths.

Find this line in js/meme_captain.js

```
genUrl = '/g',
```

and change it to

```
genUrl = 'http://memecaptain.com/g',
```

# Changing the Default Source Images

The source image thumbnails that show up on the page are driven by a JSON
description and a single image that contain CSS sprites. The JSON and image
must be regenerated to change them.

The rmagick ruby gem must be installed:

```sh
gem install rmagick
```

Get and run the script:

```sh
wget https://raw.github.com/mmb/meme_captain/master/script/thumb_sprites.rb
RUBYOPT='r rubygems'
ruby thumb_sprites.rb -u URL_ROOT -s SOURCE_URL_PREFIX SOURCE_IMAGE_PATH/*
```

SOURCE_IMAGE_PATH is the directory where the source images are stored.
URL_ROOT is the root url of the Meme Captain installation. SOURCE_URL_PREFIX
is the part between the root url and the image filenames in the image urls.

For example if the images are stored in /var/www/meme.com/source and the
url root is http://meme.com/, use:

```sh
ruby thumb_sprites.rb -u http://meme.com/ -s source/ /var/www/meme.com/source/*
```

Copy the generated source_images.json and thumbs_xxx.jpg files to the Meme
Captain document root.
