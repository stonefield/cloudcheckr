module CloudCheckr
  module API
    class ResponseError < StandardError

      def initialize(data)
        message       = data['Message']
        model_state   = data['ModelState']
        error_code    = model_state['ErrorCode'].join(', ')
        error_message = model_state['ErrorMessage'].join(', ')

        super("#{message} (#{error_code}: #{error_message})")
      end

    end
  end
end