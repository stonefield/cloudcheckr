module CloudCheckr
  module API
    class Controller
      
      attr_reader :client

      def initialize(client)
        @client = client
      end

    end
  end
end