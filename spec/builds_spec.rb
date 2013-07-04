require_relative "spec_helper"

describe ArtifactoryApi::Client::Builds do

  before(:each) do
    #Setup mocks
    logger = Logger.new("test_log.log")
    @client = double("client")
    @client.stub(:logger) {logger}
  end

  it "should call the all builds endpoint" do
    #@client.should_receive(:api_get_request) {"/api/builds"}
    @client.should_receive(:api_get_request).with("/api/build").and_return(nil)
    builds = ArtifactoryApi::Client::Builds.new(@client)
    builds.list_all
  end

  it "should return the builds map" do
  end

  it "should return all runs given a build" do
  end

  it "should return info for a run, given a build and run" do
  end

end