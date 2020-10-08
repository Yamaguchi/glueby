module Glueby
  module Contract
    module AR
      module Tx
        class Issue < ::ActiveRecord::Base
          include Tx::TxValidator

          belongs_to :token
          enum status: { init: 0, broadcasted: 1, finalized: 2 }
          validates :receiver_wallet_id, format: { with: /\A[[:xdigit:]]{32}\z/ }, presence: true
          validates :token, presence: true
        end
      end
    end
  end
end
