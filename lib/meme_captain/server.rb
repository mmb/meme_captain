require 'cgi'
require 'digest/sha1'

require 'curb'
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

<p><a href="https://github.com/mmb/meme_captain">source code</a></p>

</body>

</html>
eos
    end

    get '/i' do
      @processed_cache ||= MemeCaptain::FilesystemCache.new(
        'img_cache/processed')
      @source_cache ||= MemeCaptain::FilesystemCache.new('img_cache/source')

      processed_id = Digest::SHA1.hexdigest(params.sort.map(&:join).join)
      processed_img_data = @processed_cache.get(processed_id) {
        source_id = Digest::SHA1.hexdigest(params[:u])
        source_img_data = @source_cache.get(source_id) {
          Curl::Easy.perform(params[:u]).body_str
        }
        MemeCaptain.meme(source_img_data, params[:tt], params[:tb]).to_blob
      }

      headers = {
        'Content-Type' => MemeCaptain.content_type(processed_img_data),
        'ETag' => "\"#{Digest::SHA1.hexdigest(processed_img_data)}\"",
        }

      [ 200, headers, processed_img_data ]
    end

  end

end
