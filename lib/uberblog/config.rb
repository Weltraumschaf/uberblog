module Uberblog

  class Config
    attr_reader :hash

    def initialize(hash)
      @hash = hash
    end

    def headline
      @hash['headline']
    end

    def description
      @hash['description']
    end

    def siteUrl
      @hash['siteUrl']
    end

    def language
      @hash['language']
    end

    def dataDir
      @hash['dataDir']
    end

    def tplDir
      @hash['tplDir']
    end

    def htdocs
      @hash['htdocs']
    end

    def twitter
      @hash['twitter']
    end

    def bitly
      @hash['bitly']
    end

    def api
      @hash['api']
    end

    def features
      @hash['features']
    end

  end

end