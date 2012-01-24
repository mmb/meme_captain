require 'mongo_mapper'

module MemeCaptain

  class MemeData
    include MongoMapper::Document

    set_collection_name 'meme'

    key :meme_id, String
    key :fs_path, String
    key :mime_type, String
    key :size, Integer

    key :source_url, String
    key :source_fs_path, String
    key :texts, Array

    key :request_count, Integer
    key :last_request, Time

    key :creator_ip, String

    timestamps!

    def requested!
      increment :request_count => 1
      set :last_request => Time.now
    end

  end

end
