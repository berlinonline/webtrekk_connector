require 'net/http'
require 'openssl'
require 'logger'
require 'json'

# This class is a wrapper around the Webtrekk/Mapp Analytics JSON/RPC API.

class WebtrekkConnector

    # Create an instance of WebtrekkConnector.
    #
    # @param conf[Hash] the configuration object for the connector
    # @option conf [String] :endpoint the API endpoint, e.g. +https://xyz.webtrekk.com/cgi-bin/wt/JSONRPC.cgi+ (*required*)
    # @option conf [String] :user the user name to use with the API (*required*)
    # @option conf [String] :pwd the password for +:user+ (*required*)
    # @option conf [String] :customerId the customer Id to used for all requests (optional).
    #   If not set, the id of the first account retrieved via +getAccountList+ will be used.
    # @option conf [Logger] :logger the logging object to use for logging output (optional, _defaults_ _to_ +Logger.new(STDERR)+)
    def initialize(conf)
        @endpoint = conf[:endpoint]
        @user = conf[:user]
        @pwd = conf[:pwd]
        @customerId = conf[:customerId]
        @logger = conf[:logger] ? conf[:logger] : Logger.new(STDERR)
        @logger.info("Connector set up for #{@endpoint}.")
    end

    # Send the actual HTTP(s) request.
    #
    # @param uri[URI] where to send the request
    # @param payload[Object] the payload to be sent, will be converted by calling +payload.to_json+
    #
    # @return [String] the response body
    # @raise [Net::HTTPError] if the response code is not 200
    def make_https_request(uri, payload=nil)
        @logger.info("sending request (method #{payload[:method]}) ...")
        Net::HTTP.start(uri.host, uri.port,
            :use_ssl => uri.scheme == 'https', 
            :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|

            request = Net::HTTP::Post.new(uri.request_uri)
            request.body = payload.to_json

            response = http.request(request)

            if response.code.eql?("200")
                return response.body
            else
                raise Net::HTTPError.new(response.code, response.message)
            end
        end
    end

    # Call a method on the API.
    #
    # @param method[String] the method name
    # @param params[Hash] the method parameters
    #
    # @return [Object] the response body converted to a Ruby object by calling +JSON.parse(response)+
    def call_method(method, params={})
        @logger.info("call_method: #{method}")
        payload = {
            :params => params ,
            :version => "1.1" ,
            :method => method
        }
        response = make_https_request(URI(@endpoint), payload)
        data = JSON.parse(response)
        data['result']
    end

    # Call the +getConnectionTest+ method.
    #
    # @return [Object] the response body as a Ruby object
    def get_connection_test
        response = call_method('getConnectionTest')
    end

    # Get a token from the API by calling the +login+ method.
    #
    # @return [String] the token returned by the API
    def get_token
        unless @customerId
            @customerId = self.get_first_account['customerId']
        end
        params = {
            :login => @user,
            :pass => @pwd ,
            :customerId => @customerId ,
            :language => "en"
        }
        response = call_method('login', params)
    end
    
    # Log into the API by setting the \@token attribute.
    #
    # @return [String] the token returned by the API
    def login
        @token = get_token
    end

    # Get the list of accounts associated with \@user.
    #
    # @return [Array] the list of accounts
    def get_account_list
        params = {
            :login => @user,
            :pass => @pwd ,
        }
        response = call_method('getAccountList', params)
    end

    # Get the first account associated with \@user.
    #
    # @return [Hash] the first account as a Hash
    def get_first_account
        account_list = get_account_list
        account_list.first
    end

    # Call the +getAnalysisData+ method.
    #
    # @param analysis_config[Hash] the +analysisConfig+ object as a Ruby Hash.
    #
    # @return [Hash] the response body converted as a Hash
    def request_analysis(analysis_config)
        params = {
            :token => @token ,
            :analysisConfig => analysis_config
        }
        response = call_method("getAnalysisData", params)
    end

    # Call the +getAnalysisObjectsAndMetricsList+ method.
    #
    # @return [Hash] the response body as a Hash
    def get_analysis_objects_and_metrics_list
        params = {
            :token => @token
        }
        response = call_method("getAnalysisObjectsAndMetricsList", params)
    end

end