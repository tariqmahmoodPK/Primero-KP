# frozen_string_literal: true

# Enpoint for triggering an export of records
module Api::V2::Concerns::Export
  extend ActiveSupport::Concern

  def export
    authorize_export!

    # The '::' is necessary so Export model does not conflict with current concern
    @export = ::Export.new(
      exporter: exporter, record_type: record_type, module_id: module_id,
      file_name: export_params[:file_name], visible: visible_param,
      managed_report: @managed_report, opts: export_params
    )
    @export.run
    status = @export.status == ::Export::SUCCESS ? 200 : 422
    render 'api/v2/exports/export', status: status
  end

  def record_type
    export_params[:record_type]
  end

  def module_id
    export_params[:module_id]
  end

  def visible_param
    return nil if export_params[:visible].nil?

    export_params[:visible]&.start_with?(/[yYTt]/) ? true : false
  end

  def export_params
    params.permit(:record_type, :module_id, :file_name, :visible)
  end

  def authorize_export!
    authorize! :export, model_class
  end
end
