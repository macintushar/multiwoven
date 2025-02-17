# frozen_string_literal: true

class AlertChannel < ApplicationRecord
  belongs_to :alert
  belongs_to :alert_medium

  def send_success_alert(sync_attrs)
    SyncAlertMailer.new.sync_success_email(sync_attrs.merge({ recipients: })).deliver_now
  end

  def send_failure_alert(sync_attrs)
    SyncAlertMailer.new.sync_failure_email(sync_attrs.merge({ recipients: })).deliver_now
  end

  def send_row_failure_alert(sync_attrs)
    SyncAlertMailer.new.sync_row_failure_email(sync_attrs.merge({ recipients: })).deliver_now
  end

  delegate :platform, to: :alert_medium

  private

  def recipients
    email? ? email_recipients : slack_recipients
  end

  def email_recipients
    (configuration[:extra_email_recipients] || []).merge(alert.workspace.admin_user_emails).uniq
  end

  def slack_recipients
    configuration[:slack_email_alias].uniq
  end
end
