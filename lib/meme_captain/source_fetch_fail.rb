require 'mongo_mapper'

module MemeCaptain

  # For tracking source image fetch failures so they won't be retried.
  class SourceFetchFail
    include MongoMapper::Document

    set_collection_name 'source_fetch_fail'

    key :url, String

    key :orig_ip, String
    key :response_code, Integer

    key :attempt_count, Integer
    key :last_request, Time

    timestamps!

    def requested!
      increment :attempt_count => 1
      set :last_request => Time.now
    end

  end

end
