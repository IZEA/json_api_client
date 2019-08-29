module JsonApiClient
  module Associations
    class BaseAssociation
      attr_reader :attr_name, :klass, :options
      def initialize(attr_name, klass, options = {})
        @attr_name = attr_name
        @klass = klass
        @options = options
      end

      def association_class
        @association_class ||= if options[:class_resolver]
          options[:class_resolver].call
        else
          class_name = options.fetch(:class_name) { attr_name.to_s.classify }
          Utils.compute_type(klass, class_name)
        end
      end

      def data(url)
        from_result_set(association_class.requestor.linked(url))
      end

      def from_result_set(result_set)
        result_set.to_a
      end

      def resolve_class(record)
        if options[:class_resolver]
          options[:class_resolver].call(record)
        else
          Utils.compute_type(klass, record["type"].classify)
        end
      end

      def load_records(data)
        data.map do |d|
          # record_class = Utils.compute_type(klass, d["type"].classify)
          record_class = resolve_class(d)
          record_class.load id: d["id"]
        end
      end
    end
  end
end
