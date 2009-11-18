module ValidatesAsFragment
  class FormScanner
    attr_reader :object

    def initialize(*args)
      @controller, @object, @partials, @path = *args
      @path ||= @object.class.name.underscore.pluralize
    end
  
    def fragment
      @partials.find do |partial|
        @fields = []
        @controller.send(:render_to_string, :partial => File.join(@path, partial), :locals => {:form => self})
        @fields.uniq!
        @object.errors.clear unless @object.valid_fragment?(@fields)
      end
    end
  
    def method_missing(method_name, *args, &block)
      @fields << args.first if args.first.is_a?(Symbol)
    end
  end
end