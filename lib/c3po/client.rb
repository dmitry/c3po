# encoding: utf-8
class C3po
  module Client

    attr_accessor :request

    # Query a web service.
    #
    # Returns a translated string or an array of errors.
    #
    # @exemple :
    #   fetch {:key => 'MYAPIKEY',
    #          :q => 'Something to translate'
    #         }
    #
    # @params [Hash] Query containing all the params.
    #
    # @return [String] Translated string.
    #         [Array]  Errors.
    #
    # @since 0.0.1
    #
    def fetch(query)
      request = Typhoeus::Request.new @base, :params => query

      request.on_complete do |response|
        if response.success?
          begin
            @result = parse response.body
          rescue
            @errors << 'Invalid response'
          end
        elsif response.timed_out?
          @errors << 'timeout'
        elsif response.code == 0
          @errors << response.curl_error_message
        else
          @errors << "HTTP request failed: #{response.code}"
        end
      end

      hydra = Typhoeus::Hydra.hydra
      hydra.queue request
      hydra.run
      @errors.empty? ? @result : @errors
    end

  end # Client
end # C3po
