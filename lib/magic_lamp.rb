module MagicLamp
  LAMP = "_lamp"
  MAGIC_LAMP = "magic#{LAMP}"
  SPEC = "spec"
  STARS = "**"
  TEST = "test"
  TMP = "tmp"
  TMP_PATH = [TMP, MAGIC_LAMP]

  class << self
    attr_accessor :registered_fixtures

    def path
      Rails.root.join(directory_path)
    end

    def register_fixture(controller_class, fixture_name, &block)
      raise "MagicLamp#register_fixture requires a block" if block.nil?
      registered_fixtures[fixture_name] = [controller_class, block]
    end

    def load_lamp_files
      self.registered_fixtures = {}
      load_all(Dir[path.join(STARS, "*#{LAMP}.rb")])
    end

    def generate_fixture(fixture_name)
      load_lamp_files
      unless registered_fixtures.key?(fixture_name)
        raise "'#{fixture_name}' is not a registered fixture"
      end
      controller_class, block = registered_fixtures[fixture_name]
      FixtureCreator.new.generate_template(controller_class, &block)
    end

    def create_fixture(fixture_name, controller_class, &block)
      FixtureCreator.new.create_fixture(fixture_name, controller_class, &block)
    end

    def create_fixture_files
      create_tmp_directory
      load_lamp_files
    end

    def tmp_path
      Rails.root.join(*TMP_PATH)
    end

    def create_tmp_directory
      FileUtils.mkdir_p(tmp_path)
    end

    def remove_tmp_directory
      FileUtils.rm_rf(tmp_path)
    end

    private

    def directory_path
      Dir.exist?(Rails.root.join(SPEC)) ? SPEC : TEST
    end

    def load_all(files)
      files.each { |file| load file }
    end
  end
end

require "fileutils"
require "magic_lamp/fixture_creator"
require "magic_lamp/render_catcher"
require "tasks/magic_lamp_tasks"
