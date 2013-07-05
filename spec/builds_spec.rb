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
    the_response = { "builds" => [{"uri" => "/Build1",
                                   "lastStarted" => "2013-06-03T13:41:18.147+0000"}],
                     "uri" => "http://artifactory/api/build"}

    @client.should_receive(:api_get_request).with("/api/build").and_return(the_response)
    builds = ArtifactoryApi::Client::Builds.new(@client)

    build_list = builds.list_all
    puts build_list
    expect(build_list.length).to eq(1)
    expect(build_list[0][:last_built]).to eq("2013-06-03T13:41:18.147+0000")
    expect(build_list[0][:name]).to eq("Build1")

  end

  it "should return all runs given a build" do
  end

  it "should return info for a run, given a build and run" do
  end

end