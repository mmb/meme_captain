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
http://memecaptain.com/i?u=<url encoded source image url>&tt=<url encoded top text>&tb=<url encoded bottom text>
```

Example:

```
http://memecaptain.com/i?u=http%3A%2F%2Fmemecaptain.com%2Fyao_ming.jpg&tt=sure+i%27ll+test&tb=the+api
```

![Sure I'll test the API](http://memecaptain.com/i?u=http%3A%2F%2Fmemecaptain.com%2Fyao_ming.jpg&tt=sure+i%27ll+test&tb=the+api)

If you want better error messages, use this which will return JSON:

```
http://memecaptain.com/g?u=<url encoded source image url>&tt=<url encoded top text>&tb=<url encoded bottom text>
```

Example:

```
http://memecaptain.com/g?u=http%3A%2F%2Fmemecaptain.com%2Fyao_ming.jpg&tt=sure+i%27ll+test&tb=the+api
```

```json
{
  permUrl: "http://memecaptain.com/i?u=http%3A%2F%2Fmemecaptain.com%2Fyao_ming.jpg&tt=sure+i%27ll+test&tb=the+api"
  tempUrl: "http://memecaptain.com/tmp/de55f7a78c6559d4a24ef3e72e2de89992b82695.jpeg"
}
```
