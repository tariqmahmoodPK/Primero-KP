# frozen_string_literal: true

# Main API controller for Prevention Components Records
class Api::V2::PreventionsController < ApplicationApiController
  include Api::V2::Concerns::Pagination
  include Api::V2::Concerns::Record

end
