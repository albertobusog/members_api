# frozen_string_literal: true

class HealthController < ApplicationController
  def show
    render json: {
      status: "ok",
      environment: Rails.env,
      database: database_status,
      time: Time.current.iso8601
    }
  end

  private

  def database_status
    ActiveRecord::Base.connection.select_value("SELECT 1") == 1 ? "ok" : "error"
  rescue StandardError
    "error"
  end
end
