require 'digest/sha1'

require 'sinatra/base'

require 'meme_captain'

module MemeCaptain

  class Server < Sinatra::Base

    get '/' do
      img_tag = if params[:u]
        "<img src=\"#{request.fullpath.sub(%r{^/}, '/i')}\" />"
      else
        ''
      end

      <<-eos
<!DOCTYPE html>
<html lang="en">

<head>
<title>Meme Captain</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
</head>

<body>

<p><a href="/">Meme Captain</a></p>

<p>Add text to images from the internet.</p>

#{img_tag}

<form action="" method="get">

<table>

<tr>
<td><label for="u" />Source image URL: </label></td>
<td><input type="text" id="u" name="u" size="64" value="#{params[:u]}"/></td>
</tr>

<tr>
<td><label for="tt" />Top text: </label></td>
<td><input type="text" id="tt" name="tt" size="64" value="#{params[:tt]}" /></td>
</tr>

<tr>
<td><label for="tb" />Bottom text: </label></td>
<td><input type="text" id="tb" name="tb" size="64" value="#{params[:tb]}" /></td>
</tr>

<tr>
<td></td>
<td><input type="submit" value="Create Image" /></td>
</tr>

</table>

</form>

<p>by Matthew M. Boedicker <a href="mailto:matthewm@boedicker.org">matthewm@boedicker.org</a></p>

</body>

</html>
eos
    end

    get '/i' do
      @fetcher ||= MemeCaptain::Fetcher.new('img_cache')
      source_image_data = @fetcher.fetch(params[:u])
      new_image = MemeCaptain.meme(source_image_data, params[:tt], params[:tb])
      image_data = new_image.to_blob

      headers = {
        'Content-Type' => new_image.mime_type,
        'ETag' => "\"#{Digest::SHA1.hexdigest(image_data)}\"",
        }

      [ 200, headers, image_data ]
    end

  end

end
