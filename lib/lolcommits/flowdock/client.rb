# frozen_string_literal: true

require 'rest_client'
require 'json'

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
      def organizations
        get(organizations_url)
      end

      # GET /flows
      def flows
        get(flows_url)
      end

      # POST /flows/:organization/:flow/messages
      def create_message(organization: nil, flow: nil, params: {})
        post(messages_url(organization, flow), params)
      end

      private

      def post(*args)
        request(*args, :post)
      end

      def get(*args)
        request(*args)
      end

      def request(url, params = {}, method = :get)
        response = RestClient.send(method, url, params)
        if response.code.to_s =~ /^2/
          JSON.parse(response)
        else
          raise RestClient::RequestFailed.new(response)
        end
      rescue RestClient::RequestFailed, JSON::ParserError => e
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
    end
  end
end
