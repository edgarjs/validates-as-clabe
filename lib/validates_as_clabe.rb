module Mimbles # :nodoc:
  module ClabeValidator # :nodoc:
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      # Main method, call it as any other validation
      #   validates_as_clabe :bank_account, :if => :should_validate_clabe?
      def validates_as_clabe(*attr_names)
        extend Mimbles::ClabeValidator::SingletonMethods
        
        configuration = { :message => ActiveRecord::Errors.default_error_messages[:invalid],
          :on => :save }
        configuration.update(attr_names.pop) if attr_names.last.is_a?(Hash)

        validates_each(attr_names, configuration) do |record, attr_name, value|
          record.errors.add(attr_name, configuration[:message]) unless self.valid_clabe?(value.to_s)
        end
      end
    end
  
    module SingletonMethods
      # Validates a given CLABE number
      def valid_clabe?(clabe)
        return false unless clabe.length == 18
    
        result_acc = ""
        sum = 0
        dv, check_acc = clabe.split(/(\d{17})(\d)/).reverse
        check_acc.length.times do |i|
          if i % 3 == 0 && i < 16
            validator = 3
          else
            validator = case i
            when 1, 4, 7, 10, 13, 16 then 7
            else 1
            end
          end
          temp = (check_acc[0, i + 1][-1, 1].to_i * validator).to_s[-1, 1]
          result_acc << temp
        end
        result_acc.length.times do |i|
          sum += result_acc[0, i + 1][-1, 1].to_i
        end
        dc = 0 if (10 - sum.to_s[-1, 1].to_i) == 10
        dc.to_s == dv
      end
    end
  end
end