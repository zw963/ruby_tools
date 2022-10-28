# frozen_string_literal: true

# Laziness copied from rubocop source code
require 'rubocop/rspec/expect_offense'
require 'rubocop/cop/legacy/corrector'

module RuboCop
  module Minitest
    # Mixin for `assert_offense` and `assert_no_offenses`
    #
    # This mixin makes it easier to specify strict offense assertions
    # in a declarative and visual fashion. Just type out the code that
    # should generate a offense, annotate code by writing '^'s
    # underneath each character that should be highlighted, and follow
    # the carets with a string (separated by a space) that is the
    # message of the offense. You can include multiple offenses in
    # one code snippet.
    #
    # @example Usage
    #
    #   assert_offense(<<~RUBY)
    #     class FooTest < Minitest::Test
    #       def test_do_something
    #         assert_equal(nil, somestuff)
    #         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_nil(somestuff)`.
    #       end
    #     end
    #   RUBY
    #
    # Autocorrection can be tested using `assert_correction` after
    # `assert_offense`.
    #
    # @example `assert_offense` and `assert_correction`
    #
    #   assert_offense(<<~RUBY)
    #     class FooTest < Minitest::Test
    #       def test_do_something
    #         assert_equal(nil, somestuff)
    #         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_nil(somestuff)`.
    #       end
    #     end
    #   RUBY
    #
    #   assert_correction(<<~RUBY)
    #     class FooTest < Minitest::Test
    #       def test_do_something
    #         assert_nil(somestuff)
    #       end
    #     end
    #   RUBY
    #
    # If you do not want to specify an offense then use the
    # companion method `assert_no_offenses`. This method is a much
    # simpler assertion since it just inspects the source and checks
    # that there were no offenses. The `assert_offense` method has
    # to do more work by parsing out lines that contain carets.
    #
    # If the code produces an offense that could not be autocorrected, you can
    # use `assert_no_corrections` after `assert_offense`.
    #
    # @example `assert_offense` and `assert_no_corrections`
    #
    #   assert_offense(<<~RUBY)
    #     class FooTest < Minitest::Test
    #       def test_do_something
    #         assert_equal(nil, somestuff)
    #         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer using `assert_nil(somestuff)`.
    #       end
    #     end
    #   RUBY
    #
    #   assert_no_corrections
    module AssertOffense
      private

      def setup
        cop_name = self.class.to_s.delete_suffix('Test')

        @cop = RuboCop::Cop::Minitest.const_get(cop_name).new
      end

      def assert_no_offenses(source, file = nil)
        setup_assertion

        offenses = inspect_source(source, @cop, file)

        expected_annotations = RuboCop::RSpec::ExpectOffense::AnnotatedSource.parse(source)
        actual_annotations = expected_annotations.with_offense_annotations(offenses)

        assert_equal(source, actual_annotations.to_s)
      end

      def assert_offense(source, file = nil)
        setup_assertion

        @cop.instance_variable_get(:@options)[:autocorrect] = true

        expected_annotations = RuboCop::RSpec::ExpectOffense::AnnotatedSource.parse(source)
        if expected_annotations.plain_source == source
          raise 'Use `assert_no_offenses` to assert that no offenses are found'
        end

        @processed_source = parse_source!(expected_annotations.plain_source, file)

        offenses = _investigate(@cop, @processed_source)

        actual_annotations = expected_annotations.with_offense_annotations(offenses)

        assert_equal(expected_annotations.to_s, actual_annotations.to_s)
      end

      def _investigate(cop, processed_source)
        team = RuboCop::Cop::Team.new([cop], nil, raise_error: true)
        report = team.investigate(processed_source)
        @last_corrector = report.correctors.first || RuboCop::Cop::Corrector.new(processed_source)
        report.offenses
      end

      def assert_correction(correction, loop: true)
        raise '`assert_correction` must follow `assert_offense`' unless @processed_source

        iteration = 0
        new_source = loop do
          iteration += 1

          corrected_source = @last_corrector.rewrite

          break corrected_source unless loop
          break corrected_source if @last_corrector.empty? || corrected_source == @processed_source.buffer.source

          if iteration > RuboCop::Runner::MAX_ITERATIONS
            raise RuboCop::Runner::InfiniteCorrectionLoop.new(@processed_source.path, [])
          end

          # Prepare for next loop
          @processed_source = parse_source!(corrected_source, @processed_source.path)

          _investigate(@cop, @processed_source)
        end

        assert_equal(correction, new_source)
      end

      def setup_assertion
        RuboCop::Formatter::DisabledConfigFormatter.config_to_allow_offenses = {}
        RuboCop::Formatter::DisabledConfigFormatter.detected_styles = {}
      end

      def inspect_source(source, cop, file = nil)
        processed_source = parse_source!(source, file)
        raise 'Error parsing example code' unless processed_source.valid_syntax?

        _investigate(cop, processed_source)
      end

      def investigate(cop, processed_source)
        needed = Hash.new { |h, k| h[k] = [] }
        Array(cop.class.joining_forces).each { |force| needed[force] << cop }
        forces = needed.map do |force_class, joining_cops|
          force_class.new(joining_cops)
        end

        commissioner = RuboCop::Cop::Commissioner.new([cop], forces, raise_error: true)
        commissioner.investigate(processed_source)
        commissioner
      end

      def parse_source!(source, file = nil)
        if file.respond_to?(:write)
          file.write(source)
          file.rewind
          file = file.path
        end

        RuboCop::ProcessedSource.new(source, ruby_version, file)
      end

      def ruby_version
        2.6
      end
    end
  end
end
