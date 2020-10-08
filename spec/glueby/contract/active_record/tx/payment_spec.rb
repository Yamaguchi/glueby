# frozen_string_literal: true

require 'active_record'

RSpec.describe 'Glueby::Contract::AR::Tx::Payment' do
  def setup_database
    ::ActiveRecord::Base.establish_connection(config)
    connection = ::ActiveRecord::Base.connection
    connection.create_table :payments do |t|
      t.string     :txid, null: true
      t.integer    :status, null: false
      t.bigint     :amount, null: false
      t.string     :sender_wallet_id, null: false
      t.string     :receiver_wallet_id, null: false
      t.timestamps
    end

    connection.add_index :payments, [:txid], unique: true
  end

  let(:config) { { adapter: 'sqlite3', database: 'test' } }

  before { setup_database }
  after do
    connection = ::ActiveRecord::Base.connection
    connection.drop_table :payments, if_exists: true
  end

  describe '#valid?' do
    subject { tx.valid? }

    let(:tx) { Glueby::Contract::AR::Tx::Payment.new(sender_wallet_id: sender_wallet_id, receiver_wallet_id: receiver_wallet_id, amount: amount, txid: txid, status: status) }
    let(:sender_wallet_id) { '00000000000000000000000000000001' }
    let(:receiver_wallet_id) { '00000000000000000000000000000002' }
    let(:amount) { 1 }
    let(:txid) { '0000000000000000000000000000000000000000000000000000000000000001' }
    let(:status) { :init }

    it { is_expected.to be_truthy }
    
    context 'if sender_wallet_id is invalid' do
      let(:sender_wallet_id) { '00000000000000000000000000000001F' }

      it { is_expected.to be_falsy }
    end

    context 'if receiver_wallet_id is invalid' do
      let(:sender_wallet_id) { '00000000000000000000000000000002F' }

      it { is_expected.to be_falsy }
    end

    context 'if amount is not positive' do
      let(:amount) { 0 }

      it { is_expected.to be_falsy }
    end

    context 'if txid is invalid' do
      let(:txid) { '0000000000000000000000000000000000000000000000000000000000000001F' }

      it { is_expected.to be_falsy }
    end

    context 'if txid is empty' do
      let(:txid) { nil }

      it { is_expected.to be_truthy }
    end
  end
end
