require 'yaml'

class Config
    attr_reader :theme, :title, :avatar, :name, :tagline, :links, :social, :footer

    class Link
        attr_reader :title, :url, :target, :alt
      
        def initialize(title, url, target, alt)
            @title = title
            @url = url
            @target = target
            @alt = alt
        end
    end

    class Social
        attr_reader :type, :data
      
        def initialize(social)
            @type = social.keys
            @data = social.values
        end
    end
    
    def initialize(file_path = 'config.yml')
        if File.exist?(file_path)
            config = YAML.load_file(file_path)
            puts "#{file_path} loaded successfully."
        else
            raise "Error: #{file_path} not found."
        end
        
        settings = YAML.load_file(file_path) || {}
        
        @theme = settings["theme"] || "default"
        @title = settings["title"]
        @avatar = settings["avatar"]
        @name = settings["name"]
        @tagline = settings["tagline"]
        @footer = settings["footer"]

        links = []
        if !settings["links"].nil?
            settings["links"].each do |link|
                links.push(Link.new(link["link"]["title"], link["link"]["url"], link["link"]["target"], link["link"]["alt"]))
            end
        end
        @links = links

        socials = []
        if !settings["socials"].nil?
            settings["socials"].each do |social|
                socials.push(Social.new(social))
            end
        end
        @socials = socials


        
    end
end
