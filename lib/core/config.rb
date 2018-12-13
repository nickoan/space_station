module SpaceStation
  class Config

    def initialize
      @config_type = :ruby
      @path = 'configure'
    end

    def set(name, value)
      raise ConfigOperationError, 'should use set method in .rb files' unless @config_type == :ruby
      @config_data[name] = value
    end

    def file_type(option)
      @config_type = option.to_sym
    end

    def file_path(path)
      @path = path
    end

    def options
      load_config_file
      @config_data.dup
    end

    private

    def load_config_file
      case @config_type
      when :ruby
        @config_data = {}
        code = File.read(filename)
        instance_eval(code)
      else
        raise UnknownConfigType
      end
    end

    def filename
      return @path if @path.match(/\.(json|rb)$/)
      case @config_type
      when :ruby
        "#{@path}.rb"
      when :json
        "#{@path}.json"
      else
        raise UnknownConfigType
      end
    end

  end
end