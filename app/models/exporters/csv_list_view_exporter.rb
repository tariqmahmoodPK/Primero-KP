# frozen_string_literal: true

require 'csv'

# Export as CSV the record list that the user sees.
class Exporters::CsvListViewExporter < Exporters::BaseExporter
  class << self
    def id
      'list_view_csv'
    end

    def mime_type
      'csv'
    end

    def supported_models
      [Child, Incident, TracingRequest]
    end
  end

  def initialize(output_file_path = nil, config = {}, options = {})
    super(output_file_path, config, options)
    @record_data_service = RecordDataService.new
    self.locale = user.locale
  end

  def setup_export_constraints?
    false
  end

  def export(records)
    csv_export = build_csv_export(records, list_headers)
    buffer.write(csv_export)
  end

  def build_csv_export(records, list_headers)
    CSVSafe.generate do |rows|
      next unless list_headers

      rows << headers(list_headers) if @called_first_time.nil?
      @called_first_time ||= true

      records.each do |record|
        rows << row(record)
      end
    end
  end

  def list_headers
    return @list_headers if @list_headers

    @list_headers = record_type && Header.get_headers(user, record_type)
  end

  def headers(list_headers)
    list_headers.map do |header|
      I18n.t("#{record_type.pluralize}.#{header.name}", default: '', locale: locale)
    end
  end

  def row(record)
    field_names = list_headers.map(&:field_name)
    data = @record_data_service.data(record, user, field_names)
    header_fields = header_fields(list_headers)
    list_headers.map do |header|
      field = header_fields.find { |f| f.name == header.field_name }
      export_value(data[header.field_name], field)
    end
  end

  def header_fields(list_headers)
    return @header_fields if @header_fields

    field_names = list_headers.map(&:field_name)
    @header_fields = Field.where(name: field_names).uniq(&:name)
  end
end
