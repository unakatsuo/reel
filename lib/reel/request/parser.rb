require 'puma'

module Reel
  # Parses incoming HTTP requests
  class Request
    class Parser
      attr_reader :headers
    
      def initialize
        @parser = Puma::HttpParser.new
        @params = {}
        @read_body = false
        @position = 0
      end

      def add(data)
        @parser.execute @params, data, @position
        @position += data.size
        on_headers_complete(@params) if @parser.finished?
      end
      alias_method :<<, :add

      def headers?
        !!@params
      end
    
      def http_method
        @params[Puma::Const::REQUEST_METHOD].downcase.to_sym
      end
    
      def http_version
        @params[Puma::Const::HTTP_VERSION][%r{^HTTP/(\d+.\d+)}, 1]
      end
    
      def url
        @params[Puma::Const::REQUEST_URI]
      end

      #
      # Http::Parser callbacks
      #
    
      def on_headers_complete(headers)
        @headers = headers
      end
    
      def on_body(chunk)
        # FIXME: handle request bodies
      end

      def on_message_complete
        @read_body = true
      end    
    end
  end
end