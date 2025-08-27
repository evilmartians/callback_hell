# frozen_string_literal: true

module CallbackHell
  class Callback
    attr_reader :model, :method_name, :conditional, :origin, :inherited, :kind,
      :association_generated, :attribute_generated, :callback, :defining_class,
      :fingerprint

    def initialize(model:, rails_callback:, name:, defining_class:)
      @model = model
      @callback = rails_callback
      @name = name
      @defining_class = defining_class

      analyzer = Analyzers::CallbackAnalyzer.new(@callback, model, defining_class)

      @kind = @callback.kind
      @method_name = @callback.filter
      @conditional = analyzer.conditional?
      @origin = analyzer.origin
      @inherited = analyzer.inherited?
      @association_generated = analyzer.association_generated?
      @attribute_generated = analyzer.attribute_generated?
      # fingerprint allows us to de-duplicate callbacks/validations;
      # in most cases, it's just an object_id, but for named validations/callbacks,
      # it's a combination of the name, kind and the method_name.
      # The "0" and "1" prefixes define how to handle duplicates (1 means last write wins, 0 means first write wins)
      @fingerprint = (@method_name.is_a?(Symbol) && @origin != :rails) ? ["1", @name, @kind, @method_name].join("-") : "0-#{@callback.object_id}"
    end

    def callback_group
      @name.to_s
    end

    def validation_type
      return nil unless callback_group == "validate"
      Analyzers::ValidationAnalyzer.detect_type(@callback.filter, model)
    end

    def human_method_name
      Analyzers::ValidationAnalyzer.human_method_name(@callback.filter)
    end

    def to_s
      [
        "#{model.name}: #{human_method_name}",
        "kind=#{kind}_#{callback_group}",
        "origin=#{origin}",
        inherited ? "inherited=true" : nil,
        conditional ? "conditional=true" : nil,
        association_generated ? "association=true" : nil,
        attribute_generated ? "attribute=true" : nil
      ].compact.join(" ")
    end
  end
end
