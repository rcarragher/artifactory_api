
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
        response_json["builds"].map { |build| build["uri"] }.sort
      end
    end
  end
end