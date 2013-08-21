module ArtifactoryApi
  class Client
    class Artifacts
      def initialize(client)
        @client = client
        @logger = @client.logger
      end

      def to_s
        "#<ArtifactoryApi::Clients::Builds>"
      end

      def deploy_artifact repo, path, file
        url = "/#{repo}#{path}"
        @client.api_put_request url, file
      end

      def retrieve_artifact repo, path
        url = "/#{repo}#{path}"
        response = @client.api_get_request url, raw_response=true
        response.body
      end

      def artifact_info repo, path
        url = "/api/storage/#{repo}#{path}"
        @client.api_get_request url
      end
    end
  end
end