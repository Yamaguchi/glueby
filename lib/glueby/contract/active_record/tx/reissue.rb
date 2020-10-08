module Glueby
  module Contract
    module AR
      module Tx
        class Reissue < ::ActiveRecord::Base
          include Tx::TxValidator

          belongs_to :token
          enum status: { init: 0, broadcasted: 1, finalized: 2 }
          validates :token, presence: true
        end
      end
    end
  end
end
