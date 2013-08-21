require 'logger'
require 'base64'
require 'uri'
require 'json'
require 'net/http'
require 'net/https'

module ArtifactoryApi
  class Client
    attr_accessor :logger

    DEFAULT_SERVER_PORT = 80

    VALID_PARAMS = [
      "server_url",
      "server_ip",
      "server_port",
      "artifactory_path",
      "username",
      "password",
      "password_base64",
      "log_location",
      "log_level",
      "ssl",
      "follow_redirects"
    ].freeze

    def initialize(args)
      args.each do |key, value|
        if value && VALID_PARAMS.include?(key.to_s)
          instance_variable_set("@#{key}", value)
        end
      end if args.is_a? Hash

      # Server IP or Server URL must be specified
      unless @server_ip || @server_url
        raise ArgumentError, "Server IP or Server URL is required to connect" +
          " to Artifactory"
      end

      # Username/password are optional as some artifactory servers do not require
      # authentication
      if @username && !(@password || @password_base64)
        raise ArgumentError, "If username is provided, password is required"
      end

      # Get info from the server_url, if we got one
      if @server_url
        server_uri = URI.parse(@server_url)
        @server_ip = server_uri.host
        @server_port = server_uri.port
        @ssl = server_uri.scheme == "https"
        @artifactory_path = server_uri.path
      end

      @artifactory_path ||= ""
      @artifactory_path.gsub!(/\/$/,"") # remove trailing slash if there is one

      @server_port = DEFAULT_SERVER_PORT unless @server_port
      @ssl ||= false

      # Setting log options
      @log_location = STDOUT unless @log_location
      @log_level = Logger::INFO unless @log_level
      @logger = Logger.new(@log_location)
      @logger.level = @log_level

      # Base64 decode inserts a newline character at the end. As a workaround
      # added chomp to remove newline characters. I hope nobody uses newline
      # characters at the end of their passwords :)
      @password = Base64.decode64(@password_base64).chomp if @password_base64

    end

    def builds
      ArtifactoryApi::Client::Builds.new(self)
    end

    def artifacts
      ArtifactoryApi::Client::Artifacts.new(self)
    end

    # Returns a string representing the class name
    #
    # @return [String] string representation of class name
    #
    def to_s
      "#<ArtifactoryApi::Client>"
    end

    # Connects to the Artifactory server, sends the specified request and returns
    # the response.
    #
    # @param [Net::HTTPRequest] request The request object to send
    # @param [Boolean] follow_redirect whether to follow redirects or not
    #
    # @return [Net::HTTPResponse] Response from Jenkins
    #
    def make_http_request(request, follow_redirect = @follow_redirects)
      request.basic_auth @username, @password if @username

      http = Net::HTTP.new(@server_ip, @server_port)

      if @ssl
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      response = http.request(request)
      case response
        when Net::HTTPRedirection then
          # If we got a redirect request, follow it (if flag set), but don't
          # go any deeper (only one redirect supported - don't want to follow
          # our tail)
          if follow_redirect
            redir_uri = URI.parse(response['location'])
            response = make_http_request(
              Net::HTTP::Get.new(redir_uri.path, false)
            )
          end
      end
      return response
    end
    protected :make_http_request


    # Sends a GET request to the Artifactory server with the specified URL
    #
    # @param [String] url_prefix The prefix to use in the URL
    # @param [Boolean] raw_response Return complete Response object instead of
    #   JSON body of response
    #
    # @return [String, JSON] JSON response from Jenkins
    #
    def api_get_request(url_prefix, raw_response = false)
      url_prefix = "#{@artifactory_path}#{url_prefix}"

      to_get = URI.escape(url_prefix)
      request = Net::HTTP::Get.new(to_get)
      @logger.info "GET #{to_get}"
      response = make_http_request(request)
      if raw_response
        handle_exception(response, "raw")
      else
        handle_exception(response, "body", send_json=true)
      end
    end

    # Sends a PUT request to the Artifactory server with the specified URL
    def api_put_request(url_prefix,data, raw_response = false)
      to_put = URI.escape(url_prefix)
      req = Net::HTTP::Put.new(to_put)
      req.body = data
      # Net::HTTP.start(@server_ip,@server_port) do |http|
      #   http.request(req)
      # end
      @logger.info "PUT #{to_put}"
      response = make_http_request(req)
      if raw_response
        handle_exception(response, "raw")
      else
        handle_exception(response, "body", send_json=true)
      end
    end

    private

    # Private method that handles the exception and raises with proper error
    # message with the type of exception and returns the required values if no
    # exceptions are raised.
    #
    # @param [Net::HTTP::Response] response Response from Artifactory
    # @param [String] to_send What should be returned as a response. Allowed
    #   values: "code", "body", and "raw".
    # @param [Boolean] send_json Boolean value used to determine whether to
    #   load the JSON or send the response as is.
    #
    # @return [String, JSON] Response returned whether loaded JSON or raw
    #   string
    #
    # @raise [Exceptions::Unauthorized] When invalid credentials are
    #   provided to connect to Artifactory
    # @raise [Exceptions::NotFound] When the requested page on Artifactory is not
    #   found
    # @raise [Exceptions::InternalServerError] When Artifactory returns a 500
    #   Internal Server Error
    # @raise [Exceptions::ApiException] Any other exception returned from
    #   Artifactory that are not categorized in the API Client.
    #
    def handle_exception(response, to_send = "code", send_json = false)
      msg = "ArtifactoryAPI HTTP Code: #{response.code}, Response Body: #{response.body}"
      @logger.debug msg
      case response.code.to_i
        when 200, 201, 302
          if to_send == "body" && send_json
            return JSON.parse(response.body)
          elsif to_send == "body"
            return response.body
          elsif to_send == "code"
            return response.code
          elsif to_send == "raw"
            return response
          end
        when 400
          matched = response.body.match(/<p>(.*)<br\s*\/>/)
          api_message = matched[1] unless matched.nil?
          @logger.info "API message: #{api_message}"
          raise Exceptions::ApiException.new(api_message)
        when 401
          raise Exceptions::Unauthorized.new
        when 403
          raise Exceptions::Forbidden.new
        when 404
          raise Exceptions::NotFound.new
        when 500
          raise Exceptions::InternalServerError.new
        when 503
          raise Exceptions::ServiceUnavailable.new
        else
          raise Exceptions::ApiException.new(
            "Error code #{response.code}"
          )
      end
    end


  end
end
