module Uberblog

  class Config
    attr_reader :hash, :baseDir

    def initialize(hash, baseDir)
      @hash    = hash
      @baseDir = baseDir
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
      "#{@baseDir}/#{@hash['dataDir']}"
    end

    def tplDir
      "#{@baseDir}/#{@hash['tplDir']}"
    end

    def htdocs
      "#{@baseDir}/#{@hash['htdocs']}"
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