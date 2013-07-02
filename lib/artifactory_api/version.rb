module ArtifactoryApi
  class Client
    # Major version of the gem
    MAJOR   = 0
    # Minor version of the gem
    MINOR   = 0
    # Tiny version of the gem used for patches
    TINY    = 0
    # Used for pre-releases
    PRE     = "pre1"
    # Version String of Jenkins API Client.
    VERSION = [MAJOR, MINOR, TINY, PRE].compact.join('.')
  end
end