require 'curb'
require 'sinatra/base'

require 'meme_captain'

module MemeCaptain

  class Server < Sinatra::Base

    get '/' do
      <<-eos
<!DOCTYPE html>
<html lang="en">

<head>
<title>Meme Captain</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

<body>

#{header}

<p>Add text to images from the internet.</p>

<form action="p" method="get">

<p>
<label for="u" />Source image URL: </label>
<input type="text" id="u" name="u" />
</p>

<p>
<label for="tt" />Top text: </label>
<input type="text" id="tt" name="tt" />
</p>

<p>
<label for="tb" />Bottom text: </label>
<input type="text" id="tb" name="tb" />
</p>

<p>
<input type="submit" value="Create Image" />
</p>

</form>

#{footer}

</body>

</html>
eos
    end

    get '/i' do
      resp = Curl::Easy.perform(params[:u])
      new_image = MemeCaptain.meme(resp.body_str, params[:tt], params[:tb])
      [ 200, { 'Content-type' => new_image.mime_type }, new_image.to_blob ]
    end

    get '/p' do
      img_url = request.fullpath.sub(%r{^/p}, '/i')
      <<-eos
<!DOCTYPE html>
<html lang="en">

<head>
<title>Meme Captain - #{params[:tt]} / #{params[:tb]}</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

<body>

#{header}

<img src=#{img_url} />

<p>Source image URL: <a href="#{params[:u]}">#{params[:u]}</a></p>

#{footer}

</body>

</html>
eos
    end

    def header
      '<h1><a href="/">Meme Captain</a></h1>'
    end

    def footer
      'by Matthew M. Boedicker <a href="mailto:matthewm@boedicker.org">matthewm@boedicker.org</a>'
    end

  end

end
