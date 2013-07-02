

require 'logger'

module ArtifactoryApi
  # This module contains classes that define exceptions for various catories.
  #
  module Exceptions
    # This is the base class for Exceptions that is inherited from
    # RuntimeError.
    #
    class ApiException < RuntimeError
      def initialize(logger, message = "", log_level = Logger::ERROR)
        logger.add(log_level) { "#{self.class}: #{message}" }
        super(message)
      end
    end

    # This exception class handles cases where invalid credentials are provided
    # to connect to Artifactory.
    #
    class Unauthorized < ApiException
      def initialize(logger, message = "", log_level = Logger::ERROR)
        msg = "Invalid credentials are provided. #{message}"
        super(logger, msg, Logger::FATAL)
      end
    end

    # This exception class handles cases where invalid credentials are provided
    # to connect to Artifactory.
    #
    class Forbidden < ApiException
      def initialize(logger, message = "", log_level = Logger::ERROR)
        msg = "Forbiddent exception #{message}"
        super(logger, msg)
      end
    end

    # This exception class handles cases where a requested page is not found on
    # the Artifactory API.
    #
    class NotFound < ApiException
      def initialize(logger, message = "", log_level = Logger::ERROR)
        msg = "Requested component is not found on Artifactory" \
          if message.empty?
        super(logger, msg)
      end
    end

    # This exception class handles cases where the Artifactory API returns with a
    # 500 Internel Server Error.
    #
    class InternalServerError < ApiException
      def initialize(logger, message = "", log_level = Logger::ERROR)
        msg = "Internel Server Error. #{message}"
        super(logger, msg)
      end
    end
  
    # This exception class handles cases where Artifactory is getting restarted
    # or reloaded where the response code returned is 503
    #
    class ServiceUnavailable < ApiException
      def initialize(logger, message = "", log_level = Logger::ERROR)
        msg = "Artifactory is unavailable #{message}"
        super(logger, msg)
      end
    end

  end
end