require "simple_spark"

module T
  module Mailer
    module Api
      module SparkPost
        class Transmissions
          include Helper

          attr_reader :settings

          # Set settings and check if the required credential exists. If the
          # credential is missing then it will raise error.
          #
          # @param [Hash] with the credentials
          def initialize(options)
            @settings = options

            check_settings(:sparkpost_api_key)
          end

          # Creates a client which will connect to server via API
          def client
            SimpleSpark::Client.new(api_key: settings[:sparkpost_api_key])
          end

          # The following attribute should be set in the content object when sending
          # RFC822 content as the transmission's content:
          #
          # Request
          #
          # POST /api/v1/transmissions/{?num_rcpt_errors}
          # {
          #   "description": "Christmas Campaign Email",
          #   "recipients": [
          #     {
          #       "address": {
          #         "email": "wilma@flintstone.com",
          #         "name": "Wilma Flintstone"
          #       },
          #       "substitution_data": {
          #         "first_name": "Wilma",
          #         "customer_type": "Platinum",
          #         "year": "Freshman"
          #       }
          #     }
          #   ],
          #   "content": {
          #     "email_rfc822": "Content-Type: text/plain\r\nTo: \"{{address.name}}\"
          #                      <{{address.email}}>\r\n\r\n Hi {{first_name}} \nSave
          #                      big this Christmas in your area {{place}}! \nClick
          #                      http://www.mysite.com and get huge discount\n Hurry,
          #                      this offer is only to {{customer_type}}\n {{sender}}\r\n"
          #   }
          # }
          # Response
          #
          # {
          #   "results": {
          #     "total_rejected_recipients": 0,
          #     "total_accepted_recipients": 2,
          #     "id": "11668787484950529"
          #   }
          # }
          #
          # @param [Hash] with the details of the email
          #
          # @return [Hash] with the server response
          def create(attrs)
            client.transmissions.create(attrs)
          end
        end
      end
    end
  end
end
