Ruby gem to create meme images (images with text added).

Runs locally and has no web dependencies.

Works with animated gifs.

Create a simple top and bottom text meme:

```ruby
require 'open-uri'

require 'meme_captain'

open('http://memecaptain.com/troll_face.jpg', 'rb') do |f|
  i = MemeCaptain.meme_top_bottom(f, 'test', '1 2 3')
  i.display
  i.write('out.jpg')
end
```

Advanced usage with text sizing and positioning and RMagick attributes:

```ruby
require 'open-uri'

require 'meme_captain'

open('http://memecaptain.com/cool_story_bro.jpg', 'rb') do |f|
  i = MemeCaptain.meme(f, [
    MemeCaptain::TextPos.new('the quick brown fox', 0.70, 0.1, 0.25, 0.5,
      :fill => 'green'),
    MemeCaptain::TextPos.new('jumped over the lazy dog', 100, 400, 200, 100,
      :font => 'Impact-Regular'),
    MemeCaptain::TextPos.new('test', 10, 10, 50, 25)
    ])
  i.display
  i.write('out.jpg')
end
```

Text box sizes and positions can be specified as pixels (the origin is the top
left corner of the image) or as floats which are percentages of the image
width and height. The x and y coordinates of a text box are the coordinates
of its top left corner.

Also includes a Sinatra app that exposes the API over HTTP which is currently
running http://memecaptain.com/

You can use the memecaptain.com API if you prefer it to using the gem.

Simplest API:

```
http://memecaptain.com/i?u=<url encoded source image url>&t1=<url encoded top text>&t2=<url encoded bottom text>
```

Example:

```
http://memecaptain.com/i?u=http%3A%2F%2Fmemecaptain.com%2Fyao_ming.jpg&t1=sure+i%27ll+test&t2=the+api
```

![Sure I'll test the API](http://memecaptain.com/i?u=http%3A%2F%2Fmemecaptain.com%2Fyao_ming.jpg&t1=sure+i%27ll+test&t2=the+api)

If you want better error messages, use this which will return JSON:

```
http://memecaptain.com/g?u=<url encoded source image url>&t1=<url encoded top text>&t2=<url encoded bottom text>
```

Example:

```
http://memecaptain.com/g?u=http%3A%2F%2Fmemecaptain.com%2Fyao_ming.jpg&t1=sure+i%27ll+test&t2=the+api
```

```json
{
  imageUrl: "http://memecaptain.com/c7757f.jpg",
  templateUrl: "http://memecaptain.com/?u=c7757f.jpg"
}
```

Optional parameters t1x, t1y, t1w, t1h, t2x, t2y, t2w, t2h can be added to
position and size text (see example above).

If you want to host a customized version of the memecaptain.com web interface
on your own web server but use the memecaptain.com backend see
[lightweight front end](https://github.com/mmb/meme_captain/blob/master/doc/lightweight_front_end.md).
