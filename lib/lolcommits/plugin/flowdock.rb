require 'lolcommits/plugin/base'
require 'lolcommits/cli/launcher'
require 'rest_client'
require 'json'
# require 'lolcommits/flowdock/client'

module Lolcommits
  module Flowdock
    class RequestFailed < StandardError; end

    class Client
      attr_accessor :access_token, :organization, :flow

      API_HOST = 'api.flowdock.com'

      def initialize(access_token, organization: nil, flow: nil)
        @access_token = access_token
        @organization = organization
        @flow         = flow
      end

      # GET /organizations
      def get_organizations
        make_request { http_client.get(organizations_url) }
      end

      # GET /flows
      def get_flows
        make_request { http_client.get(flows_url) }
      end

      # POST /flows/:organization/:flow/messages
      def create_file_message(file, organization: nil, flow: nil, tags: [])
        make_request do
          http_client.post(
            messages_url(organization, flow),
            event: 'file',
            tags: tags,
            content: file
          )
        end
      end

      private

      def make_request
        response = yield
        if response.code.to_s =~ /^20/
          JSON.parse(response)
        else
          raise RestClient::RequestFailed.new(response)
        end
      rescue RestClient::RequestFailed => e
        raise Flowdock::RequestFailed.new(e.message)
      end

      def base_url
        "https://#{access_token}@#{API_HOST}"
      end

      def organizations_url
        "#{base_url}/organizations"
      end

      def flows_url
        "#{base_url}/flows"
      end

      def messages_url(organization, flow)
        "#{base_url}/flows/#{organization}/#{flow}/messages"
      end

      def http_client
        RestClient
      end
    end
  end


  module Plugin
    class Flowdock < Base

      ##
      # Returns the name of the plugin to identify the plugin to lolcommits.
      #
      # @return [String] the plugin name
      #
      def self.name
        'flowdock'
      end

      ##
      # Returns position(s) of when this plugin should run during the capture
      # process. Uploading happens when a new capture is ready.
      #
      # @return [Array] the position(s) (:capture_ready)
      #
      def self.runner_order
        [:capture_ready]
      end

      ##
      # Returns true if the plugin has been configured.
      #
      # @return [Boolean] true/false indicating if plugin is configured
      #
      def configured?
        !configuration['access_token'].nil?
      end

      ##
      # Prompts the user to configure plugin options.
      # Options are enabled (true/false), API token, flow and organization name
      #
      # @return [Hash] a hash of configured plugin options
      #
      def configure_options!
        options = super
        if options['enabled']
          print "Open the URL below and issue a token for your user (Personal API token):\n"
          print "https://flowdock.com/account/tokens\n"
          print "Enter the generated token below, then press enter: \n"
          code = gets.to_s.strip
          print "Enter the machine name of the flow you want to post to from this repo.\n"
          print "Go to https://www.flowdock.com/account and click Flows, then click the flow, then get the machine name from the URL:\n"
          flow = gets.to_s.strip.downcase
          print "Enter the name of the organization for this Flowdock account.\n"
          organization = gets.to_s.strip.downcase

          options.merge!(
            'access_token' => code,
            'flow' => flow,
            'organization' => organization
          )
        end
        options
      end

      ##
      # Post-capture hook, runs after lolcommits captures a snapshot. Uploads
      # the lolcommit image to the Flowdock flow (room).
      #
      # @return [Hash]] JSON hash object from a sucessful POST request
      # @return [Nil] if any error occurs
      #
      def run_capture_ready
        print "Posting to Flowdock ... "
        message = flowdock.create_file_message(
          lolcommits_image,
          organization: configuration['organization'],
          flow: configuration['flow'],
          tags: %w(lolcommits)
        )
        print "done!\n" if message['thread_id']
      rescue Lolcommits::Flowdock::RequestFailed => e
        print "failed :( (try again with --debug)\n"
        log_error(e, "ERROR: POST to Flowdock FAILED - #{e.message}")
        nil
      end

      private

      def lolcommits_image
        File.new(runner.main_image)
      end

      def flowdock
        @flowdock ||= Lolcommits::Flowdock::Client.new(configuration['access_token'])
      end
    end
  end
end
