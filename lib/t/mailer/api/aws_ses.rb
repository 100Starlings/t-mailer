require "aws-sdk-ses"

module T
  module Mailer
    module Api
      class AwsSes
        include Helper

        attr_reader :settings

        # Set settings and check if the required credentials are exist. If the
        # credentials are missing then it will raise error.
        #
        # @param [Hash] options with the credentials
        def initialize(options)
          @settings = options

          check_settings(:aws_access_key_id, :aws_default_region,
            :aws_secret_access_key)
        end

        # Creates a client which will connect to server via API
        def client
          credentials = Aws::Credentials.new(settings[:aws_access_key_id],
            settings[:aws_secret_access_key])
          region = settings[:aws_default_region]

          Aws::SES::Client.new(credentials: credentials, region: region)
        end

        # Composes an email message and immediately queues it for sending. When
        # calling this operation, you may specify the message headers as well as
        # the content. The `SendRawEmail` operation is particularly useful for
        # sending multipart MIME emails (such as those that contain both a
        # plain-text and an HTML version).
        #
        # @example Example: SendRawEmail
        #
        #   # The following example sends an email with an attachment:
        #
        #   resp = client.send_raw_email({
        #     destinations: [
        #     ],
        #     from_arn: "",
        #     raw_message: {
        #       data: "From: sender@example.com\\nTo: recipient@example.com\\n
        #              Subject: Test email (contains an attachment)\\n
        #              MIME-Version: 1.0\\nContent-type: Multipart/Mixed;
        #              boundary=\"NextPart\"\\n\\n--NextPart\\n
        #              Content-Type: text/plain\\n\\nThis is the message body.\\n\\n
        #              --NextPart\\n
        #              Content-Type: text/plain;\\n
        #              Content-Disposition: attachment; filename=\"attachment.txt\"
        #              \\n\\nThis is the text in the attachment.\\n\\n--NextPart--",
        #     },
        #     return_path_arn: "",
        #     source: "",
        #     source_arn: "",
        #   })
        #
        #   resp.to_h outputs the following:
        #   {
        #     message_id: "EXAMPLEf3f73d99b-c63fb06f-d263-41f8-a0fb-d0dc67d56c07-000",
        #   }
        #
        # @example Request syntax with placeholder values
        #
        #   resp = client.send_raw_email({
        #     source: "Address",
        #     destinations: ["Address"],
        #     raw_message: {                                  # required
        #       data: "data",                                 # required
        #     },
        #     from_arn: "AmazonResourceName",
        #     source_arn: "AmazonResourceName",
        #     return_path_arn: "AmazonResourceName",
        #     tags: [
        #       {
        #         name: "MessageTagName",                     # required
        #         value: "MessageTagValue",                   # required
        #       },
        #     ],
        #     configuration_set_name: "ConfigurationSetName",
        #   })
        #
        # @example Response structure
        #
        #   resp.message_id #=> String
        #
        # @overload send_raw_email(params = {})
        #
        # @param [Hash] params with the details of the email
        #
        # @return [Object]
        #   #<struct Aws::SES::Types::SendRawEmailResponse message_id="an_id">
        def send_raw_email(params = {})
          client.send_raw_email(params)
        end
      end
    end
  end
end
