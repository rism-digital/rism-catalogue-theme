require "jekyll"
require 'json'
require 'net/http'
require 'uri'
require 'csv'

module Jekyll
  module RismCatalogueTheme
    class LoadData < Command

      @docs = []
      # the map for index => original instrument values
      @keyMode_map = {}

      def self.init_with_program(prog)
        prog.command("load-data".to_sym) do |c|
          c.syntax "jekyll load data"
          c.description "Runs the RISM Catalogue Theme helper script."

          c.option "verbose", "--verbose", "Show more output"

          c.action do |args, options|
            Jekyll.logger.info "RISM:", "Running load data..."
            # Your script logic goes here
            # You can load Jekyll config if needed:
            site = Jekyll::Site.new(Jekyll.configuration({}))
            # Example logic:
            if ! site.config["rism_catalogue"]
              Jekyll.logger.error "rism_catalogue is missing in the configuration"
              exit
            end

            start_url = "https://rism.online/#{site.config["rism_catalogue"]}/works"

            # Start processing paginated results
            iterate_paginated_results(start_url)

            File.write("index/index.json", @docs.to_json)
            File.write("index/keyMode.json", @keyMode_map.to_json)
          end
        end
      end
    
      def self.normalize_facet(s)
        s.rstrip.gsub(/[()]/, '').gsub(/[ -]/, '_')
      end

      # Method to fetch and parse JSON-LD data from RISM Online
      def self.fetch_json_ld(url)
          uri = URI(url)
          request = Net::HTTP::Get.new(uri)
          # Set the Accept header to request JSON-LD
          request['Accept'] = 'application/ld+json'
          # Authentication for dev.rism.online
          # request.basic_auth("rism", "rism")
          response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') do |http|
              http.request(request)
          end
          
          if response.is_a?(Net::HTTPSuccess)
              JSON.parse(response.body)
          else
              Jekyll.logger.warning "Failed to retrieve data from #{url}: #{response.code} #{response.message}"
              nil
          end
      end

      # Method to iterate through JSON-LD data["items"] and to add them to the document list
      def self.iterate_json_ld(data, indent = 0)
          data.each_with_index do |value, index|
              doc = {}
              doc["id"] = value["id"]
              doc["title"] = value["label"]["none"][0]
              if value["summary"]
                  doc["textIncipit"] = value["summary"]["textIncipit"]["value"]["none"] if value["summary"]["textIncipit"]
              end
              doc["catalogNumber"] = value["flags"]["catalogNumber"] if value["flags"]["catalogNumber"]

              # special handling of keyMode with normalization and map
              keyMode = value["flags"]["keyMode"]["en"][0] if value["flags"]["keyMode"]
              if keyMode
                  normKeyMode = normalize_facet(keyMode)
                  @keyMode_map[normKeyMode] = keyMode.rstrip
                  doc["keyMode"] = normKeyMode;
              end

              doc["scoringSummary"] = value["flags"]["scoringSummary"] if value["flags"]["scoringSummary"]

              if value["rendered"] && value["rendered"]["format"] == "image/svg+xml"
                  filename = value["id"][/([^\/]+)$/]
                  File.write("incipits/%s.svg" % filename, value["rendered"]["data"])
                  doc["incipit"] = filename
              end

              @docs << doc
          end
      end

      # Method to iterate through paginated results
      def self.iterate_paginated_results(start_url)
        current_url = start_url
        
        loop do
          data = fetch_json_ld(current_url)
          
          # Process the items in the current page
          Jekyll.logger.info "Processing items from #{current_url}:"
          iterate_json_ld(data["items"])

          # Check if there is a next page
          if data["view"]["next"]
              current_url = data["view"]["next"]
          else
              break
          end
        end
      end    
    end
  end
end