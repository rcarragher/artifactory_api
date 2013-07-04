
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

      def list_all
        response_json = @client.api_get_request("/api/build")
        @logger.debug response_json
        if response_json
          response_json["builds"].map { |build| build["uri"] }.sort
        end
        response_json 
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