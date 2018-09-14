require 'forwardable'

module JsonApiClient
  class ResultSet < Array
    extend Forwardable

    attr_accessor :errors,
                  :record_class,
                  :meta,
                  :pages,
                  :uri,
                  :links,
                  :implementation,
                  :relationships,
                  :included

    # pagination methods are handled by the paginator
    def_delegators :pages, :total_pages, :total_entries, :total_count, :offset, :per_page, :current_page, :limit_value, :next_page, :previous_page, :out_of_bounds?

    def has_errors?
      errors.present?
    end

    def data_for(method_name, definition)
      # If data is defined, pull the record from the included data
      return nil unless data = definition["data"]

      if data.is_a?(Array)
        # has_many link
        data.map do |link_def|
          record_for(link_def)
        end
      else
        # has_one link
        record_for(data)
      end
    end

    def record_for(link_def)
      detect { |record| record.type == link_def["type"] && record.id == link_def["id"] }
    end

  end
end
