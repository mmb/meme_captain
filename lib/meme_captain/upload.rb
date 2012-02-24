require 'mongo_mapper'

module MemeCaptain

  # Data about uploaded files.
  class Upload
    include MongoMapper::Document

    set_collection_name 'upload'

    key :upload_id, String
    key :fs_path, String
    key :mime_type, String
    key :size, Integer

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
