
module ArtifactoryApi
  class Client
    class Builds
      def initialize(client)
        @client = client
        @logger = @client.logger
      end

      def to_s
        "#<ArtifactoryApi::Client::Builds"
      end

      #Returns an array of hashes, containing a "name" key and a "last_built" key
      #The api returns build names with a starting slash, this will remove them.
      def list_all
        response_json = @client.api_get_request("/api/build")

        return nil unless response_json

        response_json["builds"].map do |build|
          {
            :name => build["uri"].sub(/^\//,''),
            :uri => build["uri"],
            :lastStarted => build["lastStarted"]
          }
        end.sort{ |x,y| x[:name] <=> y[:name]}

      end

      def get_runs_for_build build
        response_json = @client.api_get_request("/api/build/#{build}")
        return nil unless response_json

        response_json["buildsNumbers"].map do |build|
          {
            :run => build["uri"].sub(/^\//,''),
            :uri => build["uri"],
            :started => build["started"]
          }
        end.sort{|x,y| x[:run] <=> y[:run]}
      end

      def get_run_info build,run
        response_json = @client.api_get_request("/api/build/#{build}/#{run}")
        return nil unless response_json
        result = response_json["buildInfo"]
        result[:run] = result["number"]
        result[:name] = result["name"]
        result
      end

      def diffs_for_build_run build, to_run, from_run
      end
    end
  end
end