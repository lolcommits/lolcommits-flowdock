# frozen_string_literal: true

require 'lolcommits/plugin/base'
require 'lolcommits/cli/launcher'
require 'lolcommits/flowdock/client'
require 'readline'

module Lolcommits
  module Plugin
    class Flowdock < Base

      ##
      # Prompts the user to configure plugin options. Options are enabled
      # (true/false), a Flowdock Personal API token, and the Flowdock
      # organization and flow names.
      #
      # @return [Hash] a hash of configured plugin options
      #
      def configure_options!
        options = super
        if options[:enabled]
          puts "\nCopy (or create) your Flowdock personal API token (paste it below)"
          open_url("https://flowdock.com/account/tokens")
          print "API token: "
          access_token = gets.strip
          flowdock.access_token = access_token

          organization = configure_organization
          flow         = configure_flow
          raise Interrupt unless flow && organization

          options.merge!(
            access_token: access_token,
            flow: flow,
            organization: organization
          )
        end

        options
      end

      ##
      # Post-capture hook, runs after lolcommits captures a snapshot. Posts the
      # lolcommit image (as a file message) to the configured Flowdock flow.
      #
      # @return [Hash] JSON response object (newly created message hash)
      # @return [Nil] if an error occurs
      #
      def run_capture_ready
        print "Posting to Flowdock ... "
        message = flowdock.create_message(
          organization: configuration[:organization],
          flow: configuration[:flow],
          params: {
            event: 'file',
            content: File.new(runner.lolcommit_path),
            tags: %w(lolcommits)
          }
        )
        print "done!\n"
        message
      rescue Lolcommits::Flowdock::RequestFailed => e
        print "failed :( (try again with --debug)\n"
        log_error(e, "ERROR: POST to Flowdock FAILED - #{e.message}")
        nil
      end


      private

      def configure_organization
        orgs = flowdock.organizations
        if orgs.empty?
          puts "\nNo Flowdock organizations found, please check your account at flowdock.com"
          nil
        else
          puts "\nEnter your Flowdock organization name (tab to autocomplete, Ctrl+c cancels)"
          prompt_autocomplete_hash("Organization: ", orgs, value: "parameterized_name")
        end
      end

      def configure_flow
        flows = flowdock.flows
        if flows.empty?
          puts "\nNo Flowdock flows found, please check your account at flowdock.com"
          nil
        else
          puts "\nEnter your Flowdock flow name (tab to autocomplete, Ctrl+c cancels)"
          prompt_autocomplete_hash("Flow: ", flows, value: "parameterized_name")
        end
      end

      def open_url(url)
        Lolcommits::CLI::Launcher.open_url(url)
      end

      def flowdock
        @flowdock ||= Lolcommits::Flowdock::Client.new(
          configuration[:access_token]
        )
      end
    end
  end
end
