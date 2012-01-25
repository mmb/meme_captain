Ruby gem to create meme images (images with text added at the top and bottom).

Runs locally and has no web dependencies.

Works with animated gifs.

```ruby
require 'open-uri'

require 'meme_captain'

open('http://memecaptain.com/troll_face.jpg', 'rb') do |f|
  i = MemeCaptain.meme(f, 'test', '1 2 3')
  i.display
  i.write('out.jpg')
end
```

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
  imageUrl: "http://memecaptain.com/i?u=http%3A%2F%2Fmemecaptain.com%2Fyao_ming.jpg&t1=sure+i%27ll+test&t2=the+api"
}
```

Optional parameters t1x, t1y, t1w, t1h, t2x, t2y, t2w, t2h can be added to
specify the coordinates of the upper left corner, width and height of the text
on the image. They can be integers which represent pixels or floats which
represent percentages of the image dimensions.
