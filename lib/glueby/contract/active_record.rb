require 'active_record'

module Glueby
  module Contract
    module AR
      autoload :Timestamp, 'glueby/contract/active_record/timestamp'
      autoload :Token, 'glueby/contract/active_record/token'
      autoload :Tx, 'glueby/contract/active_record/tx'
    end
  end
end
