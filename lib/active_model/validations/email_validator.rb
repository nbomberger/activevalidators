require 'mail'
module ActiveModel
  module Validations
    class EmailValidator < EachValidator
      def validate_each(record, attribute, value)
        # takes from: https://github.com/hallelujah/valid_email
        begin
          mail = Mail::Address.new(value)
          # We must check that value contains a domain and that value is an email address
          valid = mail.domain && value.include?(mail.address)

          if options[:only_address]
            # We need to dig into treetop
            # A valid domain must have dot_atom_text elements size > 1
            # user@localhost is excluded
            # treetop must respond to domain
            # We exclude valid email values like <user@localhost.com>
            # Hence we use m.__send__(tree).domain
            tree = mail.__send__(:tree)
            valid &&= (tree.domain.dot_atom_text.elements.size > 1)
          else
            valid &&= (mail.domain.split('.').length > 1)
          end
        rescue Exception => e
          valid = false
        end
        record.errors.add attribute, (options[:message]) unless valid
      end
    end
  end
end
