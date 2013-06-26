[![Build Status](https://travis-ci.org/mmb/meme_captain.png)](https://travis-ci.org/mmb/meme_captain)
[![Code Climate](https://codeclimate.com/github/mmb/meme_captain.png)](https://codeclimate.com/github/mmb/meme_captain)

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
