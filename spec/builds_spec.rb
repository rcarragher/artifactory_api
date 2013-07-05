require_relative "spec_helper"

describe ArtifactoryApi::Client::Builds do

  before(:each) do
    #Setup mocks
    logger = Logger.new("test_log.log")
    @client = double("client")
    @client.stub(:logger) {logger}
    @builds = ArtifactoryApi::Client::Builds.new(@client)
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

    build_list = @builds.list_all
    expect(build_list.length).to eq(1)
    expect(build_list[0][:lastStarted]).to eq("2013-06-03T13:41:18.147+0000")
    expect(build_list[0][:name]).to eq("Build1")

  end

  it "should return all runs given a build" do
    the_response = {"buildsNumbers" => [{"uri" => "/149","started" => "2013-03-14T16:07:43.636+0000"}],
                    "uri" => "https://artifactory-1.ampaxs.net/api/build/Server"}
    @client.should_receive(:api_get_request).with("/api/build/MyBuild").and_return(the_response)

    runs = @builds.get_runs_for_build "MyBuild"

    expect(runs.length).to eq(1)
    expect(runs[0][:run]).to eq("149")
    expect(runs[0][:started]).to eq("2013-03-14T16:07:43.636+0000")

  end

  it "should sort runs by the run number" do
     the_response = {"buildsNumbers" => [
                      {"uri" => "/149","started" => "2013-03-14T16:07:43.636+0000"},
                      {"uri" => "/2464","started" => "2013-03-14T16:07:43.636+0000"},
                      {"uri" => "/379","started" => "2013-06-10T19:38:05.857+0000"},
                      {"uri" => "/222","started" => "2013-04-25T19:39:26.464+0000"}],
                    "uri" => "https://artifactory-1.ampaxs.net/api/build/Server"}

    @client.should_receive(:api_get_request).with("/api/build/MyBuild").and_return(the_response)

    runs = @builds.get_runs_for_build "MyBuild"

    expect(runs.length).to eq(4)
    expect(runs[0][:run]).to eq("149")
    expect(runs[1][:run]).to eq("222")
    expect(runs[2][:run]).to eq("379")
    expect(runs[3][:run]).to eq("2464")

  end


  it "should return info for a run, given a build and run" do

    the_response = {"buildInfo" => {"version" => "1.0.1", "name" => "MyBuild", "number" => "430"},
                          "uri" => "https://artifactory-1.ampaxs.net/api/build/Server/430"}

    @client.should_receive(:api_get_request).with("/api/build/MyBuild/430").and_return(the_response)

    run_info = @builds.get_run_info "MyBuild","430"

    expect(run_info[:run]).to eq("430")
    expect(run_info[:name]).to eq("MyBuild")
  end

end