# frozen_string_literal: true

require "rails_helper"

RSpec.describe "SyncRunContracts" do
  subject(:contract) { described_class.new }

  describe SyncRunContracts::Index do
    context "when sync_id is valid" do
      let(:valid_inputs) { { sync_id: 1 } }

      it "passes validation" do
        expect(contract.call(valid_inputs)).to be_success
      end
    end

    context "when sync_id is invalid" do
      let(:invalid_inputs) { { sync_id: "invalid" } }

      it "fails validation" do
        result = contract.call(invalid_inputs)
        expect(result.errors.to_h).to have_key(:sync_id)
        expect(result.errors[:sync_id]).to include("must be an integer")
      end
    end
    context "when page is valid" do
      let(:valid_inputs) { { sync_id: 1, page: 1 } }

      it "passes validation" do
        expect(contract.call(valid_inputs)).to be_success
      end
    end

    context "when page is invalid" do
      let(:invalid_inputs) { { sync_id: 1, page: "a" } }
      it "fails validation" do
        result = contract.call(invalid_inputs)
        expect(result.errors.to_h).to have_key(:page)
        expect(result.errors[:page]).to include("must be an integer")
      end
    end

    context "when status is valid" do
      let(:valid_inputs) { { sync_id: 1, status: SyncRun.statuses.keys.first } }

      it "passes validation" do
        expect(contract.call(valid_inputs)).to be_success
      end
    end

    context "when status is invalid" do
      let(:invalid_inputs) { { sync_id: 1, status: "invalid_status" } }

      it "fails validation" do
        result = contract.call(invalid_inputs)
        expect(result.errors.to_h).to have_key(:status)
        expect(result.errors[:status]).to include("must be a valid status")
      end
    end
  end

  describe SyncRunContracts::Show do
    subject(:contract) { described_class.new }
    context "when sync_id and id are valid" do
      let(:valid_inputs) { { sync_id: 1, id: 1 } }

      it "passes validation" do
        expect(contract.call(valid_inputs)).to be_success
      end
    end

    context "when sync_id is invalid" do
      let(:invalid_inputs) { { sync_id: "invalid", id: 1 } }

      it "fails validation" do
        result = contract.call(invalid_inputs)
        expect(result.errors.to_h).to have_key(:sync_id)
        expect(result.errors[:sync_id]).to include("must be an integer")
      end
    end

    context "when id is invalid" do
      let(:invalid_inputs) { { sync_id: 1, id: "invalid" } }

      it "fails validation" do
        result = contract.call(invalid_inputs)
        expect(result.errors.to_h).to have_key(:id)
        expect(result.errors[:id]).to include("must be an integer")
      end
    end
  end
end
