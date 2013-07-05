
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
            :last_built => build["lastStarted"]
          }
        end.sort{ |x,y| x[:name] <=> y[:name]}

      end

      def get_runs_for_build build
        response_json = @client.api_get_request("/api/build#{build}")
        response_json["buildsNumbers"].sort{|x,y| x["uri"] <=> y["uri"]}
      end

      def get_run_info build,run
        response_json = @client.api_get_request("/api/build#{build}#{run}")
        response_json["buildInfo"]
      end

      def diffs_for_build_run build, to_run, from_run
      end
    end
  end
end