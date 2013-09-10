require_relative "spec_helper"

describe ArtifactoryApi::Client do

  describe "initialization" do
    it "should initialize when server ip, port, and user/password is provided" do
      expect(
        lambda do
          ArtifactoryApi::Client.new(
            :server_ip   => '127.0.0.1',
            :server_port => 8080,
            :username    => 'username',
            :password    => 'password'
          )
        end
      ).not_to raise_error
    end

    it "should initialize when username/password not specified" do
      expect(
        lambda do
          ArtifactoryApi::Client.new({
              :server_ip   => '127.0.0.1',
              :server_port => 8080
            })
        end
      ).not_to raise_error
    end

    it "should initializes with server_url" do
      expect(
        lambda do
          ArtifactoryApi::Client.new(
            :server_url => 'http://localhost',
            :username   => 'username',
            :password   => 'password'
          )
        end
      ).not_to raise_error
    end

    it "should fail to initialize when a username is provided but not a password" do
      expect(
        lambda do
          ArtifactoryApi::Client.new(
            :server_url => 'http://localhost',
            :username   => 'user_id'
          )
        end
      ).to raise_error
    end

    it "should fail to initialize when you don't provide any server data" do
      expect(
        lambda do
          ArtifactoryApi::Client.new(
            :username => "user", :password => "password")
        end
      ).to raise_error
    end
  end

  context "With valid credentials given" do
    before do
      @client = ArtifactoryApi::Client.new(
        :server_ip    => '127.0.0.1',
        :server_port  => 8080,
        :username     => 'username',
        :password     => 'password',
        :log_location => '/dev/null'
      )
    end

    it "should return a Build object when you ask for it" do
      expect(@client.builds.class).to eq(ArtifactoryApi::Client::Builds)
    end

    it "should return a Artifacts object when you ask for it" do
      expect(@client.artifacts.class).to eq(ArtifactoryApi::Client::Artifacts)
    end
  end

end