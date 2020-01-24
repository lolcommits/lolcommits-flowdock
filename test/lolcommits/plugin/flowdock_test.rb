# frozen_string_literal: true

require "test_helper"
require 'webmock/minitest'

describe Lolcommits::Plugin::Flowdock do

  include Lolcommits::TestHelpers::GitRepo
  include Lolcommits::TestHelpers::FakeIO

  describe "with a runner" do
    def runner
      # a simple lolcommits runner with an empty configuration Hash
      @runner ||= Lolcommits::Runner.new(
        lolcommit_path: Tempfile.new('lolcommit.jpg')
      )
    end

    def plugin
      @plugin ||= Lolcommits::Plugin::Flowdock.new(runner: runner)
    end

    def plugin_config
      {
        enabled: true,
        access_token: "f4f6aa86fd747a00e75238810412x543",
        organization: "myorg",
        flow: "myflow"
      }
    end

    describe "#enabled?" do
      it "is not enabled by default" do
        _(plugin.enabled?).must_equal false
      end

      it "is true when configured" do
        plugin.configuration = plugin_config
        _(plugin.enabled?).must_equal true
      end
    end

    describe "run_capture_ready" do
      before { commit_repo_with_message("first commit!") }
      after { teardown_repo }

      it "posts lolcommit as a new file message to Flowdock" do
        in_repo do
          plugin.configuration = plugin_config
          message_url = "https://api.flowdock.com/flows/#{plugin_config[:organization]}/#{plugin_config[:flow]}/messages"
          valid_response = { id: "123", event: "file", tags: ["lolcommits"]}

          stub_request(:post, message_url).to_return(status: 200, body: valid_response.to_json)

          output = fake_io_capture do
            plugin.run_capture_ready
          end

          _(output).must_equal "Posting to Flowdock ... done!\n"
          assert_requested :post, message_url, times: 1, headers: {
              'Content-Type' => /multipart\/form-data/,
              'Host' => Lolcommits::Flowdock::Client::API_HOST
            } do |req|
            _(req.body).must_match(/Content-Disposition: form-data;.+name="content"; filename="lolcommit.jpg.+"/)
            _(req.body).must_match(/Content-Disposition: form-data;.+name="tags\[\]"/)
          end
        end
      end
    end

    describe "configuration" do
      it "allows plugin options to be configured" do
        # enabled, access token, organization and flow
        access_token = "mytoken"
        configured_plugin_options = {}

        stub_request(:get, "https://api.flowdock.com/organizations").to_return(
          status: 200,
          body: [
            { name: "My Org", parameterized_name: "myorgparam" },
            { name: "Another", parameterized_name: "anotherorg" }
          ].to_json
        )

        stub_request(:get, "https://api.flowdock.com/flows").to_return(
          status: 200,
          body: [
            { name: "Flowtwo", parameterized_name: "anotherflow" },
            { name: "My Flow", parameterized_name: "myflowparam" }
          ].to_json
        )

        # fake readline input and redirect output to a file
        Readline.input = File.new("./test/readline/config_input.txt", "r")
        Readline.output = File.new("./test/readline/config_output.txt", "w+")
        output = fake_io_capture(inputs: ["true", access_token]) do
          configured_plugin_options = plugin.configure_options!
        end

        _(output).must_match(/Enter your Flowdock organization name \(tab to autocomplete, Ctrl\+c cancels\)/)
        _(output).must_match(/e.g. Another, My Org/)
        _(output).must_match(/Enter your Flowdock flow name \(tab to autocomplete, Ctrl\+c cancels\)/)
        _(output).must_match(/e.g. Flowtwo, My Flow/)

        _(configured_plugin_options).must_equal({
          enabled: true,
          access_token: access_token,
          organization: "myorgparam",
          flow: "myflowparam"
        })
      end
    end
  end
end
