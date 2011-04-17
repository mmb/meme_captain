require 'digest/sha1'

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

<table>

<tr>
<td><label for="u" />Source image URL: </label></td>
<td><input type="text" id="u" name="u" size="64" value="#{params[:u]}"/></td>
</tr>

<tr>
<td><label for="tt" />Top text: </label></td>
<td><input type="text" id="tt" name="tt" size="64" /></td>
</tr>

<tr>
<td><label for="tb" />Bottom text: </label></td>
<td><input type="text" id="tb" name="tb" size="64" /></td>
</tr>

<tr>
<td></td>
<td><input type="submit" value="Create Image" /></td>
</tr>

</table>

</form>

#{footer}

</body>

</html>
eos
    end

    get '/i' do
      resp = Curl::Easy.perform(params[:u])
      new_image = MemeCaptain.meme(resp.body_str, params[:tt], params[:tb])
      image_data = new_image.to_blob

      headers = {
        'Content-Type' => new_image.mime_type,
        'ETag' => "\"#{Digest::SHA1.hexdigest(image_data)}\"",
        }

      [ 200, headers, image_data ]
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
      '<p><a href="/">Meme Captain</a></p>'
    end

    def footer
      '<p>by Matthew M. Boedicker <a href="mailto:matthewm@boedicker.org">matthewm@boedicker.org</a></p>'
    end

  end

end
