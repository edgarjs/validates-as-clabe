require 'validates_as_clabe'

ActiveRecord::Base.send(:include, Mimbles::ClabeValidator)