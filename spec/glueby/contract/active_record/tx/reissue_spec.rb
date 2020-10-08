# frozen_string_literal: true

require 'active_record'

RSpec.describe 'Glueby::Contract::AR::Tx::Reissue' do
  def setup_database
    ::ActiveRecord::Base.establish_connection(config)
    connection = ::ActiveRecord::Base.connection
    connection.create_table :reissues do |t|
      t.string     :txid, null: true
      t.integer    :status, null: false
      t.bigint     :amount, null: false
      t.belongs_to :token, null: false
      t.timestamps
    end

    connection.add_index :reissues, [:txid], unique: true

    connection.create_table :tokens do |t|
      t.integer :token_type, null: false
      t.string :color_id, null: true
      t.string :script_pubkey, null: true
      t.string :issuer_wallet_id, null: false
      t.timestamps
    end

    connection.add_index :tokens, [:color_id], unique: true
    connection.add_index :tokens, [:token_type]
    connection.add_index :tokens, [:script_pubkey], unique: true
    connection.add_index :tokens, [:issuer_wallet_id]
  end

  let(:config) { { adapter: 'sqlite3', database: 'test' } }

  before { setup_database }
  after do
    connection = ::ActiveRecord::Base.connection
    connection.drop_table :reissues, if_exists: true
    connection.drop_table :tokens, if_exists: true
  end

  describe '#valid?' do
    subject { tx.valid? }

    let(:tx) { Glueby::Contract::AR::Tx::Reissue.new(amount: amount, txid: txid, status: status, token: token) }
    let(:amount) { 1 }
    let(:txid) { '0000000000000000000000000000000000000000000000000000000000000001' }
    let(:status) { :init }
    let(:token) { Glueby::Contract::AR::Token.new(token_type: token_type, color_id: color_id, script_pubkey: script_pubkey, issuer_wallet_id: issuer_wallet_id) }
    let(:token_type) { Tapyrus::Color::TokenTypes::REISSUABLE }
    let(:color_id) { 'c10000000000000000000000000000000000000000000000000000000000000000' }
    let(:script_pubkey) { '0000000000000000000000000000000000000000' }
    let(:issuer_wallet_id) { '00000000000000000000000000000001' }

    it { is_expected.to be_truthy }

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

    context 'if token is not present' do
      let(:token) { nil }

      it { is_expected.to be_falsy }
    end
  end
end
