# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reports::ActivityReport do
  let(:workspace) { create(:workspace) }
  let(:sync_run) { create(:sync_run, workspace:, total_rows: 2, successful_rows: 1, failed_rows: 1, error: "failed") }
  let(:connector_id) { sync_run.source_id }
  let(:start_time) { 1.week.ago.beginning_of_day }
  let(:end_time) { Time.zone.now }
  let(:interval) { (((end_time - start_time) / 60) / Reports::ActivityReport::SLICE).to_i }

  describe "#call" do
    context "when type is workspace_activity" do
      it "generates workspace activity report" do
        report_params = { workspace:, type: "workspace_activity", connector_id: }
        result = described_class.call(report_params)

        expect(result.success?).to eq(true)
        expect(result.workspace_activity)
        expect(result.workspace_activity).to include(
          sync_run_triggered: a_kind_of(Array),
          total_sync_run_rows: a_kind_of(Array)
        )
        sync_run_triggered = result.workspace_activity.with_indifferent_access[:sync_run_triggered]
        expect(sync_run_triggered.count).to eq(1)
        expect(sync_run_triggered[0]["time_slice"]).not_to be_nil
        expect(sync_run_triggered[0]["total_count"]).to eq(1)
        expect(sync_run_triggered[0]["success_count"]).to eq(0)
        expect(sync_run_triggered[0]["failed_count"]).to eq(1)

        total_sync_run_rows = result.workspace_activity.with_indifferent_access[:total_sync_run_rows]
        expect(total_sync_run_rows.count).to eq(1)
        expect(total_sync_run_rows[0]["time_slice"]).not_to be_nil
        expect(total_sync_run_rows[0]["total_count"]).to eq(2)
        expect(total_sync_run_rows[0]["success_count"]).to eq(1)
        expect(total_sync_run_rows[0]["failed_count"]).to eq(1)
      end
    end

    context "with invalide type" do
      it "raises an error" do
        expect do
          described_class.call(type: "invalid", metric: "total_sync_run_rows", connector_id: 1, time_period: "one_week")
        end.to raise_error(ArgumentError)
      end
    end
  end

  describe "private methods" do
    let(:report_params) { { workspace:, type: "workspace_activity", connector_id: } }
    let(:result) { described_class.new(report_params) }

    describe "#fetch_sync_activity" do
      it "fetches sync activity within specified time range" do
        sync_activity = result.send(:fetch_sync_activity, start_time, end_time)
        expect(sync_activity).not_to be_empty
        expect(sync_activity.pluck(:workspace_id).uniq).to eq([workspace.id])
      end
    end

    describe "#calculate_start_time" do
      it "calculates start time correctly for one_week" do
        expect(result.send(:calculate_start_time, "one_week")).to eq(1.week.ago.beginning_of_day)
      end

      it "calculates start time correctly for one_day" do
        expect(result.send(:calculate_start_time, "one_day")).to eq(1.day.ago.beginning_of_day)
      end
    end
  end
end
