module Glueby
  module Contract
    module AR
      module Tx
        class Payment < ::ActiveRecord::Base
          include Tx::TxValidator

          enum status: { init: 0, broadcasted: 1, finalized: 2 }
          validates :sender_wallet_id, format: { with: /\A[[:xdigit:]]{32}\z/ }, presence: true
          validates :receiver_wallet_id, format: { with: /\A[[:xdigit:]]{32}\z/ }, presence: true
        end
      end
    end
  end
end
